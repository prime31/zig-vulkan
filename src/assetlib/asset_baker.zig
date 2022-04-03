const std = @import("std");
const fs = std.fs;
const path = std.fs.path;
const stb = @import("stb");
const assets = @import("assets.zig");


var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{ .thread_safe = false }){};
const gpa = general_purpose_allocator.allocator();

// all the extensions supported. each one must be handled in bakeFnForFileExtension
const asset_extensions = &[_][]const u8{".png", ".jpg", ".tga"};

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

        try bakeFnForFileExtension(extension)(file, dst_file);
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
    unreachable;
}

fn bakeTexture(src: []const u8, dst: []const u8) !void {
    std.debug.print("processing texture: {s}\n", .{ src });

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
