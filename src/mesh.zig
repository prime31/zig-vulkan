const std = @import("std");
const vk = @import("vulkan");
const vma = @import("vma");
const tiny = @import("tiny");

const GraphicsContext = @import("graphics_context.zig").GraphicsContext;

pub const AllocatedBuffer = struct {
    buffer: vk.Buffer,
    allocation: vma.VmaAllocation,

    pub fn deinit(self: AllocatedBuffer, vk_allocator: vma.VmaAllocator) void {
        if (self.allocation) |alloc| vma.vmaDestroyBuffer(vk_allocator, self.buffer, alloc);
    }
};

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
    vert_buffer: vma.AllocatedBuffer,

    pub fn init(allocator: std.mem.Allocator) Mesh {
        return .{
            .vertices = std.ArrayList(Vertex).init(allocator),
            .vert_buffer = undefined,
        };
    }

    pub fn initFromObj(allocator: std.mem.Allocator, filename: []const u8) !Mesh {
        const ret = tiny.obj_load(filename.ptr);
        defer tiny.obj_free(ret);

        var vertices = std.ArrayList(Vertex).init(allocator);

        var s: usize = 0;
        while (s < ret.num_shapes) : (s += 1) {
            const shape = ret.shapes[s];
            try vertices.ensureTotalCapacity(vertices.items.len + shape.num_vertices);

            var i: usize = 0;
            while (i < shape.num_vertices) : (i += 1) {
                var vert: Vertex = undefined;
                vert.position[0] = shape.vertices[i].x;
                vert.position[1] = shape.vertices[i].y;
                vert.position[2] = shape.vertices[i].z;

                if (shape.num_normals > 0) {
                    vert.normal[0] = shape.normals[i].x;
                    vert.normal[1] = shape.normals[i].y;
                    vert.normal[2] = shape.normals[i].z;
                }

                if (shape.num_uvs > 0) {
                    vert.uv[0] = shape.uvs[i].u;
                    vert.uv[1] = shape.uvs[i].v;
                }

                vert.color[0] = shape.colors[i].x;
                vert.color[1] = shape.colors[i].y;
                vert.color[2] = shape.colors[i].z;

                vertices.appendAssumeCapacity(vert);
            }
        }

        return Mesh{
            .vertices = vertices,
            .vert_buffer = undefined,
        };
    }

    pub fn deinit(self: Mesh, allocator: vma.Allocator) void {
        self.vert_buffer.deinit(allocator);
        self.vertices.deinit();
    }
};

fn getFileData(ctx: ?*anyopaque, filename: [*c]const u8, is_mtl: c_int, obj_filename: [*c]const u8, data: [*c][*c]u8, len: [*c]usize) callconv(.C) void {
    _ = ctx;

    var file: std.fs.File = undefined;

    if (is_mtl == 1) {
        var fname = std.mem.sliceTo(obj_filename, 0);
        var buff = std.heap.c_allocator.alloc(u8, fname.len) catch unreachable;
        _ = std.mem.replace(u8, fname, ".obj", ".mtl", buff);
        file = std.fs.cwd().openFile(std.mem.sliceTo(buff, 0), .{}) catch unreachable;
    } else {
        file = std.fs.cwd().openFile(std.mem.sliceTo(filename, 0), .{}) catch unreachable;
    }

    defer file.close();

    const file_size = file.getEndPos() catch unreachable;
    var buffer = std.heap.c_allocator.alloc(u8, file_size) catch unreachable;
    _ = file.read(buffer) catch unreachable;

    len.* = file_size;
    data.* = buffer.ptr;
}
