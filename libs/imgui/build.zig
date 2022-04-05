const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

fn pwd() []const u8 {
    return std.fs.path.dirname(@src().file).? ++ "/";
}

/// prefix_path is used to add package paths. It should be the the same path used to include this build file
pub fn link(exe: *std.build.LibExeObjStep, target: std.zig.CrossTarget) void {
    if (target.isWindows()) {
        exe.linkSystemLibrary("user32");
        exe.linkSystemLibrary("gdi32");
    } else if (target.isDarwin()) {
        exe.linkSystemLibrary("c++");
        exe.linkSystemLibrary("vulkan");
    } else {
        exe.linkLibC();
        exe.linkSystemLibrary("c++");
    }

    exe.addIncludeDir(pwd());

    // glfw include for cross compile
    exe.addIncludeDir("/usr/local/include");

    const cpp_args = [_][]const u8{ "-Wno-return-type-c-linkage", "-DIMGUI_IMPL_API=extern \"C\"", "-Wall", "-DIMGUI_DISABLE_OBSOLETE_FUNCTIONS=1", "-DIMGUI_IMPL_VULKAN_NO_PROTOTYPES=1" };
    exe.addCSourceFile(pwd() ++ "src/imgui/imgui.cpp", &cpp_args);
    exe.addCSourceFile(pwd() ++ "src/imgui/imgui_demo.cpp", &cpp_args);
    exe.addCSourceFile(pwd() ++ "src/imgui/imgui_draw.cpp", &cpp_args);
    exe.addCSourceFile(pwd() ++ "src/imgui/imgui_tables.cpp", &cpp_args);
    exe.addCSourceFile(pwd() ++ "src/imgui/imgui_widgets.cpp", &cpp_args);
    exe.addCSourceFile(pwd() ++ "src/cimgui.cpp", &cpp_args);
    // exe.addCSourceFile(pwd() ++ "src/temporary_hacks.cpp", &cpp_args);

    const cpp_args2 = [_][]const u8{ "-Wno-return-type-c-linkage", "-DIMGUI_IMPL_API=extern \"C\"", "-DCIMGUI_DEFINE_ENUMS_AND_STRUCTS=1", "-DIMGUI_IMPL_VULKAN_NO_PROTOTYPES=1", "-DVK_NO_PROTOTYPES=1" };
    exe.addCSourceFile(pwd() ++ "src/imgui/imgui_impl_glfw.cpp", &cpp_args2);
    exe.addCSourceFile(pwd() ++ "src/imgui/imgui_impl_vulkan.cpp", &cpp_args);
}

pub const pkg = std.build.Pkg{
    .name = "imgui",
    .path = .{ .path = pwd() ++ "imgui.zig" },
};

pub fn getVkPackage(vulkan_pkg: std.build.Pkg) std.build.Pkg {
    return .{
        .name = "imgui_vk",
        .path = .{ .path = pwd() ++ "imgui_glfw.zig" },
        .dependencies = &[_]std.build.Pkg{vulkan_pkg},
    };
}
