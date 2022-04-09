const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

fn pwd() []const u8 {
    return std.fs.path.dirname(@src().file).? ++ "/";
}

pub fn link(exe: *std.build.LibExeObjStep) void {
    exe.addIncludePath(pwd());
    exe.addCSourceFile(pwd() ++ "spirv_reflect.c", &.{});
}

pub const pkg = std.build.Pkg{
    .name = "spirv",
    .path = .{ .path = pwd() ++ "spirv_reflect.zig" },
};
