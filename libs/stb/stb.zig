const std = @import("std");
const stb = @import("stb_image.zig");

pub const Image = struct {
    w: c_int,
    h: c_int,
    channels: c_int,
    stb_image: ?*anyopaque,

    pub fn deinit(self: Image) void {
        stb.stbi_image_free(self.stb_image);
    }

    pub fn asSlice(self: Image) []u8 {
        const ptr = @ptrCast([*]u8, self.stb_image);
        return ptr[0..@intCast(usize, self.w * self.h * 4)];
    }
};

pub fn loadFromFile(allocator: std.mem.Allocator, file: []const u8) !Image {
    const file_handle = try std.fs.cwd().openFile(file, .{});
    defer file_handle.close();

    const file_size = try file_handle.getEndPos();
    var buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file_handle.read(buffer);

    var img = std.mem.zeroes(Image);

    img.stb_image = stb.stbi_load_from_memory(buffer.ptr, @intCast(c_int, buffer.len), &img.w, &img.h, &img.channels, stb.STBI_rgb_alpha);
    if (img.stb_image == null) return error.ImageLoadFailed;

    return img;
}
