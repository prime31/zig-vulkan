const std = @import("std");

const glfw = @import("libs/mach-glfw/build.zig");
const vkgen = @import("libs/vulkan-zig/generator/index.zig");
const zigvulkan = @import("libs/vulkan-zig/build.zig");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const examples = getAllExamples(b, "examples");
    for (examples) |example| {
        if (std.mem.endsWith(u8, example[0], "chain") or std.mem.endsWith(u8, example[0], "context")) continue;

        const name = example[0];
        const source = example[1];

        var exe = b.addExecutable(name, source);
        exe.setOutputDir("zig-cache/bin");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        exe.addPackage(.{
            .name = "vulkan",
            .path = .{
                .path = std.fs.path.join(b.allocator, &[_][]const u8{
                    b.build_root,
                    b.cache_root,
                    "vk.zig",
                }) catch unreachable,
            },
        });

        // mach-glfw
        exe.addPackagePath("glfw", "libs/mach-glfw/src/main.zig");
        glfw.link(b, exe, .{});

        // shader resources, to be compiled using glslc
        const res = zigvulkan.ResourceGenStep.init(b, "resources.zig");
        res.shader_step = vkgen.ShaderCompileStep.init(b, &[_][]const u8{ "glslc", "--target-env=vulkan1.3" }, "shaders");
        res.step.dependOn(&res.shader_step.step);
        res.addShader("triangle_vert", "shaders/triangle.vert");
        res.addShader("triangle_frag", "shaders/triangle.frag");
        exe.addPackage(res.package);

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step(name, b.fmt("run {s}.zig", .{name}));
        run_step.dependOn(&run_cmd.step);
    }

    // generate vk.zig bindings
    var generate_exe = b.addSystemCommand(&[_][]const u8{ "echo", "done" });
    const exe_step = b.step("generate_vulkan_bindings", b.fmt("Generates the vk.zig file", .{}));
    exe_step.dependOn(&generate_exe.step);

    _ = vkgen.VkGenerateStep.initFromSdk(b, "/Users/mikedesaro/VulkanSDK/1.3.204.1/macOS", "vk.zig");
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
