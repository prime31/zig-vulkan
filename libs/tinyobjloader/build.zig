const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub fn link(exe: *std.build.LibExeObjStep, comptime prefix_path: []const u8) void {
    if (prefix_path.len > 0 and !std.mem.endsWith(u8, prefix_path, "/")) @panic("prefix-path must end with '/' if it is not empty");

    exe.addIncludePath(prefix_path ++ "libs/tinyobjloader");
    exe.addCSourceFile(prefix_path ++ "libs/tinyobjloader/obj_loader.cc", &.{});
}

pub fn getPackage(comptime prefix_path: []const u8) std.build.Pkg {
    return .{
        .name = "tiny",
        .path = .{ .path = prefix_path ++ "libs/tinyobjloader/tinyobjloader.zig" },
    };
}