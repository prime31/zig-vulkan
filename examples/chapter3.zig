const std = @import("std");
const glfw = @import("glfw");
const vk = @import("vk");
const vkmem = @import("vkmem");

const Engine = @import("vengine").EngineChap3;

const c = @cImport({
    // these need to match what we have in vk_mem_alloc.cpp
    @cDefine("VMA_DYNAMIC_VULKAN_FUNCTIONS", "1");
    @cDefine("VMA_VULKAN_VERSION", "1002000");
    @cDefine("VMA_EXTERNAL_MEMORY", "0");
    @cInclude("vk_mem_alloc.h");
});

// https://vkguide.dev/docs/chapter-2/triangle_walkthrough/
pub fn main() !void {
    // uncomment to generate cImport.zig
    // std.debug.print("---- alloc: {any}, funcs: {any}\n", .{ @sizeOf(c.VmaAllocatorCreateInfo), @sizeOf(c.VmaVulkanFunctions) });

    var engine = try Engine.init("chapter 3");
    defer engine.deinit();
    try engine.run();
}
