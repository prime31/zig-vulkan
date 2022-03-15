const std = @import("std");
const vk = @import("vulkan");
const vkmem = @import("vk_mem_alloc.zig");

const GraphicsContext = @import("graphics_context.zig").GraphicsContext;

pub const AllocatedBuffer = struct {
    buffer: vk.Buffer,
    allocation: vkmem.VmaAllocation,

    pub fn deinit(self: AllocatedBuffer, vk_allocator: vkmem.VmaAllocator) void {
        vkmem.vmaDestroyBuffer(vk_allocator, self.buffer, self.allocation);
    }
};

pub const Vertex = extern struct {
    const binding_description = vk.VertexInputBindingDescription{
        .binding = 0,
        .stride = @sizeOf(Vertex),
        .input_rate = .vertex,
    };

    const attribute_description = [_]vk.VertexInputAttributeDescription{
        .{
            .binding = 0,
            .location = 0,
            .format = .r32g32_sfloat,
            .offset = @offsetOf(Vertex, "position"),
        },
        .{
            .binding = 0,
            .location = 1,
            .format = .r32g32b32_sfloat,
            .offset = @offsetOf(Vertex, "normal"),
        },
        .{
            .binding = 0,
            .location = 2,
            .format = .r32g32b32_sfloat,
            .offset = @offsetOf(Vertex, "color"),
        },
    };

    position: [3]f32,
    normal: [3]f32,
    color: [3]f32,
};

pub const Mesh = struct {
    vertices: std.ArrayList(Vertex),
    vert_buffer: AllocatedBuffer,

    pub fn init(allocator: std.mem.Allocator) Mesh {
        return .{
            .vertices = std.ArrayList(Vertex).init(allocator),
            .vert_buffer = undefined,
        };
    }

    pub fn deinit(self: Mesh, vk_allocator: vkmem.VmaAllocator) void {
        self.vert_buffer.deinit(vk_allocator);
        self.vertices.deinit();
    }
};
