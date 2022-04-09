const std = @import("std");
const glfw = @import("glfw");
const vk = @import("vk");

const Engine = @import("vengine").Engine;

// pub const disable_validation = true;

pub fn main() !void {
    var engine = try Engine.init("Here We Go Fool");
    defer engine.deinit();

    try engine.loadContent();
    try engine.run();
}
