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
