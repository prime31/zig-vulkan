const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

fn pwd() []const u8 {
    return std.fs.path.dirname(@src().file).? ++ "/";
}

pub fn link(exe: *std.build.LibExeObjStep) void {
    exe.addIncludePath(pwd() ++ "tinyobjloader");
    exe.addCSourceFile(pwd() ++ "obj_loader.cc", &.{});
}

pub const pkg = std.build.Pkg{
    .name = "tiny",
    .path = .{ .path = pwd() ++ "tinyobjloader.zig" },
};
