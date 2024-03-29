const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub fn linkArtifact(exe: *std.build.LibExeObjStep, comptime prefix_path: []const u8) void {
    if (prefix_path.len > 0 and !std.mem.endsWith(u8, prefix_path, "/")) @panic("prefix-path must end with '/' if it is not empty");

    exe.linkLibC();
    exe.addIncludeDir(prefix_path ++ "libs/stb");

    const lib_cflags = &[_][]const u8{ "-std=c99", "-O3" };
    exe.addCSourceFile(prefix_path ++ "libs/stb/stb_impl.c", lib_cflags);
}

pub fn getPackage(comptime prefix_path: []const u8) std.build.Pkg {
    return .{
        .name = "stb",
        .path = .{ .path = prefix_path ++ "libs/stb/stb.zig" },
    };
}
