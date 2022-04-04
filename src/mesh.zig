const std = @import("std");
const vk = @import("vulkan");
const vma = @import("vma");
const tiny = @import("tiny");

const GraphicsContext = @import("graphics_context.zig").GraphicsContext;

pub const Vertex = extern struct {
    pub const binding_description = vk.VertexInputBindingDescription{
        .binding = 0,
        .stride = @sizeOf(Vertex),
        .input_rate = .vertex,
    };

    pub const attribute_description = [_]vk.VertexInputAttributeDescription{
        .{
            .binding = 0,
            .location = 0,
            .format = .r32g32b32_sfloat,
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
        .{
            .binding = 0,
            .location = 3,
            .format = .r32g32_sfloat,
            .offset = @offsetOf(Vertex, "uv"),
        },
    };

    position: [3]f32,
    normal: [3]f32,
    color: [3]f32,
    uv: [2]f32,
};

pub const Mesh = struct {
    vertices: std.ArrayList(Vertex),
    indices: []u32,
    index_count: u32 = 0,
    vert_buffer: vma.AllocatedBuffer = undefined,
    index_buffer: vma.AllocatedBuffer = undefined,

    pub fn init(allocator: std.mem.Allocator) Mesh {
        var indices = allocator.alloc(u32, 3) catch unreachable;
        indices[0] = 0;
        indices[1] = 1;
        indices[2] = 2;
        return .{ .vertices = std.ArrayList(Vertex).init(allocator), .indices = indices, .index_count = 3 };
    }

    pub fn initFromObj(allocator: std.mem.Allocator, filename: []const u8) !Mesh {
        const tiny_mesh = tiny.obj_load_indexed(filename.ptr);
        defer tiny.obj_free_indexed(tiny_mesh);

        var vertices = try std.ArrayList(Vertex).initCapacity(allocator, tiny_mesh.num_vertices);

        var i: usize = 0;
        while (i < tiny_mesh.num_vertices) : (i += 1) {
            var vert: Vertex = undefined;
            vert.position[0] = tiny_mesh.vertices[i].x;
            vert.position[1] = tiny_mesh.vertices[i].y;
            vert.position[2] = tiny_mesh.vertices[i].z;

            vert.normal[0] = tiny_mesh.normals[i].x;
            vert.normal[1] = tiny_mesh.normals[i].y;
            vert.normal[2] = tiny_mesh.normals[i].z;

            vert.uv[0] = tiny_mesh.uvs[i].u;
            vert.uv[1] = tiny_mesh.uvs[i].v;

            vert.color[0] = tiny_mesh.colors[i].x;
            vert.color[1] = tiny_mesh.colors[i].y;
            vert.color[2] = tiny_mesh.colors[i].z;

            vertices.appendAssumeCapacity(vert);
        }

        var indices = try allocator.alloc(u32, tiny_mesh.num_indices);
        std.mem.copy(u32, indices, tiny_mesh.indices[0..tiny_mesh.num_indices]);

        return Mesh{
            .vertices = vertices,
            .indices = indices,
            .index_count = @intCast(u32, indices.len),
        };
    }

    pub fn deinit(self: Mesh, allocator: vma.Allocator) void {
        self.vert_buffer.deinit(allocator);
        self.index_buffer.deinit(allocator);
        self.vertices.deinit();
        self.vertices.allocator.free(self.indices);
    }
};
