const std = @import("std");
const vk = @import("vulkan");
const glfw = @import("glfw");
const vkinit = @import("vkinit.zig");

const GraphicsContext = @import("graphics_context.zig").GraphicsContext;

const VkObject = union(enum) {
    cmd_buffer: struct {
        buffer: vk.CommandBuffer,
        pool: vk.CommandPool,
    },
    cmd_pool: vk.CommandPool,
    framebuffer: vk.Framebuffer,
    pipeline: vk.Pipeline,
    pipeline_layout: vk.PipelineLayout,
    render_pass: vk.RenderPass,
};

pub const DeletionQueue = struct {
    gc: *GraphicsContext,
    queue: std.ArrayList(VkObject),

    pub fn init(allocator: std.mem.Allocator, gc: *GraphicsContext) DeletionQueue {
        return .{
            .gc = gc,
            .queue = std.ArrayList(VkObject).init(allocator),
        };
    }

    pub fn deinit(self: DeletionQueue) void {
        self.queue.deinit();
    }

    pub fn append(self: *DeletionQueue, obj: anytype) void {
        const vk_obj = switch (@TypeOf(obj)) {
            vk.CommandBuffer => @panic("Cannot use app for CommandBuffers!"),
            vk.CommandPool => .{ .cmd_pool = obj },
            vk.Framebuffer => .{ .framebuffer = obj },
            vk.Pipeline => .{ .pipeline = obj },
            vk.PipelineLayout => .{ .pipeline_layout = obj },
            vk.RenderPass => .{ .render_pass = obj },
            else => unreachable,
        };
        self.queue.append(vk_obj) catch unreachable;
    }

    pub fn appendCommandBuffer(self: *DeletionQueue, cmd_buffer: vk.CommandBuffer, pool: vk.CommandPool) void {
        self.queue.append(.{ .cmd_buffer = .{
            .buffer = cmd_buffer,
            .pool = pool,
        } }) catch unreachable;
    }

    pub fn flush(self: *DeletionQueue) void {
        std.debug.print("\n", .{});
        var iter = ReverseSliceIterator(VkObject).init(self.queue.items);
        while (iter.next()) |obj| {
            switch (obj) {
                .cmd_buffer => |*buf_pool| self.gc.vkd.freeCommandBuffers(self.gc.dev, buf_pool.pool, 1, @ptrCast([*]const vk.CommandBuffer, &buf_pool.buffer)),
                .cmd_pool => |pool| self.gc.vkd.destroyCommandPool(self.gc.dev, pool, null),
                .framebuffer => |fb| self.gc.vkd.destroyFramebuffer(self.gc.dev, fb, null),
                .pipeline => |pip| self.gc.vkd.destroyPipeline(self.gc.dev, pip, null),
                .pipeline_layout => |pip_layout| self.gc.vkd.destroyPipelineLayout(self.gc.dev, pip_layout, null),
                .render_pass => |rp| self.gc.vkd.destroyRenderPass(self.gc.dev, rp, null),
            }
        }
    }
};

fn ReverseSliceIterator(comptime T: type) type {
    return struct {
        slice: []T,
        index: usize,

        pub fn init(slice: []T) @This() {
            return .{
                .slice = slice,
                .index = slice.len,
            };
        }

        pub fn next(self: *@This()) ?T {
            if (self.index == 0) return null;
            self.index -= 1;

            return self.slice[self.index];
        }
    };
}

test "deletion queue" {
    try glfw.init(.{});

    var extent = vk.Extent2D{ .width = 800, .height = 600 };
    const window = try glfw.Window.create(extent.width, extent.height, "tests", null, null, .{
        .client_api = .no_api,
    });

    var gc = try std.testing.allocator.create(GraphicsContext);
    gc.* = try GraphicsContext.init(std.testing.allocator, "test", window, true);
    defer std.testing.allocator.destroy(gc);

    var q = DeletionQueue.init(std.testing.allocator, gc);
    defer q.deinit();

    const pool = try gc.vkd.createCommandPool(gc.dev, &.{
        .flags = .{ .reset_command_buffer_bit = true },
        .queue_family_index = gc.graphics_queue.family,
    }, null);
    q.append(pool);

    var cmd_buffer: vk.CommandBuffer = undefined;
    try gc.vkd.allocateCommandBuffers(gc.dev, &.{
        .command_pool = pool,
        .level = .primary,
        .command_buffer_count = 1,
    }, @ptrCast([*]vk.CommandBuffer, &cmd_buffer));
    q.appendCommandBuffer(cmd_buffer, pool);

    try gc.vkd.allocateCommandBuffers(gc.dev, &.{
        .command_pool = pool,
        .level = .primary,
        .command_buffer_count = 1,
    }, @ptrCast([*]vk.CommandBuffer, &cmd_buffer));
    q.appendCommandBuffer(cmd_buffer, pool);

    const pipeline_layout = try gc.vkd.createPipelineLayout(gc.dev, &vkinit.pipelineLayoutCreateInfo(), null);
    q.append(pipeline_layout);

    q.flush();
    window.destroy();
    glfw.terminate();
}
