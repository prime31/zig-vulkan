const std = @import("std");
const glfw = @import("glfw");
const vk = @import("vk");
const vkmem = @import("vkmem");

const Engine = @import("vengine").EngineChap3;

// const c = @cImport({
//     @cInclude("vk_mem_alloc.h");
// });

// https://vkguide.dev/docs/chapter-2/triangle_walkthrough/
pub fn main() !void {
    // std.debug.print("----- {any}\n", .{ std.mem.zeroes(c.VmaAllocationCreateInfo) });

    // var buffer_info = std.mem.zeroes(vkmem.VkBufferCreateInfo);
    // buffer_info.size = 65536;
    // buffer_info.sType = vkmem.VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO;

    // var alloc_info = std.mem.zeroes(vkmem.VmaAllocationCreateInfo);
    // alloc_info.usage = vkmem.VMA_MEMORY_USAGE_UNKNOWN;

    // var buffer: vk.Buffer = undefined;
    // var allocation: vkmem.VmaAllocation = undefined;
    // const res = vkmem.vmaCreateBuffer(allocator, &buffer_info, &alloc_info, &buffer, &allocation, undefined);
    // std.debug.print("---- res: {d}\n", .{ res });

    var engine = try Engine.init("chapter 3");
    defer engine.deinit();
    try engine.run();
}
