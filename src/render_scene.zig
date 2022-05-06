const std = @import("std");
const vk = @import("vulkan");
const vma = @import("vma");
const vkinit = @import("vkinit.zig");
const vkutil = @import("vk_util/vk_util.zig");

const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;

const GraphicsContext = @import("graphics_context.zig").GraphicsContext;
const Material = vkutil.Material;
const ShaderPass = vkutil.ShaderPass;
const Mesh = @import("mesh.zig").Mesh;
const MeshPassType = vkutil.MeshPassType;
const RenderBounds = @import("mesh.zig").RenderBounds;

const GpuObjectData = vkutil.GpuObjectData;
const Vertex = @import("mesh.zig").Vertex;
const Mat4 = @import("chapters/mat4.zig").Mat4;
const Vec4 = @import("chapters/vec4.zig").Vec4;
const Vec3 = @import("chapters/vec3.zig").Vec3;

pub const RenderScene = struct {
    const Self = @This();

    gc: *const GraphicsContext,
    renderables: ArrayList(RenderObject),
    meshes: ArrayList(DrawMesh),
    materials: ArrayList(Material),
    dirty_objects: ArrayList(Handle(RenderObject)),
    forward_pass: MeshPass,
    transparent_forward_pass: MeshPass,
    shadow_pass: MeshPass,
    material_convert: AutoHashMap(*Material, Handle(Material)),
    mesh_convert: AutoHashMap(*Mesh, Handle(DrawMesh)),
    merged_vert_buffer: vma.AllocatedBuffer(Vertex) = .{},
    merged_index_buffer: vma.AllocatedBuffer(u32) = .{},
    object_data_buffer: vma.AllocatedBuffer(vkutil.GpuObjectData) = .{},

    pub fn init(gc: *const GraphicsContext) Self {
        return .{
            .gc = gc,
            .renderables = ArrayList(RenderObject).init(gc.gpa),
            .meshes = ArrayList(DrawMesh).init(gc.gpa),
            .materials = ArrayList(Material).init(gc.gpa),
            .dirty_objects = ArrayList(Handle(RenderObject)).init(gc.gpa),
            .forward_pass = MeshPass.init(gc.gpa, .forward),
            .transparent_forward_pass = MeshPass.init(gc.gpa, .transparency),
            .shadow_pass = MeshPass.init(gc.gpa, .directional_shadow),
            .material_convert = AutoHashMap(*Material, Handle(Material)).init(gc.gpa),
            .mesh_convert = AutoHashMap(*Mesh, Handle(DrawMesh)).init(gc.gpa),
        };
    }

    pub fn deinit(self: *Self) void {
        self.renderables.deinit();
        self.meshes.deinit();
        self.materials.deinit();
        self.dirty_objects.deinit();
        self.forward_pass.deinit(self.gc);
        self.transparent_forward_pass.deinit(self.gc);
        self.shadow_pass.deinit(self.gc);
        self.material_convert.deinit();
        self.mesh_convert.deinit();

        self.merged_vert_buffer.deinit(self.gc.vma);
        self.merged_index_buffer.deinit(self.gc.vma);
        self.object_data_buffer.deinit(self.gc.vma);
    }

    pub fn registerObject(self: *Self, object: MeshObject) !Handle(RenderObject) {
        var new_obj = RenderObject{
            .mesh_id = try self.getMeshHandle(object.mesh),
            .material = self.getMaterialHandle(object.material),
            .update_index = std.math.maxInt(u32),
            .custom_sort_key = object.custom_sort_key,
            .pass_indices = .{},
            .transform_matrix = object.transform_matrix,
            .bounds = object.bounds,
        };
        new_obj.pass_indices.clear(-1);

        const handle = Handle(RenderObject){ .handle = @intCast(u32, self.renderables.items.len) };
        try self.renderables.append(new_obj);

        if (object.draw_forward_pass) {
            if (object.material.original.pass_shaders.get(.transparency).pip != .null_handle)
                try self.transparent_forward_pass.unbatched_objects.append(handle);
            if (object.material.original.pass_shaders.get(.forward).pip != .null_handle)
                try self.forward_pass.unbatched_objects.append(handle);
        }

        if (object.draw_shadow_pass) {
            if (object.material.original.pass_shaders.get(.directional_shadow).pip != .null_handle)
                try self.shadow_pass.unbatched_objects.append(handle);
        }

        try self.updateObject(handle);
        return handle;
    }

    pub fn registerObjectBatch(self: *Self, objects: []MeshObject) !void {
        try self.renderables.ensureUnusedCapacity(objects.len);
        for (objects) |obj| self.registerObject(obj);
    }

    pub fn updateTransform(self: *Self, object_id: Handle(RenderObject), local_to_world: Mat4) void {
        self.getObject(object_id).*.transform_matrix = local_to_world;
        self.updateObject(object_id) catch unreachable;
    }

    pub fn updateObject(self: *Self, object_id: Handle(RenderObject)) !void {
        var pass_indices = &self.getObject(object_id).pass_indices;
        if (pass_indices.get(.forward) != -1) {
            const obj = Handle(PassObject).init(@intCast(u32, pass_indices.get(.forward)));
            try self.forward_pass.objects_to_delete.append(obj);
            try self.forward_pass.unbatched_objects.append(object_id);
            pass_indices.set(.forward, -1);
        }

        if (pass_indices.get(.directional_shadow) != -1) {
            const obj = Handle(PassObject).init(@intCast(u32, pass_indices.get(.directional_shadow)));
            try self.shadow_pass.objects_to_delete.append(obj);
            try self.shadow_pass.unbatched_objects.append(object_id);
            pass_indices.set(.directional_shadow, -1);
        }

        if (pass_indices.get(.transparency) != -1) {
            const obj = Handle(PassObject).init(@intCast(u32, pass_indices.get(.transparency)));
            try self.transparent_forward_pass.objects_to_delete.append(obj);
            try self.transparent_forward_pass.unbatched_objects.append(object_id);
            pass_indices.set(.transparency, -1);
        }

        if (self.getObject(object_id).update_index == std.math.maxInt(u32)) {
            self.getObject(object_id).update_index = @intCast(u32, self.dirty_objects.items.len);
            try self.dirty_objects.append(object_id);
        }
    }

    pub fn fillObjectData(self: Self, data: []GpuObjectData) void {
        for (self.renderables.items) |_, i| {
            const h = Handle(RenderObject).init(@intCast(u32, i));
            self.writeObject(&data[i], h);
        }
    }

    pub fn fillIndirectArray(self: Self, data: []GpuIndirectObject, pass: *MeshPass) void {
        for (pass.batches.items) |*batch, i| {
            data[i].command.first_instance = batch.first;
            data[i].command.instance_count = 0;
            data[i].command.first_index = self.getMesh(batch.mesh_id).first_index;
            data[i].command.vertex_offset = @intCast(i32, self.getMesh(batch.mesh_id).first_vert);
            data[i].command.index_count = self.getMesh(batch.mesh_id).index_count;
            data[i].object_id = 0;
            data[i].batch_id = @intCast(u32, i);
        }
    }

    pub fn fillInstancesArray(_: Self, data: []GpuInstance, pass: *MeshPass) void {
        var data_index: usize = 0;
        for (pass.batches.items) |*batch, i| {
            var b: usize = 0;
            while (b < batch.count) : (b += 1) {
                data[data_index].object_id = pass.get(pass.flat_batches.items[b + batch.first].object).original.handle;
                data[data_index].batch_id = @intCast(u32, i);
                data_index += 1;
            }
        }
    }

    pub fn writeObject(self: Self, target: *GpuObjectData, object_id: Handle(RenderObject)) void {
        const renderable = self.getObject(object_id);
        target.* = GpuObjectData{
            .model = renderable.transform_matrix,
            .origin_rad = Vec4.new(renderable.bounds.origin.x, renderable.bounds.origin.y, renderable.bounds.origin.z, renderable.bounds.radius),
            .extents = Vec4.new(renderable.bounds.extents.x, renderable.bounds.extents.y, renderable.bounds.extents.z, if (renderable.bounds.valid) 1 else 0),
        };
    }

    pub fn clearDirtyObjects(self: *Self) void {
        for (self.dirty_objects.items) |obj| {
            self.getObject(obj).update_index = std.math.maxInt(u32);
        }
        self.dirty_objects.clearRetainingCapacity();
    }

    pub fn buildBatches(self: *Self) !void {
        // TODO: rather than create threads and throw them away switch to a proper threadpool/job scheduler
        if (true) {
            var t1 = try std.Thread.spawn(.{}, refreshPass, .{ self, &self.forward_pass });
            var t2 = try std.Thread.spawn(.{}, refreshPass, .{ self, &self.transparent_forward_pass });
            var t3 = try std.Thread.spawn(.{}, refreshPass, .{ self, &self.shadow_pass });

            t1.join();
            t2.join();
            t3.join();
        } else {
            try self.refreshPass(&self.forward_pass);
            try self.refreshPass(&self.transparent_forward_pass);
            try self.refreshPass(&self.shadow_pass);
        }
    }

    pub fn mergeMeshes(self: *Self) !void {
        var total_indices: usize = 0;
        var total_verts: usize = 0;

        for (self.meshes.items) |*m| {
            m.first_index = @intCast(u32, total_indices);
            m.first_vert = @intCast(u32, total_verts);

            total_indices += m.index_count;
            total_verts += m.vert_count;

            m.is_merged = true;
        }

        self.merged_vert_buffer = try self.gc.vma.createBuffer(Vertex, total_verts * @sizeOf(Vertex), .{ .transfer_dst_bit = true, .vertex_buffer_bit = true }, .gpu_only, .{});
        self.merged_index_buffer = try self.gc.vma.createBuffer(u32, total_indices * @sizeOf(u32), .{ .transfer_dst_bit = true, .index_buffer_bit = true }, .gpu_only, .{});

        const cmd_buf = try self.gc.beginOneTimeCommandBuffer();
        for (self.meshes.items) |m| {
            const vertex_copy = vk.BufferCopy{
                .src_offset = 0,
                .dst_offset = m.first_vert * @sizeOf(Vertex),
                .size = m.vert_count * @sizeOf(Vertex),
            };
            cmd_buf.copyBuffer(m.original.vert_buffer.buffer, self.merged_vert_buffer.buffer, 1, @ptrCast([*]const vk.BufferCopy, &vertex_copy));

            const index_copy = vk.BufferCopy{
                .src_offset = 0,
                .dst_offset = m.first_index * @sizeOf(u32),
                .size = m.index_count * @sizeOf(u32),
            };
            cmd_buf.copyBuffer(m.original.index_buffer.buffer, self.merged_index_buffer.buffer, 1, @ptrCast([*]const vk.BufferCopy, &index_copy));
        }
        try self.gc.endOneTimeCommandBuffer();
    }

    pub fn refreshPass(self: *const Self, pass: *MeshPass) !void {
        // early out for no changes
        if (pass.objects_to_delete.items.len == 0 and pass.unbatched_objects.items.len == 0)
            return;

        pass.needs_indirect_refresh = true;
        pass.needs_instance_refresh = true;

        // delete objects
        if (pass.objects_to_delete.items.len > 0) {
            // create the render batches so that then we can do the deletion on the flat-array directly
            var deletion_batches = try std.ArrayList(RenderBatch).initCapacity(self.gc.gpa, pass.objects_to_delete.items.len);
            defer deletion_batches.deinit();

            try pass.reusable_objects.ensureUnusedCapacity(pass.objects_to_delete.items.len);
            for (pass.objects_to_delete.items) |pass_obj| {
                pass.reusable_objects.appendAssumeCapacity(pass_obj);

                var new_command = RenderBatch{
                    .object = pass_obj,
                    .sort_key = 0,
                };

                var obj = pass.objects.items[pass_obj.handle];
                // const pip_hash = std.hash.Wyhash.hash(0, std.mem.asBytes(&obj.material.shader_pass.pip));
                // const set_hash = std.hash.Wyhash.hash(0, std.mem.asBytes(&obj.material.material_set));
                const pip_hash = @enumToInt(obj.material.shader_pass.pip);
                const set_hash = @enumToInt(obj.material.material_set);
                const mathash = @truncate(u32, pip_hash ^ set_hash);
                const meshmat = @intCast(u64, mathash) ^ @intCast(u64, obj.mesh_id.handle);

                // pack mesh id and material into 64 bits
                new_command.sort_key = @intCast(u64, meshmat) | (@intCast(u64, obj.custom_key) << 32);

                pass.objects.items[pass_obj.handle].custom_key = 0;
                pass.objects.items[pass_obj.handle].material.shader_pass = .{};
                pass.objects.items[pass_obj.handle].mesh_id.handle = std.math.maxInt(u32);
                pass.objects.items[pass_obj.handle].original.handle = std.math.maxInt(u32);

                deletion_batches.appendAssumeCapacity(new_command);
            }

            pass.objects_to_delete.clearRetainingCapacity();
            std.sort.sort(RenderBatch, deletion_batches.items, {}, sortRenderBatches);

            // removal
            {
                const search_closure = struct {
                    fn contains(_: void, a: RenderBatch, b: RenderBatch) std.math.Order {
                        if (a.sort_key < b.sort_key) return .lt;
                        if (a.sort_key > b.sort_key) return .gt;
                        if (a.sort_key == b.sort_key) return std.math.order(a.object.handle, b.object.handle);
                        unreachable;
                    }
                }.contains;

                // get all the elements from flat_batches that are not in deletion_batches. We can use a binary search here because deletion_batches is sorted
                var new_batches = try ArrayList(RenderBatch).initCapacity(self.gc.gpa, pass.flat_batches.items.len);
                for (pass.flat_batches.items) |fb_batch| {
                    if (std.sort.binarySearch(RenderBatch, fb_batch, deletion_batches.items, {}, search_closure) == null)
                        new_batches.appendAssumeCapacity(fb_batch);
                }

                pass.flat_batches.deinit();
                pass.flat_batches = new_batches;
            }
        }

        var new_objects = std.ArrayList(u32).init(self.gc.scratch);

        // fill object list
        if (pass.unbatched_objects.items.len > 0) {
            const total_new_objects_required = pass.unbatched_objects.items.len - pass.reusable_objects.items.len;
            try pass.objects.ensureUnusedCapacity(total_new_objects_required);
            try new_objects.ensureUnusedCapacity(pass.unbatched_objects.items.len);

            for (pass.unbatched_objects.items) |o| {
                const mt = self.getMaterial(self.getObject(o).material);
                var new_obj = PassObject{
                    .material = .{
                        .material_set = mt.pass_sets.get(pass.pass_type),
                        .shader_pass = mt.original.pass_shaders.get(pass.pass_type),
                    },
                    .mesh_id = self.getObject(o).mesh_id,
                    .original = o,
                    .custom_key = self.getObject(o).custom_sort_key,
                };

                // reuse handle
                var handle: u32 = 0;
                if (pass.reusable_objects.items.len > 0) {
                    handle = pass.reusable_objects.items[pass.reusable_objects.items.len - 1].handle;
                    _ = pass.reusable_objects.pop();
                    pass.objects.items[handle] = new_obj;
                } else {
                    handle = @intCast(u32, pass.objects.items.len);
                    try pass.objects.append(new_obj);
                }

                new_objects.appendAssumeCapacity(handle);
                self.getObject(o).pass_indices.set(pass.pass_type, @intCast(i32, handle));
            }

            pass.unbatched_objects.clearRetainingCapacity();
        }

        var new_batches = try std.ArrayList(RenderBatch).initCapacity(self.gc.gpa, new_objects.items.len);
        defer new_batches.deinit();

        // fill draw list
        if (new_objects.items.len > 0) for (new_objects.items) |obj_id| {
            const obj = pass.objects.items[obj_id];

            // const pip_hash = std.hash.Wyhash.hash(0, std.mem.asBytes(&obj.material.shader_pass.pip));
            // const set_hash = std.hash.Wyhash.hash(0, std.mem.asBytes(&obj.material.material_set));
            const pip_hash = @enumToInt(obj.material.shader_pass.pip);
            const set_hash = @enumToInt(obj.material.material_set);
            const mathash = @truncate(u32, pip_hash ^ set_hash);
            const meshmat = @intCast(u64, mathash) ^ @intCast(u64, obj.mesh_id.handle);

            // pack mesh id and material into 64 bits
            new_batches.appendAssumeCapacity(.{
                .object = Handle(PassObject).init(obj_id),
                .sort_key = @intCast(u64, meshmat) | (@intCast(u64, obj.custom_key) << 32),
            });
        };

        // draw sort
        if (new_batches.items.len > 0) {
            std.sort.sort(RenderBatch, new_batches.items, {}, sortRenderBatches);

            // merge the new batches into the main batch array
            try pass.flat_batches.ensureUnusedCapacity(new_batches.items.len);
            pass.flat_batches.appendSliceAssumeCapacity(new_batches.items);

            std.sort.sort(RenderBatch, pass.flat_batches.items, {}, sortRenderBatches);
        }

        {
            // draw merge
            pass.batches.clearRetainingCapacity();
            try buildIndirectBatches(pass, &pass.batches, pass.flat_batches);

            // flatten batches into multibatch
            pass.multibatches.clearRetainingCapacity();
            var new_batch = Multibatch{
                .first = 0,
                .count = 1,
            };

            if (pass.batches.items.len > 1) for (pass.batches.items[1..]) |*batch, i| {
                var join_batch = &pass.batches.items[new_batch.first];

                const compatible_batch = self.getMesh(join_batch.mesh_id).is_merged;
                var same_mat = blk: {
                    if (compatible_batch and join_batch.material.material_set == batch.material.material_set and
                        join_batch.material.shader_pass.eql(batch.material.shader_pass))
                    {
                        break :blk true;
                    }
                    break :blk false;
                };

                if (!same_mat or !compatible_batch) {
                    try pass.multibatches.append(new_batch);
                    new_batch.count = 1;
                    new_batch.first = @intCast(u32, i + 1);
                } else {
                    new_batch.count += 1;
                }
            };
            try pass.multibatches.append(new_batch);

            // alternative to entire section above skipping multibatch
            // for (pass.batches.items) |_, i|
            //     try pass.multibatches.append(.{ .count = 1, .first = @intCast(u32, i) });
        }
    }

    fn sortRenderBatches(_: void, a: RenderBatch, b: RenderBatch) bool {
        if (a.sort_key < b.sort_key) return true;
        if (a.sort_key == b.sort_key) return a.object.handle < b.object.handle;
        return false;
    }

    pub fn buildIndirectBatches(pass: *MeshPass, out_batches: *ArrayList(IndirectBatch), in_objects: ArrayList(RenderBatch)) !void {
        if (in_objects.items.len == 0) return;

        var new_batch = IndirectBatch{
            .mesh_id = pass.get(in_objects.items[0].object).mesh_id,
            .material = pass.get(in_objects.items[0].object).material,
            .first = 0,
            .count = 0,
        };
        try out_batches.append(new_batch);

        var back = &pass.batches.items[pass.batches.items.len - 1];
        const last_mat = new_batch.material;
        for (in_objects.items) |ind_batch, i| {
            const obj = pass.get(ind_batch.object);
            const same_mesh = obj.mesh_id.handle == back.mesh_id.handle;
            var same_material = obj.material.eql(last_mat);

            if (!same_mesh or !same_material) {
                new_batch.material = obj.material;
                if (new_batch.material.eql(back.material))
                    same_material = true;
            }

            if (same_mesh and same_material) {
                back.count += 1;
            } else {
                new_batch.first = @intCast(u32, i);
                new_batch.count = 1;
                new_batch.mesh_id = obj.mesh_id;

                try out_batches.append(new_batch);
                back = &out_batches.items[out_batches.items.len - 1];
            }
        }
    }

    pub fn getObject(self: Self, object_id: Handle(RenderObject)) *RenderObject {
        return &self.renderables.items[object_id.handle];
    }

    pub fn getMesh(self: Self, object_id: Handle(DrawMesh)) *DrawMesh {
        return &self.meshes.items[object_id.handle];
    }

    pub fn getMeshPass(self: Self, pass_type: MeshPassType) *MeshPass {
        return &switch (pass_type) {
            .forward => self.forward_pass,
            .transparency => self.transparent_forward_pass,
            .directional_shadow => self.shadow_pass,
            else => unreachable,
        };
    }

    pub fn getMaterial(self: Self, object_id: Handle(Material)) *Material {
        return &self.materials.items[object_id.handle];
    }

    pub fn getMaterialHandle(self: *Self, m: *Material) Handle(Material) {
        if (self.material_convert.get(m)) |mat| {
            return mat;
        }

        const index = self.materials.items.len;
        self.materials.append(m.*) catch unreachable;

        const handle = Handle(Material).init(@intCast(u32, index));
        self.material_convert.put(m, handle) catch unreachable;
        return handle;
    }

    pub fn getMeshHandle(self: *Self, m: *Mesh) !Handle(DrawMesh) {
        if (self.mesh_convert.get(m)) |mesh| {
            return mesh;
        }

        const index = @intCast(u32, self.meshes.items.len);
        try self.meshes.append(.{
            .first_index = 0,
            .first_vert = 0,
            .vert_count = @intCast(u32, m.vertices.items.len),
            .index_count = @intCast(u32, m.indices.len),
            .is_merged = false,
            .original = m,
        });

        const handle = Handle(DrawMesh).init(index);
        try self.mesh_convert.put(m, handle);
        return handle;
    }
};

pub fn Handle(comptime T: type) type {
    return struct {
        handle: u32 = std.math.maxInt(u32),

        pub fn init(handle: u32) Handle(T) {
            return .{ .handle = handle };
        }
    };
}

pub const MeshObject = struct {
    mesh: *Mesh,
    material: *Material,
    custom_sort_key: u32,
    transform_matrix: Mat4,
    bounds: RenderBounds,
    draw_forward_pass: bool,
    draw_shadow_pass: bool,

    pub fn refreshRenderBounds(self: *MeshObject) void {
        if (!self.mesh.bounds.valid) return;

        const orig_bounds = self.mesh.bounds;

        // convert bounds to 8 vertices, and transform those
        var verts: [8]Vec3 = undefined;
        for (verts) |*v| v.* = self.bounds.origin;

        verts[0] = verts[0].add(orig_bounds.extents.mul(Vec3.new(1, 1, 1)));
        verts[1] = verts[1].add(orig_bounds.extents.mul(Vec3.new(1, 1, -1)));
        verts[2] = verts[2].add(orig_bounds.extents.mul(Vec3.new(1, -1, 1)));
        verts[3] = verts[3].add(orig_bounds.extents.mul(Vec3.new(1, -1, -1)));
        verts[4] = verts[4].add(orig_bounds.extents.mul(Vec3.new(-1, 1, 1)));
        verts[5] = verts[5].add(orig_bounds.extents.mul(Vec3.new(-1, 1, -1)));
        verts[6] = verts[6].add(orig_bounds.extents.mul(Vec3.new(-1, -1, 1)));
        verts[7] = verts[7].add(orig_bounds.extents.mul(Vec3.new(-1, -1, -1)));

        // recalc min/max
        var min = Vec3.new(std.math.f32_max, std.math.f32_max, std.math.f32_max);
        var max = Vec3.new(std.math.f32_min, std.math.f32_min, std.math.f32_min);

        // transform every vertex, accumulating max/min
        for (verts) |*vert| {
            vert.* = vert.transform(self.transform_matrix);

            min = vert.componentMin(min);
            max = vert.componentMax(max);
        }

        const m = self.transform_matrix.fields;
        var max_scale: f32 = 0;
        max_scale = std.math.max(Vec3.new(m[0][0], m[0][1], m[0][2]).length(), max_scale);
        max_scale = std.math.max(Vec3.new(m[1][0], m[1][1], m[1][2]).length(), max_scale);
        max_scale = std.math.max(Vec3.new(m[2][0], m[2][1], m[2][2]).length(), max_scale);

        const extents = max.sub(min).scale(0.5);

        self.bounds.extents = extents;
        self.bounds.origin = min.add(extents);
        self.bounds.radius = max_scale * orig_bounds.radius;
        self.bounds.valid = true;
    }
};

pub const GpuIndirectObject = extern struct {
    command: vk.DrawIndexedIndirectCommand,
    object_id: u32,
    batch_id: u32,
};

const DrawMesh = struct {
    first_vert: u32,
    first_index: u32,
    index_count: u32,
    vert_count: u32,
    is_merged: bool,
    original: *Mesh,
};

pub const RenderObject = struct {
    mesh_id: Handle(DrawMesh),
    material: Handle(Material),
    update_index: u32,
    custom_sort_key: u32 = 0,
    pass_indices: vkutil.PerPassData(i32),
    transform_matrix: Mat4,
    bounds: RenderBounds,
};

pub const GpuInstance = extern struct {
    object_id: u32,
    batch_id: u32,
};

// RenderScene internal types
const PassMaterial = struct {
    material_set: vk.DescriptorSet,
    shader_pass: ShaderPass,

    pub fn eql(self: PassMaterial, other: PassMaterial) bool {
        return self.material_set == other.material_set and self.shader_pass.eql(other.shader_pass);
    }
};

const PassObject = struct {
    material: PassMaterial,
    mesh_id: Handle(DrawMesh),
    original: Handle(RenderObject),
    built_batch: i32 = -1, // TODO: unused?
    custom_key: u32,
};

const RenderBatch = struct {
    object: Handle(PassObject),
    sort_key: u64,

    pub fn eql(self: RenderBatch, other: RenderBatch) bool {
        return self.object.handle == other.object.handle and self.sort_key == other.sort_key;
    }
};

const IndirectBatch = struct {
    mesh_id: Handle(DrawMesh),
    material: PassMaterial,
    first: u32,
    count: u32,
};

const Multibatch = struct {
    first: u32,
    count: u32,
};

pub const MeshPass = struct {
    multibatches: ArrayList(Multibatch), // final draw-indirect segments
    batches: ArrayList(IndirectBatch), // draw indirect batches
    flat_batches: ArrayList(RenderBatch), // sorted list of objects in the pass
    objects: ArrayList(PassObject), // unsorted object data
    unbatched_objects: ArrayList(Handle(RenderObject)), // objects pending addition
    reusable_objects: ArrayList(Handle(PassObject)), // indicides for the objects array that can be reused
    objects_to_delete: ArrayList(Handle(PassObject)),

    compacted_instance_buffer: vma.AllocatedBuffer(u32) = .{},
    pass_objects_buffer: vma.AllocatedBuffer(GpuInstance) = .{},
    draw_indirect_buffer: vma.AllocatedBuffer(GpuIndirectObject) = .{},
    clear_indirect_buffer: vma.AllocatedBuffer(GpuIndirectObject) = .{},

    pass_type: MeshPassType,
    needs_indirect_refresh: bool = true,
    needs_instance_refresh: bool = true,

    pub fn init(gpa: std.mem.Allocator, pass_type: MeshPassType) MeshPass {
        return .{
            .multibatches = ArrayList(Multibatch).init(gpa),
            .batches = ArrayList(IndirectBatch).init(gpa),
            .flat_batches = ArrayList(RenderBatch).init(gpa),
            .objects = ArrayList(PassObject).init(gpa),
            .unbatched_objects = ArrayList(Handle(RenderObject)).init(gpa),
            .reusable_objects = ArrayList(Handle(PassObject)).init(gpa),
            .objects_to_delete = ArrayList(Handle(PassObject)).init(gpa),
            .pass_type = pass_type,
        };
    }

    pub fn deinit(self: MeshPass, gc: *const GraphicsContext) void {
        self.multibatches.deinit();
        self.batches.deinit();
        self.flat_batches.deinit();
        self.objects.deinit();
        self.unbatched_objects.deinit();
        self.reusable_objects.deinit();
        self.objects_to_delete.deinit();

        self.compacted_instance_buffer.deinit(gc.vma);
        self.pass_objects_buffer.deinit(gc.vma);
        self.draw_indirect_buffer.deinit(gc.vma);
        self.clear_indirect_buffer.deinit(gc.vma);
    }

    pub fn get(self: MeshPass, handle: Handle(PassObject)) *PassObject {
        return &self.objects.items[handle.handle];
    }
};
