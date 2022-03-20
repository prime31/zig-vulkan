const std = @import("std");

const glfw = @import("libs/mach-glfw/build.zig");
const vkgen = @import("libs/vulkan-zig/generator/index.zig");

const Step = std.build.Step;
const Builder = std.build.Builder;

/// compiles all shaders with glslc and generates a resources.zig file to access them at runtime.
pub const ResourceGenStep = struct {
    step: Step,
    shader_step: *vkgen.ShaderCompileStep,
    builder: *Builder,
    package: std.build.Pkg,
    output_file: std.build.GeneratedFile,
    resources: std.ArrayList(u8),

    pub fn init(builder: *Builder, out: []const u8) *ResourceGenStep {
        const self = builder.allocator.create(ResourceGenStep) catch unreachable;
        const full_out_path = std.fs.path.join(builder.allocator, &[_][]const u8{
            builder.build_root,
            builder.cache_root,
            out,
        }) catch unreachable;

        self.* = .{
            .step = Step.init(.custom, "resources", builder.allocator, make),
            .shader_step = vkgen.ShaderCompileStep.init(builder, &[_][]const u8{ "glslc", "--target-env=vulkan1.1" }, "shaders"),
            .builder = builder,
            .package = .{
                .name = "resources",
                .path = .{ .generated = &self.output_file },
                .dependencies = null,
            },
            .output_file = .{
                .step = &self.step,
                .path = full_out_path,
            },
            .resources = std.ArrayList(u8).init(builder.allocator),
        };

        self.step.dependOn(&self.shader_step.step);
        return self;
    }

    fn renderPath(path: []const u8, writer: anytype) void {
        const separators = &[_]u8{ std.fs.path.sep_windows, std.fs.path.sep_posix };
        var i: usize = 0;
        while (std.mem.indexOfAnyPos(u8, path, i, separators)) |j| {
            writer.writeAll(path[i..j]) catch unreachable;
            switch (std.fs.path.sep) {
                std.fs.path.sep_windows => writer.writeAll("\\\\") catch unreachable,
                std.fs.path.sep_posix => writer.writeByte(std.fs.path.sep_posix) catch unreachable,
                else => unreachable,
            }

            i = j + 1;
        }
        writer.writeAll(path[i..]) catch unreachable;
    }

    pub fn addShader(self: *ResourceGenStep, name: []const u8, source: []const u8) void {
        const shader_out_path = self.shader_step.add(source);
        var writer = self.resources.writer();

        writer.print("pub const {s} = @embedFile(\"", .{name}) catch unreachable;
        renderPath(shader_out_path, writer);
        writer.writeAll("\");\n") catch unreachable;
    }

    fn make(step: *Step) !void {
        const self = @fieldParentPtr(ResourceGenStep, "step", step);
        const cwd = std.fs.cwd();

        const dir = std.fs.path.dirname(self.output_file.path.?).?;
        try cwd.makePath(dir);
        try cwd.writeFile(self.output_file.path.?, self.resources.items);
    }
};

// packages
const vulkan_pkg = std.build.Pkg{
    .name = "vulkan",
    .path = .{ .path = "src/vk.zig" },
};
const glfw_pkg = std.build.Pkg{
    .name = "glfw",
    .path = .{ .path = "libs/mach-glfw/src/main.zig" },
};

const tinyobjloader_pkg = std.build.Pkg{
    .name = "tiny",
    .path = .{ .path = "libs/tinyobjloader/tinyobjloader.zig" },
};

const vma_pkg = std.build.Pkg{
    .name = "vma",
    .path = .{ .path = "libs/vma/vma.zig" },
    .dependencies = &[_]std.build.Pkg{vulkan_pkg},
};

const vk_sdk_root = "/Users/mikedesaro/VulkanSDK/1.3.204.1/macOS";

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    // shader compilation and resources.zig generation
    const resources_pkg = addShaderCompilationStep(b, true);

    const examples = getAllExamples(b, "examples");
    for (examples) |example| {
        const name = example[0];
        const source = example[1];

        var exe = b.addExecutable(name, source);
        exe.setOutputDir("zig-cache/bin");
        exe.setTarget(target);
        exe.setBuildMode(mode);

        // packages
        exe.addPackage(vulkan_pkg);
        exe.addPackage(resources_pkg);

        // mach-glfw
        exe.addPackage(glfw_pkg);
        glfw.link(b, exe, .{ .opengl = false });

        exe.addPackage(.{
            .name = "vengine",
            .path = .{ .path = "src/v.zig" },
            .dependencies = &[_]std.build.Pkg{ glfw_pkg, vulkan_pkg, resources_pkg, tinyobjloader_pkg, vma_pkg },
        });

        // vulken-mem
        linkVulkanMemoryAllocator(exe, vk_sdk_root);
        linkTinyObjLoader(exe);

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

    const gen = vkgen.VkGenerateStep.initFromSdk(b, vk_sdk_root, "vk.zig");
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
fn addShaderCompilationStep(b: *Builder, always_compile_shaders: bool) std.build.Pkg {
    // compile shaders
    const compile_shaders_exe_step = b.step("compile_shaders", b.fmt("Compiles shaders", .{}));

    const res = ResourceGenStep.init(b, "resources.zig");
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

fn linkVulkanMemoryAllocator(step: *std.build.LibExeObjStep, comptime sdk_root: []const u8) void {
    step.linkLibCpp();
    step.addIncludePath(sdk_root ++ "/include");
    step.addIncludePath("libs/vma");
    step.addCSourceFile("libs/vma/vk_mem_alloc.cpp", &.{ "-Wno-nullability-completeness", "-std=c++14" });
}

fn linkTinyObjLoader(step: *std.build.LibExeObjStep) void {
    step.addIncludePath("libs/tinyobjloader");
    step.addCSourceFile("libs/tinyobjloader/tinyobj_loader_c.c", &.{"-std=c99"});
}

fn getAllExamples(b: *Builder, root_directory: []const u8) [][2][]const u8 {
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

fn getAllShaders(b: *Builder, root_directory: []const u8) [][2][]const u8 {
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
