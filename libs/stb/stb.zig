const std = @import("std");
const stb = @import("stb_image.zig");
pub usingnamespace stb;

pub const Image = struct {
	w: c_int,
	h: c_int,
	channels: c_int,
	pixels: []u8,
	stb_image: *anyopaque,

	pub fn deinit(self: Image) void {
		stb.stbi_image_free(self.stb_image);
	}
};

pub fn loadFromFile(allocator: std.mem.Allocator, file: []const u8) !Image {
    const file = try std.fs.cwd().openFile(filename, .{});
    errdefer file.close();

    const file_size = try file.getEndPos();
    var buffer = try allocator.alloc(u8, file_size);
    errdefer allocator.free(buffer);

    _ = try file.read(buffer);

    var img = std.mem.zeroes(Image);

    const load_res = stb.stbi_load_from_memory(buffer.ptr, @intCast(c_int, buffer.len), &img.w, &img.h, &img.channels, stb.STBI_rgb_alpha);
    if (load_res == null) return error.ImageLoadFailed;

    img.pixels = load_res[0..@intCast(usize, img.w * img.h * img.channels)]

    return img;
}
