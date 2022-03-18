const std = @import("std");
const glfw = @import("glfw");
const vk = @import("vk");

const Engine = @import("vengine").EngineChap3s;


pub fn main() !void {
    var engine = try Engine.init("chapter 3");
    defer engine.deinit();
    try engine.run();
}
