const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

fn pwd() []const u8 {
    return std.fs.path.dirname(@src().file).? ++ "/";
}

pub fn link(exe: *std.build.LibExeObjStep) void {
    exe.linkLibC();
    exe.addIncludeDir(pwd());

    const lib_cflags = &[_][]const u8{ "-std=c99", "-O3" };
    exe.addCSourceFile(pwd() ++ "stb_impl.c", lib_cflags);
}

pub const pkg = std.build.Pkg{
    .name = "stb",
    .path = .{ .path = pwd() ++ "stb.zig" },
};
