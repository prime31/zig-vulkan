const std = @import("std");
const vk = @import("vulkan");
const vma = @import("vma");
const vkutil = @import("vk_util/vk_util.zig");
const vkinit = @import("vkinit.zig");

const Engine = @import("engine.zig").Engine;
const FrameData = @import("engine.zig").FrameData;
const GpuObjectData = vkutil.GpuObjectData;
const MeshPass = @import("render_scene.zig").MeshPass;
const GpuInstance = @import("render_scene.zig").GpuInstance;
const GpuIndirectObject = @import("render_scene.zig").GpuIndirectObject;

pub fn readyMeshDraw(self: *Engine, frame: *FrameData) !void {
    // upload object data to gpu
    if (self.render_scene.dirty_objects.items.len > 0) {
        const copy_size = self.render_scene.renderables.items.len * @sizeOf(GpuObjectData);
        if (self.render_scene.object_data_buffer.size < copy_size) {
            self.render_scene.object_data_buffer.deinit(self.gc.vma);
            self.render_scene.object_data_buffer = try self.gc.vma.createBuffer(GpuObjectData, copy_size, .{ .transfer_dst_bit = true, .storage_buffer_bit = true }, .cpu_to_gpu, .{});
        }

        // if 80% of the objects are dirty, then just reupload the whole thing
        if (@intToFloat(f32, self.render_scene.dirty_objects.items.len) >= @intToFloat(f32, self.render_scene.renderables.items.len) * 0.8) {
            const new_buffer = try self.gc.vma.createBuffer(GpuObjectData, copy_size, .{ .transfer_dst_bit = true, .storage_buffer_bit = true }, .cpu_to_gpu, .{});
            const objectSSBO = try new_buffer.mapMemory(self.gc.vma);
            self.render_scene.fillObjectData(objectSSBO[0..self.render_scene.renderables.items.len]);
            new_buffer.unmapMemory(self.gc.vma);

            frame.deletion_queue.append(new_buffer);

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
        barrier.dst_access_mask = .{ .shader_write_bit = true, .shader_read_bit = true };
        barrier.src_access_mask = .{ .transfer_write_bit = true };

        try self.upload_barriers.append(barrier);
        self.render_scene.clearDirtyObjects();
    }

    var passes = [_]*MeshPass{ &self.render_scene.forward_pass, &self.render_scene.transparent_forward_pass, &self.render_scene.shadow_pass };
    for (passes) |pass| {
        // reallocate the gpu side buffers if needed
        if (pass.draw_indirect_buffer.size < pass.batches.items.len * @sizeOf(GpuIndirectObject)) {
            pass.draw_indirect_buffer.deinit(self.gc.vma);
            pass.draw_indirect_buffer = try self.gc.vma.createBuffer(GpuIndirectObject, pass.batches.items.len * @sizeOf(GpuIndirectObject), .{ .transfer_dst_bit = true, .storage_buffer_bit = true, .indirect_buffer_bit = true }, .gpu_only, .{});
        }

        if (pass.compacted_instance_buffer.size < pass.flat_batches.items.len * @sizeOf(u32)) {
            pass.compacted_instance_buffer.deinit(self.gc.vma);
            pass.compacted_instance_buffer = try self.gc.vma.createBuffer(u32, pass.flat_batches.items.len * @sizeOf(u32), .{ .transfer_dst_bit = true, .storage_buffer_bit = true }, .gpu_only, .{});
        }

        if (pass.pass_objects_buffer.size < pass.flat_batches.items.len * @sizeOf(GpuInstance)) {
            pass.pass_objects_buffer.deinit(self.gc.vma);
            pass.pass_objects_buffer = try self.gc.vma.createBuffer(GpuInstance, pass.flat_batches.items.len * @sizeOf(GpuInstance), .{ .transfer_dst_bit = true, .storage_buffer_bit = true }, .gpu_only, .{});
        }
    }

    // TODO: multithread this
    for (passes) |pass| {
        // if the pass has changed the batches, need to reupload them
        if (pass.needs_indirect_refresh and pass.batches.items.len > 0) {
            const new_buffer = try self.gc.vma.createBuffer(GpuIndirectObject, pass.batches.items.len * @sizeOf(GpuIndirectObject), .{ .transfer_src_bit = true, .storage_buffer_bit = true, .indirect_buffer_bit = true }, .cpu_to_gpu, .{});
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
            const new_buffer = try self.gc.vma.createBuffer(GpuInstance, pass.flat_batches.items.len * @sizeOf(GpuInstance), .{ .transfer_src_bit = true, .storage_buffer_bit = true }, .cpu_to_gpu, .{});
            const instance_data = try new_buffer.mapMemory(self.gc.vma);
            self.render_scene.fillInstancesArray(instance_data[0..pass.flat_batches.items.len], pass);
            new_buffer.unmapMemory(self.gc.vma);

            frame.deletion_queue.append(new_buffer.asUntypedBuffer());

            const indirect_copy = vk.BufferCopy{
                .src_offset = 0,
                .dst_offset = 0,
                .size = pass.flat_batches.items.len * @sizeOf(GpuInstance),
            };
            self.gc.vkd.cmdCopyBuffer(frame.cmd_buffer, new_buffer.buffer, pass.pass_objects_buffer.buffer, 1, vkutil.ptrToMany(&indirect_copy));

            var barrier = vkinit.bufferBarrier(pass.pass_objects_buffer.buffer, self.gc.graphics_queue.family);
            barrier.dst_access_mask = .{ .shader_write_bit = true, .shader_read_bit = true };
            barrier.src_access_mask = .{ .transfer_write_bit = true };
            
            try self.upload_barriers.append(barrier);
            pass.needs_instance_refresh = false;
        }
    }

    if (self.upload_barriers.items.len > 0) {
        self.gc.vkd.cmdPipelineBarrier(frame.cmd_buffer, .{ .transfer_bit = true }, .{ .compute_shader_bit = true }, .{}, 0, undefined, @intCast(u32, self.upload_barriers.items.len), self.upload_barriers.items.ptr, 0, undefined);
        self.upload_barriers.clearRetainingCapacity();
    }
}
