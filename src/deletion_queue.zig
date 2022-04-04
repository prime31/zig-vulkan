const std = @import("std");
const vk = @import("vulkan");
const glfw = @import("glfw");
const vma = @import("vma");
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
    allocated_buffer: vma.AllocatedBuffer,
    allocated_image: vma.AllocatedImage,
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
            vk.CommandBuffer => @panic("Cannot use append for CommandBuffers! Use appendCommandBuffer instead."),
            vk.CommandPool => .{ .cmd_pool = obj },
            vk.Framebuffer => .{ .framebuffer = obj },
            vk.Pipeline => .{ .pipeline = obj },
            vk.PipelineLayout => .{ .pipeline_layout = obj },
            vk.RenderPass => .{ .render_pass = obj },
            vma.AllocatedBuffer => .{ .allocated_buffer = obj },
            vma.AllocatedImage => .{ .allocated_image = obj },
            else => @panic("Attempted to delete an object that isnt supported by the DeletionQueue: " ++ @typeName(@TypeOf(obj))),
        };
        self.queue.append(vk_obj) catch unreachable;
    }

    /// special handling for cmd_buffer since it requires
    pub fn appendCommandBuffer(self: *DeletionQueue, cmd_buffer: vk.CommandBuffer, pool: vk.CommandPool) void {
        self.queue.append(.{ .cmd_buffer = .{
            .buffer = cmd_buffer,
            .pool = pool,
        } }) catch unreachable;
    }

    pub fn flush(self: *DeletionQueue) void {
        var iter = ReverseSliceIterator(VkObject).init(self.queue.items);
        while (iter.next()) |obj| {
            switch (obj) {
                .cmd_buffer => |*buf_pool| self.gc.vkd.freeCommandBuffers(self.gc.dev, buf_pool.pool, 1, @ptrCast([*]const vk.CommandBuffer, &buf_pool.buffer)),
                .cmd_pool => |pool| self.gc.destroy(pool),
                .framebuffer => |fb| self.gc.destroy(fb),
                .pipeline => |pip| self.gc.destroy(pip),
                .pipeline_layout => |pip_layout| self.gc.destroy(pip_layout),
                .render_pass => |rp| self.gc.destroy(rp),
                .allocated_buffer => |buf| buf.deinit(self.gc.allocator),
                .allocated_image => |img| img.deinit(self.gc.allocator),
            }
        }

        self.queue.clearRetainingCapacity();
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
    gc.* = try GraphicsContext.init(std.testing.allocator, "test", window);
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

    {
        const buffer_info = std.mem.zeroInit(vk.BufferCreateInfo, .{
            .flags = .{},
            .size = 16,
            .usage = .{ .uniform_buffer_bit = true },
        });

        const malloc_info = std.mem.zeroInit(vma.VmaAllocationCreateInfo, .{
            .flags = .{},
            .usage = .auto,
            .requiredFlags = .{ .host_visible_bit = true, .host_coherent_bit = true },
        });
        const allocated_buffer = try gc.allocator.createBuffer(&buffer_info, &malloc_info, null);
        q.append(allocated_buffer);
    }

    q.flush();
    window.destroy();
    glfw.terminate();
}
