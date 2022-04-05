const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

pub fn link(exe: *std.build.LibExeObjStep, comptime prefix_path: []const u8) void {
    if (prefix_path.len > 0 and !std.mem.endsWith(u8, prefix_path, "/")) @panic("prefix-path must end with '/' if it is not empty");

    exe.linkLibCpp();
    // exe.addIncludePath(sdk_root ++ "/include");
    exe.addIncludePath(prefix_path ++ "libs/vma");
    exe.addCSourceFile(prefix_path ++ "libs/vma/vk_mem_alloc.cpp", &.{ "-Wno-nullability-completeness", "-std=c++14" });
}

pub fn getPackage(comptime prefix_path: []const u8, vulkan_pkg: std.build.Pkg) std.build.Pkg {
    return .{
        .name = "vma",
        .path = .{ .path = prefix_path ++ "libs/vma/vma.zig" },
        .dependencies = &[_]std.build.Pkg{vulkan_pkg},
    };
}
