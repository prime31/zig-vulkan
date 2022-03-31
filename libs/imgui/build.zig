const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

var framework_dir: ?[]u8 = null;

pub fn linkArtifactDYLIB(_: *Builder, exe: *std.build.LibExeObjStep, _: std.zig.CrossTarget, comptime prefix_path: []const u8) void {
    if (prefix_path.len > 0 and !std.mem.endsWith(u8, prefix_path, "/")) @panic("prefix-path must end with '/' if it is not empty");
    exe.addLibPath("libs/imgui");
    exe.linkSystemLibrary("cimgui");
}

/// prefix_path is used to add package paths. It should be the the same path used to include this build file
pub fn linkArtifact(_: *Builder, exe: *std.build.LibExeObjStep, target: std.zig.CrossTarget, comptime prefix_path: []const u8) void {
    if (prefix_path.len > 0 and !std.mem.endsWith(u8, prefix_path, "/")) @panic("prefix-path must end with '/' if it is not empty");

    if (target.isWindows()) {
        exe.linkSystemLibrary("user32");
        exe.linkSystemLibrary("gdi32");
    } else if (target.isDarwin()) {
        // const frameworks_dir = macosFrameworksDir(b) catch unreachable;
        // exe.addFrameworkDir(frameworks_dir);
        // macosAddSdkDirs(b, exe) catch unreachable;
        // exe.linkFramework("Foundation");
        // exe.linkFramework("Cocoa");
        // exe.linkFramework("Quartz");
        // exe.linkFramework("QuartzCore");
        // exe.linkFramework("OpenGL");
        // exe.linkFramework("Audiotoolbox");
        // exe.linkFramework("CoreAudio");
        exe.linkSystemLibrary("c++");
        exe.linkSystemLibrary("vulkan");
    } else {
        exe.linkLibC();
        exe.linkSystemLibrary("c++");
    }

    const base_path = prefix_path ++ "libs/imgui/src/";
    exe.addIncludeDir(base_path ++ "imgui");

    const cpp_args = [_][]const u8{"-Wno-return-type-c-linkage", "-DIMGUI_IMPL_API=extern \"C\"", "-Wall", "-DIMGUI_DISABLE_OBSOLETE_FUNCTIONS=1", "-DIMGUI_IMPL_VULKAN_NO_PROTOTYPES=1"};
    exe.addCSourceFile(base_path ++ "imgui/imgui.cpp", &cpp_args);
    exe.addCSourceFile(base_path ++ "imgui/imgui_demo.cpp", &cpp_args);
    exe.addCSourceFile(base_path ++ "imgui/imgui_draw.cpp", &cpp_args);
    exe.addCSourceFile(base_path ++ "imgui/imgui_tables.cpp", &cpp_args);
    exe.addCSourceFile(base_path ++ "imgui/imgui_widgets.cpp", &cpp_args);
    exe.addCSourceFile(base_path ++ "cimgui.cpp", &cpp_args);
    // exe.addCSourceFile(base_path ++ "temporary_hacks.cpp", &cpp_args);

    const cpp_args2 = [_][]const u8{"-Wno-return-type-c-linkage", "-DIMGUI_IMPL_API=extern \"C\"", "-DCIMGUI_DEFINE_ENUMS_AND_STRUCTS=1", "-DIMGUI_IMPL_VULKAN_NO_PROTOTYPES=1", "-DVK_NO_PROTOTYPES=1"};
    exe.addCSourceFile(base_path ++ "imgui/imgui_impl_glfw.cpp", &cpp_args2);
    exe.addCSourceFile(base_path ++ "imgui/imgui_impl_vulkan.cpp", &cpp_args);
}

fn macosFrameworksDir(b: *Builder) ![]u8 {
    if (framework_dir) |dir| return dir;

    var str = try b.exec(&[_][]const u8{ "xcrun", "--show-sdk-path" });
    const strip_newline = std.mem.lastIndexOf(u8, str, "\n");
    if (strip_newline) |index| {
        str = str[0..index];
    }
    framework_dir = try std.mem.concat(b.allocator, u8, &[_][]const u8{ str, "/System/Library/Frameworks" });
    return framework_dir.?;
}

fn macosAddSdkDirs(b: *Builder, step: *std.build.LibExeObjStep) !void {
    var sdk_dir = try b.exec(&[_][]const u8 { "xcrun", "--show-sdk-path" });
    const newline_index = std.mem.lastIndexOf(u8, sdk_dir, "\n");
    if (newline_index) |idx| {
        sdk_dir = sdk_dir[0..idx];
    }
    framework_dir = try std.mem.concat(b.allocator, u8, &[_][]const u8 { sdk_dir, "/System/Library/Frameworks" });
    const usrinclude_dir = try std.mem.concat(b.allocator, u8, &[_][]const u8 { sdk_dir, "/usr/include"});
    step.addFrameworkDir(framework_dir.?);
    step.addIncludeDir(usrinclude_dir);
}

pub fn getPackage(comptime prefix_path: []const u8) std.build.Pkg {
    return .{
        .name = "imgui",
        .path = .{ .path = prefix_path ++ "libs/imgui/imgui.zig" },
    };
}

pub fn getVkPackage(comptime prefix_path: []const u8, vulkan_pkg: std.build.Pkg) std.build.Pkg {
    return .{
        .name = "imgui_vk",
        .path = .{ .path = prefix_path ++ "libs/imgui/imgui_glfw.zig" },
        .dependencies = &[_]std.build.Pkg{vulkan_pkg},
    };
}