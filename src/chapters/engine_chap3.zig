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
    pipeline: vk.Pipeline,
    mesh_pipeline: vk.Pipeline,
    triangle_mesh: Mesh,

    pub fn init(app_name: [*:0]const u8) !Self {
        const allocator = std.heap.page_allocator;
        try glfw.init(.{});

        var extent = vk.Extent2D{ .width = 800, .height = 600 };
        const window = try glfw.Window.create(extent.width, extent.height, app_name, null, null, .{
            .client_api = .no_api,
        });

        var gc = try allocator.create(GraphicsContext);
        gc.* = try GraphicsContext.init(allocator, app_name, window, true);

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

        var swapchain = try Swapchain.init(gc, allocator, extent);
        const render_pass = try createRenderPass(gc, swapchain);
        const framebuffers = try createFramebuffers(gc, allocator, render_pass, swapchain);

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

        const pipeline_layout = try gc.vkd.createPipelineLayout(gc.dev, &vkinit.pipelineLayoutCreateInfo(), null);
        const pipeline = try createPipeline(gc, allocator, swapchain.extent, render_pass, pipeline_layout);

        var mesh = try loadMeshes();
        uploadMesh(&mesh, vk_allocator);

        return Self{
            .allocator = allocator,
            .window = window,
            .gc = gc,
            .vk_allocator = vk_allocator,
            .swapchain = swapchain,
            .render_pass = render_pass,
            .framebuffers = framebuffers,
            .pool = pool,
            .main_cmd_buffer = main_cmd_buffer,
            .pipeline_layout = pipeline_layout,
            .pipeline = pipeline,
            .mesh_pipeline = pipeline,
            .triangle_mesh = mesh,
        };
    }

    pub fn deinit(self: *Self) void {
        try self.swapchain.waitForAllFences();

        self.triangle_mesh.deinit(self.vk_allocator);
        vkmem.vmaDestroyAllocator(self.vk_allocator);

        self.gc.vkd.freeCommandBuffers(self.gc.dev, self.pool, 1, @ptrCast([*]vk.CommandBuffer, &self.main_cmd_buffer));
        self.gc.vkd.destroyCommandPool(self.gc.dev, self.pool, null);

        for (self.framebuffers) |fb| self.gc.vkd.destroyFramebuffer(self.gc.dev, fb, null);
        self.allocator.free(self.framebuffers);

        self.gc.vkd.destroyPipeline(self.gc.dev, self.pipeline, null);
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
            try recordCommandBuffer(self.main_cmd_buffer, self.gc, self.swapchain.extent, self.render_pass, self.framebuffers[self.swapchain.image_index], self.pipeline);

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
                self.framebuffers = try createFramebuffers(self.gc, self.allocator, self.render_pass, self.swapchain);
            }

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

    const subpass = vk.SubpassDescription{
        .flags = .{},
        .pipeline_bind_point = .graphics,
        .input_attachment_count = 0,
        .p_input_attachments = undefined,
        .color_attachment_count = 1,
        .p_color_attachments = @ptrCast([*]const vk.AttachmentReference, &color_attachment_ref),
        .p_resolve_attachments = null,
        .p_depth_stencil_attachment = null,
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

    return try gc.vkd.createRenderPass(gc.dev, &.{
        .flags = .{},
        .attachment_count = 1,
        .p_attachments = @ptrCast([*]const vk.AttachmentDescription, &color_attachment),
        .subpass_count = 1,
        .p_subpasses = @ptrCast([*]const vk.SubpassDescription, &subpass),
        .dependency_count = 1,
        .p_dependencies = @ptrCast([*]const vk.SubpassDependency, &dependency),
    }, null);
}

fn createFramebuffers(gc: *const GraphicsContext, allocator: Allocator, render_pass: vk.RenderPass, swapchain: Swapchain) ![]vk.Framebuffer {
    const framebuffers = try allocator.alloc(vk.Framebuffer, swapchain.swap_images.len);
    errdefer allocator.free(framebuffers);

    var i: usize = 0;
    errdefer for (framebuffers[0..i]) |fb| gc.vkd.destroyFramebuffer(gc.dev, fb, null);

    for (framebuffers) |*fb| {
        fb.* = try gc.vkd.createFramebuffer(gc.dev, &.{
            .flags = .{},
            .render_pass = render_pass,
            .attachment_count = 1,
            .p_attachments = @ptrCast([*]const vk.ImageView, &swapchain.swap_images[i].view),
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
    const vert = try createShaderModule(gc, @ptrCast([*]const u32, resources.tri_vert), resources.tri_vert.len);
    const frag = try createShaderModule(gc, @ptrCast([*]const u32, resources.tri_frag), resources.tri_frag.len);

    defer gc.vkd.destroyShaderModule(gc.dev, vert, null);
    defer gc.vkd.destroyShaderModule(gc.dev, frag, null);

    var builder = PipelineBuilder.init(allocator, extent, pipeline_layout);
    try builder.addShaderStage(createShaderStageCreateInfo(vert, .{ .vertex_bit = true }));
    try builder.addShaderStage(createShaderStageCreateInfo(frag, .{ .fragment_bit = true }));
    return try builder.build(gc, render_pass);
}

fn loadMeshes() !Mesh {
    var mesh = Mesh.init(std.heap.page_allocator);

    // vertex positions
    try mesh.vertices.append(.{ .position = .{ 1, 1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0, 1, 0 } });
    try mesh.vertices.append(.{ .position = .{ -1, 1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0, 1, 0 } });
    try mesh.vertices.append(.{ .position = .{ 0, -1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0, 1, 0 } });

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
    var res = vkmem.vmaCreateBuffer(
        allocator,
        &buffer_info,
        &vma_malloc_info,
        &mesh.vert_buffer.buffer,
        &mesh.vert_buffer.allocation,
        undefined,
    );
    std.debug.assert(res == vk.Result.success);

    // copy vertex data
    var data: ?*anyopaque = undefined;
    res = vkmem.vmaMapMemory(allocator, mesh.vert_buffer.allocation, @ptrCast([*c]?*anyopaque, &data));
    std.debug.assert(res == vk.Result.success);

    const gpu_vertices = @ptrCast([*]Vertex, @alignCast(@alignOf(Vertex), data));
    std.mem.copy(Vertex, gpu_vertices[0..mesh.vertices.items.len], mesh.vertices.items);
    vkmem.vmaUnmapMemory(allocator, mesh.vert_buffer.allocation);
}

fn recordCommandBuffer(
    cmdbuf: vk.CommandBuffer,
    gc: *const GraphicsContext,
    extent: vk.Extent2D,
    render_pass: vk.RenderPass,
    framebuffer: vk.Framebuffer,
    pipeline: vk.Pipeline,
) !void {
    const clear = vk.ClearValue{
        .color = .{ .float_32 = .{ 0.2, 0.5, 0, 1 } },
    };

    // This needs to be a separate definition - see https://github.com/ziglang/zig/issues/7627.
    const render_area = vk.Rect2D{
        .offset = .{ .x = 0, .y = 0 },
        .extent = extent,
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
        .clear_value_count = 1,
        .p_clear_values = @ptrCast([*]const vk.ClearValue, &clear),
    }, .@"inline");
    gc.vkd.cmdBindPipeline(cmdbuf, .graphics, pipeline);
    gc.vkd.cmdDraw(cmdbuf, 3, 1, 0, 0);

    gc.vkd.cmdEndRenderPass(cmdbuf);
    try gc.vkd.endCommandBuffer(cmdbuf);
}
