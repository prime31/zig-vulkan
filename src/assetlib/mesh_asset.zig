const std = @import("std");
const assets = @import("assets.zig");

pub const VertexFormat = enum {
    pncv_f32, // everything is 32bit

    pub fn jsonStringify(self: VertexFormat, _: std.json.StringifyOptions, writer: anytype) !void {
        try writer.print("{d}", .{@enumToInt(self)});
    }
};

pub const VertexF32PNCV = extern struct {
    position: [3]f32,
    normal: [3]f32,
    color: [3]f32,
    uv: [2]f32,
};

pub const MeshInfo = struct {
    vert_buffer_size: usize,
    index_buffer_size: usize,
    // bounds: Bounds,
    vert_format: VertexFormat,
    index_size: u8,
    orig_file: []const u8,
};

// TODO: make this generic so it works with more than one vert type
pub const MeshBuffers = struct {
    alloc: std.mem.Allocator,
    vert: []VertexF32PNCV,
    index: []u32,

    pub fn deinit(self: MeshBuffers) void {
        self.alloc.free(self.vert);
        self.alloc.free(self.index);
    }
};

pub fn unpackMesh(allocator: std.mem.Allocator, mesh_asset: assets.Asset(MeshInfo)) !MeshBuffers {
    // TODO: dont ignore mesh_asset.info.vert_format and use it instead
    var verts_bytes = try allocator.alloc(u8, mesh_asset.info.vert_buffer_size);
    var indices_bytes = try allocator.alloc(u8, mesh_asset.info.index_buffer_size);

    std.mem.copy(u8, verts_bytes, mesh_asset.blob[0..verts_bytes.len]);
    std.mem.copy(u8, indices_bytes, mesh_asset.blob[verts_bytes.len..]);

    return MeshBuffers {
        .alloc = allocator,
        .vert = std.mem.bytesAsSlice(VertexF32PNCV, verts_bytes),
        .index = std.mem.bytesAsSlice(u32, indices_bytes),
    };
}