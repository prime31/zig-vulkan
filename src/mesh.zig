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

    pub fn initFromObj(allocator: std.mem.Allocator, filename: []const u8) Mesh {
        var attrib: tiny.tinyobj_attrib_t = undefined;
        var shapes: [*c]tiny.tinyobj_shape_t = undefined;
        var num_shapes: usize = 0;
        var materials: [*c]tiny.tinyobj_material_t = undefined;
        var num_materials: usize = 0;

        const ret = tiny.tinyobj_parse_obj(&attrib, &shapes, &num_shapes, &materials, &num_materials, filename.ptr, getFileData, null, tiny.TINYOBJ_FLAG_TRIANGULATE);
        if (ret != tiny.TINYOBJ_SUCCESS) unreachable;

        defer tiny.tinyobj_shapes_free(shapes, num_shapes);
        defer tiny.tinyobj_materials_free(materials, num_materials);
        defer tiny.tinyobj_attrib_free(&attrib);

        var vertices = std.ArrayList(Vertex).init(allocator);
        var tmp_verts: [3]Vertex = undefined;

        var face_offset: usize = 0;
        var i: usize = 0;
        while (i < attrib.num_face_num_verts) : (i += 1) {
            // we only deal with tris, no quads
            std.debug.assert(@mod(attrib.face_num_verts[i], 3) == 0);
            var f: usize = 0;
            while (f < @divExact(attrib.face_num_verts[i], 3)) : (f += 1) {
                var idx0 = attrib.faces[face_offset + 3 * f + 0];
                var idx1 = attrib.faces[face_offset + 3 * f + 1];
                var idx2 = attrib.faces[face_offset + 3 * f + 2];

                var k: usize = 0;
                while (k < 3) : (k += 1) {
                    var f0 = @intCast(usize, idx0.v_idx);
                    var f1 = @intCast(usize, idx1.v_idx);
                    var f2 = @intCast(usize, idx2.v_idx);

                    tmp_verts[0].position[k] = attrib.vertices[3 * f0 + k];
                    tmp_verts[1].position[k] = attrib.vertices[3 * f1 + k];
                    tmp_verts[2].position[k] = attrib.vertices[3 * f2 + k];

                    // normals
                    f0 = @intCast(usize, idx0.vn_idx);
                    f1 = @intCast(usize, idx1.vn_idx);
                    f2 = @intCast(usize, idx2.vn_idx);

                    tmp_verts[0].normal[k] = attrib.normals[3 * f0 + k];
                    tmp_verts[1].normal[k] = attrib.normals[3 * f1 + k];
                    tmp_verts[2].normal[k] = attrib.normals[3 * f2 + k];

                    // color either from material or normal
                    if (attrib.material_ids[i] >= 0) {
                        const mat_id = @intCast(usize, attrib.material_ids[i]);
                        tmp_verts[0].color[k] = materials[mat_id].diffuse[0];
                        tmp_verts[1].color[k] = materials[mat_id].diffuse[1];
                        tmp_verts[2].color[k] = materials[mat_id].diffuse[2];
                    } else {
                        tmp_verts[0].color[k] = tmp_verts[0].normal[k];
                        tmp_verts[1].color[k] = tmp_verts[1].normal[k];
                        tmp_verts[2].color[k] = tmp_verts[2].normal[k];
                    }
                }

                for (tmp_verts) |v| {
                    vertices.append(v) catch unreachable;
                }
            }
            face_offset += @intCast(usize, attrib.face_num_verts[i]);
        }

        return .{
            .vertices = vertices,
            .vert_buffer = undefined,
        };
    }

    pub fn deinit(self: Mesh, vk_allocator: vma.VmaAllocator) void {
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
