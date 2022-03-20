const std = @import("std");
const vk = @import("vulkan");
const vma = @import("vma");
const resources = @import("resources");
const glfw = @import("glfw");
const vkinit = @import("../vkinit.zig");

const GraphicsContext = @import("../graphics_context.zig").GraphicsContext;
const Swapchain = @import("../swapchain.zig").Swapchain;
const PipelineBuilder = @import("../pipeline_builder.zig").PipelineBuilder;
const Mesh = @import("../mesh.zig").Mesh;
const Vertex = @import("../mesh.zig").Vertex;
const Allocator = std.mem.Allocator;
const Mat4 = @import("mat4.zig").Mat4;
const Vec3 = @import("vec3.zig").Vec3;
const Vec4 = @import("vec4.zig").Vec4;

pub fn toRadians(deg: anytype) @TypeOf(deg) {
    return std.math.pi * deg / 180.0;
}

pub fn toDegrees(rad: anytype) @TypeOf(rad) {
    return 180.0 * rad / std.math.pi;
}

const FlyCamera = struct {
    window: glfw.Window,
    speed: f32 = 3.5,
    pos: Vec3 = Vec3.new(2, 0.5, 20),
    front: Vec3 = Vec3.new(0, 0, -1),
    up: Vec3 = Vec3.new(0, 1, 0),
    pitch: f32 = 0,
    yaw: f32 = -90,
    last_mouse_x: f32 = 400,
    last_mouse_y: f32 = 300,

    pub fn init(window: glfw.Window) FlyCamera {
        return .{
            .window = window,
        };
    }

    pub fn update(self: *FlyCamera, dt: f64) void {
        var cursor_pos = self.window.getCursorPos() catch unreachable;
        var x_offset = @floatCast(f32, cursor_pos.xpos) - self.last_mouse_x;
        var y_offset = self.last_mouse_y - @floatCast(f32, cursor_pos.ypos); // reversed since y-coordinates range from bottom to top
        self.last_mouse_x = @floatCast(f32, cursor_pos.xpos);
        self.last_mouse_y = @floatCast(f32, cursor_pos.ypos);

        var sensitivity: f32 = 0.2;
        x_offset *= sensitivity * 1.5; // bit more sensitivity for x
        y_offset *= sensitivity;

        self.yaw += x_offset;
        self.pitch += y_offset;
        self.pitch = std.math.clamp(self.pitch, -90, 90);

        var direction = Vec3.new(0, 0, 0);
        direction.x = std.math.cos(toRadians(self.yaw)) * std.math.cos(toRadians(self.pitch));
        direction.y = std.math.sin(toRadians(self.pitch));
        direction.z = std.math.sin(toRadians(self.yaw)) * std.math.cos(toRadians(self.pitch));
        self.front = direction.normalize();

        // wasd
        var spd = self.speed * @floatCast(f32, dt);

        if (self.window.getKey(.w) == .press) {
            self.pos = self.pos.add(self.front.scale(spd));
        } else if (self.window.getKey(.s) == .press) {
            self.pos = self.pos.sub(self.front.scale(spd));
        }
        if (self.window.getKey(.a) == .press) {
            self.pos = self.pos.sub(Vec3.normalize(self.front.cross(self.up)).scale(spd));
        } else if (self.window.getKey(.d) == .press) {
            self.pos = self.pos.add(Vec3.normalize(self.front.cross(self.up)).scale(spd));
        }
        if (self.window.getKey(.e) == .press) {
            self.pos.y += spd;
        } else if (self.window.getKey(.q) == .press) {
            self.pos.y -= spd;
        }
    }

    pub fn getViewMatrix(self: FlyCamera) Mat4 {
        return Mat4.createLookAt(self.pos, self.pos.add(self.front), self.up);
    }
};

const AllocatedImage = struct {
    image: vk.Image,
    allocation: vma.VmaAllocation,

    pub fn deinit(self: AllocatedImage, vk_allocator: vma.VmaAllocator) void {
        vma.vmaDestroyImage(vk_allocator, self.image, self.allocation);
    }
};

const Material = struct {
    pipeline: vk.Pipeline,
    pipeline_layout: vk.PipelineLayout,

    pub fn init(pipeline: vk.Pipeline, pipeline_layout: vk.PipelineLayout) Material {
        return .{
            .pipeline = pipeline,
            .pipeline_layout = pipeline_layout,
        };
    }
};

const RenderObject = struct {
    mesh: *Mesh,
    material: *Material,
    transform_matrix: Mat4,
};

var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = general_purpose_allocator.allocator();

const depth_format = vk.Format.d32_sfloat;

const MeshPushConstants = struct {
    data: Vec4 = .{},
    render_matrix: Mat4,
};

pub const EngineChap3s = struct {
    const Self = @This();

    allocator: Allocator,
    window: glfw.Window,
    gc: *GraphicsContext,
    vk_allocator: vma.VmaAllocator,
    swapchain: Swapchain,
    render_pass: vk.RenderPass,
    framebuffers: []vk.Framebuffer,
    pool: vk.CommandPool,
    main_cmd_buffer: vk.CommandBuffer,
    frame_num: f32 = 0,
    dt: f64 = 0.0,
    last_frame_time: f64 = 0.0,
    depth_image: AllocatedImage,
    depth_image_view: vk.ImageView,
    renderables: std.ArrayList(RenderObject),
    materials: std.StringHashMap(Material),
    meshes: std.StringHashMap(Mesh),
    camera: FlyCamera,

    pub fn init(app_name: [*:0]const u8) !Self {
        try glfw.init(.{});

        var extent = vk.Extent2D{ .width = 800, .height = 600 };
        const window = try glfw.Window.create(extent.width, extent.height, app_name, null, null, .{
            .client_api = .no_api,
        });

        var gc = try gpa.create(GraphicsContext);
        gc.* = try GraphicsContext.init(gpa, app_name, window, true);

        // initialize the memory allocator
        var allocator_info = std.mem.zeroInit(vma.VmaAllocatorCreateInfo, .{
            .physicalDevice = gc.pdev,
            .device = gc.dev,
            .pVulkanFunctions = &std.mem.zeroInit(vma.VmaVulkanFunctions, .{
                .vkGetInstanceProcAddr = gc.vkb.dispatch.vkGetInstanceProcAddr,
                .vkGetDeviceProcAddr = gc.vki.dispatch.vkGetDeviceProcAddr,
            }),
            .instance = gc.instance,
            .vulkanApiVersion = vk.API_VERSION_1_2,
        });

        var vk_allocator: vma.VmaAllocator = undefined;
        const alloc_res = vma.vmaCreateAllocator(&allocator_info, &vk_allocator);
        std.debug.assert(alloc_res == vk.Result.success);

        // swapchain
        var swapchain = try Swapchain.init(gc, gpa, extent);
        const render_pass = try createRenderPass(gc, swapchain);

        // depth image
        var depth_image: AllocatedImage = undefined;
        const depth_extent = vk.Extent3D{ .width = swapchain.extent.width, .height = swapchain.extent.height, .depth = 1 };
        const dimg_info = vkinit.imageCreateInfo(depth_format, depth_extent, .{ .depth_stencil_attachment_bit = true });

        // we want to allocate it from GPU local memory
        const mem_prop_bits = vk.MemoryPropertyFlags{ .device_local_bit = true };
        var vma_malloc_info = std.mem.zeroInit(vma.VmaAllocationCreateInfo, .{
            .usage = vma.VMA_MEMORY_USAGE_GPU_ONLY,
            .flags = mem_prop_bits.toInt(),
        });
        const res = vma.vmaCreateImage(vk_allocator, &dimg_info, &vma_malloc_info, &depth_image.image, &depth_image.allocation, null);
        std.debug.assert(res == .success);

        const dview_info = vkinit.imageViewCreateInfo(depth_format, depth_image.image, .{ .depth_bit = true });
        var depth_image_view = try gc.vkd.createImageView(gc.dev, &dview_info, null);

        const framebuffers = try createFramebuffers(gc, gpa, render_pass, swapchain, depth_image_view);

        const pool = try gc.vkd.createCommandPool(gc.dev, &.{
            .flags = .{ .reset_command_buffer_bit = true },
            .queue_family_index = gc.graphics_queue.family,
        }, null);

        var main_cmd_buffer: vk.CommandBuffer = undefined;
        try gc.vkd.allocateCommandBuffers(gc.dev, &.{
            .command_pool = pool,
            .level = .primary,
            .command_buffer_count = 1,
        }, @ptrCast([*]vk.CommandBuffer, &main_cmd_buffer));

        return Self{
            .allocator = gpa,
            .window = window,
            .gc = gc,
            .vk_allocator = vk_allocator,
            .swapchain = swapchain,
            .render_pass = render_pass,
            .framebuffers = framebuffers,
            .pool = pool,
            .main_cmd_buffer = main_cmd_buffer,
            .depth_image = depth_image,
            .depth_image_view = depth_image_view,
            .renderables = std.ArrayList(RenderObject).init(gpa),
            .materials = std.StringHashMap(Material).init(gpa),
            .meshes = std.StringHashMap(Mesh).init(gpa),
            .camera = FlyCamera.init(window),
        };
    }

    pub fn deinit(self: *Self) void {
        try self.swapchain.waitForAllFences();

        self.depth_image.deinit(self.vk_allocator);
        self.gc.vkd.destroyImageView(self.gc.dev, self.depth_image_view, null);

        var iter = self.meshes.valueIterator();
        while (iter.next()) |mesh| mesh.*.deinit(self.vk_allocator);
        vma.vmaDestroyAllocator(self.vk_allocator);

        self.gc.vkd.freeCommandBuffers(self.gc.dev, self.pool, 1, @ptrCast([*]vk.CommandBuffer, &self.main_cmd_buffer));
        self.gc.vkd.destroyCommandPool(self.gc.dev, self.pool, null);

        for (self.framebuffers) |fb| self.gc.vkd.destroyFramebuffer(self.gc.dev, fb, null);
        self.allocator.free(self.framebuffers);

        var mat_iter = self.materials.valueIterator();
        while (mat_iter.next()) |mat| {
            self.gc.vkd.destroyPipeline(self.gc.dev, mat.pipeline, null);
            self.gc.vkd.destroyPipelineLayout(self.gc.dev, mat.pipeline_layout, null);
        }
        self.gc.vkd.destroyRenderPass(self.gc.dev, self.render_pass, null);

        self.swapchain.deinit();

        self.gc.deinit();
        self.allocator.destroy(self.gc);

        self.window.destroy();
        glfw.terminate();

        self.renderables.deinit();
        self.materials.deinit();
        self.meshes.deinit();
    }

    pub fn loadContent(self: *Self) !void {
        try self.loadMeshes();
        try self.initPipelines();
        try self.initScene();
    }

    pub fn run(self: *Self) !void {
        while (!self.window.shouldClose()) {
            var curr_frame_time = glfw.getTime();
            self.dt = curr_frame_time - self.last_frame_time;
            self.last_frame_time = curr_frame_time;

            self.camera.update(self.dt);

            // we only have one CommandBuffer so just wait on all the swapchain images
            try self.swapchain.waitForAllFences();
            try self.draw(self.framebuffers[self.swapchain.image_index]);

            const state = self.swapchain.present(self.main_cmd_buffer) catch |err| switch (err) {
                error.OutOfDateKHR => Swapchain.PresentState.suboptimal,
                else => |narrow| return narrow,
            };

            if (state == .suboptimal) {
                const size = try self.window.getSize();
                var extent = vk.Extent2D{ .width = size.width, .height = size.height };
                try self.swapchain.recreate(extent);

                for (self.framebuffers) |fb| self.gc.vkd.destroyFramebuffer(self.gc.dev, fb, null);
                self.allocator.free(self.framebuffers);

                self.depth_image.deinit(self.vk_allocator);
                self.gc.vkd.destroyImageView(self.gc.dev, self.depth_image_view, null);

                const depth_extent = vk.Extent3D{ .width = self.swapchain.extent.width, .height = self.swapchain.extent.height, .depth = 1 };
                const dimg_info = vkinit.imageCreateInfo(depth_format, depth_extent, .{ .depth_stencil_attachment_bit = true });

                // we want to allocate it from GPU local memory
                const mem_prop_bits = vk.MemoryPropertyFlags{ .device_local_bit = true };
                var vma_malloc_info = std.mem.zeroInit(vma.VmaAllocationCreateInfo, .{
                    .usage = vma.VMA_MEMORY_USAGE_GPU_ONLY,
                    .flags = mem_prop_bits.toInt(),
                });
                const res = vma.vmaCreateImage(self.vk_allocator, &dimg_info, &vma_malloc_info, &self.depth_image.image, &self.depth_image.allocation, null);
                std.debug.assert(res == .success);

                const dview_info = vkinit.imageViewCreateInfo(depth_format, self.depth_image.image, .{ .depth_bit = true });
                self.depth_image_view = try self.gc.vkd.createImageView(self.gc.dev, &dview_info, null);
                self.framebuffers = try createFramebuffers(self.gc, self.allocator, self.render_pass, self.swapchain, self.depth_image_view);
            }

            self.frame_num += 1;
            try glfw.pollEvents();
        }
    }

    fn loadMeshes(self: *Self) !void {
        var tri_mesh = Mesh.init(gpa);
        try tri_mesh.vertices.append(.{ .position = .{ 1, 1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0, 1, 0 } });
        try tri_mesh.vertices.append(.{ .position = .{ -1, 1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0, 1, 0 } });
        try tri_mesh.vertices.append(.{ .position = .{ 0, -1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0, 1, 0 } });

        var monkey_mesh = Mesh.initFromObj(gpa, "src/chapters/monkey_smooth.obj");
        var cube_thing_mesh = Mesh.initFromObj(gpa, "src/chapters/cube_thing.obj");

        uploadMesh(&tri_mesh, self.vk_allocator);
        uploadMesh(&monkey_mesh, self.vk_allocator);
        uploadMesh(&cube_thing_mesh, self.vk_allocator);

        try self.meshes.put("triangle", tri_mesh);
        try self.meshes.put("monkey", monkey_mesh);
        try self.meshes.put("cube_thing", cube_thing_mesh);
    }

    fn initPipelines(self: *Self) !void {
        var push_constant = vk.PushConstantRange{
            .stage_flags = .{ .vertex_bit = true },
            .offset = 0,
            .size = @sizeOf(MeshPushConstants),
        };

        var pip_layout_info = vkinit.pipelineLayoutCreateInfo();
        pip_layout_info.push_constant_range_count = 1;
        pip_layout_info.p_push_constant_ranges = @ptrCast([*]const vk.PushConstantRange, &push_constant);

        const pipeline_layout = try self.gc.vkd.createPipelineLayout(self.gc.dev, &pip_layout_info, null);
        const pipeline = try createPipeline(self.gc, self.allocator, self.render_pass, pipeline_layout, resources.colored_tri_frag);
        const material = Material{
            .pipeline = pipeline,
            .pipeline_layout = pipeline_layout,
        };
        try self.materials.put("defaultmesh", material);

        const pipeline_layout2 = try self.gc.vkd.createPipelineLayout(self.gc.dev, &pip_layout_info, null);
        const pipeline2 = try createPipeline(self.gc, self.allocator, self.render_pass, pipeline_layout2, resources.tri_frag);
        const material2 = Material{
            .pipeline = pipeline2,
            .pipeline_layout = pipeline_layout2,
        };
        try self.materials.put("redmesh", material2);
    }

    fn initScene(self: *Self) !void {
        var monkey = RenderObject{
            .mesh = self.meshes.getPtr("monkey").?,
            .material = self.materials.getPtr("defaultmesh").?,
            .transform_matrix = Mat4.identity,
        };
        try self.renderables.append(monkey);

        var x: f32 = 0;
        while (x < 20) : (x += 1) {
            var y: f32 = 0;
            while (y < 20) : (y += 1) {
                var matrix = Mat4.createTranslation(.{ .x = x, .y = 0, .z = y });
                var scale_matrix = Mat4.createScale(.{ .x = 0.2, .y = 0.2, .z = 0.2 });

                const mesh_material = if (@mod(x, 2) == 0) self.materials.getPtr("defaultmesh").? else self.materials.getPtr("redmesh").?;
                const mesh = if (@mod(x, 2) == 0 and @mod(x, 6) == 0) self.meshes.getPtr("cube_thing").? else self.meshes.getPtr("triangle").?;
                var object = RenderObject{
                    .mesh = mesh,
                    .material = mesh_material,
                    .transform_matrix = Mat4.mul(matrix, scale_matrix),
                };
                try self.renderables.append(object);

                matrix = Mat4.createTranslation(.{ .x = x, .y = 0.8, .z = y });
                scale_matrix = Mat4.createScale(.{ .x = 0.1, .y = 0.1, .z = 0.1 });

                object = RenderObject{
                    .mesh = mesh,
                    .material = mesh_material,
                    .transform_matrix = Mat4.mul(matrix, scale_matrix),
                };
                try self.renderables.append(object);
            }
        }
    }

    fn draw(self: *Self, framebuffer: vk.Framebuffer) !void {
        const clear = vk.ClearValue{
            .color = .{ .float_32 = .{ 0.6, 0.5, 0, 1 } },
        };

        const depth_clear = vk.ClearValue{
            .depth_stencil = .{ .depth = 1, .stencil = 0 },
        };

        const clear_values = [_]vk.ClearValue{ clear, depth_clear };

        // This needs to be a separate definition - see https://github.com/ziglang/zig/issues/7627.
        const render_area = vk.Rect2D{
            .offset = .{ .x = 0, .y = 0 },
            .extent = self.swapchain.extent,
        };

        const viewport = vk.Viewport{
            .x = 0,
            .y = 0,
            .width = @intToFloat(f32, self.swapchain.extent.width),
            .height = @intToFloat(f32, self.swapchain.extent.height),
            .min_depth = 0,
            .max_depth = 1,
        };

        try self.gc.vkd.resetCommandBuffer(self.main_cmd_buffer, .{});
        try self.gc.vkd.beginCommandBuffer(self.main_cmd_buffer, &.{
            .flags = .{ .one_time_submit_bit = true },
            .p_inheritance_info = null,
        });

        self.gc.vkd.cmdSetViewport(self.main_cmd_buffer, 0, 1, @ptrCast([*]const vk.Viewport, &viewport));
        self.gc.vkd.cmdSetScissor(self.main_cmd_buffer, 0, 1, @ptrCast([*]const vk.Rect2D, &render_area));

        self.gc.vkd.cmdBeginRenderPass(self.main_cmd_buffer, &.{
            .render_pass = self.render_pass,
            .framebuffer = framebuffer,
            .render_area = render_area,
            .clear_value_count = clear_values.len,
            .p_clear_values = @ptrCast([*]const vk.ClearValue, &clear_values),
        }, .@"inline");
        try self.drawRenderObjects();
        self.gc.vkd.cmdEndRenderPass(self.main_cmd_buffer);
        try self.gc.vkd.endCommandBuffer(self.main_cmd_buffer);
    }

    fn drawRenderObjects(self: Self) !void {
        var view = self.camera.getViewMatrix();
        var proj = Mat4.createPerspective(toRadians(70.0), @intToFloat(f32, self.swapchain.extent.width) / @intToFloat(f32, self.swapchain.extent.height), 0.1, 200);
        proj.fields[1][1] *= -1;
        var view_proj = Mat4.mul(proj, view);

        var last_mesh: *Mesh = @intToPtr(*Mesh, @ptrToInt(&self));
        var last_material: *Material = @intToPtr(*Material, @ptrToInt(&self));

        for (self.renderables.items) |*object| {
            // only bind the pipeline if it doesnt match with the already bound one
            if (object.material != last_material) {
                last_material = object.material;
                self.gc.vkd.cmdBindPipeline(self.main_cmd_buffer, .graphics, object.material.pipeline);
            }

            var model = object.transform_matrix;
            var rot = Mat4.createAngleAxis(.{ .y = 1 }, toRadians(25.0) * self.frame_num * 0.04);
            model = model.mul(rot);
            var mvp = Mat4.mul(view_proj, model);

            var constants = MeshPushConstants{
                .render_matrix = mvp,
            };
            self.gc.vkd.cmdPushConstants(self.main_cmd_buffer, object.material.pipeline_layout, .{ .vertex_bit = true }, 0, @sizeOf(MeshPushConstants), &constants);

            // only bind the mesh if its a different one from last bind
            if (object.mesh != last_mesh) {
                last_mesh = object.mesh;
                // bind the mesh vertex buffer with offset 0
                var offset: vk.DeviceSize = 0;
                self.gc.vkd.cmdBindVertexBuffers(self.main_cmd_buffer, 0, 1, @ptrCast([*]const vk.Buffer, &object.mesh.vert_buffer.buffer), @ptrCast([*]const vk.DeviceSize, &offset));
            }

            self.gc.vkd.cmdDraw(self.main_cmd_buffer, @intCast(u32, object.mesh.vertices.items.len), 1, 0, 0);
        }
    }
};

fn createRenderPass(gc: *const GraphicsContext, swapchain: Swapchain) !vk.RenderPass {
    const color_attachment = vk.AttachmentDescription{
        .flags = .{},
        .format = swapchain.surface_format.format,
        .samples = .{ .@"1_bit" = true },
        .load_op = .clear,
        .store_op = .store,
        .stencil_load_op = .dont_care,
        .stencil_store_op = .dont_care,
        .initial_layout = .@"undefined",
        .final_layout = .present_src_khr,
    };

    const color_attachment_ref = vk.AttachmentReference{
        .attachment = 0,
        .layout = .color_attachment_optimal,
    };

    const depth_attachment = vk.AttachmentDescription{
        .flags = .{},
        .format = depth_format,
        .samples = .{ .@"1_bit" = true },
        .load_op = .clear,
        .store_op = .store,
        .stencil_load_op = .clear,
        .stencil_store_op = .dont_care,
        .initial_layout = .@"undefined",
        .final_layout = .depth_stencil_attachment_optimal,
    };

    const depth_attachment_ref = vk.AttachmentReference{
        .attachment = 1,
        .layout = .depth_stencil_attachment_optimal,
    };

    const subpass = vk.SubpassDescription{
        .flags = .{},
        .pipeline_bind_point = .graphics,
        .input_attachment_count = 0,
        .p_input_attachments = undefined,
        .color_attachment_count = 1,
        .p_color_attachments = @ptrCast([*]const vk.AttachmentReference, &color_attachment_ref),
        .p_resolve_attachments = null,
        .p_depth_stencil_attachment = &depth_attachment_ref,
        .preserve_attachment_count = 0,
        .p_preserve_attachments = undefined,
    };

    const dependency = vk.SubpassDependency{
        .src_subpass = vk.SUBPASS_EXTERNAL,
        .dst_subpass = 0,
        .src_stage_mask = .{
            .color_attachment_output_bit = true,
        },
        .src_access_mask = .{},
        .dst_stage_mask = .{
            .color_attachment_output_bit = true,
        },
        .dst_access_mask = .{
            .color_attachment_write_bit = true,
        },
        .dependency_flags = .{},
    };

    const depth_dependency = vk.SubpassDependency{
        .src_subpass = vk.SUBPASS_EXTERNAL,
        .dst_subpass = 0,
        .src_stage_mask = .{
            .early_fragment_tests_bit = true,
            .late_fragment_tests_bit = true,
        },
        .src_access_mask = .{},
        .dst_stage_mask = .{
            .early_fragment_tests_bit = true,
            .late_fragment_tests_bit = true,
        },
        .dst_access_mask = .{
            .depth_stencil_attachment_write_bit = true,
        },
        .dependency_flags = .{},
    };

    var attachments: [2]vk.AttachmentDescription = [_]vk.AttachmentDescription{ color_attachment, depth_attachment };
    var dependencies: [2]vk.SubpassDependency = [_]vk.SubpassDependency{ dependency, depth_dependency };
    return try gc.vkd.createRenderPass(gc.dev, &.{
        .flags = .{},
        .attachment_count = 2,
        .p_attachments = @ptrCast([*]const vk.AttachmentDescription, &attachments),
        .subpass_count = 1,
        .p_subpasses = @ptrCast([*]const vk.SubpassDescription, &subpass),
        .dependency_count = 1,
        .p_dependencies = @ptrCast([*]const vk.SubpassDependency, &dependencies),
    }, null);
}

fn createFramebuffers(gc: *const GraphicsContext, allocator: Allocator, render_pass: vk.RenderPass, swapchain: Swapchain, depth_image_view: vk.ImageView) ![]vk.Framebuffer {
    const framebuffers = try allocator.alloc(vk.Framebuffer, swapchain.swap_images.len);
    errdefer allocator.free(framebuffers);

    var i: usize = 0;
    errdefer for (framebuffers[0..i]) |fb| gc.vkd.destroyFramebuffer(gc.dev, fb, null);

    for (framebuffers) |*fb| {
        var attachments = [2]vk.ImageView{ swapchain.swap_images[i].view, depth_image_view };
        fb.* = try gc.vkd.createFramebuffer(gc.dev, &.{
            .flags = .{},
            .render_pass = render_pass,
            .attachment_count = 2,
            .p_attachments = @ptrCast([*]const vk.ImageView, &attachments),
            .width = swapchain.extent.width,
            .height = swapchain.extent.height,
            .layers = 1,
        }, null);
        i += 1;
    }

    return framebuffers;
}

fn createShaderModule(gc: *const GraphicsContext, data: [*]const u32, len: usize) !vk.ShaderModule {
    return try gc.vkd.createShaderModule(gc.dev, &.{
        .flags = .{},
        .code_size = len,
        .p_code = data,
    }, null);
}

fn createShaderStageCreateInfo(shader_module: vk.ShaderModule, stage: vk.ShaderStageFlags) vk.PipelineShaderStageCreateInfo {
    return .{
        .flags = .{},
        .stage = stage,
        .module = shader_module,
        .p_name = "main",
        .p_specialization_info = null,
    };
}

fn createPipeline(
    gc: *const GraphicsContext,
    allocator: std.mem.Allocator,
    render_pass: vk.RenderPass,
    pipeline_layout: vk.PipelineLayout,
    frag_shader_bytes: [:0]const u8,
) !vk.Pipeline {
    const vert = try createShaderModule(gc, @ptrCast([*]const u32, resources.tri_mesh_pushconstants_vert), resources.tri_mesh_pushconstants_vert.len);
    const frag = try createShaderModule(gc, @ptrCast([*]const u32, @alignCast(@alignOf(u32), frag_shader_bytes)), frag_shader_bytes.len);

    defer gc.vkd.destroyShaderModule(gc.dev, vert, null);
    defer gc.vkd.destroyShaderModule(gc.dev, frag, null);

    var builder = PipelineBuilder.init(allocator, pipeline_layout);
    builder.depth_stencil = vkinit.pipelineDepthStencilCreateInfo(true, true, .less_or_equal);

    builder.vertex_input_info.vertex_attribute_description_count = Vertex.attribute_description.len;
    builder.vertex_input_info.p_vertex_attribute_descriptions = &Vertex.attribute_description;
    builder.vertex_input_info.vertex_binding_description_count = 1;
    builder.vertex_input_info.p_vertex_binding_descriptions = @ptrCast([*]const vk.VertexInputBindingDescription, &Vertex.binding_description);

    try builder.addShaderStage(createShaderStageCreateInfo(vert, .{ .vertex_bit = true }));
    try builder.addShaderStage(createShaderStageCreateInfo(frag, .{ .fragment_bit = true }));
    return try builder.build(gc, render_pass);
}

fn uploadMesh(mesh: *Mesh, allocator: vma.VmaAllocator) void {
    // allocate vertex buffer
    var buffer_info = std.mem.zeroInit(vk.BufferCreateInfo, .{
        .flags = .{},
        .size = mesh.vertices.items.len * @sizeOf(Vertex),
        .usage = .{ .vertex_buffer_bit = true, .transfer_dst_bit = true },
    });

    // let the VMA library know that this data should be writeable by CPU, but also readable by GPU
    var vma_malloc_info = std.mem.zeroes(vma.VmaAllocationCreateInfo);
    vma_malloc_info.usage = vma.VMA_MEMORY_USAGE_AUTO_PREFER_DEVICE;
    vma_malloc_info.requiredFlags = .{ .host_visible_bit = true, .host_coherent_bit = true };
    vma_malloc_info.flags = vma.VMA_ALLOCATION_CREATE_DEDICATED_MEMORY_BIT | vma.VMA_ALLOCATION_CREATE_HOST_ACCESS_SEQUENTIAL_WRITE_BIT;

    // allocate the buffer
    var res = vma.vmaCreateBuffer(
        allocator,
        &buffer_info,
        &vma_malloc_info,
        &mesh.vert_buffer.buffer,
        &mesh.vert_buffer.allocation,
        null,
    );
    std.debug.assert(res == vk.Result.success);

    // copy vertex data
    var data: *anyopaque = undefined;
    res = vma.vmaMapMemory(allocator, mesh.vert_buffer.allocation, @ptrCast([*c]?*anyopaque, &data));
    std.debug.assert(res == vk.Result.success);

    const gpu_vertices = @ptrCast([*]Vertex, @alignCast(@alignOf(Vertex), data));
    std.mem.copy(Vertex, gpu_vertices[0..mesh.vertices.items.len], mesh.vertices.items);

    vma.vmaUnmapMemory(allocator, mesh.vert_buffer.allocation);
}
