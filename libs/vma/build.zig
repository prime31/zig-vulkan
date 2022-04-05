const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

fn pwd() []const u8 {
    return std.fs.path.dirname(@src().file).? ++ "/";
}

pub fn link(exe: *std.build.LibExeObjStep) void {
    exe.linkLibCpp();

    // TODO: seems compiler finds Vulkan SDK on its own...
    // exe.addIncludePath(pwd() ++ sdk_root ++ "/include");
    exe.addIncludePath(pwd() ++ "vma");
    exe.addCSourceFile(pwd() ++ "vk_mem_alloc.cpp", &.{ "-Wno-nullability-completeness", "-std=c++14" });
}

pub fn getPackage(vulkan_pkg: std.build.Pkg) std.build.Pkg {
    return .{
        .name = "vma",
        .path = .{ .path = pwd() ++ "vma.zig" },
        .dependencies = &[_]std.build.Pkg{vulkan_pkg},
    };
}
