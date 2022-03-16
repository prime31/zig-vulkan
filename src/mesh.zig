const std = @import("std");
const vk = @import("vulkan");
const vkmem = @import("vk_mem_alloc.zig");
const tiny = @import("tinyobjloader.zig");

const GraphicsContext = @import("graphics_context.zig").GraphicsContext;

pub const AllocatedBuffer = struct {
    buffer: vk.Buffer,
    allocation: vkmem.VmaAllocation,

    pub fn deinit(self: AllocatedBuffer, vk_allocator: vkmem.VmaAllocator) void {
        vkmem.vmaDestroyBuffer(vk_allocator, self.buffer, self.allocation);
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
        // return initFromObj(allocator, "src/chapters/monkey_smooth.obj");

        return .{
            .vertices = std.ArrayList(Vertex).init(allocator),
            .vert_buffer = undefined,
        };
    }

    pub fn initFromObj(allocator: std.mem.Allocator, filename: []const u8) Mesh {
        var attrib: tiny.tinyobj_attrib_t = undefined;
        var shapes: [*c]tiny.tinyobj_shape_t = undefined;
        var num_shapes: usize = 0;
        var materials: [*c]tiny.tinyobj_material_t = undefined;
        var num_materials: usize = 0;

        const ret = tiny.tinyobj_parse_obj(&attrib, &shapes, &num_shapes, &materials,
                          &num_materials, filename.ptr, getFileData, null, tiny.TINYOBJ_FLAG_TRIANGULATE);
        if (ret != tiny.TINYOBJ_SUCCESS) unreachable;

        var vertices = std.ArrayList(Vertex).init(allocator);
        // for (i = 0; i < attrib.num_face_num_verts; i++) {
        var face_offset: usize = 0;
        var i: usize = 0;
        while (i < attrib.num_face_num_verts) : (i += 1) {
            // var v: usize = 0;
            // while (v < 3) : (v += 3) {
            //     const idx = attrib.faces[face_offset + v];

            //     const vx = attrib.vertices[3 * @intCast(usize, idx.v_idx) + 0];
            //     const vy = attrib.vertices[3 * @intCast(usize, idx.v_idx) + 1];
            //     const vz = attrib.vertices[3 * @intCast(usize, idx.v_idx) + 2];

            //     const nx = attrib.normals[3 * @intCast(usize, idx.vn_idx) + 0];
            //     const ny = attrib.normals[3 * @intCast(usize, idx.vn_idx) + 1];
            //     const nz = attrib.normals[3 * @intCast(usize, idx.vn_idx) + 2];

            //     // std.debug.print("{d}, {d}, {d} - {d}, {d}, {d}\n", .{ vx, vy, vz, nx, ny, nz });
            //     vertices.append(.{
            //         .position = [3]f32{vx, vy, vz},
            //         .normal = [3]f32{nx, ny, nz},
            //         .color = [3]f32{nx, ny, nz},
            //     }) catch unreachable;
            // }
            // if (i >= 0) continue;

            std.debug.assert(@mod(attrib.face_num_verts[i], 3) == 0);
            var f: usize = 0;
            while (f < @divExact(attrib.face_num_verts[i], 3)) : (f += 1) {
                var idx0 = attrib.faces[face_offset + 3 * f + 0];
                var idx1 = attrib.faces[face_offset + 3 * f + 1];
                var idx2 = attrib.faces[face_offset + 3 * f + 2];

                var k: usize = 0;
                while (k < 3) : (k += 1) {
                    const f0 = idx0.v_idx;
                    const f1 = idx1.v_idx;
                    const f2 = idx2.v_idx;

                    const vx = attrib.vertices[3 * @intCast(usize, f0) + 0];
                    const vy = attrib.vertices[3 * @intCast(usize, f1) + 1];
                    const vz = attrib.vertices[3 * @intCast(usize, f2) + 2];

                    const nx = attrib.normals[3 * @intCast(usize, f0) + 0];
                    const ny = attrib.normals[3 * @intCast(usize, f1) + 1];
                    const nz = attrib.normals[3 * @intCast(usize, f2) + 2];

                    vertices.append(.{
                        .position = [3]f32{vx, vy, vz},
                        .normal = [3]f32{nx, ny, nz},
                        .color = [3]f32{nx, ny, nz},
                    }) catch unreachable;
                }
            }
            face_offset += @intCast(usize, attrib.face_num_verts[i]);
            // std.debug.print("total verts: {d}\n", .{ face_offset });
        }

        // std.debug.print("total verts: {d}\n", .{ vertices.items });
        return .{
            .vertices = vertices,
            .vert_buffer = undefined,
        };
    }

    pub fn deinit(self: Mesh, vk_allocator: vkmem.VmaAllocator) void {
        self.vert_buffer.deinit(vk_allocator);
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
