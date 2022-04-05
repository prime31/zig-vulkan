const std = @import("std");
const Builder = std.build.Builder;

pub const LinuxWindowManager = enum {
    X11,
    Wayland,
};

pub const Options = struct {
    /// Only respected on Linux.
    linux_window_manager: LinuxWindowManager = .X11,
};

fn pwd() []const u8 {
    return std.fs.path.dirname(@src().file).? ++ "/";
}

// TODO: this function assumes the host OS is macOS. It should detect if it is a cross compilation from any platform to any platform.
pub fn link(b: *Builder, step: *std.build.LibExeObjStep, options: Options) void {
    step.linkLibC();
    const target = (std.zig.system.NativeTargetInfo.detect(b.allocator, step.target) catch unreachable).target;
    switch (target.os.tag) {
        .windows => {
            step.addLibraryPath(pwd() ++ "binaries");
            step.linkSystemLibrary("glfw");

            step.linkSystemLibrary("gdi32");
            step.linkSystemLibrary("user32");
            step.linkSystemLibrary("shell32");
        },
        .macos => {
            step.linkSystemLibrary("glfw3");
            step.linkFramework("IOKit");
            step.linkFramework("CoreFoundation");
            step.linkFramework("Metal");
            step.linkSystemLibrary("objc");
            step.linkFramework("AppKit");
            step.linkFramework("CoreServices");
            step.linkFramework("CoreGraphics");
            step.linkFramework("Foundation");
        },
        else => {
            step.addLibraryPath(pwd() ++ "binaries");
            step.linkSystemLibrary("glfw");

            // Assume Linux-like
            switch (options.linux_window_manager) {
                .X11 => {
                    step.linkSystemLibrary("X11");
                    step.linkSystemLibrary("xcb");
                    step.linkSystemLibrary("Xau");
                    step.linkSystemLibrary("Xdmcp");
                },
                .Wayland => step.linkSystemLibrary("wayland-client"),
            }
            // Note: no need to link against vulkan, GLFW finds it dynamically at runtime.
            // https://www.glfw.org/docs/3.3/vulkan_guide.html#vulkan_loader
        },
    }
}

pub fn getPackage(vulkan_pkg: std.build.Pkg) std.build.Pkg {
    return .{
        .name = "glfw",
        .path = .{ .path = pwd() ++ "src/main.zig" },
        .dependencies = &[_]std.build.Pkg{vulkan_pkg},
    };
}
