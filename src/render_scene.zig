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

pub const RenderScene = struct {
    const Self = @This();

    gc: *const GraphicsContext,
    renderables: ArrayList(RenderObject),
    meshes: ArrayList(DrawMesh),
    materials: ArrayList(Material),
    dirty_objects: ArrayList(RenderObject),
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
            .dirty_objects = ArrayList(RenderObject).init(gc.gpa),
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
        self.forward_pass.deinit();
        self.transparent_forward_pass.deinit();
        self.shadow_pass.deinit();
        self.material_convert.deinit();
        self.mesh_convert.deinit();

        self.merged_vert_buffer.deinit(self.gc.vma);
        self.merged_index_buffer.deinit(self.gc.vma);
        self.object_data_buffer.deinit(self.gc.vma);
    }

    pub fn registerObject(self: Self, object: MeshObject) !Handle(RenderObject) {
        const new_obj = RenderObject{
            .mesh_id = self.getMeshHandle(object.mesh),
            .material = self.getMaterialHandle(object.material),
            .update_index = std.math.maxInt(u32),
            .custom_sort_key = object.custom_sort_key,
            .pass_indices = .{},
            .transform_matrix = object.transform_matrix,
            .bounds = object.bounds,
        };
        new_obj.pass_indices.clear(-1);

        const handle = Handle(RenderObject){ .handle = self.renderables.items.len };
        try self.renderables.append(handle);

        if (object.draw_forward_pass) {
            if (object.material.original.pass_shaders.getOpt(.transparency) != null)
                try self.transparent_forward_pass.unbatched_objects.append(handle);
            if (object.material.original.pass_shaders.getOpt(.forward) != null)
                try self.forward_pass.unbatched_objects.append(handle);
        }

        if (object.draw_shadow_pass) {
            if (object.material.original.pass_shaders.getOpt(.directional_shadow) != null)
                try self.shadow_pass.unbatched_objects.append(handle);
        }

        return handle;
    }

    pub fn registerObjectBatch(self: Self, objects: []MeshObject) !void {
        try self.renderables.ensureUnusedCapacity(objects.len);
        for (objects) |obj| self.registerObject(obj);
    }

    pub fn updateTransform(self: Self, object_id: Handle(RenderObject), local_to_world: Mat4) void {
        self.getObject(object_id).*.transform_matrix = local_to_world;
        self.updateObject(object_id);
    }

    pub fn updateObject(self: Self, object_id: Handle(RenderObject)) !void {
        var pass_indices = &self.getObject(object_id).pass_indices;
        if (pass_indices.get(.forward) != -1) {
            const obj = Handle(RenderObject).init(pass_indices.get(.forward));
            try self.forward_pass.objects_to_delete.append(obj);
            try self.forward_pass.unbatched_objects.append(object_id);
            pass_indices.set(.forward, -1);
        }

        if (pass_indices.get(.directional_shadow) != -1) {
            const obj = Handle(RenderObject).init(pass_indices.get(.directional_shadow));
            try self.shadow_pass.objects_to_delete.append(obj);
            try self.shadow_pass.unbatched_objects.append(object_id);
            pass_indices.set(.directional_shadow, -1);
        }

        if (pass_indices.get(.transparency) != -1) {
            const obj = Handle(RenderObject).init(pass_indices.get(.transparency));
            try self.transparent_forward_pass.objects_to_delete.append(obj);
            try self.transparent_forward_pass.unbatched_objects.append(object_id);
            pass_indices.set(.transparency, -1);
        }

        if (self.getObject(object_id).update_index == std.math.maxInt(u32)) {
            self.getObject(object_id).update_index = self.dirty_objects.len;
            try self.dirty_objects.append(object_id);
        }
    }

    pub fn fillObjectData(self: Self, data: []GpuObjectData) void {
        for (self.renderables.items) |_, i| {
            const h = Handle(RenderObject).init(i);
            self.writeObject(&data[i], h);
        }
    }

    pub fn fillIndirectArray(self: Self, data: []GpuIndirectObject, pass: *MeshPass) void {
        for (pass.batches.items) |*batch, i| {
            data[i].command.first_instance = batch.first;
            data[i].command.instance_count = 0;
            data[i].command.first_index = self.getMesh(batch.mesh_id).first_index;
            data[i].command.vertex_offset = self.getMesh(batch.mesh_id).first_vert;
            data[i].command.index_count = self.getMesh(batch.mesh_id).index_count;
            data[i].object_id = 0;
            data[i].batch_id = i;
        }
    }

    pub fn fillInstancesArray(data: []GpuInstance, pass: *MeshPass) void {
        var data_index: usize = 0;
        for (pass.batches.items) |*batch, i| {
            var b: usize = 0;
            while (b < batch.count) : (b += 1) {
                data[data_index].object_id = pass.get(pass.flat_batches[b + batch.first].obj).original.handle;
                data[data_index].batch_id = i;
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

    pub fn clearDirtyObjects(self: Self) void {
        for (self.dirty_objects.items) |obj| {
            self.getObject(obj).update_index = std.math.maxInt(u32);
        }
        self.dirty_objects.clearRetainingCapacity();
    }

    pub fn buildBatches(self: Self) void {
        // TODO: thread this
        self.refreshPass(&self.forward_pass);
        self.refreshPass(&self.transparent_forward_pass);
        self.refreshPass(&self.shadow_pass);
    }

    pub fn mergeMeshes(self: Self) !void {
        var total_verts: usize = 0;
        var total_indices: usize = 0;

        for (self.meshes.items) |*m| {
            m.first_index = @intCast(u32, total_indices);
            m.first_vert = @intCast(u32, total_verts);
        }

        self.merged_vert_buffer = try self.gc.vma.createBuffer(Vertex, total_verts * @sizeOf(Vertex), .{ .transfer_dst_bit = true, .vertex_buffer_bit = true }, .gpu_only, .{});
        self.merged_index_buffer = try self.gc.vma.createBuffer(u32, total_indices * @sizeOf(u32), .{ .transfer_dst_bit = true, .index_buffer_bit = true }, .gpu_only, .{});

        const cmd_buf = try self.gc.beginOneTimeCommandBuffer();
        for (self.meshes.items) |m| {
            const vertex_copy = vk.BufferCopy{
                .dst_offset = m.first_vert * @sizeOf(Vertex),
                .size = m.vert_count * @sizeOf(Vertex),
                .src_offset = 0,
            };
            self.gc.vkd.cmdCopyBuffer(cmd_buf, m.original.vert_buffer.buffer, self.merged_vert_buffer, 1, @ptrCast([*]const vk.BufferCopy, &vertex_copy));

            const index_copy = vk.BufferCopy{
                .dst_offset = m.first_index * @sizeOf(u32),
                .size = m.total_indices * @sizeOf(u32),
                .src_offset = 0,
            };
            self.gc.vkd.cmdCopyBuffer(cmd_buf, m.original.index_buffer.buffer, self.merged_index_buffer, 1, @ptrCast([*]const vk.BufferCopy, &index_copy));
        }
        try self.gc.endOneTimeCommandBuffer();
    }

    pub fn refreshPass(self: Self, pass: *MeshPass) void {
        pass.needs_indirect_flush = true;
        pass.needs_instance_flush = true;

        var new_objects = std.ArrayList(u32).init(self.gc.gpa);
        if (pass.objects_to_delete.items.len > 0) {
            // create the render batches so that then we can do the deletion on the flat-array directly
            var deletion_batches = std.ArrayList(RenderBatch).init(self.gc.gpa);

            for (pass.objects_to_delete) |pass_obj, i| {
                try pass.reusable_objects.append(pass_obj);

                var obj = pass.objects.items[pass_obj.handle];
                var new_command = RenderBatch{
                    .object = obj,
                    .sort_key = 0,
                };

                const pip_hash = std.hash.Wyhash.hash(0, std.mem.asBytes(&obj.material.shader_pass.pipeline));
                const set_hash = std.hash.Wyhash.hash(0, std.mem.asBytes(&obj.material.material_set));
                const mathash = pip_hash ^ set_hash;
                const meshmat = @intCast(u64, mathash) ^ @intCast(u64, obj.mesh_id.handle);

                // pack mesh id and material into 64 bits
                new_command.sort_key = @intCast(u64, meshmat) | (@intCast(u64, obj.custom_key) << 32);

                pass.objects.items[i.handle].custom_key = 0;
                pass.objects.items[i.handle].material.shader_pass = null;
                pass.objects.items[i.handle].mesh_id.handle = -1;
                pass.objects.items[i.handle].original.handle = -1;

                try deletion_batches.append(new_command);
            }

            pass.objects_to_delete.clearRetainingCapacity();
            std.sort.sort(RenderBatch, deletion_batches.items, {}, sortRenderBatches);

            {
                // removal. get all the elements from flat_batches that are not in deletion_batches
                var new_batches = ArrayList(RenderBatch).initCapacity(self.gc.gpa, pass.flat_batches.items.len);

                for (pass.flat_batches.items) |fb_batch| {
                    if (std.mem.indexOfScalar(RenderBatch, deletion_batches, fb_batch) == null)
                        try new_batches.append(fb_batch);
                }
                pass.flat_batches.deinit();
                pass.flat_batches = new_batches;
            }

            {
                // fill object list
                try new_objects.ensureUnusedCapacity(pass.unbatched_objects.items.len);
                for (pass.unbatched_objects.items) |o| {
                    const mt = self.getMaterial(self.getObject(o).material);
                    var new_obj = PassObject{
                        .material = .{
                            .material_set = mt.pass_sets[pass.pass_type],
                            .shader_pass = mt.original.pass_shaders[pass.pass_type],
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
                        try pass.objects.append(new_obj);
                    }

                    try new_objects.append(handle);
                    self.getObject(o).pass_indices[pass.pass_type] = @intCast(i32, handle);
                }
            }

            var new_batches = std.ArrayList(RenderBatch).init(self.gc.gpa);
            {
                // fill draw list
                for (new_objects) |i| {
                    const obj = pass.objects[i];
                    const pip_hash = std.hash.Wyhash.hash(0, std.mem.asBytes(&obj.material.shader_pass.pipeline));
                    const set_hash = std.hash.Wyhash.hash(0, std.mem.asBytes(&obj.material.material_set));
                    const mathash = @intCast(u32, pip_hash ^ set_hash);
                    const meshmat = @intCast(u64, mathash) ^ @intCast(u64, obj.mesh_id.handle);

                    // pack mesh id and material into 64 bits
                    try new_batches.append(.{
                        .object = pass.objects[i],
                        .sort_key = @intCast(u64, meshmat) | (@intCast(u64, obj.custom_key) << 32),
                    });
                }
            }

            {
                // draw sort
                std.sort.sort(RenderBatch, new_batches.items, {}, sortRenderBatches);
            }

            {
                // draw merged batches. merge the new batches into the main batch array
                if (new_batches.items.len > 0) {
                    try pass.flat_batches.ensureUnusedCapacity(pass.flat_batches.items.len + new_batches.items.len);

                    for (new_batches.items) |b|
                        pass.flat_batches.appendAssumeCapacity(b);

                    std.sort.sort(RenderBatch, pass.flat_batches.items, {}, sortRenderBatches);
                }
            }

            {
                // draw merge
                pass.batches.clearRetainingCapacity();
                try buildIndirectBatches(pass, pass.batches, pass.flat_batches);

                // flatten batches into multibatch
                pass.multibatches.clearRetainingCapacity();
                var new_batch = Multibatch{
                    .first = 0,
                    .count = 1,
                };

                for (pass.batches.items[1..]) |*batch, i| {
                    var join_batch = *pass.batches.items[new_batch.first];

                    const compatible_batch = self.getMesh(join_batch.mesh_id).is_merged;
                    var same_mat = blk: {
                        if (compatible_batch and join_batch.material.material_set == batch.material.material_set and
                            join_batch.material.shader_pass == batch.material.shader_pass) {
                            break :blk true;
                        }
                        break :blk false;
                    };

                    if (!same_mat or !compatible_batch) {
                        try pass.multibatches.append(new_batch);
                        new_batch.count = 1;
                        new_batch.first = i;
                    } else {
                        new_batch.count += 1;
                    }
                }
                try pass.multibatches.append(new_batch);

                // no multi batch
                for (pass.batches.items) |_, i|
                    try pass.multibatches.append(.{ .count = 1, .first = i });
            }
        }
    }

    fn sortRenderBatches(_: void, a: RenderBatch, b: RenderBatch) bool {
        if (a.sort_key < b.sort_key) return true;
        if (a.sort_key == b.sort_key) return a.object.handle < b.object.handle;
        return false;
    }

    pub fn buildIndirectBatches(pass: *MeshPass, out_batches: ArrayList(IndirectBatch), in_objects: ArrayList(RenderBatch)) !void {
        if (in_objects.items.len == 0) return;

        const new_batch = IndirectBatch{
            .mesh_id = pass.get(in_objects[0].object).mesh_id,
            .material = pass.get(in_objects[0].object).material,
            .first = 0,
            .count = 0,
        };
        try out_batches.append(new_batch);

        const back = &pass.batches.items[pass.batches.items - 1];
        const last_mat = new_batch.material;
        for (in_objects.items) |obj, i| {
            const same_mesh = obj.mesh_id.handle == back.mesh_id.handle;
            const same_material = obj.material == last_mat;

            if (!same_mesh or !same_material) {
                new_batch.material = obj.material;
                if (new_batch.material == back.material)
                    same_material = true;
            }

            if (same_mesh and same_material) {
                back.count += 1;
            } else {
                new_batch.first = i;
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

    pub fn getMaterialHandle(self: Self, m: Material) Handle(Material) {
        if (self.material_convert.get(m)) |mat| {
            return mat;
        }

        const index = self.materials.items.len;
        try self.material_convert.append(m);

        const handle = Handle(Material).init(index);
        try self.material_convert.put(m, handle);
        return handle;
    }

    pub fn getMeshHandle(self: Self, m: *Mesh) !Handle(DrawMesh) {
        if (self.mesh_convert.get(m)) |mesh| {
            return mesh;
        }

        const index = self.meshes.items.len;
        try self.meshes.append(.{
            .original = m,
            .first_index = 0,
            .first_vertex = 0,
            .vert_count = @intCast(u32, m.vertices.items.len),
            .index_count = @intCast(u32, m.indices.len),
        });
        
        const handle = Handle(DrawMesh).init(index);
        try self.mesh_convert.put(m, handle);
        return handle;
    }
};

pub fn Handle(comptime T: type) type {
    return struct {
        handle: u32,

        pub fn init(handle: u32) Handle(T) {
            return .{ .handle = handle };
        }
    };
}

pub const MeshObject = struct {
    mesh: *Mesh,
    material: Material,
    custom_sort_key: u32,
    transform_matrix: Mat4,
    bounds: RenderBounds,
    draw_forward_pass: u1,
    draw_shadow_pass: u1,
};

const GpuIndirectObject = struct {
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

const RenderObject = struct {
    mesh_id: Handle(DrawMesh),
    material: Handle(Material),
    update_index: u32,
    custom_sort_key: u32 = 0,
    pass_indices: vkutil.PerPassData(i32),
    transform_matrix: Mat4,
    bounds: RenderBounds,
};

const GpuInstance = struct {
    object_id: u32,
    batch_id: u32,
};

// RenderScene internal types
const PassMaterial = struct {
    material_set: vk.DescriptorSet,
    shader_pass: ShaderPass,

    pub fn eql(self: PassMaterial, other: PassMaterial) bool {
        return self.material_set == other.material_set and self.shader_pass == other.shader_pass;
    }
};

const PassObject = struct {
    material: PassMaterial,
    mesh_id: Handle(DrawMesh),
    original: Handle(RenderObject),
    built_batch: i32,
    custom_key: u32,
};

const RenderBatch = struct {
    object: Handle(PassObject),
    sort_key: u64,
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

const MeshPass = struct {
    multibatches: ArrayList(Multibatch),
    batches: ArrayList(IndirectBatch),
    unbatched_objects: ArrayList(RenderObject),
    flat_batches: ArrayList(RenderBatch),
    objects: ArrayList(PassObject),
    reusable_objects: ArrayList(PassObject),
    objects_to_delete: ArrayList(PassObject),

    compacted_instance_buffer: vma.AllocatedBuffer(u32) = undefined,
    pass_objects_buffer: vma.AllocatedBuffer(GpuInstance) = undefined,

    draw_indirect_buffer: vma.AllocatedBuffer(GpuIndirectObject) = undefined,
    clear_indirect_buffer: vma.AllocatedBuffer(GpuIndirectObject) = undefined,

    pass_type: MeshPassType,
    needs_indirect_flush: bool = true,
    needs_instance_flush: bool = true,

    pub fn init(gpa: std.mem.Allocator, pass_type: MeshPassType) MeshPass {
        return .{
            .multibatches = ArrayList(Multibatch).init(gpa),
            .batches = ArrayList(IndirectBatch).init(gpa),
            .unbatched_objects = ArrayList(RenderObject).init(gpa),
            .flat_batches = ArrayList(RenderBatch).init(gpa),
            .objects = ArrayList(PassObject).init(gpa),
            .reusable_objects = ArrayList(PassObject).init(gpa),
            .objects_to_delete = ArrayList(PassObject).init(gpa),
            .pass_type = pass_type,
        };
    }

    pub fn deinit(self: MeshPass) void {
        self.multibatches.deinit();
        self.batches.deinit();
        self.unbatched_objects.deinit();
        self.flat_batches.deinit();
        self.objects.deinit();
        self.reusable_objects.deinit();
        self.objects_to_delete.deinit();
        // TODO: delete the allocated buffers
    }

    pub fn get(self: MeshPass, handle: Handle(PassObject)) *PassObject {
        return &self.objects[handle.handle];
    }
};
