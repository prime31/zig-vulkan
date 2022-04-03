const std = @import("std");
const stb = @import("stb");
const tiny = @import("tiny");

const fs = std.fs;
const path = std.fs.path;
const assets = @import("assets.zig");

var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{ .thread_safe = false }){};
const gpa = general_purpose_allocator.allocator();

// all the extensions supported. each one must be handled in bakeFnForFileExtension
const asset_extensions = &[_][]const u8{ ".png", ".jpg", ".tga", ".obj" };

pub fn main() !void {
    var args = std.process.args();
    defer args.deinit();

    _ = args.skip();

    var src: []const u8 = undefined;
    var dst: []const u8 = undefined;
    var i: usize = 0;
    while (args.next()) |arg| {
        if (i == 0) src = try gpa.dupe(u8, arg);
        if (i == 1) dst = try gpa.dupe(u8, arg);
        i += 1;
    }

    if (i != 2) return error.ShouldBeTwoArguments;

    try std.fs.cwd().makePath(dst);
    try bake(src, dst);

    gpa.free(src);
    gpa.free(dst);
    _ = general_purpose_allocator.deinit();
}

fn bake(src: []const u8, dst: []const u8) !void {
    std.debug.print("asset baking input. src: {s}, dst: {s}\n", .{ src, dst });

    const asset_files = getAllAssetFiles(src);
    defer gpa.free(asset_files);
    for (asset_files) |file| {
        defer gpa.free(file);

        var dst_subfolder = path.dirname(file).?[src.len..];
        defer gpa.free(dst_subfolder);
        if (dst_subfolder.len > 0) {
            dst_subfolder = try std.fmt.allocPrint(gpa, "{s}{s}", .{ dst, dst_subfolder });
            try fs.cwd().makePath(dst_subfolder);
        } else {
            dst_subfolder = try gpa.dupe(u8, dst);
        }

        const extension = path.extension(file);
        const filename = path.basename(file);
        const filename_no_ext = filename[0..std.mem.indexOf(u8, filename, extension).?];

        var dst_file = try std.fmt.allocPrint(gpa, "{s}/{s}", .{ dst_subfolder, filename_no_ext });
        defer gpa.free(dst_file);

        var timer = try std.time.Timer.start();
        try bakeFnForFileExtension(extension)(file, dst_file);
        var elapsed = timer.lap();
        std.debug.print("elapsed: {} ms\n\n", .{@intToFloat(f32, elapsed) / 1000000.0});
    }
}

fn getAllAssetFiles(root_directory: []const u8) [][]const u8 {
    var list = std.ArrayList([]const u8).init(gpa);

    var recursor = struct {
        fn search(directory: []const u8, filelist: *std.ArrayList([]const u8)) void {
            var dir = fs.cwd().openDir(directory, .{ .iterate = true }) catch unreachable;
            defer dir.close();

            var iter = dir.iterate();
            while (iter.next() catch unreachable) |entry| {
                if (entry.kind == .File) {
                    if (hasAssetExtension(entry.name)) {
                        const abs_path = path.join(gpa, &[_][]const u8{ directory, entry.name }) catch unreachable;
                        filelist.append(abs_path) catch unreachable;
                    }
                } else if (entry.kind == .Directory) {
                    const abs_path = path.join(gpa, &[_][]const u8{ directory, entry.name }) catch unreachable;
                    defer gpa.free(abs_path);
                    search(abs_path, filelist);
                }
            }
        }
    }.search;

    recursor(root_directory, &list);

    return list.toOwnedSlice();
}

fn hasAssetExtension(file: []const u8) bool {
    for (asset_extensions) |ext| {
        if (std.mem.endsWith(u8, file, ext)) return true;
    }
    return false;
}

fn bakeFnForFileExtension(ext: []const u8) fn ([]const u8, []const u8) anyerror!void {
    if (std.mem.eql(u8, ext, ".png") or std.mem.eql(u8, ext, ".jpg") or std.mem.eql(u8, ext, ".tga")) return bakeTexture;
    if (std.mem.eql(u8, ext, ".obj")) return bakeMesh;
    unreachable;
}

fn bakeTexture(src: []const u8, dst: []const u8) !void {
    std.debug.print("processing texture: {s}\n", .{src});

    const img = try stb.loadFromFile(gpa, src);
    defer img.deinit();

    const tex_info = assets.TextureInfo{
        .width = @intCast(u32, img.w),
        .height = @intCast(u32, img.h),
        .size = img.asSlice().len,
        .format = .rgba8,
        .orig_file = src,
    };

    var json_buffer = std.ArrayList(u8).init(gpa);
    defer json_buffer.deinit();
    try std.json.stringify(tex_info, .{}, json_buffer.writer());

    var asset = assets.AssetFile{
        .kind = [_]u8{ 'T', 'E', 'X', 'I' },
        .json = json_buffer.items,
        .blob = img.asSlice(),
    };

    const dst_file = try std.fmt.allocPrint(gpa, "{s}.tx", .{dst});
    defer gpa.free(dst_file);

    try assets.save(dst_file, &asset);
}

fn bakeMesh(src: []const u8, dst: []const u8) !void {
    std.debug.print("processing mesh: {s}\n", .{src});

    const srcz = try gpa.dupeZ(u8, src);
    defer gpa.free(srcz);

    const ret = tiny.obj_load(srcz.ptr);
    defer tiny.obj_free(ret);

    var vertices = std.ArrayList(assets.VertexF32PNCV).init(gpa);
    defer vertices.deinit();

    var indices = std.ArrayList(u32).init(gpa);
    defer indices.deinit();

    var s: usize = 0;
    while (s < ret.num_shapes) : (s += 1) {
        const shape = ret.shapes[s];
        try vertices.ensureTotalCapacity(vertices.items.len + shape.num_vertices);
        try indices.ensureTotalCapacity(vertices.items.len + shape.num_vertices);

        var i: usize = 0;
        while (i < shape.num_vertices) : (i += 1) {
            var vert: assets.VertexF32PNCV = undefined;
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

            indices.appendAssumeCapacity(@intCast(u32, vertices.items.len));
            vertices.appendAssumeCapacity(vert);
        }
    }

    // prep AssetFile data
    var mesh_info = assets.MeshInfo {
        .vert_buffer_size = vertices.items.len * @sizeOf(assets.VertexF32PNCV),
        .index_buffer_size = indices.items.len * @sizeOf(u32),
        .vert_format = .pncv_f32,
        .index_size = @sizeOf(u32),
        .orig_file = src,
    };

    var json_buffer = std.ArrayList(u8).init(gpa);
    defer json_buffer.deinit();
    try std.json.stringify(mesh_info, .{}, json_buffer.writer());

    // create the blob, merging the vert and index buffers
    const vert_bytes = std.mem.sliceAsBytes(vertices.items);
    const indices_bytes = std.mem.sliceAsBytes(indices.items);

    const merged_blob = try gpa.alloc(u8, vert_bytes.len + indices_bytes.len);
    defer gpa.free(merged_blob);

    // @memcpy(merged_blob, vert_bytes, vert_bytes.len);
    std.mem.copy(u8, merged_blob, vert_bytes);
    std.mem.copy(u8, merged_blob[vert_bytes.len..], indices_bytes);

    var asset = assets.AssetFile{
        .kind = [_]u8{ 'M', 'E', 'S', 'H' },
        .json = json_buffer.items,
        .blob = merged_blob,
    };

    const dst_file = try std.fmt.allocPrint(gpa, "{s}.mesh", .{dst});
    defer gpa.free(dst_file);

    try assets.save(dst_file, &asset);
}
