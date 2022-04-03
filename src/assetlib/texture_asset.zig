const std = @import("std");
const assets = @import("assets.zig");

pub const TextureFormat = enum {
    rgba8,

    pub fn jsonStringify(self: TextureFormat, _: std.json.StringifyOptions, writer: anytype) !void {
        try writer.print("{d}", .{@enumToInt(self)});
    }
};

pub const TextureInfo = struct {
    width: u32,
    height: u32,
    size: usize,
    format: TextureFormat,
    orig_file: []const u8,
};

test "texture save/load" {
    const stb = @import("stb");
    const src_file = "src/chapters/background.png";
    const dst_file = "/Users/desaro/Desktop/texture.txt";

    const img = try stb.loadFromFile(std.testing.allocator, src_file);
    defer img.deinit();

    const tex_info = TextureInfo{
        .width = @intCast(u32, img.w),
        .height = @intCast(u32, img.h),
        .size = img.asSlice().len,
        .format = .rgba8,
        .orig_file = src_file,
    };

    var json_buffer = std.ArrayList(u8).init(std.testing.allocator);
    defer json_buffer.deinit();

    try std.json.stringify(tex_info, .{}, json_buffer.writer());

    var asset = assets.AssetFile{
        .kind = [_]u8{ 'T', 'E', 'X', 'I' },
        .json = json_buffer.items,
        .blob = img.asSlice(),
    };
    try assets.save(dst_file, &asset);

    // load
    {
        var new_asset = try assets.load(TextureInfo, dst_file);
        try std.testing.expectEqual(tex_info.width, new_asset.info.width);
        try std.testing.expectEqual(tex_info.height, new_asset.info.height);
        try std.testing.expectEqual(tex_info.size, new_asset.info.size);
        try std.testing.expectEqual(tex_info.format, new_asset.info.format);
        try std.testing.expectEqualSlices(u8, asset.blob, new_asset.blob);

        new_asset.deinit();
    }
}
