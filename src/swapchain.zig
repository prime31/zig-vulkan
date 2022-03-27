const std = @import("std");
const vk = @import("vulkan");
const GraphicsContext = @import("graphics_context.zig").GraphicsContext;
const Allocator = std.mem.Allocator;

pub const Swapchain = struct {
    pub const PresentState = enum {
        optimal,
        suboptimal,
    };

    gc: *const GraphicsContext,
    allocator: Allocator,

    surface_format: vk.SurfaceFormatKHR,
    present_mode: vk.PresentModeKHR,
    extent: vk.Extent2D,
    handle: vk.SwapchainKHR,

    swap_images: []SwapImage,
    sync_structures: []FrameSyncStructure,
    image_index: u32 = 0,
    frame_index: usize = 0,

    pub fn init(gc: *const GraphicsContext, allocator: Allocator, extent: vk.Extent2D, desired_image_count: u32) !Swapchain {
        return try initRecycle(gc, allocator, extent, .null_handle, desired_image_count);
    }

    pub fn initRecycle(gc: *const GraphicsContext, allocator: Allocator, extent: vk.Extent2D, old_handle: vk.SwapchainKHR, desired_image_count: u32) !Swapchain {
        const caps = try gc.vki.getPhysicalDeviceSurfaceCapabilitiesKHR(gc.pdev, gc.surface);
        const actual_extent = findActualExtent(caps, extent);
        if (actual_extent.width == 0 or actual_extent.height == 0) {
            return error.InvalidSurfaceDimensions;
        }

        const surface_format = try findSurfaceFormat(gc, allocator);
        const present_mode = try findPresentMode(gc, allocator);

        var image_count = desired_image_count;
        if (image_count > caps.max_image_count) image_count = caps.max_image_count;
        if (image_count < caps.min_image_count) image_count = caps.min_image_count;

        const qfi = [_]u32{ gc.graphics_queue.family, gc.present_queue.family };
        const sharing_mode: vk.SharingMode = if (gc.graphics_queue.family != gc.present_queue.family)
            .concurrent
        else
            .exclusive;

        const handle = try gc.vkd.createSwapchainKHR(gc.dev, &.{
            .flags = .{},
            .surface = gc.surface,
            .min_image_count = image_count,
            .image_format = surface_format.format,
            .image_color_space = surface_format.color_space,
            .image_extent = actual_extent,
            .image_array_layers = 1,
            .image_usage = .{ .color_attachment_bit = true, .transfer_dst_bit = true },
            .image_sharing_mode = sharing_mode,
            .queue_family_index_count = qfi.len,
            .p_queue_family_indices = &qfi,
            .pre_transform = caps.current_transform,
            .composite_alpha = .{ .opaque_bit_khr = true },
            .present_mode = present_mode,
            .clipped = vk.TRUE,
            .old_swapchain = old_handle,
        }, null);
        errdefer gc.vkd.destroySwapchainKHR(gc.dev, handle, null);

        if (old_handle != .null_handle) {
            // Apparently, the old swapchain handle still needs to be destroyed after recreating.
            gc.vkd.destroySwapchainKHR(gc.dev, old_handle, null);
        }

        const swap_images = try initSwapchainImages(gc, handle, surface_format.format, allocator);
        errdefer for (swap_images) |si| si.deinit(gc);

        const sync_structures = try initSyncStructures(gc, allocator, swap_images.len);

        return Swapchain{
            .gc = gc,
            .allocator = allocator,
            .surface_format = surface_format,
            .present_mode = present_mode,
            .extent = actual_extent,
            .handle = handle,
            .swap_images = swap_images,
            .sync_structures = sync_structures,
        };
    }

    fn deinitExceptSwapchain(self: Swapchain) void {
        for (self.swap_images) |si| si.deinit(self.gc);
        self.allocator.free(self.swap_images);

        for (self.sync_structures) |ss| ss.deinit(self.gc);
        self.allocator.free(self.sync_structures);
    }

    pub fn deinit(self: Swapchain) void {
        self.deinitExceptSwapchain();
        self.gc.vkd.destroySwapchainKHR(self.gc.dev, self.handle, null);
    }

    pub fn waitForAllFences(self: Swapchain) !void {
        for (self.sync_structures) |ss| try ss.waitForFence(self.gc);
    }

    /// waits for the current SwapImage's fence and acquires the next. Call this before filling CommandBuffers. A suboptimal return value
    /// indidates that framebuffers and the SwapChain need to be recreated.
    pub fn waitForFrame(self: *Swapchain) !PresentState {
        const sync_structs = self.currentFrameSyncStructure();
        try sync_structs.waitForFence(self.gc);

        // Step 4: Acquire next frame
        const result = try self.gc.vkd.acquireNextImageKHR(
            self.gc.dev,
            self.handle,
            std.math.maxInt(u64),
            sync_structs.present_semaphore,
            .null_handle,
        );
        self.image_index = result.image_index;

        return switch (result.result) {
            .success => .optimal,
            .suboptimal_khr => .suboptimal,
            else => unreachable,
        };
    }

    pub fn recreate(self: *Swapchain, new_extent: vk.Extent2D) !void {
        const gc = self.gc;
        const allocator = self.allocator;
        const old_handle = self.handle;
        const desired_image_count = @intCast(u32, self.swap_images.len);
        const frame_index = self.frame_index;
        self.deinitExceptSwapchain();
        self.* = try initRecycle(gc, allocator, new_extent, old_handle, desired_image_count);
        self.frame_index = frame_index;
    }

    pub fn currentImage(self: Swapchain) vk.Image {
        return self.swap_images[self.image_index].image;
    }

    pub fn currentSwapImage(self: Swapchain) *const SwapImage {
        return &self.swap_images[self.image_index];
    }

    fn currentFrameSyncStructure(self: Swapchain) *const FrameSyncStructure {
        return &self.sync_structures[self.frame_index % self.sync_structures.len];
    }

    pub fn present(self: *Swapchain, cmdbuf: vk.CommandBuffer) !void {
        // ---- Simple method:
        // 1) Acquire next image
        // 2) Wait for and reset fence of the acquired image
        // 3) Submit command buffer with fence of acquired image,
        //    dependendent on the semaphore signalled by the first step.
        // 4) Present current frame, dependent on semaphore signalled by previous step
        // Problem: This way we can't reference the current image while rendering.
        // ---- Better method: Shuffle the steps around such that acquire next image is the last step,
        // leaving the swapchain in a state with the current image.
        // 1) Wait for and reset fence of current image
        // 2) Submit command buffer, signalling semaphore of current image and dependent on
        //    the semaphore signalled by step 4.
        // 3) Present current frame, dependent on semaphore signalled by the submit
        // 4) Acquire next image, signalling its semaphore
        // One problem that arises is that we can't know beforehand which semaphore to signal,
        // so we keep an extra auxilery semaphore that is swapped around

        // Step 1: Make sure the current frame has finished rendering
        const sync_structs = self.currentFrameSyncStructure();

        // Step 2: Submit the command buffer
        // TODO: should the flag used here be color_attachment_output_bit?
        const wait_stage = [_]vk.PipelineStageFlags{.{ .top_of_pipe_bit = true }};
        try self.gc.vkd.queueSubmit(self.gc.graphics_queue.handle, 1, &[_]vk.SubmitInfo{.{
            .wait_semaphore_count = 1,
            .p_wait_semaphores = @ptrCast([*]const vk.Semaphore, &sync_structs.present_semaphore),
            .p_wait_dst_stage_mask = &wait_stage,
            .command_buffer_count = 1,
            .p_command_buffers = @ptrCast([*]const vk.CommandBuffer, &cmdbuf),
            .signal_semaphore_count = 1,
            .p_signal_semaphores = @ptrCast([*]const vk.Semaphore, &sync_structs.render_semaphore),
        }}, sync_structs.render_fence);

        // Step 3: Present the current frame
        _ = try self.gc.vkd.queuePresentKHR(self.gc.present_queue.handle, &.{
            .wait_semaphore_count = 1,
            .p_wait_semaphores = @ptrCast([*]const vk.Semaphore, &sync_structs.render_semaphore),
            .swapchain_count = 1,
            .p_swapchains = @ptrCast([*]const vk.SwapchainKHR, &self.handle),
            .p_image_indices = @ptrCast([*]const u32, &self.image_index),
            .p_results = null,
        });

        self.frame_index += 1;
    }
};

const FrameSyncStructure = struct {
    present_semaphore: vk.Semaphore,
    render_semaphore: vk.Semaphore,
    render_fence: vk.Fence,

    fn init(gc: *const GraphicsContext) !FrameSyncStructure {
        const present_semaphore = try gc.vkd.createSemaphore(gc.dev, &.{ .flags = .{} }, null);
        errdefer gc.vkd.destroySemaphore(gc.dev, present_semaphore, null);

        const render_semaphore = try gc.vkd.createSemaphore(gc.dev, &.{ .flags = .{} }, null);
        errdefer gc.vkd.destroySemaphore(gc.dev, render_semaphore, null);

        const render_fence = try gc.vkd.createFence(gc.dev, &.{ .flags = .{ .signaled_bit = true } }, null);
        errdefer gc.vkd.destroyFence(gc.dev, frame_fence, null);

        return FrameSyncStructure{
            .present_semaphore = present_semaphore,
            .render_semaphore = render_semaphore,
            .render_fence = render_fence,
        };
    }

    fn deinit(self: FrameSyncStructure, gc: *const GraphicsContext) void {
        self.waitForFence(gc) catch return;
        gc.vkd.destroySemaphore(gc.dev, self.present_semaphore, null);
        gc.vkd.destroySemaphore(gc.dev, self.render_semaphore, null);
        gc.vkd.destroyFence(gc.dev, self.render_fence, null);
    }

    fn waitForFence(self: FrameSyncStructure, gc: *const GraphicsContext) !void {
        _ = try gc.vkd.waitForFences(gc.dev, 1, @ptrCast([*]const vk.Fence, &self.render_fence), vk.TRUE, std.math.maxInt(u64));
        try gc.vkd.resetFences(gc.dev, 1, @ptrCast([*]const vk.Fence, &self.render_fence));
    }
};

const SwapImage = struct {
    image: vk.Image,
    view: vk.ImageView,

    fn init(gc: *const GraphicsContext, image: vk.Image, format: vk.Format) !SwapImage {
        const view = try gc.vkd.createImageView(gc.dev, &.{
            .flags = .{},
            .image = image,
            .view_type = .@"2d",
            .format = format,
            .components = .{ .r = .identity, .g = .identity, .b = .identity, .a = .identity },
            .subresource_range = .{
                .aspect_mask = .{ .color_bit = true },
                .base_mip_level = 0,
                .level_count = 1,
                .base_array_layer = 0,
                .layer_count = 1,
            },
        }, null);
        errdefer gc.vkd.destroyImageView(gc.dev, view, null);

        return SwapImage{
            .image = image,
            .view = view,
        };
    }

    fn deinit(self: SwapImage, gc: *const GraphicsContext) void {
        gc.vkd.destroyImageView(gc.dev, self.view, null);
    }
};

fn initSwapchainImages(gc: *const GraphicsContext, swapchain: vk.SwapchainKHR, format: vk.Format, allocator: Allocator) ![]SwapImage {
    var count: u32 = undefined;
    _ = try gc.vkd.getSwapchainImagesKHR(gc.dev, swapchain, &count, null);

    const images = try allocator.alloc(vk.Image, count);
    defer allocator.free(images);
    _ = try gc.vkd.getSwapchainImagesKHR(gc.dev, swapchain, &count, images.ptr);

    const swap_images = try allocator.alloc(SwapImage, count);
    errdefer allocator.free(swap_images);

    var i: usize = 0;
    errdefer for (swap_images[0..i]) |si| si.deinit(gc);

    for (images) |image| {
        swap_images[i] = try SwapImage.init(gc, image, format);
        i += 1;
    }

    return swap_images;
}

fn initSyncStructures(gc: *const GraphicsContext, allocator: Allocator, count: usize) ![]FrameSyncStructure {
    const sync_structures = try allocator.alloc(FrameSyncStructure, count);
    errdefer allocator.free(sync_structures);

    var i: usize = 0;
    errdefer for (sync_structures[0..i]) |ss| ss.deinit(gc);

    for (sync_structures) |*structure| {
        structure.* = try FrameSyncStructure.init(gc);
    }

    return sync_structures;
}

fn findSurfaceFormat(gc: *const GraphicsContext, allocator: Allocator) !vk.SurfaceFormatKHR {
    const preferred = vk.SurfaceFormatKHR{
        .format = .b8g8r8a8_srgb,
        .color_space = .srgb_nonlinear_khr,
    };

    var count: u32 = undefined;
    _ = try gc.vki.getPhysicalDeviceSurfaceFormatsKHR(gc.pdev, gc.surface, &count, null);
    const surface_formats = try allocator.alloc(vk.SurfaceFormatKHR, count);
    defer allocator.free(surface_formats);
    _ = try gc.vki.getPhysicalDeviceSurfaceFormatsKHR(gc.pdev, gc.surface, &count, surface_formats.ptr);

    for (surface_formats) |sfmt| {
        if (std.meta.eql(sfmt, preferred)) {
            return preferred;
        }
    }

    return surface_formats[0]; // There must always be at least one supported surface format
}

fn findPresentMode(gc: *const GraphicsContext, allocator: Allocator) !vk.PresentModeKHR {
    var count: u32 = undefined;
    _ = try gc.vki.getPhysicalDeviceSurfacePresentModesKHR(gc.pdev, gc.surface, &count, null);
    const present_modes = try allocator.alloc(vk.PresentModeKHR, count);
    defer allocator.free(present_modes);
    _ = try gc.vki.getPhysicalDeviceSurfacePresentModesKHR(gc.pdev, gc.surface, &count, present_modes.ptr);

    const preferred = [_]vk.PresentModeKHR{
        .fifo_khr,
        .mailbox_khr,
    };

    for (preferred) |mode| {
        if (std.mem.indexOfScalar(vk.PresentModeKHR, present_modes, mode) != null) {
            return mode;
        }
    }

    return .fifo_khr;
}

fn findActualExtent(caps: vk.SurfaceCapabilitiesKHR, extent: vk.Extent2D) vk.Extent2D {
    if (caps.current_extent.width != 0xFFFF_FFFF) {
        return caps.current_extent;
    } else {
        return .{
            .width = std.math.clamp(extent.width, caps.min_image_extent.width, caps.max_image_extent.width),
            .height = std.math.clamp(extent.height, caps.min_image_extent.height, caps.max_image_extent.height),
        };
    }
}
