const std = @import("std");
const glfw = @import("glfw");
const Engine = @import("vengine").Engine;

pub fn main() !void {
    var engine = try Engine.init("chapter 2");
    defer engine.deinit();

    while (!engine.window.shouldClose()) {
        // _ = try engine.swapchain.present(engine.main_cmd_buffer);
        try glfw.pollEvents();
    }
}
