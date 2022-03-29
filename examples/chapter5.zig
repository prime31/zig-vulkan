const std = @import("std");
const glfw = @import("glfw");
const vk = @import("vk");

const Engine = @import("vengine").EngineChap5;

pub fn main() !void {
    var engine = try Engine.init("chapter 4");
    defer engine.deinit();

    try engine.loadContent();
    try engine.run();
}
