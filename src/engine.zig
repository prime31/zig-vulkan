const std = @import("std");
const stb = @import("stb");
const vk = @import("vulkan");
const vma = @import("vma");
const resources = @import("resources");
const glfw = @import("glfw");
const ig = @import("imgui");
const igvk = @import("imgui_vk");
const assets = @import("assetlib/assets.zig");
const vkinit = @import("vkinit.zig");
const vkutil = @import("vk_util/vk_util.zig");
const config = @import("utils/config.zig");

const GraphicsContext = @import("graphics_context.zig").GraphicsContext;
const RenderScene = @import("render_scene.zig").RenderScene;
const Swapchain = @import("swapchain.zig").Swapchain;
const PipelineBuilder = vkutil.PipelineBuilder;
const Mesh = @import("mesh.zig").Mesh;
const RenderBounds = @import("mesh.zig").RenderBounds;
const Vertex = @import("mesh.zig").Vertex;
const Allocator = std.mem.Allocator;

const MeshObject = @import("render_scene.zig").MeshObject;
const MeshPass = @import("render_scene.zig").MeshPass;
const GpuIndirectObject = @import("render_scene.zig").GpuIndirectObject;
const FlyCamera = @import("chapters/FlyCamera.zig");
const GpuCameraData = vkutil.GpuCameraData;
const GpuSceneData = vkutil.GpuSceneData;

const Mat4 = @import("chapters/mat4.zig").Mat4;
const Vec3 = @import("chapters/vec3.zig").Vec3;
const Vec4 = @import("chapters/vec4.zig").Vec4;

const FRAME_OVERLAP: usize = 2;

const Texture = struct {
    image: vma.AllocatedImage,
    view: vk.ImageView,

    pub fn init(image: vma.AllocatedImage) Texture {
        return .{ .image = image, .view = image.default_view };
    }

    pub fn deinit(self: Texture, gc: *const GraphicsContext) void {
        // only destroy the view if it isnt the default view from the AllocatedImage
        if (self.view != self.image.default_view)
            gc.destroy(self.view);
        self.image.deinit(gc.vma);
    }
};

const DirectionalLight = struct {
    light_pos: Vec3 = Vec3.new(0, 0, 0),
    light_dir: Vec3 = Vec3.new(0.3, -1, 0.3),
    shadow_extent: Vec3 = Vec3.new(20, 20, 100),
    use_ortho: bool = true,

    pub fn getViewMatrix(self: DirectionalLight) Mat4 {
        // return Mat4.createLookAt(self.light_pos, self.light_pos.add(self.light_dir), Vec3.new(0, 1, 0));
        return Mat4.createLookAt(self.light_pos, Vec3.new(0, 0, 0), Vec3.new(0, 1, 0));
    }

    pub fn getProjMatrix(self: DirectionalLight) Mat4 {
        if (self.use_ortho) {
            const se = self.shadow_extent;
            var proj = Mat4.createOrthographicLH_Z0(-se.x, se.x, se.y, -se.y, -se.z, se.z);
            return proj;
        } else {
            // Sascha uses a perspective cam for shadows
            var proj = Mat4.createPerspective(std.math.pi * 45.0 / 180.0, 1, 0.1, 96);
            proj.fields[1][1] *= -1;
            return proj;
        }
    }

    pub fn drawImGuiEditor(self: *DirectionalLight) void {
        if (ig.igCollapsingHeader_BoolPtr("Directional Light", null, ig.ImGuiTreeNodeFlags_None)) {
            ig.igIndent(10);
            defer ig.igUnindent(10);

            _ = ig.igCheckbox("Use Orthographic Matrix", &self.use_ortho);

            _ = ig.igDragFloat3("light_pos", &self.light_pos.x, 0.1, -360, 360, null, ig.ImGuiSliderFlags_None);
            _ = ig.igDragFloat3("light_dir", &self.light_dir.x, 0.1, -360, 360, null, ig.ImGuiSliderFlags_None);
            if (ig.igDragFloat("shadow_extent", &self.shadow_extent.x, 1, 0, 1000, null, ig.ImGuiSliderFlags_None)) {
                self.shadow_extent.y = self.shadow_extent.x;
                self.shadow_extent.z = self.shadow_extent.x;
            }

            if (ig.igButton("Reset Pos", .{.x = 0, .y = 0})) self.light_pos = Vec3.new(0, 0, 0);
        }
    }
};

pub const FrameData = struct {
    deletion_queue: vkutil.DeletionQueue,
    cmd_pool: vk.CommandPool,
    cmd_buffer: vk.CommandBuffer,
    dynamic_data: vkutil.PushBuffer,
    dynamic_descriptor_allocator: vkutil.DescriptorAllocator,

    pub fn init(gc: *GraphicsContext) !FrameData {
        const cmd_pool = try gc.vkd.createCommandPool(gc.dev, &.{
            .flags = .{ .reset_command_buffer_bit = true },
            .queue_family_index = gc.graphics_queue.family,
        }, null);

        var cmd_buffer: vk.CommandBuffer = undefined;
        try gc.vkd.allocateCommandBuffers(gc.dev, &.{
            .command_pool = cmd_pool,
            .level = .primary,
            .command_buffer_count = 1,
        }, @ptrCast([*]vk.CommandBuffer, &cmd_buffer));

        // 1 megabyte of dynamic data buffer
        const dynamic_data_buffer = try gc.vma.createUntypedBuffer(1000000, .{ .uniform_buffer_bit = true }, .cpu_only, .{});

        return FrameData{
            .deletion_queue = vkutil.DeletionQueue.init(gpa, gc),
            .cmd_pool = cmd_pool,
            .cmd_buffer = cmd_buffer,
            .dynamic_data = try vkutil.PushBuffer.init(gc, dynamic_data_buffer),
            .dynamic_descriptor_allocator = vkutil.DescriptorAllocator.init(gc),
        };
    }

    pub fn deinit(self: *FrameData, gc: *GraphicsContext) void {
        self.deletion_queue.deinit();
        gc.vkd.freeCommandBuffers(gc.dev, self.cmd_pool, 1, @ptrCast([*]vk.CommandBuffer, &self.cmd_buffer));
        gc.destroy(self.cmd_pool);
        self.dynamic_data.deinit(gc.vma);
        self.dynamic_descriptor_allocator.deinit();
    }
};

var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{ .thread_safe = false }){};
const gpa = general_purpose_allocator.allocator();

pub const Engine = struct {
    const Self = @This();

    gpa: Allocator,
    window: glfw.Window,
    gc: *GraphicsContext,
    swapchain: Swapchain,
    framebuffers: []vk.Framebuffer,
    frames: []FrameData,
    deletion_queue: vkutil.DeletionQueue,
    render_pass: vk.RenderPass,
    shadow_pass: vk.RenderPass,
    copy_pass: vk.RenderPass,

    // framebuffers
    render_format: vk.Format = .r32g32b32a32_sfloat,
    raw_render_image: vma.AllocatedImage = undefined,
    smooth_sampler: vk.Sampler = undefined,
    blocky_sampler: vk.Sampler = undefined,
    forward_framebuffer: vk.Framebuffer = undefined,
    shadow_framebuffer: vk.Framebuffer = undefined,

    // depth resources
    depth_image: Texture,
    depth_pyramid: Texture = undefined,
    shadow_sampler: vk.Sampler = undefined,
    shadow_image: vma.AllocatedImage = undefined,
    shadow_extent: vk.Extent2D = .{ .width = 1024 * 4, .height = 1024 * 4 },
    depth_pyramid_width: u32 = 0,
    depth_pyramid_height: u32 = 0,
    depth_pyramid_levels: u32 = 0,
    depth_format: vk.Format = .d32_sfloat,

    descriptor_allocator: vkutil.DescriptorAllocator,
    descriptor_layout_cache: vkutil.DescriptorLayoutCache,
    material_system: vkutil.MaterialSystem = undefined,

    scene_params: GpuSceneData,

    upload_barriers: std.ArrayList(vk.BufferMemoryBarrier) = undefined,
    cull_ready_barriers: std.ArrayList(vk.BufferMemoryBarrier) = undefined,
    post_cull_barriers: std.ArrayList(vk.BufferMemoryBarrier) = undefined,

    camera: FlyCamera,
    main_light: DirectionalLight = .{},
    cull_pip_lay: vkutil.PipelineAndPipelineLayout = .{},
    depth_reduce_pip_lay: vkutil.PipelineAndPipelineLayout = .{},
    spares_upload_pip_lay: vkutil.PipelineAndPipelineLayout = .{},
    blit_pipeline: vk.Pipeline = undefined,
    blit_layout: vk.PipelineLayout = undefined,
    depth_blit_pipeline: vk.Pipeline = undefined,
    depth_blit_layout: vk.PipelineLayout = undefined,

    depth_sampler: vk.Sampler = undefined,
    depth_pyramid_mips: [16]vk.ImageView = undefined,

    render_scene: RenderScene = undefined,

    frame_num: f32 = 0,
    dt: f64 = 0.0,
    last_frame_time: f64 = 0.0,

    shader_cache: vkutil.ShaderCache,
    meshes: std.StringHashMap(Mesh),
    textures: std.StringHashMap(Texture),

    imgui_pool: vk.DescriptorPool = undefined,

    pub usingnamespace @import("scene_render.zig");

    pub fn init(app_name: [*:0]const u8) !Self {
        try glfw.init(.{});

        var extent = vk.Extent2D{ .width = 800, .height = 600 };
        const window = try glfw.Window.create(extent.width, extent.height, app_name, null, null, .{
            .client_api = .no_api,
        });
        config.init(window);

        var gc = try gpa.create(GraphicsContext);
        gc.* = try GraphicsContext.init(gpa, app_name, window);

        var deletion_queue = vkutil.DeletionQueue.init(gpa, gc);

        // swapchain and RenderPasses
        var swapchain = try Swapchain.init(gc, gpa, extent, FRAME_OVERLAP);
        const render_pass = try createForwardRenderPass(gc, .d32_sfloat);
        const copy_pass = try createCopyRenderPass(gc, swapchain);
        const shadow_pass = try createShadowRenderPass(gc, .d32_sfloat);

        deletion_queue.append(render_pass);
        deletion_queue.append(copy_pass);
        deletion_queue.append(shadow_pass);

        // depth image and Swapchain framebuffers
        const depth_image = try createDepthImage(gc, .d32_sfloat, swapchain);
        const framebuffers = try createSwapchainFramebuffers(gc, copy_pass, swapchain);

        // create our FrameDatas
        const frames = try gpa.alloc(FrameData, swapchain.swap_images.len);
        errdefer gpa.free(frames);
        for (frames) |*f| f.* = try FrameData.init(gc);

        return Self{
            .gpa = gpa,
            .window = window,
            .gc = gc,
            .swapchain = swapchain,
            .render_pass = render_pass,
            .copy_pass = copy_pass,
            .shadow_pass = shadow_pass,

            .deletion_queue = deletion_queue,
            .framebuffers = framebuffers,
            .frames = frames,
            .depth_image = depth_image,

            .render_scene = RenderScene.init(gc),
            .shader_cache = vkutil.ShaderCache.init(gc),
            .meshes = std.StringHashMap(Mesh).init(gpa),
            .textures = std.StringHashMap(Texture).init(gpa),

            .descriptor_allocator = vkutil.DescriptorAllocator.init(gc),
            .descriptor_layout_cache = vkutil.DescriptorLayoutCache.init(gc),

            .upload_barriers = std.ArrayList(vk.BufferMemoryBarrier).init(gpa),
            .cull_ready_barriers = std.ArrayList(vk.BufferMemoryBarrier).init(gpa),
            .post_cull_barriers = std.ArrayList(vk.BufferMemoryBarrier).init(gpa),

            .camera = FlyCamera.init(window),
            .scene_params = .{},
        };
    }

    pub fn deinit(self: *Self) void {
        self.gc.vkd.deviceWaitIdle(self.gc.dev) catch unreachable;

        igvk.shutdown();
        ig.igDestroyContext(null);
        self.gc.destroy(self.imgui_pool);

        self.gc.destroy(self.depth_image.image.default_view);
        self.depth_image.deinit(self.gc);

        for (self.depth_pyramid_mips[0..self.depth_pyramid_levels]) |mip|
            self.gc.destroy(mip);
        self.depth_pyramid.deinit(self.gc);

        self.descriptor_allocator.deinit();
        self.descriptor_layout_cache.deinit();
        self.material_system.deinit();

        self.render_scene.deinit();
        self.shader_cache.deinit();

        var iter = self.meshes.valueIterator();
        while (iter.next()) |mesh| mesh.deinit(self.gc.vma);
        self.meshes.deinit();

        var tex_iter = self.textures.valueIterator();
        while (tex_iter.next()) |tex| tex.deinit(self.gc);
        self.textures.deinit();

        self.upload_barriers.deinit();
        self.cull_ready_barriers.deinit();
        self.post_cull_barriers.deinit();

        for (self.frames) |*frame| frame.deinit(self.gc);
        self.gpa.free(self.frames);

        for (self.framebuffers) |fb| self.gc.destroy(fb);
        self.gpa.free(self.framebuffers);

        self.deletion_queue.deinit();

        self.swapchain.deinit();
        self.gc.deinit();
        self.gpa.destroy(self.gc);

        self.window.destroy();
        glfw.terminate();

        _ = general_purpose_allocator.deinit();
    }

    pub fn loadContent(self: *Self) !void {
        try self.createFramebuffers();
        try self.createDepthSetup();
        try self.createPipelines();

        try self.initImgui();
        try self.loadImages();
        try self.loadMeshes();
        try self.initScene();

        try self.render_scene.mergeMeshes();
        try self.render_scene.buildBatches();
    }

    pub fn run(self: *Self) !void {
        while (!self.window.shouldClose()) {
            var curr_frame_time = glfw.getTime();
            self.dt = curr_frame_time - self.last_frame_time;
            self.last_frame_time = curr_frame_time;

            self.camera.update(self.dt);

            igvk.newFrame();
            ig.igNewFrame();
            @import("chapters/autogui.zig").inspect(FlyCamera, &self.camera);
            config.drawImGuiEditor(self);

            // wait for the last frame to complete before filling our CommandBuffer
            const state = self.swapchain.waitForFrame() catch |err| switch (err) {
                error.OutOfDateKHR => Swapchain.PresentState.suboptimal,
                else => |narrow| return narrow,
            };

            // grab frame and prepare it for rendering
            var frame = self.getCurrentFrameData();
            frame.dynamic_data.reset();
            frame.deletion_queue.flush();
            try frame.dynamic_descriptor_allocator.reset();
            try self.render_scene.buildBatches();

            // now that we are sure that the commands finished executing, we can safely reset the command buffer to begin recording again
            try self.gc.vkd.resetCommandBuffer(frame.cmd_buffer, .{});

            try self.draw(frame);

            try self.swapchain.present(frame.cmd_buffer);

            // TODO: why does this have to be after present?
            if (state == .suboptimal) {
                try self.swapchain.waitForAllFences();

                const size = try self.window.getSize();
                var extent = vk.Extent2D{ .width = size.width, .height = size.height };
                try self.swapchain.recreate(extent);

                for (self.framebuffers) |fb| self.gc.destroy(fb);
                self.gpa.free(self.framebuffers);

                self.gc.destroy(self.depth_image.image.default_view);
                self.depth_image.deinit(self.gc);
                self.depth_image = try createDepthImage(self.gc, self.depth_format, self.swapchain);
                self.framebuffers = try createSwapchainFramebuffers(self.gc, self.copy_pass, self.swapchain);

                // TODO: recreate all framebuffers. they shouldnt use the deletion queue because we need to deinit them on-the-fly
            }

            self.frame_num += 1;
            try glfw.pollEvents();
        }
    }

    pub fn getCurrentFrameData(self: *Self) *FrameData {
        return &self.frames[self.swapchain.frame_index % self.swapchain.swap_images.len];
    }

    fn createFramebuffers(self: *Self) !void {
        // render image size will match the window
        {
            const render_extent = vk.Extent3D{
                .width = self.swapchain.extent.width,
                .height = self.swapchain.extent.height,
                .depth = 1,
            };
            const ri_info = vkinit.imageCreateInfo(.r32g32b32a32_sfloat, render_extent, .{ .color_attachment_bit = true, .transfer_src_bit = true, .sampled_bit = true });
            const alloc_info = std.mem.zeroInit(vma.VmaAllocationCreateInfo, .{
                .flags = .{},
                .usage = .gpu_only,
                .requiredFlags = .{ .device_local_bit = true },
            });
            self.raw_render_image = try self.gc.vma.createImage(&ri_info, &alloc_info, null);

            const iview_info = vkinit.imageViewCreateInfo(.r32g32b32a32_sfloat, self.raw_render_image.image, .{ .color_bit = true });
            self.raw_render_image.default_view = try self.gc.vkd.createImageView(self.gc.dev, &iview_info, null);
            self.deletion_queue.append(self.raw_render_image);
        }

        // TODO: move depth image creation here
        {}

        // shadow image
        {
            const extent = vk.Extent3D{
                .width = self.shadow_extent.width,
                .height = self.shadow_extent.height,
                .depth = 1,
            };
            const img_info = vkinit.imageCreateInfo(.d32_sfloat, extent, .{ .sampled_bit = true, .depth_stencil_attachment_bit = true });
            const alloc_info = std.mem.zeroInit(vma.VmaAllocationCreateInfo, .{
                .flags = .{},
                .usage = .gpu_only,
                .requiredFlags = .{ .device_local_bit = true },
            });
            self.shadow_image = try self.gc.vma.createImage(&img_info, &alloc_info, null);

            const iview_info = vkinit.imageViewCreateInfo(.d32_sfloat, self.shadow_image.image, .{ .depth_bit = true });
            self.shadow_image.default_view = try self.gc.vkd.createImageView(self.gc.dev, &iview_info, null);
            self.deletion_queue.append(self.shadow_image);
        }

        var attachments = [2]vk.ImageView{ self.raw_render_image.default_view, self.depth_image.view };
        self.forward_framebuffer = try self.gc.vkd.createFramebuffer(self.gc.dev, &.{
            .flags = .{},
            .render_pass = self.render_pass,
            .attachment_count = 2,
            .p_attachments = &attachments,
            .width = self.swapchain.extent.width,
            .height = self.swapchain.extent.height,
            .layers = 1,
        }, null);

        self.shadow_framebuffer = try self.gc.vkd.createFramebuffer(self.gc.dev, &.{
            .flags = .{},
            .render_pass = self.shadow_pass,
            .attachment_count = 1,
            .p_attachments = @ptrCast([*]const vk.ImageView, &self.shadow_image.default_view),
            .width = self.shadow_extent.width,
            .height = self.shadow_extent.height,
            .layers = 1,
        }, null);

        self.deletion_queue.append(self.forward_framebuffer);
        self.deletion_queue.append(self.shadow_framebuffer);
    }

    fn previousPow2(v: u32) u32 {
        var r: u32 = 1;
        while (r * 2 < v)
            r *= 2;
        return r;
    }

    fn getImageMipLevels(width: u32, height: u32) u32 {
        var w = width;
        var h = height;

        var result: u32 = 1;
        while (w > 1 or h > 1) {
            result += 1;
            w /= 2;
            h /= 2;
        }
        return result;
    }

    fn createDepthSetup(self: *Self) !void {
        // Note: previousPow2 makes sure all reductions are at most by 2x2 which makes sure they are conservative
        self.depth_pyramid_width = previousPow2(self.swapchain.extent.width);
        self.depth_pyramid_height = previousPow2(self.swapchain.extent.height);
        self.depth_pyramid_levels = getImageMipLevels(self.depth_pyramid_width, self.depth_pyramid_height);

        const extent = vk.Extent3D{
            .width = self.depth_pyramid_width,
            .height = self.depth_pyramid_height,
            .depth = 1,
        };
        var img_info = vkinit.imageCreateInfo(.r32_sfloat, extent, .{ .sampled_bit = true, .storage_bit = true, .transfer_src_bit = true });
        img_info.mip_levels = self.depth_pyramid_levels;

        const alloc_info = std.mem.zeroInit(vma.VmaAllocationCreateInfo, .{
            .flags = .{},
            .usage = .gpu_only,
            .requiredFlags = .{ .device_local_bit = true },
        });
        var img = try self.gc.vma.createImage(&img_info, &alloc_info, null);

        var iview_info = vkinit.imageViewCreateInfo(.r32_sfloat, img.image, .{ .color_bit = true });
        iview_info.subresource_range.level_count = self.depth_pyramid_levels;

        img.default_view = try self.gc.vkd.createImageView(self.gc.dev, &iview_info, null);
        self.depth_pyramid = Texture{ .image = img, .view = img.default_view };

        self.deletion_queue.append(img.default_view);

        var i: usize = 0;
        while (i < self.depth_pyramid_levels) : (i += 1) {
            var level_info = vkinit.imageViewCreateInfo(.r32_sfloat, self.depth_pyramid.image.image, .{ .color_bit = true });
            level_info.subresource_range.level_count = 1;
            level_info.subresource_range.base_mip_level = @intCast(u32, i);

            self.depth_pyramid_mips[i] = try self.gc.vkd.createImageView(self.gc.dev, &level_info, null);
        }

        // transition depth pyramid to .general before first use
        const cmd = try self.gc.beginOneTimeCommandBuffer();
        const transition_barrier = vkinit.imageBarrier(self.depth_pyramid.image.image, .{}, .{ .transfer_write_bit = true }, .@"undefined", .general, .{ .color_bit = true });
        self.gc.vkd.cmdPipelineBarrier(cmd, .{ .top_of_pipe_bit = true }, .{ .transfer_bit = true }, .{ .by_region_bit = true }, 0, undefined, 0, undefined, 1, vkutil.ptrToMany(&transition_barrier));
        try self.gc.endOneTimeCommandBuffer();

        const reduction_mode: vk.SamplerReductionMode = .min;
        const create_info = std.mem.zeroInit(vk.SamplerCreateInfo, .{
            .mag_filter = .linear,
            .min_filter = .linear,
            .mipmap_mode = .nearest,
            .address_mode_u = .clamp_to_edge,
            .address_mode_v = .clamp_to_edge,
            .address_mode_w = .clamp_to_edge,
            .min_lod = 0,
            .max_lod = 16,
        });

        if (reduction_mode != .min) {
            const create_info_reduction = vk.SamplerReductionModeCreateInfoEXT{ .reduction_mode = vk.SamplerReductionMode.weighted_average };
            create_info.p_next = &create_info_reduction;
        }

        self.depth_sampler = try self.gc.vkd.createSampler(self.gc.dev, &create_info, null);
        self.deletion_queue.append(self.depth_sampler);

        var sampler_info = vkinit.samplerCreateInfo(.linear, .repeat);
        sampler_info.mipmap_mode = .linear;
        self.smooth_sampler = try self.gc.vkd.createSampler(self.gc.dev, &sampler_info, null);
        self.deletion_queue.append(self.smooth_sampler);

        const blocky_sampler_info = vkinit.samplerCreateInfo(.nearest, vk.SamplerAddressMode.repeat);
        self.blocky_sampler = try self.gc.vkd.createSampler(self.gc.dev, &blocky_sampler_info, null);
        self.deletion_queue.append(self.blocky_sampler);

        var shadow_sampler_info = vkinit.samplerCreateInfo(.linear, .clamp_to_border);
        shadow_sampler_info.border_color = .float_opaque_white;
        // shadow_sampler_info.compare_enable = vk.TRUE; // TODO: doesnt work with MoltenVK
        shadow_sampler_info.compare_op = .less;
        self.shadow_sampler = try self.gc.vkd.createSampler(self.gc.dev, &shadow_sampler_info, null);
        self.deletion_queue.append(self.shadow_sampler);
    }

    fn createPipelines(self: *Self) !void {
        self.material_system = try vkutil.MaterialSystem.init(self);

        // fullscreen triangle pipeline for blits
        var blit_effect = vkutil.ShaderEffect.init(gpa);
        try blit_effect.addStage(self.shader_cache.getShader("fullscreen_vert"), .{ .vertex_bit = true });
        try blit_effect.addStage(self.shader_cache.getShader("blit_frag"), .{ .fragment_bit = true });
        try blit_effect.reflectLayout(self.gc, null);

        // defaults are triangle_list, polygon fill, no culling, no blending
        var pip_builder = vkutil.PipelineBuilder.init();
        try pip_builder.setShaders(&blit_effect);

        // blit pipeline uses hardcoded triangle so no need for vertex input
        pip_builder.clearVertexInput();
        pip_builder.depth_stencil = vkinit.pipelineDepthStencilCreateInfo(false, false, .always);
        self.blit_pipeline = try pip_builder.build(self.gc, self.copy_pass);
        self.blit_layout = blit_effect.built_layout;

        self.deletion_queue.append(blit_effect);
        self.deletion_queue.append(self.blit_pipeline);

        // fullscreen triangle pipeline for depth map blits
        var depth_blit_effect = vkutil.ShaderEffect.init(gpa);
        try depth_blit_effect.addStage(self.shader_cache.getShader("fullscreen_vert"), .{ .vertex_bit = true });
        try depth_blit_effect.addStage(self.shader_cache.getShader("blit_depth_frag"), .{ .fragment_bit = true });
        try depth_blit_effect.reflectLayout(self.gc, null);

        var depth_pip_builder = vkutil.PipelineBuilder.init();
        try depth_pip_builder.setShaders(&depth_blit_effect);

        // blit pipeline uses hardcoded triangle so no need for vertex input
        depth_pip_builder.clearVertexInput();
        depth_pip_builder.depth_stencil = vkinit.pipelineDepthStencilCreateInfo(false, false, .always);
        self.depth_blit_pipeline = try depth_pip_builder.build(self.gc, self.copy_pass);
        self.depth_blit_layout = depth_blit_effect.built_layout;

        self.deletion_queue.append(depth_blit_effect);
        self.deletion_queue.append(self.depth_blit_pipeline);

        // load the compute shaders
        self.cull_pip_lay = try self.loadComputeShader("indirect_cull_comp");
        self.depth_reduce_pip_lay = try self.loadComputeShader("depth_reduce_comp");
        self.spares_upload_pip_lay = try self.loadComputeShader("sparse_upload_comp");

        // TODO: who owns the ShaderModule/ShaderEffect? here we only kill the pip because ShaderEffect kills the layout...
        self.deletion_queue.append(self.cull_pip_lay.pipeline);
        self.deletion_queue.append(self.depth_reduce_pip_lay.pipeline);
        self.deletion_queue.append(self.spares_upload_pip_lay.pipeline);
    }

    fn loadComputeShader(self: *Self, comptime res_path: []const u8) !vkutil.PipelineAndPipelineLayout {
        const compute_module = try vkutil.ShaderModule.init(self.gc, res_path);

        var compute_effect = vkutil.ShaderEffect.init(self.gc.gpa);
        try compute_effect.addStage(&compute_module, .{ .compute_bit = true });
        try compute_effect.reflectLayout(self.gc, null);

        self.deletion_queue.append(compute_module);
        self.deletion_queue.append(compute_effect);

        var compute_builder = vkutil.ComputePipelineBuilder.init(compute_effect.built_layout, compute_module.module);
        return vkutil.PipelineAndPipelineLayout{
            .pipeline = try compute_builder.buildPipeline(self.gc),
            .layout = compute_effect.built_layout,
        };
    }

    fn initImgui(self: *Self) !void {
        // 1: create descriptor pool for IMGUI
        const sizes = [_]vk.DescriptorPoolSize{
            .{ .@"type" = .sampler, .descriptor_count = 1000 },
            .{ .@"type" = .combined_image_sampler, .descriptor_count = 1000 },
            .{ .@"type" = .sampled_image, .descriptor_count = 1000 },
            .{ .@"type" = .storage_image, .descriptor_count = 1000 },
            .{ .@"type" = .uniform_texel_buffer, .descriptor_count = 1000 },
            .{ .@"type" = .storage_texel_buffer, .descriptor_count = 1000 },
            .{ .@"type" = .uniform_buffer, .descriptor_count = 1000 },
            .{ .@"type" = .storage_buffer, .descriptor_count = 1000 },
            .{ .@"type" = .uniform_buffer_dynamic, .descriptor_count = 1000 },
            .{ .@"type" = .storage_buffer_dynamic, .descriptor_count = 1000 },
            .{ .@"type" = .input_attachment, .descriptor_count = 1000 },
        };

        const pool_info = vk.DescriptorPoolCreateInfo{
            .flags = .{ .free_descriptor_set_bit = true },
            .max_sets = 1000 * sizes.len,
            .pool_size_count = sizes.len,
            .p_pool_sizes = @ptrCast([*]const vk.DescriptorPoolSize, &sizes),
        };
        self.imgui_pool = try self.gc.vkd.createDescriptorPool(self.gc.dev, &pool_info, null);

        // 2: initialize imgui library
        _ = ig.igCreateContext(null);
        const io = ig.igGetIO();
        io.*.ConfigFlags |= ig.ImGuiConfigFlags_DockingEnable | ig.ImGuiConfigFlags_ViewportsEnable;

        ig.igStyleColorsDark(null);

        const closure = struct {
            pub fn load(function_name: [*:0]const u8, user_data: *anyopaque) callconv(.C) vk.PfnVoidFunction {
                return glfw.getInstanceProcAddress(@intToEnum(vk.Instance, @ptrToInt(user_data)), function_name);
            }
        }.load;
        _ = igvk.ImGui_ImplVulkan_LoadFunctions(closure, self.gc.instance);
        _ = igvk.ImGui_ImplGlfw_InitForVulkan(self.window.handle, true);

        var info = std.mem.zeroInit(igvk.ImGui_ImplVulkan_InitInfo, .{
            .instance = self.gc.instance,
            .physical_device = self.gc.pdev,
            .device = self.gc.dev,
            .queue_family = self.gc.graphics_queue.family,
            .queue = self.gc.graphics_queue.handle,
            .descriptor_pool = self.imgui_pool,
            .subpass = 0,
            .min_image_count = 2,
            .image_count = 2,
            .msaa_samples = .{ .@"1_bit" = true },
            .allocator = null,
            .checkVkResultFn = null,
        });
        _ = igvk.ImGui_ImplVulkan_Init(&info, self.copy_pass);

        // execute a gpu command to upload imgui font textures
        const cmd_buf = try self.gc.beginOneTimeCommandBuffer();
        _ = igvk.ImGui_ImplVulkan_CreateFontsTexture(cmd_buf);
        try self.gc.endOneTimeCommandBuffer();

        // clear font textures from cpu data
        igvk.ImGui_ImplVulkan_DestroyFontUploadObjects();
    }

    fn loadImages(self: *Self) !void {
        // const background = try loadTextureFromAsset(self.gc, "/Users/desaro/zig-vulkan/zig-cache/baked_assets/background.tx");
        const background = try loadTextureFromFile(self.gc, "src/chapters/background.png");
        self.deletion_queue.append(background.image.default_view);
        try self.textures.put("background", background);

        const white_tex = try loadTextureFromFile(self.gc, "src/chapters/white.jpg");
        self.deletion_queue.append(white_tex.image.default_view);
        try self.textures.put("white", white_tex);
    }

    fn loadMeshes(self: *Self) !void {
        var tri_mesh = Mesh.init(gpa);
        try tri_mesh.vertices.append(.{ .position = .{ 1, 1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0.6, 0.6, 0.6 }, .uv = .{ 1, 0 } });
        try tri_mesh.vertices.append(.{ .position = .{ -1, 1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0.6, 0.6, 0.6 }, .uv = .{ 0, 0 } });
        try tri_mesh.vertices.append(.{ .position = .{ 0, -1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0.6, 0.6, 0.6 }, .uv = .{ 0.5, 1 } });
        tri_mesh.recalculateBounds();

        // var monkey_mesh = try Mesh.initFromAsset(gpa, "/Users/desaro/zig-vulkan/zig-cache/baked_assets/monkey_flat.mesh");
        var monkey_mesh = try Mesh.initFromObj(gpa, "src/chapters/monkey_flat.obj");
        var cube_thing_mesh = try Mesh.initFromObj(gpa, "src/chapters/cube_thing.obj");
        var cube = try Mesh.initFromObj(gpa, "src/chapters/cube.obj");
        var lost_empire = try Mesh.initFromObj(gpa, "src/chapters/lost_empire.obj");
        var rock = try Mesh.initProcRock(gpa, 123, 2);
        var sphere = try Mesh.initProcSphere(gpa, 20, 20);
        var terrain = try Mesh.initProcTerrain(gpa);

        try uploadMesh(self.gc, &tri_mesh);
        try uploadMesh(self.gc, &monkey_mesh);
        try uploadMesh(self.gc, &cube_thing_mesh);
        try uploadMesh(self.gc, &cube);
        try uploadMesh(self.gc, &lost_empire);
        try uploadMesh(self.gc, &rock);
        try uploadMesh(self.gc, &sphere);
        try uploadMesh(self.gc, &terrain);

        try self.meshes.put("triangle", tri_mesh);
        try self.meshes.put("monkey", monkey_mesh);
        try self.meshes.put("cube_thing", cube_thing_mesh);
        try self.meshes.put("cube", cube);
        try self.meshes.put("lost_empire", lost_empire);
        try self.meshes.put("rock", rock);
        try self.meshes.put("sphere", sphere);
        try self.meshes.put("terrain", terrain);
    }

    fn initScene(self: *Self) !void {
        var textured_data = vkutil.MaterialData.init(self.gc.gpa, "texturedPBR_opaque");
        try textured_data.addTexture(self.smooth_sampler, self.textures.get("background").?.view);
        _ = try self.material_system.buildMaterial("textured", textured_data);

        var white_tex_data = vkutil.MaterialData.init(self.gc.gpa, "texturedPBR_opaque");
        try white_tex_data.addTexture(self.smooth_sampler, self.textures.get("white").?.view);
        _ = try self.material_system.buildMaterial("white_tex", white_tex_data);

        var mat_info = vkutil.MaterialData.init(self.gc.gpa, "colored_opaque");
        _ = try self.material_system.buildMaterial("opaque", mat_info);

        var x: f32 = 0;
        while (x < 20) : (x += 1) {
            var y: f32 = 0;
            while (y < 20) : (y += 1) {
                const mesh = if (@mod(x, 2) == 0) self.meshes.getPtr("triangle").? else self.meshes.getPtr("monkey").?;
                const material = if (@mod(x, 2) == 0) self.material_system.getMaterial("white_tex").? else self.material_system.getMaterial("white_tex").?;

                var tri = MeshObject{
                    .mesh = mesh,
                    .material = material,
                    .custom_sort_key = 0,
                    .transform_matrix = Mat4.createTranslation(.{ .x = x, .y = 0, .z = y }).mul(Mat4.createScale(.{ .x = 0.3, .y = 0.3, .z = 0.3 })),
                    .bounds = mesh.bounds,
                    .draw_forward_pass = true,
                    .draw_shadow_pass = true,
                };
                tri.refreshRenderBounds();
                _ = try self.render_scene.registerObject(tri);
            }
        }

        var mat = Mat4.createTranslation(.{ .x = 10, .y = -0.5, .z = 10 });
        mat = mat.mul(Mat4.createScale(.{ .x = 20, .y = 20, .z = 20 }));
        mat = mat.mul(Mat4.createRotate(-1.5708, Vec3.new(1, 0, 0)));

        var tri_ground = MeshObject{
            .mesh = self.meshes.getPtr("terrain").?,
            .material = self.material_system.getMaterial("white_tex").?,
            .custom_sort_key = 0,
            .transform_matrix = mat,
            .bounds = self.meshes.getPtr("terrain").?.bounds,
            .draw_forward_pass = true,
            .draw_shadow_pass = true,
        };
        tri_ground.refreshRenderBounds();
        _ = try self.render_scene.registerObject(tri_ground);

        var rock = MeshObject{
            .mesh = self.meshes.getPtr("rock").?,
            .material = self.material_system.getMaterial("white_tex").?,
            .custom_sort_key = 0,
            .transform_matrix = Mat4.createTranslation(.{ .x = 0, .y = 1, .z = 0 }),
            .bounds = self.meshes.getPtr("rock").?.bounds,
            .draw_forward_pass = true,
            .draw_shadow_pass = true,
        };
        rock.refreshRenderBounds();
        _ = try self.render_scene.registerObject(rock);

        var sphere = MeshObject{
            .mesh = self.meshes.getPtr("sphere").?,
            .material = self.material_system.getMaterial("textured").?,
            .custom_sort_key = 0,
            .transform_matrix = Mat4.createTranslation(.{ .x = 2, .y = 1.5, .z = 2 }),
            .bounds = self.meshes.getPtr("sphere").?.bounds,
            .draw_forward_pass = true,
            .draw_shadow_pass = true,
        };
        sphere.refreshRenderBounds();
        _ = try self.render_scene.registerObject(sphere);
    }

    fn draw(self: *Self, frame: *FrameData) !void {
        self.main_light.drawImGuiEditor();

        ig.igRender();
        if ((ig.igGetIO().*.ConfigFlags & ig.ImGuiConfigFlags_ViewportsEnable) != 0) {
            ig.igUpdatePlatformWindows();
            ig.igRenderPlatformWindowsDefault(null, null);
        }

        self.post_cull_barriers.clearRetainingCapacity();
        self.cull_ready_barriers.clearRetainingCapacity();

        try self.gc.vkd.beginCommandBuffer(frame.cmd_buffer, &.{
            .flags = .{ .one_time_submit_bit = true },
            .p_inheritance_info = null,
        });

        try self.readyMeshDraw(frame);
        try self.readyCullData(&self.render_scene.forward_pass, frame.cmd_buffer);
        // try self.readyCullData(&self.render_scene.transparent_forward_pass, frame.cmd_buffer);
        try self.readyCullData(&self.render_scene.shadow_pass, frame.cmd_buffer);

        self.gc.vkd.cmdPipelineBarrier(frame.cmd_buffer, .{ .transfer_bit = true }, .{ .compute_shader_bit = true }, .{}, 0, undefined, @intCast(u32, self.cull_ready_barriers.items.len), self.cull_ready_barriers.items.ptr, 0, undefined);

        const forward_cull = vkutil.CullParams{
            .projmat = self.camera.getProjMatrix(self.swapchain.extent),
            .viewmat = self.camera.getViewMatrix(),
            .frustum_cull = true,
            .occlusion_cull = true,
            .draw_dist = config.draw_distance.get(),
            .aabb = false,
        };
        try self.executeComputeCull(frame.cmd_buffer, &self.render_scene.forward_pass, forward_cull);
        // try self.executeComputeCull(frame.cmd_buffer, &self.render_scene.transparent_forward_pass, forward_cull);

        // CullParams for shadow pass
        const aabb_center = self.main_light.light_pos;
        const aabb_extent = self.main_light.shadow_extent.scale(1.5);

        const shadow_cull = vkutil.CullParams{
            .projmat = self.main_light.getProjMatrix(),
            .viewmat = self.main_light.getViewMatrix(),
            .frustum_cull = true,
            .occlusion_cull = false,
            .draw_dist = 9999999,
            .aabb = true,
            .aabbmax = aabb_center.add(aabb_extent),
            .aabbmin = aabb_center.sub(aabb_extent),
        };

        if (config.shadowcast.get())
            try self.executeComputeCull(frame.cmd_buffer, &self.render_scene.shadow_pass, shadow_cull);

        self.gc.vkd.cmdPipelineBarrier(frame.cmd_buffer, .{ .compute_shader_bit = true }, .{ .draw_indirect_bit = true }, .{}, 0, undefined, @intCast(u32, self.post_cull_barriers.items.len), self.post_cull_barriers.items.ptr, 0, undefined);

        try self.shadowPass(frame.cmd_buffer);
        try self.forwardPass(frame.cmd_buffer);
        try self.reduceDepth(frame.cmd_buffer);

        try self.copyRenderToSwapchain(frame.cmd_buffer);
        if (config.blit_shadow_buffer.get())
            try self.copyShadowMapToSwapchain(frame.cmd_buffer);

        try self.gc.vkd.endCommandBuffer(frame.cmd_buffer);
    }

    fn readyCullData(self: *Self, pass: *MeshPass, cmd: vk.CommandBuffer) !void {
        // if cull is frozen we want to make sure not to overwrite our draw_indirect_buffer with the clear_indirect_buffer
        if (config.freeze_cull.get()) return;
        if (pass.clear_indirect_buffer.buffer == .null_handle) return;

        // copy from the cleared indirect buffer into the one we will use on rendering
        const indirect_copy = vk.BufferCopy{
            .src_offset = 0,
            .dst_offset = 0,
            .size = pass.batches.items.len * @sizeOf(GpuIndirectObject),
        };
        self.gc.vkd.cmdCopyBuffer(cmd, pass.clear_indirect_buffer.buffer, pass.draw_indirect_buffer.buffer, 1, vkutil.ptrToMany(&indirect_copy));

        var barrier = vkinit.bufferBarrier(pass.draw_indirect_buffer.buffer, self.gc.graphics_queue.family);
        barrier.src_access_mask = .{ .transfer_write_bit = true };
        barrier.dst_access_mask = .{ .shader_write_bit = true, .shader_read_bit = true };
        try self.cull_ready_barriers.append(barrier);
    }

    fn shadowPass(self: *Self, cmd: vk.CommandBuffer) !void {
        if (!config.shadowcast.get()) return;
        if (config.freeze_shadows.get()) return;

        const depth_clear = vk.ClearValue{
            .depth_stencil = .{ .depth = 1, .stencil = 0 },
        };

        // This needs to be a separate definition - see https://github.com/ziglang/zig/issues/7627.
        const render_area = vk.Rect2D{
            .offset = .{ .x = 0, .y = 0 },
            .extent = self.shadow_extent,
        };

        const viewport = vk.Viewport{
            .x = 0,
            .y = 0,
            .width = @intToFloat(f32, self.shadow_extent.width),
            .height = @intToFloat(f32, self.shadow_extent.height),
            .min_depth = 0,
            .max_depth = 1,
        };

        self.gc.vkd.cmdSetViewport(cmd, 0, 1, @ptrCast([*]const vk.Viewport, &viewport));
        self.gc.vkd.cmdSetScissor(cmd, 0, 1, @ptrCast([*]const vk.Rect2D, &render_area));
        self.gc.vkd.cmdSetDepthBias(cmd, config.shadow_bias.get(), 0, config.shadow_slope_bias.get());

        self.gc.vkd.cmdBeginRenderPass(cmd, &.{
            .render_pass = self.shadow_pass,
            .framebuffer = self.shadow_framebuffer,
            .render_area = render_area,
            .clear_value_count = 1,
            .p_clear_values = vkutil.ptrToMany(&depth_clear),
        }, .@"inline");

        try self.drawObjectsShadow(cmd, &self.render_scene.shadow_pass);

        self.gc.vkd.cmdEndRenderPass(cmd);
    }

    fn forwardPass(self: *Self, cmd: vk.CommandBuffer) !void {
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

        self.gc.vkd.cmdSetViewport(cmd, 0, 1, @ptrCast([*]const vk.Viewport, &viewport));
        self.gc.vkd.cmdSetScissor(cmd, 0, 1, @ptrCast([*]const vk.Rect2D, &render_area));
        self.gc.vkd.cmdSetDepthBias(cmd, 0, 0, 0);

        self.gc.vkd.cmdBeginRenderPass(cmd, &.{
            .render_pass = self.render_pass,
            .framebuffer = self.forward_framebuffer,
            .render_area = render_area,
            .clear_value_count = clear_values.len,
            .p_clear_values = @ptrCast([*]const vk.ClearValue, &clear_values),
        }, .@"inline");

        try self.drawObjectsForward(cmd, &self.render_scene.forward_pass);
        // try self.drawObjectsForward(cmd, &self.render_scene.transparent_forward_pass);

        self.gc.vkd.cmdEndRenderPass(cmd);
    }

    fn copyRenderToSwapchain(self: *Self, cmd: vk.CommandBuffer) !void {
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

        self.gc.vkd.cmdBeginRenderPass(cmd, &.{
            .render_pass = self.copy_pass,
            .framebuffer = self.framebuffers[self.swapchain.image_index],
            .render_area = render_area,
            .clear_value_count = 0,
            .p_clear_values = undefined,
        }, .@"inline");

        self.gc.vkd.cmdSetViewport(cmd, 0, 1, @ptrCast([*]const vk.Viewport, &viewport));
        self.gc.vkd.cmdSetScissor(cmd, 0, 1, @ptrCast([*]const vk.Rect2D, &render_area));
        self.gc.vkd.cmdSetDepthBias(cmd, 0, 0, 0);

        self.gc.vkd.cmdBindPipeline(cmd, .graphics, self.blit_pipeline);

        var source_image = vk.DescriptorImageInfo{
            .sampler = self.smooth_sampler,
            .image_view = self.raw_render_image.default_view,
            .image_layout = .shader_read_only_optimal,
        };

        var blit_set: vk.DescriptorSet = undefined;
        var builder = vkutil.DescriptorBuilder.init(self.gc.gpa, &self.descriptor_allocator, &self.descriptor_layout_cache);
        builder.bindImage(0, &source_image, .combined_image_sampler, .{ .fragment_bit = true });
        _ = try builder.build(&blit_set);
        builder.deinit();

        self.gc.vkd.cmdBindDescriptorSets(cmd, .graphics, self.blit_layout, 0, 1, vkutil.ptrToMany(&blit_set), 0, undefined);
        self.gc.vkd.cmdDraw(cmd, 3, 1, 0, 0);

        igvk.ImGui_ImplVulkan_RenderDrawData(ig.igGetDrawData(), cmd, .null_handle);

        self.gc.vkd.cmdEndRenderPass(cmd);
    }

    fn copyShadowMapToSwapchain(self: *Self, cmd: vk.CommandBuffer) !void {
        const rect = vk.Extent2D{
            .width = @intCast(u32, self.swapchain.extent.width / 3),
            .height = @intCast(u32, self.swapchain.extent.height / 3),
        };

        const render_area = vk.Rect2D{
            .offset = .{
                .x = @intCast(i32, self.swapchain.extent.width - rect.width),
                .y = 0,
            },
            .extent = rect,
        };

        const viewport = vk.Viewport{
            .x = @intToFloat(f32, self.swapchain.extent.width - rect.width),
            .y = 0,
            .width = @intToFloat(f32, rect.width),
            .height = @intToFloat(f32, rect.height),
            .min_depth = 0,
            .max_depth = 1,
        };

        self.gc.vkd.cmdBeginRenderPass(cmd, &.{
            .render_pass = self.copy_pass,
            .framebuffer = self.framebuffers[self.swapchain.image_index],
            .render_area = render_area,
            .clear_value_count = 0,
            .p_clear_values = undefined,
        }, .@"inline");

        self.gc.vkd.cmdSetViewport(cmd, 0, 1, @ptrCast([*]const vk.Viewport, &viewport));
        self.gc.vkd.cmdSetScissor(cmd, 0, 1, @ptrCast([*]const vk.Rect2D, &render_area));
        self.gc.vkd.cmdSetDepthBias(cmd, 0, 0, 0);

        self.gc.vkd.cmdBindPipeline(cmd, .graphics, self.depth_blit_pipeline);

        var source_image = vk.DescriptorImageInfo{
            .sampler = self.smooth_sampler,
            .image_view = self.shadow_image.default_view,
            .image_layout = .shader_read_only_optimal,
        };

        var blit_set: vk.DescriptorSet = undefined;
        var builder = vkutil.DescriptorBuilder.init(self.gc.gpa, &self.descriptor_allocator, &self.descriptor_layout_cache);
        builder.bindImage(0, &source_image, .combined_image_sampler, .{ .fragment_bit = true });
        _ = try builder.build(&blit_set);
        builder.deinit();

        self.gc.vkd.cmdBindDescriptorSets(cmd, .graphics, self.depth_blit_layout, 0, 1, vkutil.ptrToMany(&blit_set), 0, undefined);
        self.gc.vkd.cmdDraw(cmd, 3, 1, 0, 0);

        self.gc.vkd.cmdEndRenderPass(cmd);
    }
};

fn createForwardRenderPass(gc: *const GraphicsContext, depth_format: vk.Format) !vk.RenderPass {
    const color_attachment = vk.AttachmentDescription{
        .flags = .{},
        .format = .r32g32b32a32_sfloat,
        .samples = .{ .@"1_bit" = true },
        .load_op = .clear,
        .store_op = .store,
        .stencil_load_op = .dont_care,
        .stencil_store_op = .dont_care,
        .initial_layout = .@"undefined",
        .final_layout = .shader_read_only_optimal,
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
        .src_stage_mask = .{ .color_attachment_output_bit = true },
        .src_access_mask = .{},
        .dst_stage_mask = .{ .color_attachment_output_bit = true },
        .dst_access_mask = .{ .color_attachment_write_bit = true },
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
        .dst_access_mask = .{ .depth_stencil_attachment_write_bit = true },
        .dependency_flags = .{},
    };

    var attachments: [2]vk.AttachmentDescription = [_]vk.AttachmentDescription{ color_attachment, depth_attachment };
    var dependencies: [2]vk.SubpassDependency = [_]vk.SubpassDependency{ dependency, depth_dependency };

    return try gc.vkd.createRenderPass(gc.dev, &.{
        .flags = .{},
        .attachment_count = attachments.len,
        .p_attachments = &attachments,
        .subpass_count = 1,
        .p_subpasses = @ptrCast([*]const vk.SubpassDescription, &subpass),
        .dependency_count = dependencies.len,
        .p_dependencies = &dependencies,
    }, null);
}

fn createCopyRenderPass(gc: *const GraphicsContext, swapchain: Swapchain) !vk.RenderPass {
    const color_attachment = vk.AttachmentDescription{
        .flags = .{},
        .format = swapchain.surface_format.format,
        .samples = .{ .@"1_bit" = true },
        .load_op = .dont_care,
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
        .p_color_attachments = vkutil.ptrToMany(&color_attachment_ref),
        .p_resolve_attachments = null,
        .p_depth_stencil_attachment = null,
        .preserve_attachment_count = 0,
        .p_preserve_attachments = undefined,
    };

    const dependency = vk.SubpassDependency{
        .src_subpass = vk.SUBPASS_EXTERNAL,
        .dst_subpass = 0,
        .src_stage_mask = .{ .color_attachment_output_bit = true },
        .src_access_mask = .{},
        .dst_stage_mask = .{ .color_attachment_output_bit = true },
        .dst_access_mask = .{ .color_attachment_write_bit = true },
        .dependency_flags = .{},
    };

    return try gc.vkd.createRenderPass(gc.dev, &.{
        .flags = .{},
        .attachment_count = 1,
        .p_attachments = vkutil.ptrToMany(&color_attachment),
        .subpass_count = 1,
        .p_subpasses = vkutil.ptrToMany(&subpass),
        .dependency_count = 1,
        .p_dependencies = vkutil.ptrToMany(&dependency),
    }, null);
}

fn createShadowRenderPass(gc: *const GraphicsContext, depth_format: vk.Format) !vk.RenderPass {
    const depth_attachment = vk.AttachmentDescription{
        .flags = .{},
        .format = depth_format,
        .samples = .{ .@"1_bit" = true },
        .load_op = .clear,
        .store_op = .store,
        .stencil_load_op = .clear,
        .stencil_store_op = .dont_care,
        .initial_layout = .@"undefined",
        .final_layout = .shader_read_only_optimal,
    };

    const depth_attachment_ref = vk.AttachmentReference{
        .attachment = 0,
        .layout = .depth_stencil_attachment_optimal,
    };

    const subpass = std.mem.zeroInit(vk.SubpassDescription, .{
        .flags = .{},
        .pipeline_bind_point = .graphics,
        .p_depth_stencil_attachment = &depth_attachment_ref,
    });

    const dependency = vk.SubpassDependency{
        .src_subpass = vk.SUBPASS_EXTERNAL,
        .dst_subpass = 0,
        .src_stage_mask = .{ .color_attachment_output_bit = true },
        .src_access_mask = .{},
        .dst_stage_mask = .{ .color_attachment_output_bit = true },
        .dst_access_mask = .{ .color_attachment_write_bit = true },
        .dependency_flags = .{},
    };

    return try gc.vkd.createRenderPass(gc.dev, &.{
        .flags = .{},
        .attachment_count = 1,
        .p_attachments = @ptrCast([*]const vk.AttachmentDescription, &depth_attachment),
        .subpass_count = 1,
        .p_subpasses = @ptrCast([*]const vk.SubpassDescription, &subpass),
        .dependency_count = 1,
        .p_dependencies = @ptrCast([*]const vk.SubpassDependency, &dependency),
    }, null);
}

fn createDepthImage(gc: *const GraphicsContext, depth_format: vk.Format, swapchain: Swapchain) !Texture {
    const depth_extent = vk.Extent3D{ .width = swapchain.extent.width, .height = swapchain.extent.height, .depth = 1 };
    const dimg_info = vkinit.imageCreateInfo(depth_format, depth_extent, .{ .depth_stencil_attachment_bit = true, .sampled_bit = true });

    // we want to allocate it from GPU local memory
    var malloc_info = std.mem.zeroInit(vma.VmaAllocationCreateInfo, .{
        .flags = .{},
        .usage = .gpu_only,
        .requiredFlags = .{ .device_local_bit = true },
    });
    var depth_image = try gc.vma.createImage(&dimg_info, &malloc_info, null);

    const dview_info = vkinit.imageViewCreateInfo(depth_format, depth_image.image, .{ .depth_bit = true });
    depth_image.default_view = try gc.vkd.createImageView(gc.dev, &dview_info, null);

    return Texture.init(depth_image);
}

fn createSwapchainFramebuffers(gc: *const GraphicsContext, render_pass: vk.RenderPass, swapchain: Swapchain) ![]vk.Framebuffer {
    const framebuffers = try gc.gpa.alloc(vk.Framebuffer, swapchain.swap_images.len);
    for (framebuffers) |*fb, i| {
        fb.* = try gc.vkd.createFramebuffer(gc.dev, &.{
            .flags = .{},
            .render_pass = render_pass,
            .attachment_count = 1,
            .p_attachments = vkutil.ptrToMany(&swapchain.swap_images[i].view),
            .width = swapchain.extent.width,
            .height = swapchain.extent.height,
            .layers = 1,
        }, null);
    }

    return framebuffers;
}

fn uploadMesh(gc: *const GraphicsContext, mesh: *Mesh) !void {
    // vert buffer
    {
        const buffer_size = mesh.vertices.items.len * @sizeOf(Vertex);

        const staging_buffer = try gc.vma.createUntypedBuffer(buffer_size, .{ .transfer_src_bit = true }, .cpu_only, .{});
        defer staging_buffer.deinit(gc.vma);

        // copy vertex data
        const verts = try gc.vma.mapMemory(Vertex, staging_buffer.allocation);
        std.mem.copy(Vertex, verts[0..mesh.vertices.items.len], mesh.vertices.items);
        gc.vma.unmapMemory(staging_buffer.allocation);

        // create Mesh vert buffer. we need transfer_src_bit for when we copy into a merged buffer later
        mesh.vert_buffer = try gc.vma.createUntypedBuffer(buffer_size, .{ .vertex_buffer_bit = true, .transfer_src_bit = true, .transfer_dst_bit = true }, .gpu_only, .{});

        // execute the copy command on the GPU
        const cmd_buf = try gc.beginOneTimeCommandBuffer();
        const copy_region = vk.BufferCopy{
            .src_offset = 0,
            .dst_offset = 0,
            .size = buffer_size,
        };
        gc.vkd.cmdCopyBuffer(cmd_buf, staging_buffer.buffer, mesh.vert_buffer.buffer, 1, @ptrCast([*]const vk.BufferCopy, &copy_region));
        try gc.endOneTimeCommandBuffer();
    }

    // index buffer
    {
        const buffer_size = mesh.indices.len * @sizeOf(u32);

        const staging_buffer = try gc.vma.createUntypedBuffer(buffer_size, .{ .transfer_src_bit = true }, .cpu_only, .{});
        defer staging_buffer.deinit(gc.vma);

        // copy index data
        const dst_indices = try gc.vma.mapMemory(u32, staging_buffer.allocation);
        std.mem.copy(u32, dst_indices[0..mesh.indices.len], mesh.indices);
        gc.vma.unmapMemory(staging_buffer.allocation);

        // create Mesh index buffer
        mesh.index_buffer = try gc.vma.createUntypedBuffer(buffer_size, .{ .index_buffer_bit = true, .transfer_src_bit = true, .transfer_dst_bit = true }, .gpu_only, .{});

        // execute the copy command on the GPU
        const cmd_buf = try gc.beginOneTimeCommandBuffer();
        const copy_region = vk.BufferCopy{
            .src_offset = 0,
            .dst_offset = 0,
            .size = buffer_size,
        };
        gc.vkd.cmdCopyBuffer(cmd_buf, staging_buffer.buffer, mesh.index_buffer.buffer, 1, @ptrCast([*]const vk.BufferCopy, &copy_region));
        try gc.endOneTimeCommandBuffer();
    }
}

fn loadTextureFromFile(gc: *const GraphicsContext, file: []const u8) !Texture {
    const img = try stb.loadFromFile(gc.gpa, file);
    defer img.deinit();

    // allocate temporary buffer for holding texture data to upload and copy image data to it
    const img_pixels = img.asSlice();
    const staging_buffer = try gc.vma.createUntypedBuffer(img_pixels.len, .{ .transfer_src_bit = true }, .cpu_only, .{});
    const data = try gc.vma.mapMemory(u8, staging_buffer.allocation);
    std.mem.copy(u8, data[0..img_pixels.len], img_pixels);
    gc.vma.unmapMemory(staging_buffer.allocation);

    const new_img = try uploadImage(gc, @intCast(u32, img.w), @intCast(u32, img.h), vk.Format.r8g8b8a8_srgb, staging_buffer);

    staging_buffer.deinit(gc.vma);
    return Texture.init(new_img);
}

fn loadTextureFromAsset(gc: *const GraphicsContext, file: []const u8) !Texture {
    const tex_asset = try assets.load(assets.TextureInfo, file);

    const staging_buffer = try gc.vma.createUntypedBuffer(tex_asset.info.size, .{ .transfer_src_bit = true }, .cpu_only, .{});
    const data = try gc.vma.mapMemory(u8, staging_buffer.allocation);
    std.mem.copy(u8, data[0..tex_asset.blob.len], tex_asset.blob);
    gc.vma.unmapMemory(staging_buffer.allocation);

    const new_img = try uploadImage(gc, tex_asset.info.width, tex_asset.info.height, vk.Format.r8g8b8a8_srgb, staging_buffer);

    staging_buffer.deinit(gc.vma);
    tex_asset.deinit();

    return Texture.init(new_img);
}

fn uploadImage(gc: *const GraphicsContext, width: u32, height: u32, format: vk.Format, staging_buffer: vma.AllocatedBufferUntyped) !vma.AllocatedImage {
    const img_extent = vk.Extent3D{
        .width = width,
        .height = height,
        .depth = 1,
    };
    const dimg_info = vkinit.imageCreateInfo(format, img_extent, .{ .sampled_bit = true, .transfer_dst_bit = true });
    const malloc_info = std.mem.zeroInit(vma.VmaAllocationCreateInfo, .{
        .usage = .gpu_only,
    });

    var new_img = try gc.vma.createImage(&dimg_info, &malloc_info, null);
    {
        const cmd_buf = try gc.beginOneTimeCommandBuffer();
        // barrier the image into the transfer-receive layout
        const range = vk.ImageSubresourceRange{
            .aspect_mask = .{ .color_bit = true },
            .base_mip_level = 0,
            .level_count = 1,
            .base_array_layer = 0,
            .layer_count = 1,
        };
        const img_barrier_to_transfer = std.mem.zeroInit(vk.ImageMemoryBarrier, .{
            .old_layout = .@"undefined",
            .new_layout = .transfer_dst_optimal,
            .dst_access_mask = .{ .transfer_write_bit = true },
            .image = new_img.image,
            .subresource_range = range,
        });

        gc.vkd.cmdPipelineBarrier(cmd_buf, .{ .top_of_pipe_bit = true }, .{ .transfer_bit = true }, .{}, 0, undefined, 0, undefined, 1, @ptrCast([*]const vk.ImageMemoryBarrier, &img_barrier_to_transfer));

        const copy_region = vk.BufferImageCopy{
            .buffer_offset = 0,
            .buffer_row_length = 0,
            .buffer_image_height = 0,
            .image_subresource = .{
                .aspect_mask = .{ .color_bit = true },
                .mip_level = 0,
                .base_array_layer = 0,
                .layer_count = 1,
            },
            .image_offset = std.mem.zeroes(vk.Offset3D),
            .image_extent = img_extent,
        };
        gc.vkd.cmdCopyBufferToImage(cmd_buf, staging_buffer.buffer, new_img.image, .transfer_dst_optimal, 1, @ptrCast([*]const vk.BufferImageCopy, &copy_region));

        // barrier the image into the shader readable layout
        const img_barrier_to_readable = std.mem.zeroInit(vk.ImageMemoryBarrier, .{
            .old_layout = .transfer_dst_optimal,
            .new_layout = .shader_read_only_optimal,
            .src_access_mask = .{ .transfer_write_bit = true },
            .dst_access_mask = .{ .shader_read_bit = true },
            .image = new_img.image,
            .subresource_range = range,
        });
        gc.vkd.cmdPipelineBarrier(cmd_buf, .{ .transfer_bit = true }, .{ .fragment_shader_bit = true }, .{}, 0, undefined, 0, undefined, 1, @ptrCast([*]const vk.ImageMemoryBarrier, &img_barrier_to_readable));
        try gc.endOneTimeCommandBuffer();
    }

    const image_info = vkinit.imageViewCreateInfo(format, new_img.image, .{ .color_bit = true });
    new_img.default_view = try gc.vkd.createImageView(gc.dev, &image_info, null);
    return new_img;
}
