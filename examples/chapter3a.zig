const std = @import("std");
const glfw = @import("glfw");
const Engine = @import("vengine").EngineChap3a;

// https://vkguide.dev/docs/chapter-2/triangle_walkthrough/
pub fn main() !void {
    var engine = try Engine.init("chapter 3a");
    defer engine.deinit();
    try engine.run();
}
