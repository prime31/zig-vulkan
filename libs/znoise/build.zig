const std = @import("std");

fn pwd() []const u8 {
    return std.fs.path.dirname(@src().file).? ++ "/";
}

pub fn link(exe: *std.build.LibExeObjStep) void {
    exe.addIncludeDir(pwd());
    const cflags = &[_][]const u8{ "-std=c99", "-fno-sanitize=undefined" };
    exe.addCSourceFile(pwd() ++ "FastNoiseLite.c", cflags);
}

pub const pkg = std.build.Pkg{
    .name = "znoise",
    .path = .{ .path = pwd() ++ "znoise.zig" },
};