const std = @import("std");
const glfw = @import("glfw");
const vk = @import("vk");

const Engine = @import("vengine").EngineChap3;

const c = @cImport({
    // these need to match what we have in vk_mem_alloc.cpp
    @cDefine("VMA_DYNAMIC_VULKAN_FUNCTIONS", "1");
    @cDefine("VMA_STATIC_VULKAN_FUNCTIONS", "0");
    @cDefine("VMA_VULKAN_VERSION", "1002000");
    @cDefine("VMA_EXTERNAL_MEMORY", "0");
    @cInclude("vk_mem_alloc.h");
});

const t = @cImport({
    @cInclude("tinyobj_loader_c.h");
});

const tiny = @import("../src/tinyobjectloader.zig");

const structs = [_][]const u8{
    "struct_VmaDeviceMemoryCallbacks",
    "struct_VmaVulkanFunctions",
    "struct_VmaAllocatorCreateInfo",
    "struct_VmaAllocatorInfo",
    "struct_VmaStatistics",
    "struct_VmaDetailedStatistics",
    "struct_VmaTotalStatistics",
    "struct_VmaBudget",
    "struct_VmaAllocationCreateInfo",
    "struct_VmaPoolCreateInfo",
    "struct_VmaAllocationInfo",
    "struct_VmaDefragmentationInfo",
    "struct_VmaDefragmentationMove",
    "struct_VmaDefragmentationPassMoveInfo",
    "struct_VmaDefragmentationStats",
    "struct_VmaVirtualBlockCreateInfo",
    "struct_VmaVirtualAllocationCreateInfo",
    "struct_VmaVirtualAllocationInfo",
};

// https://vkguide.dev/docs/chapter-2/triangle_walkthrough/
pub fn main() !void {
    // uncomment to generate cImport.zig
    // std.debug.print("---- tiny: {any}\n", .{ t });
    // std.debug.print("---- alloc: {any}, funcs: {any}\n", .{ @sizeOf(c.VmaAllocatorCreateInfo), @sizeOf(c.VmaVulkanFunctions) });

    // print struct sizes
    // inline for (structs) |s| {
    //     std.debug.print("{s}: {d}\n", .{ s, @sizeOf(@field(vkmem, s)) });
    // }
    // std.debug.print("---- alloc: {any}, funcs: {any}\n", .{ @sizeOf(vma.VmaAllocatorCreateInfo), @sizeOf(vma.VmaVulkanFunctions) });

    var engine = try Engine.init("chapter 3");
    defer engine.deinit();
    try engine.run();
}
