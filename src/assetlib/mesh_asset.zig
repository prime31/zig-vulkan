const std = @import("std");
const assets = @import("assets.zig");

const min = std.math.min;
const max = std.math.max;

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
    bounds: MeshBounds,
    vert_format: VertexFormat,
    index_size: u8,
    orig_file: []const u8,
};

pub const MeshBounds = struct {
    origin: [3]f32,
    radius: f32,
    extents: [3]f32,
};

// TODO: make this generic so it works with more than one vert type
pub fn MeshBuffers(comptime VertexT: type) type {
    return struct {
        alloc: std.mem.Allocator,
        vert: []VertexT,
        index: []u32,

        pub fn deinit(self: MeshBuffers) void {
            self.alloc.free(self.vert);
            self.alloc.free(self.index);
        }
    };
}

pub fn unpackMesh(comptime VertexT: type, allocator: std.mem.Allocator, mesh_asset: assets.Asset(MeshInfo)) !MeshBuffers(VertexT) {
    // TODO: dont ignore mesh_asset.info.vert_format and use it instead
    var verts_bytes = try allocator.alloc(u8, mesh_asset.info.vert_buffer_size);
    var indices_bytes = try allocator.alloc(u8, mesh_asset.info.index_buffer_size);

    std.mem.copy(u8, verts_bytes, mesh_asset.blob[0..verts_bytes.len]);
    std.mem.copy(u8, indices_bytes, mesh_asset.blob[verts_bytes.len..]);

    return MeshBuffers(VertexT){
        .alloc = allocator,
        .vert = @alignCast(@alignOf(VertexT), std.mem.bytesAsSlice(VertexT, verts_bytes)),
        .index = @alignCast(@alignOf(u32), std.mem.bytesAsSlice(u32, indices_bytes)),
    };
}

pub fn calculateBounds(comptime VertexT: type, verts: []VertexT) MeshBounds {
    var bounds: MeshBounds = undefined;
    var mins: [3]f32 = [_]f32{std.math.f32_max} ** 3;
    var maxes: [3]f32 = [_]f32{std.math.f32_min} ** 3;

    for (verts) |v| {
        mins[0] = min(mins[0], v.position[0]);
        mins[1] = min(mins[1], v.position[1]);
        mins[2] = min(mins[2], v.position[2]);

        maxes[0] = max(maxes[0], v.position[0]);
        maxes[1] = max(maxes[1], v.position[1]);
        maxes[2] = max(maxes[2], v.position[2]);
    }

    bounds.extents[0] = (maxes[0] - mins[0]) / 2;
    bounds.extents[1] = (maxes[1] - mins[1]) / 2;
    bounds.extents[2] = (maxes[2] - mins[2]) / 2;

    bounds.origin[0] = bounds.extents[0] + mins[0];
    bounds.origin[1] = bounds.extents[1] + mins[1];
    bounds.origin[2] = bounds.extents[2] + mins[2];

    // go through the vertices again to calculate the exact bounding sphere radius
    var r2: f32 = 0;
    for (verts) |v| {
        const offsets: [3]f32 = [_]f32{ v.position[0] - bounds.origin[0], v.position[1] - bounds.origin[1], v.position[2] - bounds.origin[2] };

        // pythagorus
        const distance = offsets[0] * offsets[0] + offsets[1] * offsets[1] + offsets[2] * offsets[2];
        r2 = max(r2, distance);
    }

    bounds.radius = std.math.sqrt(r2);
    return bounds;
}
