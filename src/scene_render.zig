const std = @import("std");
const vk = @import("vulkan");
const vma = @import("vma");
const vkutil = @import("vk_util/vk_util.zig");
const vkinit = @import("vkinit.zig");
const config = @import("utils/config.zig");

const Mat4 = @import("chapters/mat4.zig").Mat4;
const Vec3 = @import("chapters/vec3.zig").Vec3;
const Vec4 = @import("chapters/vec4.zig").Vec4;

const Engine = @import("engine.zig").Engine;
const FrameData = @import("engine.zig").FrameData;
const GpuObjectData = vkutil.GpuObjectData;
const Mesh = @import("mesh.zig").Mesh;
const MeshPass = @import("render_scene.zig").MeshPass;
const GpuInstance = @import("render_scene.zig").GpuInstance;
const GpuIndirectObject = @import("render_scene.zig").GpuIndirectObject;

const DrawCullData = extern struct {
    viewmat: Mat4,
    p00: f32, // symmetric projection parameters
    p11: f32,
    znear: f32,
    zfar: f32,
    frustum: [4]f32, // data for left/right/top/bottom frustum planes
    lod_base: f32 = 10, // lod distance i = base * pow(step, i)
    lod_step: f32 = 1.5,
    pyramid_width: f32, // depth pyramid size in texels
    pyramid_height: f32,

    draw_count: u32,

    culling_enabled: i32 = 1,
    frustum_culling_enabled: i32,
    occlusion_enabled: i32,
    aabb_check: i32, // if on, frustum culling is disabled. used for ortho projection
    aabbmin_x: f32,
    aabbmin_y: f32,
    aabbmin_z: f32,
    aabbmax_x: f32,
    aabbmax_y: f32,
    aabbmax_z: f32,

    fn normalizePlane(p: Vec4) Vec4 {
        const p3 = Vec3.new(p.x, p.y, p.z);
        const len = p3.length();
        return Vec4.new(p.x / len, p.y / len, p.z / len, p.w / len);
    }

    pub fn init(params: vkutil.CullParams) DrawCullData {
        const proj_t = params.projmat.transpose();

        const frustum_x = normalizePlane(Vec4.newFromArr(proj_t.fields[3]).add(Vec4.newFromArr(proj_t.fields[0]))); // x + w < 0
        const frustum_y = normalizePlane(Vec4.newFromArr(proj_t.fields[3]).add(Vec4.newFromArr(proj_t.fields[1]))); // y + w < 0

        return .{
            .viewmat = params.viewmat,
            .p00 = params.projmat.fields[0][0],
            .p11 = params.projmat.fields[1][1],
            .znear = 0.1,
            .zfar = config.draw_distance,
            .frustum = [4]f32{ frustum_x.x, frustum_x.z, frustum_y.y, frustum_y.z },
            .pyramid_width = undefined,
            .pyramid_height = undefined,
            .draw_count = undefined,
            .frustum_culling_enabled = if (params.frustum_cull) 1 else 0,
            .occlusion_enabled = if (params.occlusion_cull) 1 else 0,
            .aabb_check = if (params.aabb) 1 else 0,
            .aabbmin_x = params.aabbmin.x,
            .aabbmin_y = params.aabbmin.y,
            .aabbmin_z = params.aabbmin.z,
            .aabbmax_x = params.aabbmax.x,
            .aabbmax_y = params.aabbmax.y,
            .aabbmax_z = params.aabbmax.z,
        };
    }
};

fn toRadians(deg: anytype) @TypeOf(deg) {
    return std.math.pi * deg / 180.0;
}

pub fn readyMeshDraw(self: *Engine, frame: *FrameData) !void {
    // upload object data to gpu
    if (self.render_scene.dirty_objects.items.len > 0) {
        const copy_size = self.render_scene.renderables.items.len * @sizeOf(GpuObjectData);
        if (self.render_scene.object_data_buffer.size < copy_size) {
            frame.deletion_queue.append(self.render_scene.object_data_buffer.asUntypedBuffer());
            self.render_scene.object_data_buffer = try self.gc.vma.createBuffer(GpuObjectData, copy_size, .{ .transfer_dst_bit = true, .storage_buffer_bit = true }, .auto_prefer_host, .{});
        }

        // if 80% of the objects are dirty, then just reupload the whole thing
        if (@intToFloat(f32, self.render_scene.dirty_objects.items.len) >= @intToFloat(f32, self.render_scene.renderables.items.len) * 0.8) {
            const new_buffer = try self.gc.vma.createBuffer(GpuObjectData, copy_size, .{ .transfer_src_bit = true, .storage_buffer_bit = true }, .auto_prefer_host, .{});
            const objectSSBO = try new_buffer.mapMemory(self.gc.vma);
            self.render_scene.fillObjectData(objectSSBO[0..self.render_scene.renderables.items.len]);
            new_buffer.unmapMemory(self.gc.vma);

            frame.deletion_queue.append(new_buffer.asUntypedBuffer());

            // copy from the uploaded cpu side instance buffer to the gpu one
            const indirect_copy = vk.BufferCopy{
                .src_offset = 0,
                .dst_offset = 0,
                .size = copy_size,
            };
            self.gc.vkd.cmdCopyBuffer(frame.cmd_buffer, new_buffer.buffer, self.render_scene.object_data_buffer.buffer, 1, vkutil.ptrToMany(&indirect_copy));
        } else {
            // update only the changed elements
            var copies = std.ArrayList(vk.BufferCopy).init(self.gc.scratch);
            try copies.ensureTotalCapacity(self.render_scene.dirty_objects.items.len);
            // TODO: fill this in
            unreachable;
        }

        var barrier = vkinit.bufferBarrier(self.render_scene.object_data_buffer.buffer, self.gc.graphics_queue.family);
        barrier.src_access_mask = .{ .transfer_write_bit = true };
        barrier.dst_access_mask = .{ .shader_write_bit = true, .shader_read_bit = true };

        try self.upload_barriers.append(barrier);
        self.render_scene.clearDirtyObjects();
    }

    var passes = [_]*MeshPass{ &self.render_scene.forward_pass, &self.render_scene.transparent_forward_pass, &self.render_scene.shadow_pass };
    for (passes) |pass| {
        // reallocate the gpu side buffers if needed
        if (pass.draw_indirect_buffer.size < pass.batches.items.len * @sizeOf(GpuIndirectObject)) {
            frame.deletion_queue.append(pass.draw_indirect_buffer.asUntypedBuffer());
            pass.draw_indirect_buffer = try self.gc.vma.createBuffer(GpuIndirectObject, pass.batches.items.len * @sizeOf(GpuIndirectObject), .{ .transfer_dst_bit = true, .storage_buffer_bit = true, .indirect_buffer_bit = true }, .auto_prefer_device, .{});
        }

        if (pass.compacted_instance_buffer.size < pass.flat_batches.items.len * @sizeOf(u32)) {
            frame.deletion_queue.append(pass.compacted_instance_buffer.asUntypedBuffer());
            pass.compacted_instance_buffer = try self.gc.vma.createBuffer(u32, pass.flat_batches.items.len * @sizeOf(u32), .{ .transfer_dst_bit = true, .storage_buffer_bit = true }, .auto_prefer_device, .{});
        }

        if (pass.pass_objects_buffer.size < pass.flat_batches.items.len * @sizeOf(GpuInstance)) {
            frame.deletion_queue.append(pass.pass_objects_buffer.asUntypedBuffer());
            pass.pass_objects_buffer = try self.gc.vma.createBuffer(GpuInstance, pass.flat_batches.items.len * @sizeOf(GpuInstance), .{ .transfer_dst_bit = true, .storage_buffer_bit = true }, .auto_prefer_device, .{});
        }
    }

    // TODO: multithread this
    for (passes) |pass| {
        // if the pass has changed the batches, need to reupload them
        if (pass.needs_indirect_refresh and pass.batches.items.len > 0) {
            const new_buffer = try self.gc.vma.createBuffer(GpuIndirectObject, pass.batches.items.len * @sizeOf(GpuIndirectObject), .{ .transfer_src_bit = true, .storage_buffer_bit = true, .indirect_buffer_bit = true }, .auto_prefer_host, .{});
            const indirect = try new_buffer.mapMemory(self.gc.vma);
            self.render_scene.fillIndirectArray(indirect[0..pass.batches.items.len], pass);
            new_buffer.unmapMemory(self.gc.vma);

            if (pass.clear_indirect_buffer.buffer != .null_handle) {
                // add buffer to deletion queue of this frame
                frame.deletion_queue.append(pass.clear_indirect_buffer.asUntypedBuffer());
            }

            pass.clear_indirect_buffer = new_buffer;
            pass.needs_indirect_refresh = false;
        }

        if (pass.needs_instance_refresh and pass.flat_batches.items.len > 0) {
            const new_buffer = try self.gc.vma.createBuffer(GpuInstance, pass.flat_batches.items.len * @sizeOf(GpuInstance), .{ .transfer_src_bit = true, .storage_buffer_bit = true }, .auto_prefer_host, .{});
            const instance_data = try new_buffer.mapMemory(self.gc.vma);
            self.render_scene.fillInstancesArray(instance_data[0..pass.flat_batches.items.len], pass);
            new_buffer.unmapMemory(self.gc.vma);

            frame.deletion_queue.append(new_buffer.asUntypedBuffer());

            const instance_copy = vk.BufferCopy{
                .src_offset = 0,
                .dst_offset = 0,
                .size = pass.flat_batches.items.len * @sizeOf(GpuInstance),
            };
            self.gc.vkd.cmdCopyBuffer(frame.cmd_buffer, new_buffer.buffer, pass.pass_objects_buffer.buffer, 1, vkutil.ptrToMany(&instance_copy));

            var barrier = vkinit.bufferBarrier(pass.pass_objects_buffer.buffer, self.gc.graphics_queue.family);
            barrier.src_access_mask = .{ .transfer_write_bit = true };
            barrier.dst_access_mask = .{ .shader_write_bit = true, .shader_read_bit = true };

            try self.upload_barriers.append(barrier);
            pass.needs_instance_refresh = false;
        }
    }

    if (self.upload_barriers.items.len > 0) {
        self.gc.vkd.cmdPipelineBarrier(frame.cmd_buffer, .{ .transfer_bit = true }, .{ .compute_shader_bit = true }, .{}, 0, undefined, @intCast(u32, self.upload_barriers.items.len), self.upload_barriers.items.ptr, 0, undefined);
        self.upload_barriers.clearRetainingCapacity();
    }
}

pub fn drawObjectsForward(self: *Engine, cmd: vk.CommandBuffer, pass: *MeshPass) !void {
    const frame = self.getCurrentFrameData();

    const view = self.camera.getViewMatrix();
    const proj = self.camera.getProjMatrix(self.swapchain.extent);
    const view_proj = Mat4.mul(proj, view);

    // fill a GPU camera data struct
    const cam_data = vkutil.GpuCameraData{
        .view = view,
        .proj = proj,
        .view_proj = view_proj,
    };

    // push data to dynmem
    const framed = self.frame_num / 120;
    self.scene_params.cam_pos = Vec4.fromVec3(self.camera.pos, 1);
    self.scene_params.ambient_color = Vec4.new((std.math.sin(framed) + 1) * 0.5, 1, (std.math.cos(framed) + 1) * 0.5, 1);
    self.scene_params.sun_shadow_mat = self.main_light.getProjMatrix().mul(self.main_light.getViewMatrix());
    self.scene_params.sun_dir = Vec4.fromVec3(self.main_light.light_dir, 1);
    self.scene_params.sun_color = Vec4.new(1, 1, 1, 1);
    self.scene_params.sun_color.w = if (config.shadowcast) 0 else 1;

    const scene_data_offset = frame.dynamic_data.push(@TypeOf(self.scene_params), self.scene_params);
    const camera_data_offset = frame.dynamic_data.push(vkutil.GpuCameraData, cam_data);

    const obj_buffer_data = self.render_scene.object_data_buffer.getInfo(0);
    var scene_info = frame.dynamic_data.source.getInfo(0);
    scene_info.range = @sizeOf(vkutil.GpuSceneData);

    var cam_info = frame.dynamic_data.source.getInfo(0);
    cam_info.range = @sizeOf(vkutil.GpuCameraData);

    const instance_info = pass.compacted_instance_buffer.getInfo(0);

    const shadow_image = std.mem.zeroInit(vk.DescriptorImageInfo, .{
        .sampler = self.shadow_sampler,
        .image_view = self.shadow_image.default_view,
        .image_layout = .shader_read_only_optimal,
    });

    var global_set: vk.DescriptorSet = undefined;
    var builder = vkutil.DescriptorBuilder.init(self.gc.gpa, &frame.dynamic_descriptor_allocator, &self.descriptor_layout_cache);
    builder.bindBuffer(0, &cam_info, .uniform_buffer_dynamic, .{ .vertex_bit = true });
    builder.bindBuffer(1, &scene_info, .uniform_buffer_dynamic, .{ .vertex_bit = true, .fragment_bit = true });
    builder.bindImage(2, &shadow_image, .combined_image_sampler, .{ .fragment_bit = true });
    _ = try builder.build(&global_set);
    builder.deinit();

    var object_data_set: vk.DescriptorSet = undefined;
    builder = vkutil.DescriptorBuilder.init(self.gc.gpa, &frame.dynamic_descriptor_allocator, &self.descriptor_layout_cache);
    builder.bindBuffer(0, &obj_buffer_data, .storage_buffer, .{ .vertex_bit = true });
    builder.bindBuffer(1, &instance_info, .storage_buffer, .{ .vertex_bit = true });
    _ = try builder.build(&object_data_set);
    builder.deinit();

    const dynamic_offsets = [2]u32{ camera_data_offset, scene_data_offset };
    try executeDrawCommands(self, cmd, pass, object_data_set, dynamic_offsets[0..], global_set);
}

pub fn drawObjectsShadow(self: *Engine, cmd: vk.CommandBuffer, pass: *MeshPass) !void {
    if (pass.batches.items.len == 0) return;

    const frame = self.getCurrentFrameData();
    const view = self.main_light.getViewMatrix();
    const proj = self.main_light.getProjMatrix();
    const view_proj = Mat4.mul(proj, view);

    const cam_data = vkutil.GpuCameraData{
        .view = view,
        .proj = proj,
        .view_proj = view_proj,
    };

    // push data to dynmem
    const camera_data_offset = frame.dynamic_data.push(vkutil.GpuCameraData, cam_data);

    var cam_info = frame.dynamic_data.source.getInfo(0);
    cam_info.range = @sizeOf(vkutil.GpuCameraData);

    const obj_buffer_data = self.render_scene.object_data_buffer.getInfo(0);
    const instance_info = pass.compacted_instance_buffer.getInfo(0);

    var global_set: vk.DescriptorSet = undefined;
    var builder = vkutil.DescriptorBuilder.init(self.gc.gpa, &frame.dynamic_descriptor_allocator, &self.descriptor_layout_cache);
    builder.bindBuffer(0, &cam_info, .uniform_buffer_dynamic, .{ .vertex_bit = true });
    _ = try builder.build(&global_set);

    var object_data_set: vk.DescriptorSet = undefined;
    builder.clear();
    builder.bindBuffer(0, &obj_buffer_data, .storage_buffer, .{ .vertex_bit = true });
    builder.bindBuffer(1, &instance_info, .storage_buffer, .{ .vertex_bit = true });
    _ = try builder.build(&object_data_set);
    builder.deinit();

    const dynamic_offsets = [1]u32{camera_data_offset};
    try executeDrawCommands(self, cmd, pass, object_data_set, dynamic_offsets[0..], global_set);
}

fn executeDrawCommands(self: *Engine, cmd: vk.CommandBuffer, pass: *MeshPass, obj_data_set: vk.DescriptorSet, dyn_offsets: []const u32, global_set: vk.DescriptorSet) !void {
    if (pass.batches.items.len == 0) return;

    // HACK: just to get x64 functional for now since it gets confused with indirect drawing.
    if (@import("builtin").os.tag == .macos and @import("builtin").target.cpu.arch == std.Target.Cpu.Arch.x86_64) {
        try executeDrawCommandsIndexedNonIndirect(self, cmd, pass, obj_data_set, dyn_offsets, global_set);
        return;
    }

    var last_mesh: ?*Mesh = null;
    var last_pip: vk.Pipeline = .null_handle;
    var last_material_set: vk.DescriptorSet = .null_handle;

    var offset: vk.DeviceSize = 0;
    self.gc.vkd.cmdBindVertexBuffers(cmd, 0, 1, vkutil.ptrToMany(&self.render_scene.merged_vert_buffer.buffer), vkutil.ptrToMany(&offset));
    self.gc.vkd.cmdBindIndexBuffer(cmd, self.render_scene.merged_index_buffer.buffer, 0, .uint32);

    for (pass.multibatches.items) |*multibatch| {
        const instance_draw = pass.batches.items[multibatch.first];

        const new_pip = instance_draw.material.shader_pass.pip;
        const new_layout = instance_draw.material.shader_pass.pip_layout;
        const new_material_set = instance_draw.material.material_set;

        var draw_mesh = self.render_scene.getMesh(instance_draw.mesh_id).original;

        if (new_pip != last_pip) {
            last_pip = new_pip;
            self.gc.vkd.cmdBindPipeline(cmd, .graphics, last_pip);
            self.gc.vkd.cmdBindDescriptorSets(cmd, .graphics, new_layout, 1, 1, vkutil.ptrToMany(&obj_data_set), 0, undefined);

            // update dynamic binds
            self.gc.vkd.cmdBindDescriptorSets(cmd, .graphics, new_layout, 0, 1, vkutil.ptrToMany(&global_set), @intCast(u32, dyn_offsets.len), dyn_offsets.ptr);
        }

        // set 3 is optional, not defined by the system
        if (new_material_set != last_material_set and new_material_set != .null_handle) {
            last_material_set = new_material_set;
            self.gc.vkd.cmdBindDescriptorSets(cmd, .graphics, new_layout, 2, 1, vkutil.ptrToMany(&new_material_set), 0, undefined);
        }

        if (self.render_scene.getMesh(instance_draw.mesh_id).is_merged) {
            if (last_mesh != null) {
                offset = 0;
                self.gc.vkd.cmdBindVertexBuffers(cmd, 0, 1, vkutil.ptrToMany(&self.render_scene.merged_vert_buffer.buffer), vkutil.ptrToMany(&offset));
                self.gc.vkd.cmdBindIndexBuffer(cmd, self.render_scene.merged_index_buffer.buffer, 0, .uint32);
                last_mesh = null;
            }
        } else if (last_mesh) |lm| if (lm != draw_mesh) {
            // bind the mesh vertex buffer with offset 0
            offset = 0;
            self.gc.vkd.cmdBindVertexBuffers(cmd, 0, 1, vkutil.ptrToMany(&lm.vert_buffer.buffer), vkutil.ptrToMany(&offset));
            if (lm.index_buffer.buffer != .null_handle)
                self.gc.vkd.cmdBindIndexBuffer(cmd, lm.index_buffer.buffer, 0, .uint32);
            last_mesh = draw_mesh;
        };

        // TODO: why would we ever have 0 indices and wouldnt that cause issues with mesh merging method? Also, this draw call isnt right. Probably object data index is off...
        if (draw_mesh.indices.len == 0) {
            self.gc.vkd.cmdDrawIndexed(cmd, @intCast(u32, draw_mesh.indices.len), instance_draw.count, 0, 0, instance_draw.first);
        } else {
            self.gc.vkd.cmdDrawIndexedIndirect(cmd, pass.draw_indirect_buffer.buffer, multibatch.first * @sizeOf(GpuIndirectObject), multibatch.count, @sizeOf(GpuIndirectObject));
        }
    }
}

pub fn executeComputeCull(self: *Engine, cmd: vk.CommandBuffer, pass: *MeshPass, params: vkutil.CullParams) !void {
    if (config.freeze_cull) return;
    if (pass.batches.items.len == 0) return;

    var dynamic_info = self.getCurrentFrameData().dynamic_data.source.getInfo(0);
    dynamic_info.range = @sizeOf(vkutil.GpuCameraData);

    const obj_buffer_info = self.render_scene.object_data_buffer.getInfo(0);
    const indirect_info = pass.draw_indirect_buffer.getInfo(0);
    const instance_info = pass.pass_objects_buffer.getInfo(0);
    const final_info = pass.compacted_instance_buffer.getInfo(0);

    const depth_pyramid = vk.DescriptorImageInfo{
        .sampler = self.depth_sampler,
        .image_view = self.depth_pyramid.image.default_view,
        .image_layout = .general,
    };

    var comp_obj_data_set: vk.DescriptorSet = undefined;
    var builder = vkutil.DescriptorBuilder.init(self.gc.gpa, &self.getCurrentFrameData().dynamic_descriptor_allocator, &self.descriptor_layout_cache);
    builder.bindBuffer(0, &obj_buffer_info, .storage_buffer, .{ .compute_bit = true });
    builder.bindBuffer(1, &indirect_info, .storage_buffer, .{ .compute_bit = true });
    builder.bindBuffer(2, &instance_info, .storage_buffer, .{ .compute_bit = true });
    builder.bindBuffer(3, &final_info, .storage_buffer, .{ .compute_bit = true });
    builder.bindImage(4, &depth_pyramid, .combined_image_sampler, .{ .compute_bit = true });
    builder.bindBuffer(5, &dynamic_info, .uniform_buffer, .{ .compute_bit = true });
    _ = try builder.build(&comp_obj_data_set);
    builder.deinit();

    var cull_data = DrawCullData.init(params);
    cull_data.draw_count = @intCast(u32, pass.flat_batches.items.len);
    if (config.disable_cull) cull_data.culling_enabled = 0;

    cull_data.pyramid_width = @intToFloat(f32, self.depth_pyramid_width);
    cull_data.pyramid_height = @intToFloat(f32, self.depth_pyramid_height);

    self.gc.vkd.cmdBindPipeline(cmd, .compute, self.cull_pip_lay.pipeline);
    self.gc.vkd.cmdPushConstants(cmd, self.cull_pip_lay.layout, .{ .compute_bit = true }, 0, @sizeOf(DrawCullData), &cull_data);
    self.gc.vkd.cmdBindDescriptorSets(cmd, .compute, self.cull_pip_lay.layout, 0, 1, vkutil.ptrToMany(&comp_obj_data_set), 0, undefined);
    self.gc.vkd.cmdDispatch(cmd, @intCast(u32, pass.flat_batches.items.len / 256) + 1, 1, 1);

    // barrier the 2 buffers we just wrote for culling, the indirect draw one, and the instances one, so that they can be read well when rendering the pass
    var barrier = vkinit.bufferBarrier(pass.compacted_instance_buffer.buffer, self.gc.graphics_queue.family);
    barrier.src_access_mask = .{ .shader_write_bit = true };
    barrier.dst_access_mask = .{ .indirect_command_read_bit = true };

    var barrier2 = vkinit.bufferBarrier(pass.draw_indirect_buffer.buffer, self.gc.graphics_queue.family);
    barrier.src_access_mask = .{ .shader_write_bit = true };
    barrier.dst_access_mask = .{ .indirect_command_read_bit = true };

    try self.post_cull_barriers.append(barrier);
    try self.post_cull_barriers.append(barrier2);
}

pub fn reduceDepth(self: *Engine, cmd: vk.CommandBuffer) !void {
    const depth_read_barrier = vkinit.imageBarrier(self.depth_image.image.image, .{ .depth_stencil_attachment_write_bit = true }, .{ .shader_read_bit = true }, .depth_stencil_attachment_optimal, .shader_read_only_optimal, .{ .depth_bit = true });

    self.gc.vkd.cmdPipelineBarrier(cmd, .{ .late_fragment_tests_bit = true }, .{ .compute_shader_bit = true }, .{ .by_region_bit = true }, 0, undefined, 0, undefined, 1, vkutil.ptrToMany(&depth_read_barrier));
    self.gc.vkd.cmdBindPipeline(cmd, .compute, self.depth_reduce_pip_lay.pipeline);

    const DepthReduceData = struct {
        image_size: [2]f32 align(16),
    };

    var i: usize = 0;
    while (i < self.depth_pyramid_levels) : (i += 1) {
        const dst_target = vk.DescriptorImageInfo{
            .sampler = self.depth_sampler,
            .image_view = self.depth_pyramid_mips[i],
            .image_layout = .general,
        };

        const src_target = vk.DescriptorImageInfo{
            .sampler = self.depth_sampler,
            .image_view = if (i == 0) self.depth_image.view else self.depth_pyramid_mips[i - 1],
            .image_layout = if (i == 0) .shader_read_only_optimal else .general,
        };

        var depth_set: vk.DescriptorSet = undefined;
        var builder = vkutil.DescriptorBuilder.init(self.gc.gpa, &self.getCurrentFrameData().dynamic_descriptor_allocator, &self.descriptor_layout_cache);
        builder.bindImage(0, &dst_target, .storage_image, .{ .compute_bit = true });
        builder.bindImage(1, &src_target, .combined_image_sampler, .{ .compute_bit = true });
        _ = try builder.build(&depth_set);
        builder.deinit();

        self.gc.vkd.cmdBindDescriptorSets(cmd, .compute, self.depth_reduce_pip_lay.layout, 0, 1, vkutil.ptrToMany(&depth_set), 0, undefined);

        var level_width = self.depth_pyramid_width >> @intCast(u5, i);
        var level_height = self.depth_pyramid_height >> @intCast(u5, i);
        if (level_width < 1) level_width = 1;
        if (level_height < 1) level_height = 1;

        const reduce_data = DepthReduceData{
            .image_size = [2]f32{ @intToFloat(f32, level_width), @intToFloat(f32, level_height) },
        };

        self.gc.vkd.cmdPushConstants(cmd, self.depth_reduce_pip_lay.layout, .{ .compute_bit = true }, 0, @sizeOf(DepthReduceData), &reduce_data);
        self.gc.vkd.cmdDispatch(cmd, getGroupCount(level_width, 32), getGroupCount(level_height, 32), 1);

        const reduce_barrier = vkinit.imageBarrier(self.depth_pyramid.image.image, .{ .shader_write_bit = true }, .{ .shader_read_bit = true }, .general, .general, .{ .color_bit = true });
        self.gc.vkd.cmdPipelineBarrier(cmd, .{ .compute_shader_bit = true }, .{ .compute_shader_bit = true }, .{ .by_region_bit = true }, 0, undefined, 0, undefined, 1, vkutil.ptrToMany(&reduce_barrier));
    }

    const depth_write_barrier = vkinit.imageBarrier(self.depth_image.image.image, .{ .shader_read_bit = true }, .{ .depth_stencil_attachment_read_bit = true, .depth_stencil_attachment_write_bit = true }, .shader_read_only_optimal, .depth_stencil_attachment_optimal, .{ .depth_bit = true });
    self.gc.vkd.cmdPipelineBarrier(cmd, .{ .compute_shader_bit = true }, .{ .early_fragment_tests_bit = true }, .{ .by_region_bit = true }, 0, undefined, 0, undefined, 1, vkutil.ptrToMany(&depth_write_barrier));
}

fn getGroupCount(thread_cnt: u32, local_size: u32) u32 {
    return (thread_cnt + local_size - 1) / local_size;
}

// HACK: used only on x64 to work around the draw indirect bug for now...
fn executeDrawCommandsNonIndexed(self: *Engine, cmd: vk.CommandBuffer, pass: *MeshPass, obj_data_set: vk.DescriptorSet, dyn_offsets: []const u32, global_set: vk.DescriptorSet) !void {
    if (pass.batches.items.len == 0) return;

    // HACK: copy the object IDs in sequentially so we can sequentially do our draws
    var instance_buffer = (try pass.compacted_instance_buffer.mapMemory(self.gc.vma))[0..pass.flat_batches.items.len];
    for (pass.flat_batches.items) |rb, i| {
        instance_buffer[i] = pass.get(rb.object).original.handle;
    }
    pass.compacted_instance_buffer.unmapMemory(self.gc.vma);

    var last_mesh: ?*Mesh = null;
    var last_pip: vk.Pipeline = .null_handle;
    var last_material_set: vk.DescriptorSet = .null_handle;
    var offset: vk.DeviceSize = 0;

    for (pass.flat_batches.items) |rb, i| {
        const obj = pass.get(rb.object);

        const new_pip = obj.material.shader_pass.pip;
        const new_layout = obj.material.shader_pass.pip_layout;
        const new_material_set = obj.material.material_set;

        const draw_mesh = self.render_scene.getMesh(obj.mesh_id).original;

        if (new_pip != last_pip) {
            last_pip = new_pip;
            self.gc.vkd.cmdBindPipeline(cmd, .graphics, last_pip);
            self.gc.vkd.cmdBindDescriptorSets(cmd, .graphics, new_layout, 1, 1, vkutil.ptrToMany(&obj_data_set), 0, undefined);

            // update dynamic binds
            self.gc.vkd.cmdBindDescriptorSets(cmd, .graphics, new_layout, 0, 1, vkutil.ptrToMany(&global_set), @intCast(u32, dyn_offsets.len), dyn_offsets.ptr);
        }

        // set 3 is optional, not defined by the system
        if (new_material_set != last_material_set and new_material_set != .null_handle) {
            last_material_set = new_material_set;
            self.gc.vkd.cmdBindDescriptorSets(cmd, .graphics, new_layout, 2, 1, vkutil.ptrToMany(&new_material_set), 0, undefined);
        }

        if (last_mesh == null or last_mesh.? != draw_mesh) {
            // bind the mesh vertex buffer with offset 0
            offset = 0;
            self.gc.vkd.cmdBindVertexBuffers(cmd, 0, 1, vkutil.ptrToMany(&draw_mesh.vert_buffer.buffer), vkutil.ptrToMany(&offset));
            if (draw_mesh.index_buffer.buffer != .null_handle)
                self.gc.vkd.cmdBindIndexBuffer(cmd, draw_mesh.index_buffer.buffer, 0, .uint32);
            last_mesh = draw_mesh;
        }

        self.gc.vkd.cmdDrawIndexed(cmd, @intCast(u32, draw_mesh.indices.len), 1, 0, 0, @intCast(u32, i));
    }
}

fn executeDrawCommandsIndexedNonIndirect(self: *Engine, cmd: vk.CommandBuffer, pass: *MeshPass, obj_data_set: vk.DescriptorSet, dyn_offsets: []const u32, global_set: vk.DescriptorSet) !void {
    if (pass.batches.items.len == 0) return;

    var da_fook = try pass.draw_indirect_buffer.mapMemory(self.gc.vma);
    defer pass.draw_indirect_buffer.unmapMemory(self.gc.vma);

    for (da_fook[0..pass.batches.items.len]) |indirect_obj| {
        _ = indirect_obj;
    }

    var last_mesh: ?*Mesh = null;
    var last_pip: vk.Pipeline = .null_handle;
    var last_material_set: vk.DescriptorSet = .null_handle;

    var offset: vk.DeviceSize = 0;
    self.gc.vkd.cmdBindVertexBuffers(cmd, 0, 1, vkutil.ptrToMany(&self.render_scene.merged_vert_buffer.buffer), vkutil.ptrToMany(&offset));
    self.gc.vkd.cmdBindIndexBuffer(cmd, self.render_scene.merged_index_buffer.buffer, 0, .uint32);

    for (pass.multibatches.items) |*multibatch| {
        const instance_draw = pass.batches.items[multibatch.first];

        const new_pip = instance_draw.material.shader_pass.pip;
        const new_layout = instance_draw.material.shader_pass.pip_layout;
        const new_material_set = instance_draw.material.material_set;

        var draw_mesh = self.render_scene.getMesh(instance_draw.mesh_id).original;

        if (new_pip != last_pip) {
            last_pip = new_pip;
            self.gc.vkd.cmdBindPipeline(cmd, .graphics, last_pip);
            self.gc.vkd.cmdBindDescriptorSets(cmd, .graphics, new_layout, 1, 1, vkutil.ptrToMany(&obj_data_set), 0, undefined);

            // update dynamic binds
            self.gc.vkd.cmdBindDescriptorSets(cmd, .graphics, new_layout, 0, 1, vkutil.ptrToMany(&global_set), @intCast(u32, dyn_offsets.len), dyn_offsets.ptr);
        }

        // set 3 is optional, not defined by the system
        if (new_material_set != last_material_set and new_material_set != .null_handle) {
            last_material_set = new_material_set;
            self.gc.vkd.cmdBindDescriptorSets(cmd, .graphics, new_layout, 2, 1, vkutil.ptrToMany(&new_material_set), 0, undefined);
        }

        if (self.render_scene.getMesh(instance_draw.mesh_id).is_merged) {
            if (last_mesh != null) {
                offset = 0;
                self.gc.vkd.cmdBindVertexBuffers(cmd, 0, 1, vkutil.ptrToMany(&self.render_scene.merged_vert_buffer.buffer), vkutil.ptrToMany(&offset));
                self.gc.vkd.cmdBindIndexBuffer(cmd, self.render_scene.merged_index_buffer.buffer, 0, .uint32);
                last_mesh = null;
            }
        } else if (last_mesh) |lm| if (lm != draw_mesh) {
            // bind the mesh vertex buffer with offset 0
            offset = 0;
            self.gc.vkd.cmdBindVertexBuffers(cmd, 0, 1, vkutil.ptrToMany(&lm.vert_buffer.buffer), vkutil.ptrToMany(&offset));
            if (lm.index_buffer.buffer != .null_handle)
                self.gc.vkd.cmdBindIndexBuffer(cmd, lm.index_buffer.buffer, 0, .uint32);
            last_mesh = draw_mesh;
        };

        // TODO: why would we ever have 0 indices and wouldnt that cause issues with mesh merging method? Also, this draw call isnt right. Probably object data index is off...
        if (draw_mesh.indices.len == 0) {
            self.gc.vkd.cmdDrawIndexed(cmd, @intCast(u32, draw_mesh.indices.len), instance_draw.count, 0, 0, instance_draw.first);
        } else {
            for (da_fook[multibatch.first..multibatch.first + multibatch.count]) |indirect_batch| {
                if (indirect_batch.command.instance_count == 0) continue;
                // std.debug.print("indirect_batch: {}\n", .{ indirect_batch });
                self.gc.vkd.cmdDrawIndexed(cmd, indirect_batch.command.index_count, indirect_batch.command.instance_count, indirect_batch.command.first_index, indirect_batch.command.vertex_offset, indirect_batch.command.first_instance);
            }
        }
    }
}
