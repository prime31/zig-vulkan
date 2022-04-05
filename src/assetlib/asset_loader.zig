const std = @import("std");
const lz4 = @import("lz4");

pub const AssetFile = struct {
    kind: [4]u8,
    json: []const u8,
    blob: []const u8,
};

pub fn Asset(comptime T: type) type {
    return struct {
        const Self = @This();

        info: T,
        blob: []const u8,
        json_parse_options: std.json.ParseOptions,

        pub fn init(info: T, blob: []const u8, json_parse_options: std.json.ParseOptions) Self {
            return .{
                .info = info,
                .blob = blob,
                .json_parse_options = json_parse_options,
            };
        }

        pub fn deinit(self: Self) void {
            std.heap.c_allocator.free(self.blob);
            std.json.parseFree(T, self.info, self.json_parse_options);
        }
    };
}

pub fn save(filename: []const u8, asset: *AssetFile) !void {
    // compress buffer and copy it into the file struct
    const compress_staging = lz4.LZ4_compressBound(@intCast(c_int, asset.blob.len));
    var final_blob = try std.heap.c_allocator.alloc(u8, @intCast(usize, compress_staging));
    defer std.heap.c_allocator.free(final_blob);

    const compressed_size = lz4.LZ4_compress_default(asset.blob.ptr, final_blob.ptr, @intCast(c_int, asset.blob.len), compress_staging);
    final_blob.len = @intCast(usize, compressed_size);

    // open file and write data
    var handle = try std.fs.cwd().createFile(filename, .{});
    defer handle.close();

    var writer = handle.writer();
    _ = try writer.write(&asset.kind);

    _ = try writer.writeInt(u64, asset.json.len, .Little);
    _ = try writer.writeInt(u64, asset.blob.len, .Little);
    _ = try writer.writeInt(u64, final_blob.len, .Little);

    _ = try writer.write(asset.json);
    _ = try writer.write(final_blob);

    // reset final_blob so it frees cleanly
    final_blob.len = @intCast(usize, compress_staging);

    std.debug.print("---- compression ratio: {d:0.3}\n", .{ @intToFloat(f32, compressed_size) / @intToFloat(f32, asset.blob.len) });
}

/// T should be the info struct that corresponds to the format of the file loaded. The returned Asset(T)
/// must have deinit called to cleanup allocations!
pub fn load(comptime T: type, filename: []const u8) !Asset(T) {
    var handle = try std.fs.cwd().openFile(filename, .{});
    defer handle.close();

    var reader = handle.reader();
    var kind: [4]u8 = undefined;
    _ = try reader.read(&kind);

    const json_len = try reader.readInt(u64, .Little);
    const blob_decompressed_len = try reader.readInt(u64, .Little);
    const blob_compressed_len = try reader.readInt(u64, .Little);

    var json = try std.heap.c_allocator.alloc(u8, json_len);
    var blob_compressed = try std.heap.c_allocator.alloc(u8, blob_compressed_len);
    defer std.heap.c_allocator.free(blob_compressed);
    var blob_decompressed = try std.heap.c_allocator.alloc(u8, blob_decompressed_len);

    _ = try reader.read(json);
    _ = try reader.read(blob_compressed);

    var stream = std.json.TokenStream.init(json);
    const parse_options: std.json.ParseOptions = .{ .allocator = std.heap.c_allocator };
    const info = try std.json.parse(T, &stream, parse_options);

    std.heap.c_allocator.free(json);

    // decompress blob
    const res = lz4.LZ4_decompress_safe(blob_compressed.ptr, blob_decompressed.ptr, @intCast(c_int, blob_compressed_len), @intCast(c_int, blob_decompressed_len));
    if (res < 0) return error.DecompressionFailed;

    return Asset(T).init(info, blob_decompressed, parse_options);
}

test "AssetFile save/load" {
    const TestType = struct {
        t: u8,
    };

    var asset = AssetFile{
        .kind = [_]u8{ 'F', 'A', 'R', 'T' },
        .json = "{ \"t\": 6 }",
        .blob = "ldskajflksadjfkldsajfkldsjafklsdjfdklsjasdklf",
    };

    const output_file = "zig-cache/tmp/fart.txt";

    try save(output_file, &asset);

    var new_asset = try load(TestType, output_file);
    try std.testing.expectEqual(new_asset.info.t, 6);
    try std.testing.expectEqualSlices(u8, asset.blob, new_asset.blob);
}
