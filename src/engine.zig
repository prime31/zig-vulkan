const std = @import("std");
const stb = @import("stb");
const vk = @import("vulkan");
const vma = @import("vma");
const resources = @import("resources");
const glfw = @import("glfw");
const ig = @import("imgui");
const igvk = @import("imgui_vk");
const vkinit = @import("vkinit.zig");
const vkutil = @import("vk_util/vk_util.zig");

const GraphicsContext = @import("graphics_context.zig").GraphicsContext;
const RenderScene = @import("render_scene.zig").RenderScene;
const Swapchain = @import("swapchain.zig").Swapchain;
const PipelineBuilder = vkutil.PipelineBuilder;
const Mesh = @import("mesh.zig").Mesh;
const RenderBounds = @import("mesh.zig").RenderBounds;
const Vertex = @import("mesh.zig").Vertex;
const Allocator = std.mem.Allocator;

const MeshObject = @import("render_scene.zig").MeshObject;
const FlyCamera = @import("chapters/FlyCamera.zig");

const Mat4 = @import("chapters/mat4.zig").Mat4;
const Vec3 = @import("chapters/vec3.zig").Vec3;
const Vec4 = @import("chapters/vec4.zig").Vec4;

const FRAME_OVERLAP: usize = 2;

fn toRadians(deg: anytype) @TypeOf(deg) {
    return std.math.pi * deg / 180.0;
}

fn toDegrees(rad: anytype) @TypeOf(rad) {
    return 180.0 * rad / std.math.pi;
}

const GpuObjectData = struct {
    model: Mat4,
};

pub const Texture = struct {
    image: vma.AllocatedImage,
    view: vk.ImageView,

    pub fn init(image: vma.AllocatedImage) Texture {
        return .{ .image = image, .view = undefined };
    }

    pub fn deinit(self: Texture, gc: *const GraphicsContext) void {
        // only destroy the view if it isnt the default view from the AllocatedImage
        if (self.view != self.image.default_view)
            gc.destroy(self.view);
        self.image.deinit(gc.vma);
    }
};

const DirectionalLight = struct {
    light_pos: Vec3,
    light_dir: Vec3,
    shadow_extent: Vec3,
};

const GpuCameraData = struct {
    view: Mat4,
    proj: Mat4,
    view_proj: Mat4,
};

const GpuSceneData = struct {
    fog_color: Vec4 = Vec4.new(1, 0, 0, 1),
    fog_distance: Vec4 = Vec4.new(1, 0, 0, 1),
    ambient_color: Vec4 = Vec4.new(1, 0, 0, 1),
    sun_dir: Vec4 = Vec4.new(1, 0, 0, 1),
    sun_color: Vec4 = Vec4.new(1, 0, 0, 1),
};

const MeshDrawCommands = struct {
    const RenderBatch = struct {
        object: MeshObject,
        sort_key: u64,
        object_index: u64,
    };

    batch: std.ArrayList(RenderBatch),
};

const OldMaterial = struct {
    texture_set: ?vk.DescriptorSet = null,
    pipeline: vk.Pipeline,
    pipeline_layout: vk.PipelineLayout,

    pub fn init(pipeline: vk.Pipeline, pipeline_layout: vk.PipelineLayout) OldMaterial {
        return .{
            .pipeline = pipeline,
            .pipeline_layout = pipeline_layout,
        };
    }

    pub fn deinit(self: OldMaterial, gc: *const GraphicsContext) void {
        gc.destroy(self.pipeline);
        gc.destroy(self.pipeline_layout);
    }
};

const FrameData = struct {
    deletion_queue: vkutil.DeletionQueue,
    cmd_pool: vk.CommandPool,
    cmd_buffer: vk.CommandBuffer,
    dynamic_data: vkutil.PushBuffer,
    dynamic_descriptor_allocator: vkutil.DescriptorAllocator,

    camera_buffer: vma.AllocatedBufferUntyped,
    global_descriptor: vk.DescriptorSet,
    object_buffer: vma.AllocatedBufferUntyped,
    object_descriptor: vk.DescriptorSet,

    pub fn init(gc: *GraphicsContext, descriptor_set_layout: vk.DescriptorSetLayout, descriptor_pool: vk.DescriptorPool, scene_param_buffer: vma.AllocatedBufferUntyped, object_set_layout: vk.DescriptorSetLayout) !FrameData {
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

        // descriptor set setup
        var camera_buffer = try gc.vma.createUntypedBuffer(@sizeOf(GpuCameraData), .{ .uniform_buffer_bit = true }, .cpu_to_gpu, .{});

        const max_objects: usize = 10_000;
        var object_buffer = try gc.vma.createUntypedBuffer(@sizeOf(GpuObjectData) * max_objects, .{ .storage_buffer_bit = true }, .cpu_to_gpu, .{});

        var global_descriptor: vk.DescriptorSet = undefined;
        try gc.vkd.allocateDescriptorSets(gc.dev, &.{
            .descriptor_pool = descriptor_pool,
            .descriptor_set_count = 1,
            .p_set_layouts = @ptrCast([*]const vk.DescriptorSetLayout, &descriptor_set_layout),
        }, @ptrCast([*]vk.DescriptorSet, &global_descriptor));

        // allocate the descriptor set that will point to object buffer
        var object_descriptor: vk.DescriptorSet = undefined;
        try gc.vkd.allocateDescriptorSets(gc.dev, &.{
            .descriptor_pool = descriptor_pool,
            .descriptor_set_count = 1,
            .p_set_layouts = @ptrCast([*]const vk.DescriptorSetLayout, &object_set_layout),
        }, @ptrCast([*]vk.DescriptorSet, &object_descriptor));

        // information about the buffer we want to point at in the descriptor
        const cam_info = vk.DescriptorBufferInfo{
            .buffer = camera_buffer.buffer,
            .offset = 0,
            .range = @sizeOf(GpuCameraData),
        };

        const scene_info = vk.DescriptorBufferInfo{
            .buffer = scene_param_buffer.buffer,
            .offset = 0,
            .range = @sizeOf(GpuSceneData),
        };

        const object_buffer_info = vk.DescriptorBufferInfo{
            .buffer = object_buffer.buffer,
            .offset = 0,
            .range = @sizeOf(GpuObjectData) * max_objects,
        };

        const camera_write = vkinit.writeDescriptorBuffer(.uniform_buffer, global_descriptor, &cam_info, 0);
        const scene_write = vkinit.writeDescriptorBuffer(.uniform_buffer_dynamic, global_descriptor, &scene_info, 1);
        const object_write = vkinit.writeDescriptorBuffer(.storage_buffer, object_descriptor, &object_buffer_info, 0);

        const set_writes = [_]vk.WriteDescriptorSet{ camera_write, scene_write, object_write };
        gc.vkd.updateDescriptorSets(gc.dev, 3, &set_writes, 0, undefined);

        return FrameData{
            .deletion_queue = vkutil.DeletionQueue.init(gpa, gc),
            .cmd_pool = cmd_pool,
            .cmd_buffer = cmd_buffer,
            .dynamic_data = try vkutil.PushBuffer.init(gc, dynamic_data_buffer),
            .dynamic_descriptor_allocator = vkutil.DescriptorAllocator.init(gc),

            .camera_buffer = camera_buffer,
            .global_descriptor = global_descriptor,
            .object_buffer = object_buffer,
            .object_descriptor = object_descriptor,
        };
    }

    pub fn deinit(self: *FrameData, gc: *GraphicsContext) void {
        self.deletion_queue.deinit();
        gc.vkd.freeCommandBuffers(gc.dev, self.cmd_pool, 1, @ptrCast([*]vk.CommandBuffer, &self.cmd_buffer));
        gc.destroy(self.cmd_pool);
        self.dynamic_data.deinit(gc.vma);
        self.dynamic_descriptor_allocator.deinit();

        self.camera_buffer.deinit(gc.vma);
        self.object_buffer.deinit(gc.vma);
    }
};

const OldRenderObject = struct {
    mesh: *Mesh,
    material: *OldMaterial,
    transform_matrix: Mat4,
};

var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{ .thread_safe = false }){};
const gpa = general_purpose_allocator.allocator();

pub const Engine = struct {
    const Self = @This();

    allocator: Allocator,
    window: glfw.Window,
    gc: *GraphicsContext,
    swapchain: Swapchain,
    framebuffers: []vk.Framebuffer,
    frames: []FrameData,
    deletion_queue: vkutil.DeletionQueue,
    old_render_pass: vk.RenderPass,
    render_pass: vk.RenderPass,
    shadow_pass: vk.RenderPass,
    copy_pass: vk.RenderPass,

    // framebuffers
    render_format: vk.Format = .r32g32b32a32_sfloat,
    raw_render_image: vma.AllocatedImage = undefined,
    smooth_sampler: vk.Sampler = undefined,
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

    descriptor_allocator: vkutil.DescriptorAllocator = undefined,
    descriptor_layout_cache: vkutil.DescriptorLayoutCache = undefined,
    material_system: vkutil.MaterialSystem = undefined,

    single_texture_set_layout: vk.DescriptorSetLayout = undefined,
    scene_params: GpuSceneData,

    upload_barriers: std.ArrayList(vk.BufferMemoryBarrier) = undefined,
    cull_ready_barriers: std.ArrayList(vk.BufferMemoryBarrier) = undefined,
    post_cull_barriers: std.ArrayList(vk.BufferMemoryBarrier) = undefined,

    camera: FlyCamera,
    main_light: DirectionalLight = undefined,
    cull_pipeline: vk.Pipeline = undefined,
    cull_layout: vk.PipelineLayout = undefined,
    depth_reduce_pipeline: vk.Pipeline = undefined,
    depth_reduce_layout: vk.PipelineLayout = undefined,
    sparse_upload_pipeline: vk.Pipeline = undefined,
    sparse_upload_layout: vk.PipelineLayout = undefined,
    blit_pipeline: vk.Pipeline = undefined,
    blit_layout: vk.PipelineLayout = undefined,

    depth_sampler: vk.Sampler = undefined,
    depth_pyramid_mips: [16]vk.ImageView = undefined,

    current_commands: MeshDrawCommands = undefined,
    render_scene: RenderScene = undefined,

    frame_num: f32 = 0,
    dt: f64 = 0.0,
    last_frame_time: f64 = 0.0,

    shader_cache: vkutil.ShaderCache,
    renderables: std.ArrayList(OldRenderObject),
    materials: std.StringHashMap(OldMaterial),
    meshes: std.StringHashMap(Mesh),
    textures: std.StringHashMap(Texture),

    global_set_layout: vk.DescriptorSetLayout,
    object_set_layout: vk.DescriptorSetLayout,
    single_tex_layout: vk.DescriptorSetLayout = undefined,
    descriptor_pool: vk.DescriptorPool,
    imgui_pool: vk.DescriptorPool = undefined,

    scene_param_buffer: vma.AllocatedBufferUntyped,
    blocky_sampler: vk.Sampler = undefined,

    pub fn init(app_name: [*:0]const u8) !Self {
        try glfw.init(.{});

        var extent = vk.Extent2D{ .width = 800, .height = 600 };
        const window = try glfw.Window.create(extent.width, extent.height, app_name, null, null, .{
            .client_api = .no_api,
        });

        var gc = try gpa.create(GraphicsContext);
        gc.* = try GraphicsContext.init(gpa, app_name, window);

        var deletion_queue = vkutil.DeletionQueue.init(gpa, gc);

        // swapchain and RenderPasses
        var swapchain = try Swapchain.init(gc, gpa, extent, FRAME_OVERLAP);
        const old_render_pass = try createOldForwardRenderPass(gc, .d32_sfloat, swapchain);
        const render_pass = try createForwardRenderPass(gc, .d32_sfloat);
        const copy_pass = try createCopyRenderPass(gc, swapchain);
        const shadow_pass = try createShadowRenderPass(gc, .d32_sfloat);

        deletion_queue.append(old_render_pass);
        deletion_queue.append(render_pass);
        deletion_queue.append(copy_pass);
        deletion_queue.append(shadow_pass);

        // depth image and Swapchain framebuffers
        const depth_image = try createDepthImage(gc, .d32_sfloat, swapchain);
        const framebuffers = try createSwapchainFramebuffers(gc, gpa, old_render_pass, swapchain, depth_image.view);

        // descriptors
        const descriptors = createOldDescriptors(gc);

        // create our FrameDatas
        const frames = try gpa.alloc(FrameData, swapchain.swap_images.len);
        errdefer gpa.free(frames);
        for (frames) |*f| f.* = try FrameData.init(gc, descriptors.layout, descriptors.pool, descriptors.scene_param_buffer, descriptors.object_set_layout);

        return Self{
            .allocator = gpa,
            .window = window,
            .gc = gc,
            .swapchain = swapchain,
            .old_render_pass = old_render_pass,
            .render_pass = render_pass,
            .copy_pass = copy_pass,
            .shadow_pass = shadow_pass,

            .deletion_queue = deletion_queue,
            .framebuffers = framebuffers,
            .frames = frames,
            .depth_image = depth_image,
            .render_scene = RenderScene.init(gc),
            .shader_cache = vkutil.ShaderCache.init(gc),
            .renderables = std.ArrayList(OldRenderObject).init(gpa),
            .materials = std.StringHashMap(OldMaterial).init(gpa),
            .meshes = std.StringHashMap(Mesh).init(gpa),
            .textures = std.StringHashMap(Texture).init(gpa),

            .upload_barriers = std.ArrayList(vk.BufferMemoryBarrier).init(gpa),
            .cull_ready_barriers = std.ArrayList(vk.BufferMemoryBarrier).init(gpa),
            .post_cull_barriers = std.ArrayList(vk.BufferMemoryBarrier).init(gpa),

            .camera = FlyCamera.init(window),
            .global_set_layout = descriptors.layout,
            .object_set_layout = descriptors.object_set_layout,
            .descriptor_pool = descriptors.pool,
            .scene_params = .{},
            .scene_param_buffer = descriptors.scene_param_buffer,
        };
    }

    pub fn deinit(self: *Self) void {
        self.gc.vkd.deviceWaitIdle(self.gc.dev) catch unreachable;

        igvk.shutdown();
        ig.igDestroyContext(null);
        self.gc.destroy(self.imgui_pool);

        self.gc.destroy(self.blocky_sampler);

        self.scene_param_buffer.deinit(self.gc.vma);
        self.gc.destroy(self.object_set_layout);
        self.gc.destroy(self.global_set_layout);
        self.gc.destroy(self.descriptor_pool);

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
        self.allocator.free(self.frames);

        for (self.framebuffers) |fb| self.gc.destroy(fb);
        self.allocator.free(self.framebuffers);

        var mat_iter = self.materials.valueIterator();
        while (mat_iter.next()) |mat| mat.deinit(self.gc);
        self.materials.deinit();

        self.deletion_queue.deinit();

        self.swapchain.deinit();
        self.gc.deinit();
        self.allocator.destroy(self.gc);

        self.window.destroy();
        glfw.terminate();

        self.renderables.deinit();
        _ = general_purpose_allocator.deinit();
    }

    pub fn loadContent(self: *Self) !void {
        try self.createFramebuffers();
        try self.createDepthSetup();
        try self.createDescriptors();
        try self.createPipelines();

        try self.initImgui();
        try self.loadImages();
        try self.loadMeshes();
        try self.initOldPipelines();
        try self.initScene();
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

            // wait for the last frame to complete before filling our CommandBuffer
            const state = self.swapchain.waitForFrame() catch |err| switch (err) {
                error.OutOfDateKHR => Swapchain.PresentState.suboptimal,
                else => |narrow| return narrow,
            };

            const frame = self.frames[self.swapchain.frame_index % self.swapchain.swap_images.len];
            try self.draw(self.framebuffers[self.swapchain.image_index], frame);

            try self.swapchain.present(frame.cmd_buffer);

            // TODO: why does this have to be after present?
            if (state == .suboptimal) {
                try self.swapchain.waitForAllFences();

                const size = try self.window.getSize();
                var extent = vk.Extent2D{ .width = size.width, .height = size.height };
                try self.swapchain.recreate(extent);

                for (self.framebuffers) |fb| self.gc.destroy(fb);
                self.allocator.free(self.framebuffers);

                self.depth_image.deinit(self.gc);
                self.depth_image = try createDepthImage(self.gc, self.depth_format, self.swapchain);
                self.framebuffers = try createSwapchainFramebuffers(self.gc, self.allocator, self.old_render_pass, self.swapchain, self.depth_image.view);
            }

            self.frame_num += 1;
            try glfw.pollEvents();
        }
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
            level_info.subresource_range.base_mip_level = 1;

            self.depth_pyramid_mips[i] = try self.gc.vkd.createImageView(self.gc.dev, &level_info, null);
        }

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

        var shadow_sampler_info = vkinit.samplerCreateInfo(.linear, .clamp_to_border);
        shadow_sampler_info.border_color = .float_opaque_white;
        shadow_sampler_info.compare_enable = vk.TRUE;
        shadow_sampler_info.compare_op = .less;
        self.shadow_sampler = try self.gc.vkd.createSampler(self.gc.dev, &shadow_sampler_info, null);
        self.deletion_queue.append(self.shadow_sampler);
    }

    fn createDescriptors(self: *Self) !void {
        self.descriptor_allocator = vkutil.DescriptorAllocator.init(self.gc);
        self.descriptor_layout_cache = vkutil.DescriptorLayoutCache.init(self.gc);

        const texture_bind = vkinit.descriptorSetLayoutBinding(.combined_image_sampler, .{ .fragment_bit = true }, 0);
        self.single_tex_layout = try self.descriptor_layout_cache.createDescriptorSetLayout(&.{
            .flags = .{},
            .binding_count = 1,
            .p_bindings = vkutil.ptrToMany(&texture_bind),
        });
    }

    fn createPipelines(self: *Self) !void {
        self.material_system = try vkutil.MaterialSystem.init(self);
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
        _ = igvk.ImGui_ImplVulkan_Init(&info, self.old_render_pass);

        // execute a gpu command to upload imgui font textures
        const cmd_buf = try self.gc.beginOneTimeCommandBuffer();
        _ = igvk.ImGui_ImplVulkan_CreateFontsTexture(cmd_buf);
        try self.gc.endOneTimeCommandBuffer();

        // clear font textures from cpu data
        igvk.ImGui_ImplVulkan_DestroyFontUploadObjects();
    }

    fn loadImages(self: *Self) !void {
        const lost_empire_img = try loadTextureFromFile(self.gc, self.allocator, "src/chapters/lost_empire-RGBA.png");
        const lost_empire_tex = Texture{
            .image = lost_empire_img,
            .view = lost_empire_img.default_view,
        };
        self.deletion_queue.append(lost_empire_img.default_view);
        try self.textures.put("empire_diffuse", lost_empire_tex);
    }

    fn loadMeshes(self: *Self) !void {
        var tri_mesh = Mesh.init(gpa);
        try tri_mesh.vertices.append(.{ .position = .{ 1, 1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0.6, 0.6, 0.6 }, .uv = .{ 1, 0 } });
        try tri_mesh.vertices.append(.{ .position = .{ -1, 1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0.6, 0.6, 0.6 }, .uv = .{ 0, 0 } });
        try tri_mesh.vertices.append(.{ .position = .{ 0, -1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0.6, 0.6, 0.6 }, .uv = .{ 0.5, 1 } });

        var monkey_mesh = try Mesh.initFromObj(gpa, "src/chapters/monkey_flat.obj");
        var cube_thing_mesh = try Mesh.initFromObj(gpa, "src/chapters/cube_thing.obj");
        var cube = try Mesh.initFromObj(gpa, "src/chapters/cube.obj");
        var lost_empire = try Mesh.initFromObj(gpa, "src/chapters/lost_empire.obj");

        try uploadMesh(self.gc, &tri_mesh);
        try uploadMesh(self.gc, &monkey_mesh);
        try uploadMesh(self.gc, &cube_thing_mesh);
        try uploadMesh(self.gc, &cube);
        try uploadMesh(self.gc, &lost_empire);

        try self.meshes.put("triangle", tri_mesh);
        try self.meshes.put("monkey", monkey_mesh);
        try self.meshes.put("cube_thing", cube_thing_mesh);
        try self.meshes.put("cube", cube);
        try self.meshes.put("lost_empire", lost_empire);
    }

    fn initOldPipelines(self: *Self) !void {
        // push-constant setup
        var pip_layout_info = vkinit.pipelineLayoutCreateInfo();

        // hook the global set layout and object set layout
        const set_layouts = [_]vk.DescriptorSetLayout{ self.global_set_layout, self.object_set_layout };
        pip_layout_info.set_layout_count = 2;
        pip_layout_info.p_set_layouts = &set_layouts;

        const pipeline_layout = try self.gc.vkd.createPipelineLayout(self.gc.dev, &pip_layout_info, null);
        const pipeline = try createPipeline(self.gc, self.old_render_pass, pipeline_layout, resources.default_lit_old_frag);
        const material = OldMaterial{
            .pipeline = pipeline,
            .pipeline_layout = pipeline_layout,
        };
        try self.materials.put("defaultmesh", material);

        const pipeline_layout2 = try self.gc.vkd.createPipelineLayout(self.gc.dev, &pip_layout_info, null);
        const pipeline2 = try createPipeline(self.gc, self.old_render_pass, pipeline_layout2, resources.default_lit_old_frag);
        const material2 = OldMaterial{
            .pipeline = pipeline2,
            .pipeline_layout = pipeline_layout2,
        };
        try self.materials.put("redmesh", material2);

        // create pipeline layout for the textured mesh, which has 3 descriptor sets
        const textured_set_layouts = [_]vk.DescriptorSetLayout{ self.global_set_layout, self.object_set_layout, self.single_tex_layout };

        var textured_pip_layout_info = vkinit.pipelineLayoutCreateInfo();
        textured_pip_layout_info.set_layout_count = 4;
        textured_pip_layout_info.p_set_layouts = &textured_set_layouts;

        const textured_pipeline_layout = try self.gc.vkd.createPipelineLayout(self.gc.dev, &textured_pip_layout_info, null);
        const textured_pipeline = try createPipeline(self.gc, self.old_render_pass, textured_pipeline_layout, resources.textured_lit_frag);
        const textured_material = OldMaterial{
            .pipeline = textured_pipeline,
            .pipeline_layout = textured_pipeline_layout,
        };
        try self.materials.put("texturedmesh", textured_material);
    }

    fn initScene(self: *Self) !void {
        // create a sampler for the texture
        const sampler_info = vkinit.samplerCreateInfo(.nearest, vk.SamplerAddressMode.repeat);
        self.blocky_sampler = try self.gc.vkd.createSampler(self.gc.dev, &sampler_info, null);

        const textured_mat = self.materials.getPtr("texturedmesh").?;

        // allocate the descriptor set for single-texture to use on the material
        const alloc_info = std.mem.zeroInit(vk.DescriptorSetAllocateInfo, .{
            .descriptor_pool = self.descriptor_pool,
            .descriptor_set_count = 1,
            .p_set_layouts = vkutil.ptrToMany(&self.single_tex_layout),
        });
        var texture_set: vk.DescriptorSet = undefined;
        try self.gc.vkd.allocateDescriptorSets(self.gc.dev, &alloc_info, vkutil.ptrToMany(&texture_set));
        textured_mat.texture_set = texture_set;

        // write to the descriptor set so that it points to our empire_diffuse texture
        const image_buffer_info = vk.DescriptorImageInfo{
            .sampler = self.blocky_sampler,
            .image_view = self.textures.getPtr("empire_diffuse").?.view,
            .image_layout = .shader_read_only_optimal,
        };
        const texture1 = vkinit.writeDescriptorImage(.combined_image_sampler, textured_mat.texture_set.?, &image_buffer_info, 0);
        self.gc.vkd.updateDescriptorSets(self.gc.dev, 1, @ptrCast([*]const vk.WriteDescriptorSet, &texture1), 0, undefined);

        // create some objects
        var monkey = OldRenderObject{
            .mesh = self.meshes.getPtr("monkey").?,
            .material = self.materials.getPtr("defaultmesh").?,
            .transform_matrix = Mat4.createTranslation(Vec3.new(0, 2, 0)),
        };
        try self.renderables.append(monkey);

        var empire = OldRenderObject{
            .mesh = self.meshes.getPtr("lost_empire").?,
            .material = self.materials.getPtr("texturedmesh").?,
            .transform_matrix = Mat4.createTranslation(Vec3.new(0, 5, 0)),
        };
        try self.renderables.append(empire);

        var x: f32 = 0;
        while (x < 20) : (x += 1) {
            var y: f32 = 0;
            while (y < 20) : (y += 1) {
                var matrix = Mat4.createTranslation(.{ .x = x, .y = 0, .z = y });
                var scale_matrix = Mat4.createScale(.{ .x = 0.4, .y = 0.4, .z = 0.4 });

                const mesh_material = if (@mod(x, 2) == 0) self.materials.getPtr("texturedmesh").? else self.materials.getPtr("redmesh").?;
                const mesh = if (@mod(x, 2) == 0 and @mod(x, 6) == 0) self.meshes.getPtr("cube_thing").? else self.meshes.getPtr("triangle").?;
                var object = OldRenderObject{
                    .mesh = mesh,
                    .material = mesh_material,
                    .transform_matrix = Mat4.mul(matrix, scale_matrix),
                };
                try self.renderables.append(object);

                matrix = Mat4.createTranslation(.{ .x = x, .y = 0.8, .z = y });
                scale_matrix = Mat4.createScale(.{ .x = 0.2, .y = 0.2, .z = 0.2 });

                object = OldRenderObject{
                    .mesh = mesh,
                    .material = mesh_material,
                    .transform_matrix = Mat4.mul(matrix, scale_matrix),
                };
                try self.renderables.append(object);

                matrix = Mat4.createTranslation(.{ .x = x, .y = -0.8, .z = y });
                object = OldRenderObject{
                    .mesh = mesh,
                    .material = mesh_material,
                    .transform_matrix = Mat4.mul(matrix, scale_matrix),
                };
                try self.renderables.append(object);
            }
        }
    }

    fn draw(self: *Self, framebuffer: vk.Framebuffer, frame: FrameData) !void {
        ig.igRender();
        if ((ig.igGetIO().*.ConfigFlags & ig.ImGuiConfigFlags_ViewportsEnable) != 0) {
            ig.igUpdatePlatformWindows();
            ig.igRenderPlatformWindowsDefault(null, null);
        }

        const cmdbuf = frame.cmd_buffer;
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

        try self.gc.vkd.resetCommandBuffer(cmdbuf, .{});
        try self.gc.vkd.beginCommandBuffer(cmdbuf, &.{
            .flags = .{ .one_time_submit_bit = true },
            .p_inheritance_info = null,
        });

        self.gc.vkd.cmdSetViewport(cmdbuf, 0, 1, @ptrCast([*]const vk.Viewport, &viewport));
        self.gc.vkd.cmdSetScissor(cmdbuf, 0, 1, @ptrCast([*]const vk.Rect2D, &render_area));

        self.gc.vkd.cmdBeginRenderPass(cmdbuf, &.{
            .render_pass = self.old_render_pass,
            .framebuffer = framebuffer,
            .render_area = render_area,
            .clear_value_count = clear_values.len,
            .p_clear_values = @ptrCast([*]const vk.ClearValue, &clear_values),
        }, .@"inline");

        try self.drawRenderObjects(frame);

        igvk.ImGui_ImplVulkan_RenderDrawData(ig.igGetDrawData(), cmdbuf, .null_handle);
        self.gc.vkd.cmdEndRenderPass(cmdbuf);
        try self.gc.vkd.endCommandBuffer(cmdbuf);
    }

    fn drawRenderObjects(self: *Self, frame: FrameData) !void {
        const cmdbuf = frame.cmd_buffer;

        var view = self.camera.getViewMatrix();
        var proj = Mat4.createPerspective(toRadians(70.0), @intToFloat(f32, self.swapchain.extent.width) / @intToFloat(f32, self.swapchain.extent.height), 0.1, 200);
        proj.fields[1][1] *= -1;
        var view_proj = Mat4.mul(proj, view);

        // fill a GPU camera data struct
        const cam_data = GpuCameraData{
            .view = view,
            .proj = proj,
            .view_proj = view_proj,
        };

        // and copy it to the buffer
        const cam_data_ptr = try self.gc.vma.mapMemory(GpuCameraData, frame.camera_buffer.allocation);
        cam_data_ptr.* = cam_data;
        self.gc.vma.unmapMemory(frame.camera_buffer.allocation);

        // scene params
        const framed = self.frame_num / 12;
        self.scene_params.ambient_color = Vec4.new((std.math.sin(framed) + 1) * 0.5, 1, (std.math.cos(framed) + 1) * 0.5, 1);

        const frame_index = @floatToInt(usize, self.frame_num) % FRAME_OVERLAP;
        const data_offset = padUniformBufferSize(self.gc, @sizeOf(GpuSceneData)) * frame_index;
        const scene_data_ptr = (try self.gc.vma.mapMemoryAtOffset(GpuSceneData, self.scene_param_buffer.allocation, data_offset));
        scene_data_ptr.* = self.scene_params;
        self.gc.vma.unmapMemory(self.scene_param_buffer.allocation);

        // object SSBO
        const object_data_ptr = try self.gc.vma.mapMemory(GpuObjectData, frame.object_buffer.allocation);
        for (self.renderables.items) |*object, i| {
            var rot = Mat4.createAngleAxis(.{ .y = 1 }, toRadians(25.0) * self.frame_num * 0.04 + @intToFloat(f32, i));
            object_data_ptr[i].model = object.transform_matrix.mul(rot);
        }
        self.gc.vma.unmapMemory(frame.object_buffer.allocation);

        var last_mesh: *Mesh = @intToPtr(*Mesh, @ptrToInt(&self));
        var last_material: *OldMaterial = @intToPtr(*OldMaterial, @ptrToInt(&self));

        for (self.renderables.items) |*object, i| {
            // only bind the pipeline if it doesnt match with the already bound one
            if (object.material != last_material) {
                last_material = object.material;
                self.gc.vkd.cmdBindPipeline(cmdbuf, .graphics, object.material.pipeline);

                // offset for our scene buffer
                const uniform_offset = padUniformBufferSize(self.gc, @sizeOf(GpuSceneData)) * frame_index;

                // bind the descriptor set when changing pipeline
                self.gc.vkd.cmdBindDescriptorSets(cmdbuf, .graphics, object.material.pipeline_layout, 0, 1, @ptrCast([*]const vk.DescriptorSet, &frame.global_descriptor), 1, @ptrCast([*]const u32, &uniform_offset));

                // bind the object data descriptor
                self.gc.vkd.cmdBindDescriptorSets(cmdbuf, .graphics, object.material.pipeline_layout, 1, 1, @ptrCast([*]const vk.DescriptorSet, &frame.object_descriptor), 0, undefined);

                if (object.material.texture_set) |texture_set| {
                    self.gc.vkd.cmdBindDescriptorSets(cmdbuf, .graphics, object.material.pipeline_layout, 2, 1, @ptrCast([*]const vk.DescriptorSet, &texture_set), 0, undefined);
                }
            }

            var model = object.transform_matrix;
            var rot = Mat4.createAngleAxis(.{ .y = 1 }, toRadians(25.0) * self.frame_num * 0.04);
            model = model.mul(rot);

            // only bind the mesh if its a different one from last bind
            if (object.mesh != last_mesh) {
                last_mesh = object.mesh;
                // bind the mesh vertex buffer with offset 0
                var offset: vk.DeviceSize = 0;
                self.gc.vkd.cmdBindVertexBuffers(cmdbuf, 0, 1, @ptrCast([*]const vk.Buffer, &object.mesh.vert_buffer.buffer), @ptrCast([*]const vk.DeviceSize, &offset));
                self.gc.vkd.cmdBindIndexBuffer(cmdbuf, object.mesh.index_buffer.buffer, 0, .uint32);
            }

            // self.gc.vkd.cmdDraw(cmdbuf, @intCast(u32, object.mesh.vertices.items.len), 1, 0, @intCast(u32, i));
            self.gc.vkd.cmdDrawIndexed(cmdbuf, last_mesh.index_count, 1, 0, 0, @intCast(u32, i));
        }
    }
};

fn createOldForwardRenderPass(gc: *const GraphicsContext, depth_format: vk.Format, swapchain: Swapchain) !vk.RenderPass {
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
        .src_stage_mask = .{ .color_attachment_output_bit = true },
        .src_access_mask = .{},
        .dst_stage_mask = .{ .color_attachment_output_bit = true },
        .dst_access_mask = .{ .color_attachment_write_bit = true },
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
    const dimg_info = vkinit.imageCreateInfo(depth_format, depth_extent, .{ .depth_stencil_attachment_bit = true });

    // we want to allocate it from GPU local memory
    var malloc_info = std.mem.zeroInit(vma.VmaAllocationCreateInfo, .{
        .flags = .{},
        .usage = .gpu_only,
        .requiredFlags = .{ .device_local_bit = true },
    });
    var depth_image = Texture.init(try gc.vma.createImage(&dimg_info, &malloc_info, null));

    const dview_info = vkinit.imageViewCreateInfo(depth_format, depth_image.image.image, .{ .depth_bit = true });
    depth_image.view = try gc.vkd.createImageView(gc.dev, &dview_info, null);

    return depth_image;
}

fn createSwapchainFramebuffers(gc: *const GraphicsContext, allocator: Allocator, render_pass: vk.RenderPass, swapchain: Swapchain, depth_image_view: vk.ImageView) ![]vk.Framebuffer {
    const framebuffers = try allocator.alloc(vk.Framebuffer, swapchain.swap_images.len);
    for (framebuffers) |*fb, i| {
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

fn createPipeline(gc: *const GraphicsContext, render_pass: vk.RenderPass, pipeline_layout: vk.PipelineLayout, frag_shader_bytes: [:0]const u8) !vk.Pipeline {
    const vert = try createShaderModule(gc, @ptrCast([*]const u32, resources.tri_mesh_descriptors_vert), resources.tri_mesh_descriptors_vert.len);
    const frag = try createShaderModule(gc, @ptrCast([*]const u32, @alignCast(@alignOf(u32), std.mem.bytesAsSlice(u32, frag_shader_bytes))), frag_shader_bytes.len);

    defer gc.destroy(vert);
    defer gc.destroy(frag);

    var builder = PipelineBuilder.init();
    builder.pipeline_layout = pipeline_layout;
    builder.depth_stencil = vkinit.pipelineDepthStencilCreateInfo(true, true, .less_or_equal);
    builder.vertex_description = Vertex.vertex_description;

    try builder.addShaderStage(createShaderStageCreateInfo(vert, .{ .vertex_bit = true }));
    try builder.addShaderStage(createShaderStageCreateInfo(frag, .{ .fragment_bit = true }));
    return try builder.build(gc, render_pass);
}

fn padUniformBufferSize(gc: *const GraphicsContext, size: usize) usize {
    const min_ubo_alignment = gc.gpu_props.limits.min_uniform_buffer_offset_alignment;
    var aligned_size = size;
    if (min_ubo_alignment > 0)
        aligned_size = (aligned_size + min_ubo_alignment - 1) & ~(min_ubo_alignment - 1);
    return aligned_size;
}

fn createOldDescriptors(gc: *const GraphicsContext) struct { layout: vk.DescriptorSetLayout, pool: vk.DescriptorPool, scene_param_buffer: vma.AllocatedBufferUntyped, object_set_layout: vk.DescriptorSetLayout } {
    // binding for camera data at 0
    const cam_bind = vkinit.descriptorSetLayoutBinding(.uniform_buffer, .{ .vertex_bit = true }, 0);

    // binding for scene data at 1
    const scene_bind = vkinit.descriptorSetLayoutBinding(.uniform_buffer_dynamic, .{ .vertex_bit = true, .fragment_bit = true }, 1);
    const bindings = [_]vk.DescriptorSetLayoutBinding{ cam_bind, scene_bind };

    const set_info = vk.DescriptorSetLayoutCreateInfo{
        .flags = .{},
        .binding_count = 2,
        .p_bindings = &bindings,
    };
    const global_set_layout = gc.vkd.createDescriptorSetLayout(gc.dev, &set_info, null) catch unreachable;

    // binding for object data at 0
    const object_bind = vkinit.descriptorSetLayoutBinding(.storage_buffer, .{ .vertex_bit = true }, 0);
    const set_info_object = vk.DescriptorSetLayoutCreateInfo{
        .flags = .{},
        .binding_count = 1,
        .p_bindings = @ptrCast([*]const vk.DescriptorSetLayoutBinding, &object_bind),
    };
    const object_set_layout = gc.vkd.createDescriptorSetLayout(gc.dev, &set_info_object, null) catch unreachable;

    const sizes = [_]vk.DescriptorPoolSize{
        .{ .@"type" = .uniform_buffer, .descriptor_count = 10 },
        .{ .@"type" = .uniform_buffer_dynamic, .descriptor_count = 10 },
        .{ .@"type" = .storage_buffer, .descriptor_count = 10 },
        .{ .@"type" = .combined_image_sampler, .descriptor_count = 10 },
    };
    var descriptor_pool = gc.vkd.createDescriptorPool(gc.dev, &.{
        .flags = .{},
        .max_sets = 10,
        .pool_size_count = 4,
        .p_pool_sizes = &sizes,
    }, null) catch unreachable;

    const scene_param_buffer_size = FRAME_OVERLAP * padUniformBufferSize(gc, @sizeOf(GpuSceneData));
    const scene_param_buffer = gc.vma.createUntypedBuffer(scene_param_buffer_size, .{ .uniform_buffer_bit = true }, .cpu_to_gpu, .{}) catch unreachable;

    return .{
        .layout = global_set_layout,
        .pool = descriptor_pool,
        .scene_param_buffer = scene_param_buffer,
        .object_set_layout = object_set_layout,
    };
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

        // create Mesh buffer
        mesh.vert_buffer = try gc.vma.createUntypedBuffer(buffer_size, .{ .vertex_buffer_bit = true, .transfer_dst_bit = true }, .gpu_only, .{});

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

        // create Mesh buffer
        mesh.index_buffer = try gc.vma.createUntypedBuffer(buffer_size, .{ .index_buffer_bit = true, .transfer_dst_bit = true }, .gpu_only, .{});

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

fn loadTextureFromFile(gc: *const GraphicsContext, allocator: Allocator, file: []const u8) !vma.AllocatedImage {
    const img = try stb.loadFromFile(allocator, file);
    defer img.deinit();

    // allocate temporary buffer for holding texture data to upload and copy image data to it
    const img_pixels = img.asSlice();
    const staging_buffer = try gc.vma.createUntypedBuffer(img_pixels.len, .{ .transfer_src_bit = true }, .cpu_only, .{});
    const data = try gc.vma.mapMemory(u8, staging_buffer.allocation);
    std.mem.copy(u8, data[0..img_pixels.len], img_pixels);
    gc.vma.unmapMemory(staging_buffer.allocation);

    const img_extent = vk.Extent3D{
        .width = @intCast(u32, img.w),
        .height = @intCast(u32, img.h),
        .depth = 1,
    };
    const dimg_info = vkinit.imageCreateInfo(vk.Format.r8g8b8a8_srgb, img_extent, .{ .sampled_bit = true, .transfer_dst_bit = true });
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

    const image_info = vkinit.imageViewCreateInfo(.r8g8b8a8_srgb, new_img.image, .{ .color_bit = true });
    new_img.default_view = try gc.vkd.createImageView(gc.dev, &image_info, null);

    staging_buffer.deinit(gc.vma);
    return new_img;
}
