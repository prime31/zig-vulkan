const std = @import("std");

pub const CompressionMode = enum {
    none,
    lz4,
};

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
    var handle = try std.fs.cwd().createFile(filename, .{});
    defer handle.close();

    var writer = handle.writer();
    _ = try writer.write(&asset.kind);

    _ = try writer.writeInt(u64, asset.json.len, .Little);
    _ = try writer.writeInt(u64, asset.blob.len, .Little);

    _ = try writer.write(asset.json);
    _ = try writer.write(asset.blob);
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
    const blob_len = try reader.readInt(u64, .Little);

    var json = try std.heap.c_allocator.alloc(u8, json_len);
    var blob = try std.heap.c_allocator.alloc(u8, blob_len);

    _ = try reader.read(json);
    _ = try reader.read(blob);

    var stream = std.json.TokenStream.init(json);
    const parse_options: std.json.ParseOptions = .{ .allocator = std.heap.c_allocator };
    const info = try std.json.parse(T, &stream, parse_options);

    std.heap.c_allocator.free(json);

    return Asset(T).init(info, blob, parse_options);
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
    try save("/Users/desaro/Desktop/fart.txt", &asset);

    var new_asset = try load(TestType, "/Users/desaro/Desktop/fart.txt");
    try std.testing.expectEqual(new_asset.info.t, 6);
    try std.testing.expectEqualSlices(u8, asset.blob, new_asset.blob);
}
