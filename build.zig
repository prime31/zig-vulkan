const std = @import("std");

const glfw = @import("libs/mach-glfw/build.zig");
const vkgen = @import("libs/vulkan-zig/generator/index.zig");
const zigvulkan = @import("libs/vulkan-zig/build.zig");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("mach-glfw-vulkan-example", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    // optional: uncommenting will create the vk.zig file in the zig-out folder. It should be copied to the root folder.
    // vulkan-zig: Create a step that generates vk.zig (stored in zig-out) from the provided vulkan registry.
    // const gen = vkgen.VkGenerateStep.initFromSdk(b, "/Users/mikedesaro/VulkanSDK/1.3.204.1/macOS", "vk.zig");
    // exe.addPackage(gen.package);
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

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
