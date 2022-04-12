const std = @import("std");
const vk = @import("vulkan");
const vma = @import("vma");

const GraphicsContext = @import("../graphics_context.zig").GraphicsContext;

pub const PushBuffer = struct {
    source: vma.AllocatedBufferUntyped,
    alignment: usize,
    current_offset: u32 = 0,
    mapped: *anyopaque,

    pub fn init(gc: *const GraphicsContext, buffer: vma.AllocatedBufferUntyped) !PushBuffer {
        var pp_data: ?*anyopaque = undefined;
        const res = vma.vmaMapMemory(gc.vma.allocator, buffer.allocation, @ptrCast([*c]?*anyopaque, &pp_data));
        if (res == vk.Result.success) {
            return PushBuffer{
                .source = buffer,
                .alignment = gc.gpu_props.limits.min_uniform_buffer_offset_alignment,
                .mapped = pp_data.?,
            };
        }

        return switch (res) {
            .error_out_of_host_memory => error.out_of_host_memory,
            .error_out_of_device_memory => error.out_of_device_memory,
            .error_memory_map_failed => error.memory_map_failed,
            else => error.undocumented_error,
        };
    }

    pub fn deinit(self: PushBuffer, allocator: vma.Allocator) void {
        allocator.unmapMemory(self.source.allocation);
        self.source.deinit(allocator);
    }

    pub fn push(self: *PushBuffer, comptime T: type, data: T) u32 {
        const offset = self.current_offset;
        const pp_data_at_offset = @ptrCast([*]u8, self.mapped) + offset;
        const aligned_data = @ptrCast([*]T, @alignCast(@alignOf(T), pp_data_at_offset));
        aligned_data.* = data;

        self.current_offset += @sizeOf(T);
        self.current_offset = self.padUniformBufferSize(self.current_offset);

        return offset;
    }

    pub fn reset(self: *PushBuffer) void {
        self.current_offset = 0;
    }

    fn padUniformBufferSize(self: PushBuffer, original_size: usize) u32 {
        const min_ubo_alignment = self.alignment;
        var aligned_size = original_size;
        if (min_ubo_alignment > 0)
            aligned_size = (aligned_size + min_ubo_alignment - 1) & ~(min_ubo_alignment - 1);
        return @intCast(u32, aligned_size);
    }
};

test "PushBuffer" {
    var ctx = @import("../tests.zig").initTestContext();
    const gc = ctx.gc;
    defer ctx.deinit();

    const buffer = try gc.vma.createUntypedBuffer(128, .{ .uniform_buffer_bit = true }, vma.VmaMemoryUsage.cpu_to_gpu, .{});
    var pb = try PushBuffer.init(gc, buffer);
    defer pb.deinit(gc.vma);

    _ = pb.push(u32, 55);
    const data = @ptrCast([*]u32, @alignCast(@alignOf(u32), pb.mapped));
    try std.testing.expectEqual(data[0], 55);
}
