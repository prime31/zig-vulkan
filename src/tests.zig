const std = @import("std");

// include all files with tests
comptime {
    _ = @import("utils/scratch_allocator.zig");

    _ = @import("vk_util/deletion_queue.zig");
    _ = @import("vk_util/descriptors.zig");
    _ = @import("vk_util/push_buffer.zig");
    _ = @import("vk_util/shaders.zig");

    _ = @import("assetlib/asset_loader.zig");
    _ = @import("assetlib/texture_asset.zig");
}


const vk = @import("vulkan");
const glfw = @import("glfw");

const GraphicsContext = @import("graphics_context.zig").GraphicsContext;

pub const TestContext = struct {
    window: glfw.Window,
    gc: *GraphicsContext,

    pub fn deinit(self: *TestContext) void {
        self.gc.deinit();
        std.testing.allocator.destroy(self.gc);
        self.window.destroy();
        glfw.terminate();
    }
};

pub fn initTestContext() TestContext {
    glfw.init(.{}) catch unreachable;

    var extent = vk.Extent2D{ .width = 800, .height = 600 };
    const window = glfw.Window.create(extent.width, extent.height, "tests", null, null, .{
        .client_api = .no_api,
    }) catch unreachable;

    var gc = std.testing.allocator.create(GraphicsContext) catch unreachable;
    gc.* = GraphicsContext.init(std.testing.allocator, "test", window) catch unreachable;

    return .{
        .window = window,
        .gc = gc,
    };
}
