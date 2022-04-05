const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

fn pwd() []const u8 {
    return std.fs.path.dirname(@src().file).? ++ "/";
}

pub fn link(exe: *std.build.LibExeObjStep) void {
    exe.linkLibC();
    exe.addIncludeDir(pwd());

    const lib_cflags = &[_][]const u8{ "-std=c99", "-O3", "-DLZ4_FAST_DEC_LOOP=1" };
    exe.addCSourceFile(pwd() ++ "lz4.c", lib_cflags);
}

pub const pkg = std.build.Pkg{
    .name = "lz4",
    .path = .{ .path = pwd() ++ "lz4.zig" },
};
