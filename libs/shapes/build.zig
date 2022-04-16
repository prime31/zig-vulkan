const std = @import("std");

fn pwd() []const u8 {
    return std.fs.path.dirname(@src().file).? ++ "/";
}

fn buildLibrary(exe: *std.build.LibExeObjStep) *std.build.LibExeObjStep {
    const lib = exe.builder.addStaticLibrary("zmesh", pwd() ++ "/src/zmesh.zig");

    lib.setBuildMode(exe.build_mode);
    lib.setTarget(exe.target);
    lib.want_lto = false;
    lib.addIncludeDir(pwd() ++ "/libs/par_shapes");
    lib.linkSystemLibrary("c");

    lib.addCSourceFile(pwd() ++ "/libs/par_shapes/par_shapes.c", &.{ "-std=c99", "-fno-sanitize=undefined" });

    lib.install();
    return lib;
}

pub fn link(exe: *std.build.LibExeObjStep) void {
    const cflags = &[_][]const u8{ "-std=c99", "-fno-sanitize=undefined" };
    exe.addCSourceFile(pwd() ++ "par_shapes.c", cflags);
}

pub const pkg = std.build.Pkg{
    .name = "shapes",
    .path = .{ .path = pwd() ++ "shapes.zig" },
};