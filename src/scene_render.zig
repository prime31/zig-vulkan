const std = @import("std");

const Engine = @import("engine.zig").Engine;

pub fn sceneRenderAsshole(self: *Engine) void {
    std.debug.print("self: {}\n", .{ self });
}