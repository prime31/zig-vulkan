const std = @import("std");

const glfw = @import("libs/mach-glfw/build.zig");
const vkgen = @import("libs/vulkan-zig/generator/index.zig");
const zigvulkan = @import("libs/vulkan-zig/build.zig");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // shader compilation and resources.zig generation
    const resources_pkg = addShaderCompilationStep(b, true);

    // packages
    const vulkan_pkg = std.build.Pkg{
        .name = "vulkan",
        .path = .{
            .path = std.fs.path.join(b.allocator, &[_][]const u8{
                b.build_root,
                b.cache_root,
                "vk.zig",
            }) catch unreachable,
        },
    };
    const glfw_pkg = std.build.Pkg{
        .name = "glfw",
        .path = .{ .path = "libs/mach-glfw/src/main.zig" },
    };

    const examples = getAllExamples(b, "examples");
    for (examples) |example| {
        const name = example[0];
        const source = example[1];

        var exe = b.addExecutable(name, source);
        exe.setOutputDir("zig-cache/bin");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        // packages
        exe.addPackage(vulkan_pkg);
        exe.addPackage(resources_pkg);

        // mach-glfw
        exe.addPackage(glfw_pkg);
        glfw.link(b, exe, .{});

        exe.addPackage(.{
            .name = "vengine",
            .path = .{ .path = "src/v.zig" },
            .dependencies = &[_]std.build.Pkg{ glfw_pkg, vulkan_pkg, resources_pkg },
        });

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step(name, b.fmt("run {s}.zig", .{name}));
        run_step.dependOn(&run_cmd.step);
    }

    // generate vk.zig bindings
    var generate_exe = b.addSystemCommand(&[_][]const u8{ "echo", "done generating vk.zig" });
    const exe_step = b.step("generate_vulkan_bindings", b.fmt("Generates the vk.zig file", .{}));
    exe_step.dependOn(&generate_exe.step);

    const gen = vkgen.VkGenerateStep.initFromSdk(b, "/Users/desaro/VulkanSDK/1.3.204.1/macOS", "vk.zig");
    exe_step.dependOn(&gen.step);

    // tests
    const exe_tests = b.addTest("src/tests.zig");
    glfw.link(b, exe_tests, .{});

    exe_tests.addPackage(vulkan_pkg);
    exe_tests.addPackage(glfw_pkg);
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(b.standardReleaseOptions());

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}

/// if always_compile_shaders is true, every build will compile shaders. If it is false, shader compilation will only occur
/// when specifically running compile_shaders
fn addShaderCompilationStep(b: *std.build.Builder, always_compile_shaders: bool) std.build.Pkg {
    // compile shaders
    var compile_shaders_exe = b.addSystemCommand(&[_][]const u8{ "echo", "done compiling shaders" });
    const compile_shaders_exe_step = b.step("compile_shaders", b.fmt("Compiles shaders", .{}));
    compile_shaders_exe_step.dependOn(&compile_shaders_exe.step);

    const res = zigvulkan.ResourceGenStep.init(b, "resources.zig");
    res.shader_step = vkgen.ShaderCompileStep.init(b, &[_][]const u8{ "glslc", "--target-env=vulkan1.1" }, "shaders");
    res.step.dependOn(&res.shader_step.step);
    compile_shaders_exe_step.dependOn(&res.step);

    // add all shader for compilation
    const shaders = getAllShaders(b, "shaders");
    for (shaders) |shader| {
        res.addShader(shader[0], shader[1]);
    }

    if (always_compile_shaders) {
        return res.package;
    } else {
        return std.build.Pkg{ .name = "resources", .path = .{
            .path = std.fs.path.join(b.allocator, &[_][]const u8{
                b.build_root,
                b.cache_root,
                "resources.zig",
            }) catch unreachable,
        } };
    }
}

fn getAllExamples(b: *std.build.Builder, root_directory: []const u8) [][2][]const u8 {
    var list = std.ArrayList([2][]const u8).init(b.allocator);

    var recursor = struct {
        fn search(alloc: std.mem.Allocator, directory: []const u8, filelist: *std.ArrayList([2][]const u8)) void {
            var dir = std.fs.cwd().openDir(directory, .{ .iterate = true }) catch unreachable;
            defer dir.close();

            var iter = dir.iterate();
            while (iter.next() catch unreachable) |entry| {
                if (entry.kind == .File) {
                    if (std.mem.endsWith(u8, entry.name, ".zig")) {
                        const abs_path = std.fs.path.join(alloc, &[_][]const u8{ directory, entry.name }) catch unreachable;
                        const name = std.fs.path.basename(abs_path);

                        filelist.append([2][]const u8{ name[0 .. name.len - 4], abs_path }) catch unreachable;
                    }
                } else if (entry.kind == .Directory) {
                    const abs_path = std.fs.path.join(alloc, &[_][]const u8{ directory, entry.name }) catch unreachable;
                    search(alloc, abs_path, filelist);
                }
            }
        }
    }.search;

    recursor(b.allocator, root_directory, &list);

    return list.toOwnedSlice();
}

fn getAllShaders(b: *std.build.Builder, root_directory: []const u8) [][2][]const u8 {
    var list = std.ArrayList([2][]const u8).init(b.allocator);

    var recursor = struct {
        fn search(alloc: std.mem.Allocator, directory: []const u8, filelist: *std.ArrayList([2][]const u8)) void {
            var dir = std.fs.cwd().openDir(directory, .{ .iterate = true }) catch unreachable;
            defer dir.close();

            var iter = dir.iterate();
            while (iter.next() catch unreachable) |entry| {
                if (entry.kind == .File) {
                    if (std.mem.endsWith(u8, entry.name, ".vert") or std.mem.endsWith(u8, entry.name, ".frag")) {
                        const abs_path = std.fs.path.join(alloc, &[_][]const u8{ directory, entry.name }) catch unreachable;
                        const name = alloc.dupe(u8, std.fs.path.basename(abs_path)) catch unreachable;
                        if (std.mem.indexOf(u8, name, ".")) |index| name[index] = '_';

                        filelist.append([2][]const u8{ name, abs_path }) catch unreachable;
                    }
                } else if (entry.kind == .Directory) {
                    const abs_path = std.fs.path.join(alloc, &[_][]const u8{ directory, entry.name }) catch unreachable;
                    search(alloc, abs_path, filelist);
                }
            }
        }
    }.search;

    recursor(b.allocator, root_directory, &list);

    return list.toOwnedSlice();
}
