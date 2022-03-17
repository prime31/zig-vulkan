const std = @import("std");
const vk = @import("vulkan");
const vkmem = @import("../vk_mem_alloc.zig");
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

pub const AllocatedImage = struct {
    image: vk.Image,
    allocation: vkmem.VmaAllocation,

    pub fn deinit(self: AllocatedImage, vk_allocator: vkmem.VmaAllocator) void {
        vkmem.vmaDestroyImage(vk_allocator, self.image, self.allocation);
    }
};

var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = general_purpose_allocator.allocator();

const depth_format = vk.Format.d32_sfloat;

const MeshPushConstants = struct {
    data: Vec4 = .{},
    render_matrix: Mat4,
};

pub const EngineChap3 = struct {
    const Self = @This();

    allocator: Allocator,
    window: glfw.Window,
    gc: *GraphicsContext,
    vk_allocator: vkmem.VmaAllocator,
    swapchain: Swapchain,
    render_pass: vk.RenderPass,
    framebuffers: []vk.Framebuffer,
    pool: vk.CommandPool,
    main_cmd_buffer: vk.CommandBuffer,
    pipeline_layout: vk.PipelineLayout,
    mesh_pipeline: vk.Pipeline,
    triangle_mesh: Mesh,
    frame_num: f32 = 0,
    depth_image: AllocatedImage,
    depth_image_view: vk.ImageView,

    pub fn init(app_name: [*:0]const u8) !Self {
        try glfw.init(.{});

        var extent = vk.Extent2D{ .width = 800, .height = 600 };
        const window = try glfw.Window.create(extent.width, extent.height, app_name, null, null, .{
            .client_api = .no_api,
        });

        var gc = try gpa.create(GraphicsContext);
        gc.* = try GraphicsContext.init(gpa, app_name, window, true);

        // initialize the memory allocator
        var allocator_info = std.mem.zeroInit(vkmem.VmaAllocatorCreateInfo, .{
            .physicalDevice = gc.pdev,
            .device = gc.dev,
            .pVulkanFunctions = &std.mem.zeroInit(vkmem.VmaVulkanFunctions, .{
                .vkGetInstanceProcAddr = gc.vkb.dispatch.vkGetInstanceProcAddr,
                .vkGetDeviceProcAddr = gc.vki.dispatch.vkGetDeviceProcAddr,
            }),
            .instance = gc.instance,
            .vulkanApiVersion = vk.API_VERSION_1_2,
        });

        var vk_allocator: vkmem.VmaAllocator = undefined;
        const alloc_res = vkmem.vmaCreateAllocator(&allocator_info, &vk_allocator);
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
        var vma_malloc_info = std.mem.zeroInit(vkmem.VmaAllocationCreateInfo, .{
            .usage = vkmem.VMA_MEMORY_USAGE_GPU_ONLY,
            .flags = mem_prop_bits.toInt(),
        });
        const res = vkmem.vmaCreateImage(vk_allocator, &dimg_info, &vma_malloc_info, &depth_image.image, &depth_image.allocation, null);
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

        var push_constant = vk.PushConstantRange{
            .stage_flags = .{ .vertex_bit = true },
            .offset = 0,
            .size = @sizeOf(MeshPushConstants),
        };

        var pip_layout_info = vkinit.pipelineLayoutCreateInfo();
        pip_layout_info.push_constant_range_count = 1;
        pip_layout_info.p_push_constant_ranges = @ptrCast([*]const vk.PushConstantRange, &push_constant);

        const pipeline_layout = try gc.vkd.createPipelineLayout(gc.dev, &pip_layout_info, null);
        const pipeline = try createPipeline(gc, gpa, swapchain.extent, render_pass, pipeline_layout);

        var mesh = try loadMeshes();
        uploadMesh(&mesh, vk_allocator);
        // try uploadMeshNonVma(gc, pool, &mesh);

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
            .pipeline_layout = pipeline_layout,
            .mesh_pipeline = pipeline,
            .triangle_mesh = mesh,
            .depth_image = depth_image,
            .depth_image_view = depth_image_view,
        };
    }

    pub fn deinit(self: *Self) void {
        try self.swapchain.waitForAllFences();

        self.depth_image.deinit(self.vk_allocator);
        self.gc.vkd.destroyImageView(self.gc.dev, self.depth_image_view, null);
        self.triangle_mesh.deinit(self.vk_allocator, self.gc);
        vkmem.vmaDestroyAllocator(self.vk_allocator);

        self.gc.vkd.freeCommandBuffers(self.gc.dev, self.pool, 1, @ptrCast([*]vk.CommandBuffer, &self.main_cmd_buffer));
        self.gc.vkd.destroyCommandPool(self.gc.dev, self.pool, null);

        for (self.framebuffers) |fb| self.gc.vkd.destroyFramebuffer(self.gc.dev, fb, null);
        self.allocator.free(self.framebuffers);

        self.gc.vkd.destroyPipeline(self.gc.dev, self.mesh_pipeline, null);
        self.gc.vkd.destroyRenderPass(self.gc.dev, self.render_pass, null);
        self.gc.vkd.destroyPipelineLayout(self.gc.dev, self.pipeline_layout, null);

        self.swapchain.deinit();

        self.gc.deinit();
        self.allocator.destroy(self.gc);

        self.window.destroy();
        glfw.terminate();
    }

    pub fn run(self: *Self) !void {
        while (!self.window.shouldClose()) {
            // we only have one CommandBuffer so just wait on all the swapchain images
            try self.swapchain.waitForAllFences();
            try recordCommandBuffer(self.main_cmd_buffer, self.gc, self.swapchain.extent, self.render_pass, self.framebuffers[self.swapchain.image_index], self.mesh_pipeline, self.triangle_mesh, self.pipeline_layout, self.frame_num);

            const state = self.swapchain.present(self.main_cmd_buffer) catch |err| switch (err) {
                error.OutOfDateKHR => Swapchain.PresentState.suboptimal,
                else => |narrow| return narrow,
            };

            if (state == .suboptimal) {
                const size = try self.window.getSize();
                var extent = vk.Extent2D{ .width = @intCast(u32, size.width), .height = @intCast(u32, size.height) };
                try self.swapchain.recreate(extent);

                for (self.framebuffers) |fb| self.gc.vkd.destroyFramebuffer(self.gc.dev, fb, null);
                self.allocator.free(self.framebuffers);
                self.framebuffers = try createFramebuffers(self.gc, self.allocator, self.render_pass, self.swapchain, self.depth_image_view);
            }

            self.frame_num += 1;
            try glfw.pollEvents();
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
    extent: vk.Extent2D,
    render_pass: vk.RenderPass,
    pipeline_layout: vk.PipelineLayout,
) !vk.Pipeline {
    const vert = try createShaderModule(gc, @ptrCast([*]const u32, resources.tri_mesh_vert), resources.tri_mesh_vert.len);
    const frag = try createShaderModule(gc, @ptrCast([*]const u32, resources.colored_tri_frag), resources.colored_tri_frag.len);

    defer gc.vkd.destroyShaderModule(gc.dev, vert, null);
    defer gc.vkd.destroyShaderModule(gc.dev, frag, null);

    var builder = PipelineBuilder.init(allocator, extent, pipeline_layout);
    builder.depth_stencil = vkinit.pipelineDepthStencilCreateInfo(true, true, .less_or_equal);

    builder.vertex_input_info.vertex_attribute_description_count = Vertex.attribute_description.len;
    builder.vertex_input_info.p_vertex_attribute_descriptions = &Vertex.attribute_description;
    builder.vertex_input_info.vertex_binding_description_count = 1;
    builder.vertex_input_info.p_vertex_binding_descriptions = @ptrCast([*]const vk.VertexInputBindingDescription, &Vertex.binding_description);

    try builder.addShaderStage(createShaderStageCreateInfo(vert, .{ .vertex_bit = true }));
    try builder.addShaderStage(createShaderStageCreateInfo(frag, .{ .fragment_bit = true }));
    return try builder.build(gc, render_pass);
}

fn loadMeshes() !Mesh {
    var mesh = Mesh.initFromObj(gpa, "src/chapters/monkey_smooth.obj");

    // vertex positions
    // try mesh.vertices.append(.{ .position = .{ 1, 1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0, 1, 0 } });
    // try mesh.vertices.append(.{ .position = .{ -1, 1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0, 1, 0 } });
    // try mesh.vertices.append(.{ .position = .{ 0, -1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0, 1, 0 } });

    return mesh;
}

fn uploadMesh(mesh: *Mesh, allocator: vkmem.VmaAllocator) void {
    // allocate vertex buffer
    var buffer_info = std.mem.zeroInit(vk.BufferCreateInfo, .{
        .flags = .{},
        .size = mesh.vertices.items.len * @sizeOf(Vertex),
        .usage = .{ .vertex_buffer_bit = true },
    });

    // let the VMA library know that this data should be writeable by CPU, but also readable by GPU
    var vma_malloc_info = std.mem.zeroes(vkmem.VmaAllocationCreateInfo);
    vma_malloc_info.usage = vkmem.VMA_MEMORY_USAGE_CPU_TO_GPU;

    // allocate the buffer
    var allocation: vkmem.VmaAllocation = undefined;
    var res = vkmem.vmaCreateBuffer(
        allocator,
        &buffer_info,
        &vma_malloc_info,
        &mesh.vert_buffer.buffer,
        &allocation,
        null,
    );
    std.debug.assert(res == vk.Result.success);
    mesh.vert_buffer.allocation = allocation;

    // copy vertex data
    var data: *anyopaque = undefined;
    res = vkmem.vmaMapMemory(allocator, mesh.vert_buffer.allocation.?, @ptrCast([*c]?*anyopaque, &data));
    std.debug.assert(res == vk.Result.success);

    const gpu_vertices = @ptrCast([*]Vertex, @alignCast(@alignOf(Vertex), data));
    std.mem.copy(Vertex, gpu_vertices[0..mesh.vertices.items.len], mesh.vertices.items);
    vkmem.vmaUnmapMemory(allocator, mesh.vert_buffer.allocation.?);
}

fn recordCommandBuffer(
    cmdbuf: vk.CommandBuffer,
    gc: *const GraphicsContext,
    extent: vk.Extent2D,
    render_pass: vk.RenderPass,
    framebuffer: vk.Framebuffer,
    pipeline: vk.Pipeline,
    mesh: Mesh,
    pipeline_layout: vk.PipelineLayout,
    frame_num: f32,
) !void {
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
        .extent = extent,
    };

    // push constants
    var cam_pos = Vec3{ .z = -3 };
    var view = Mat4.createLookAt(cam_pos, Vec3.new(0.0, 0.0, 0.0), Vec3.new(0.0, 1.0, 0.0));
    var proj = Mat4.createPerspective(70 * 0.0174533, 1600 / 1200, 0.1, 200);
    proj.fields[1][1] *= -1;
    var view_proj = Mat4.mul(proj, view);

    var model = Mat4.createAngleAxis(.{ .y = 1 }, 25 * 0.0174533 * frame_num * 0.04);
    var mvp = Mat4.mul(view_proj, model);

    var constants = MeshPushConstants{
        .render_matrix = mvp,
    };

    try gc.vkd.resetCommandBuffer(cmdbuf, .{});
    try gc.vkd.beginCommandBuffer(cmdbuf, &.{
        .flags = .{ .one_time_submit_bit = true },
        .p_inheritance_info = null,
    });

    gc.vkd.cmdBeginRenderPass(cmdbuf, &.{
        .render_pass = render_pass,
        .framebuffer = framebuffer,
        .render_area = render_area,
        .clear_value_count = clear_values.len,
        .p_clear_values = @ptrCast([*]const vk.ClearValue, &clear_values),
    }, .@"inline");
    gc.vkd.cmdBindPipeline(cmdbuf, .graphics, pipeline);

    // bind the mesh vertex buffer with offset 0
    var offset: vk.DeviceSize = 0;
    gc.vkd.cmdBindVertexBuffers(cmdbuf, 0, 1, @ptrCast([*]const vk.Buffer, &mesh.vert_buffer.buffer), @ptrCast([*]const vk.DeviceSize, &offset));

    gc.vkd.cmdPushConstants(cmdbuf, pipeline_layout, .{ .vertex_bit = true }, 0, @sizeOf(MeshPushConstants), &constants);
    gc.vkd.cmdDraw(cmdbuf, @intCast(u32, mesh.vertices.items.len), 1, 0, 0);

    gc.vkd.cmdEndRenderPass(cmdbuf);
    try gc.vkd.endCommandBuffer(cmdbuf);
}

fn uploadMeshNonVma(gc: *const GraphicsContext, pool: vk.CommandPool, mesh: *Mesh) !void {
    // allocate vertex buffer
    const vert_size = @sizeOf(Vertex) * mesh.vertices.items.len;

    mesh.vert_buffer.buffer = try gc.vkd.createBuffer(gc.dev, &.{
        .flags = .{},
        .size = vert_size,
        .usage = .{ .transfer_dst_bit = true, .vertex_buffer_bit = true },
        .sharing_mode = .exclusive,
        .queue_family_index_count = 0,
        .p_queue_family_indices = undefined,
    }, null);

    const mem_reqs = gc.vkd.getBufferMemoryRequirements(gc.dev, mesh.vert_buffer.buffer);
    mesh.vert_buffer.memory = try gc.allocate(mem_reqs, .{ .device_local_bit = true });

    try gc.vkd.bindBufferMemory(gc.dev, mesh.vert_buffer.buffer, mesh.vert_buffer.memory.?, 0);

    // perform the upload
    const staging_buffer = try gc.vkd.createBuffer(gc.dev, &.{
        .flags = .{},
        .size = vert_size,
        .usage = .{ .transfer_src_bit = true },
        .sharing_mode = .exclusive,
        .queue_family_index_count = 0,
        .p_queue_family_indices = undefined,
    }, null);
    defer gc.vkd.destroyBuffer(gc.dev, staging_buffer, null);

    const staging_mem_reqs = gc.vkd.getBufferMemoryRequirements(gc.dev, staging_buffer);
    const staging_memory = try gc.allocate(staging_mem_reqs, .{ .host_visible_bit = true, .host_coherent_bit = true });
    defer gc.vkd.freeMemory(gc.dev, staging_memory, null);
    try gc.vkd.bindBufferMemory(gc.dev, staging_buffer, staging_memory, 0);

    {
        const data = try gc.vkd.mapMemory(gc.dev, staging_memory, 0, vk.WHOLE_SIZE, .{});
        defer gc.vkd.unmapMemory(gc.dev, staging_memory);

        const gpu_vertices = @ptrCast([*]Vertex, @alignCast(@alignOf(Vertex), data));
        for (mesh.vertices.items) |vertex, i| {
            gpu_vertices[i] = vertex;
        }
    }

    try copyBuffer(gc, pool, mesh.vert_buffer.buffer, staging_buffer, vert_size);
}

fn copyBuffer(gc: *const GraphicsContext, pool: vk.CommandPool, dst: vk.Buffer, src: vk.Buffer, size: vk.DeviceSize) !void {
    var cmdbuf: vk.CommandBuffer = undefined;
    try gc.vkd.allocateCommandBuffers(gc.dev, &.{
        .command_pool = pool,
        .level = .primary,
        .command_buffer_count = 1,
    }, @ptrCast([*]vk.CommandBuffer, &cmdbuf));
    defer gc.vkd.freeCommandBuffers(gc.dev, pool, 1, @ptrCast([*]const vk.CommandBuffer, &cmdbuf));

    try gc.vkd.beginCommandBuffer(cmdbuf, &.{
        .flags = .{ .one_time_submit_bit = true },
        .p_inheritance_info = null,
    });

    const region = vk.BufferCopy{
        .src_offset = 0,
        .dst_offset = 0,
        .size = size,
    };
    gc.vkd.cmdCopyBuffer(cmdbuf, src, dst, 1, @ptrCast([*]const vk.BufferCopy, &region));

    try gc.vkd.endCommandBuffer(cmdbuf);

    const si = vk.SubmitInfo{
        .wait_semaphore_count = 0,
        .p_wait_semaphores = undefined,
        .p_wait_dst_stage_mask = undefined,
        .command_buffer_count = 1,
        .p_command_buffers = @ptrCast([*]const vk.CommandBuffer, &cmdbuf),
        .signal_semaphore_count = 0,
        .p_signal_semaphores = undefined,
    };
    try gc.vkd.queueSubmit(gc.graphics_queue.handle, 1, @ptrCast([*]const vk.SubmitInfo, &si), .null_handle);
    try gc.vkd.queueWaitIdle(gc.graphics_queue.handle);
}
