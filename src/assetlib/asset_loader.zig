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

pub fn load(filename: []const u8) !AssetFile {
    var handle = try std.fs.cwd().openFile(filename, .{});
    defer handle.close();

    var asset: AssetFile = undefined;

    var reader = handle.reader();
    _ = try reader.read(&asset.kind);

    const json_len = try reader.readInt(u64, .Little);
    const blob_len = try reader.readInt(u64, .Little);

    var json = try std.heap.c_allocator.alloc(u8, json_len);
    var blob = try std.heap.c_allocator.alloc(u8, blob_len);

    _ = try reader.read(json);
    _ = try reader.read(blob);

    asset.json = json;
    asset.blob = blob;

    return asset;
}

test "AssetFile save/load" {
    std.testing.refAllDecls(@This());

    var asset = AssetFile{
        .kind = [_]u8{'F', 'A', 'R', 'T'},
        .json = "{ 't': 6 }",
        .blob = "ldskajflksadjfkldsajfkldsjafklsdjfdklsjasdklf",
    };
    try save("/Users/desaro/Desktop/fart.txt", &asset);

    var new_asset = try load("/Users/desaro/Desktop/fart.txt");
    try std.testing.expectEqual(asset.kind, new_asset.kind);
    try std.testing.expectEqualSlices(u8, asset.json, new_asset.json);
    try std.testing.expectEqualSlices(u8, asset.blob, new_asset.blob);
}