const std = @import("std");
const vk = @import("vulkan");
const vma = @import("vma");
const vkinit = @import("vkinit.zig");
const glfw = @import("glfw");
const dispatch = @import("vulkan_dispatch.zig");
const enableValidationLayers = dispatch.enableValidationLayers;

const Allocator = std.mem.Allocator;
const ScratchAllocator = @import("utils/scratch_allocator.zig").ScratchAllocator;
const BaseDispatch = dispatch.BaseDispatch;
const InstanceDispatch = dispatch.InstanceDispatch;
const DeviceDispatch = dispatch.DeviceDispatch;
const CommandBuffer = @import("vk_objs/CommandBuffer.zig");

// we want this but MoltenVK 1.3 doesnt seem to support it. vk.extension_info.ext_sampler_filter_minmax.name
const required_device_extensions = [_][*:0]const u8{vk.extension_info.khr_swapchain.name} ++ if (@import("builtin").os.tag == .macos) [_][*:0]const u8{vk.extension_info.khr_portability_subset.name} else [_][*:0]const u8{};
const required_instance_extensions = if (enableValidationLayers) [_][*:0]const u8{vk.extension_info.ext_debug_utils.name} else [_][*:0]const u8{};
const validation_layers = [_][*:0]const u8{"VK_LAYER_KHRONOS_validation"};

var scratch_allocator: ScratchAllocator = undefined;

pub const GraphicsContext = struct {
    vkb: BaseDispatch,
    vki: InstanceDispatch,
    vkd: DeviceDispatch,

    instance: vk.Instance,
    surface: vk.SurfaceKHR,
    pdev: vk.PhysicalDevice,
    props: vk.PhysicalDeviceProperties,
    mem_props: vk.PhysicalDeviceMemoryProperties,
    gpu_props: vk.PhysicalDeviceProperties,

    dev: vk.Device,
    graphics_queue: Queue,
    present_queue: Queue,
    vma: vma.Allocator,
    gpa: std.mem.Allocator,
    scratch: std.mem.Allocator,
    upload_context: UploadContext,
    debug_message: if (enableValidationLayers) vk.DebugUtilsMessengerEXT else void,

    pub fn init(gpa: Allocator, app_name: [*:0]const u8, window: glfw.Window) !GraphicsContext {
        // prep allocators
        var self: GraphicsContext = undefined;
        self.gpa = gpa;

        scratch_allocator = ScratchAllocator.init(gpa, 20);
        self.scratch = scratch_allocator.allocator();

        const vk_proc = @ptrCast(fn (instance: vk.Instance, procname: [*:0]const u8) callconv(.C) vk.PfnVoidFunction, glfw.getInstanceProcAddress);
        self.vkb = try BaseDispatch.load(vk_proc);

        const glfw_exts = try glfw.getRequiredInstanceExtensions();

        const app_info = vk.ApplicationInfo{
            .p_application_name = app_name,
            .application_version = vk.makeApiVersion(0, 0, 0, 0),
            .p_engine_name = app_name,
            .engine_version = vk.makeApiVersion(0, 0, 0, 0),
            .api_version = vk.API_VERSION_1_2,
        };

        // validation
        if (enableValidationLayers and !try checkValidationLayerSupport(self.vkb, gpa))
            std.debug.panic("Validation layers enabled but validationLayerSupport returned false", .{});

        var instance_exts = blk: {
            if (enableValidationLayers) {
                var exts = try std.ArrayList([*:0]const u8).initCapacity(
                    gpa,
                    glfw_exts.len + required_instance_extensions.len,
                );

                try exts.appendSlice(glfw_exts);
                for (required_instance_extensions) |e| try exts.append(e);

                break :blk exts.toOwnedSlice();
            }

            break :blk glfw_exts;
        };
        defer if (enableValidationLayers) gpa.free(instance_exts);

        self.instance = try self.vkb.createInstance(&.{
            .flags = .{},
            .p_application_info = &app_info,
            .enabled_layer_count = if (enableValidationLayers) validation_layers.len else 0,
            .pp_enabled_layer_names = if (enableValidationLayers) &validation_layers else undefined,
            .enabled_extension_count = @intCast(u32, instance_exts.len),
            .pp_enabled_extension_names = @ptrCast([*]const [*:0]const u8, &instance_exts[0]),
        }, null);

        self.vki = try InstanceDispatch.load(self.instance, vk_proc);
        errdefer self.vki.destroyInstance(self.instance, null);

        self.surface = try createSurfaceGlfw(self.instance, window);
        errdefer self.vki.destroySurfaceKHR(self.instance, self.surface, null);

        const candidate = try pickPhysicalDevice(self.vki, self.instance, gpa, self.surface);
        self.pdev = candidate.pdev;
        self.props = candidate.props;
        self.dev = try initializeCandidate(self.vki, candidate);
        self.vkd = try DeviceDispatch.load(self.dev, self.vki.dispatch.vkGetDeviceProcAddr);
        errdefer self.vkd.destroyDevice(self.dev, null);

        self.graphics_queue = Queue.init(self.vkd, self.dev, candidate.queues.graphics_family);
        self.present_queue = Queue.init(self.vkd, self.dev, candidate.queues.present_family);

        self.mem_props = self.vki.getPhysicalDeviceMemoryProperties(self.pdev);
        self.gpu_props = self.vki.getPhysicalDeviceProperties(self.pdev);

        // initialize the memory allocator
        var allocator_info = std.mem.zeroInit(vma.VmaAllocatorCreateInfo, .{
            .flags = .{},
            .physicalDevice = self.pdev,
            .device = self.dev,
            .pVulkanFunctions = &dispatch.getVmaVulkanFunctions(self.vki, self.vkd),
            .instance = self.instance,
            .vulkanApiVersion = vk.API_VERSION_1_2,
        });
        self.vma = try vma.Allocator.init(&allocator_info);

        // initialize the upload context for immediate transfers
        self.upload_context = try UploadContext.init(&self);

        if (enableValidationLayers) {
            self.debug_message = try self.vki.createDebugUtilsMessengerEXT(self.instance, &.{
                .flags = .{},
                .message_severity = .{
                    .verbose_bit_ext = true,
                    .info_bit_ext = true,
                    .warning_bit_ext = true,
                    .error_bit_ext = true,
                },
                .message_type = .{
                    .general_bit_ext = true,
                    .validation_bit_ext = true,
                    .performance_bit_ext = false,
                },
                .pfn_user_callback = debugCallback,
                .p_user_data = null,
            }, null);
        }

        return self;
    }

    pub fn deinit(self: *GraphicsContext) void {
        scratch_allocator.deinit();
        self.vma.deinit();
        self.upload_context.deinit(self);
        self.vkd.destroyDevice(self.dev, null);
        self.vki.destroySurfaceKHR(self.instance, self.surface, null);
        if (enableValidationLayers) self.vki.destroyDebugUtilsMessengerEXT(self.instance, self.debug_message, null);
        self.vki.destroyInstance(self.instance, null);
    }

    pub fn deviceName(self: GraphicsContext) []const u8 {
        const len = std.mem.indexOfScalar(u8, &self.props.device_name, 0).?;
        return self.props.device_name[0..len];
    }

    pub fn findMemoryTypeIndex(self: GraphicsContext, memory_type_bits: u32, flags: vk.MemoryPropertyFlags) !u32 {
        for (self.mem_props.memory_types[0..self.mem_props.memory_type_count]) |mem_type, i| {
            if (memory_type_bits & (@as(u32, 1) << @truncate(u5, i)) != 0 and mem_type.property_flags.contains(flags)) {
                return @truncate(u32, i);
            }
        }

        return error.NoSuitableMemoryType;
    }

    pub fn allocate(self: GraphicsContext, requirements: vk.MemoryRequirements, flags: vk.MemoryPropertyFlags) !vk.DeviceMemory {
        return try self.vkd.allocateMemory(self.dev, &.{
            .allocation_size = requirements.size,
            .memory_type_index = try self.findMemoryTypeIndex(requirements.memory_type_bits, flags),
        }, null);
    }

    pub fn beginOneTimeCommandBuffer(self: *const GraphicsContext) !CommandBuffer {
        return CommandBuffer.init(try self.upload_context.beginOneTimeCommandBuffer(self), self);
    }

    pub fn endOneTimeCommandBuffer(self: *const GraphicsContext) !void {
        try self.upload_context.endOneTimeCommandBuffer(self);
    }

    pub fn markCommandBuffer(self: *const GraphicsContext, cmd: vk.CommandBuffer, label: [*:0]const u8) void {
        if (!enableValidationLayers) return;
        self.vkd.cmdInsertDebugUtilsLabelEXT(cmd, &.{
            .p_label_name = label,
            .color = [4]f32{1, 0, 0, 0},
        });
    }

    pub fn markHandle(self: *const GraphicsContext, handle: anytype, obj_type: vk.ObjectType, label: [*:0]const u8) !void {
        if (!enableValidationLayers) return;
        try self.vkd.setDebugUtilsObjectNameEXT(self.dev, &.{
            .object_type = obj_type,
            .object_handle = @enumToInt(handle),
            .p_object_name = label,
        });
    }

    pub fn destroy(self: GraphicsContext, resource: anytype) void {
        dispatch.destroy(self.vkd, self.dev, resource);
    }
};

pub const Queue = struct {
    handle: vk.Queue,
    family: u32,

    fn init(vkd: DeviceDispatch, dev: vk.Device, family: u32) Queue {
        return .{
            .handle = vkd.getDeviceQueue(dev, family, 0),
            .family = family,
        };
    }
};

const UploadContext = struct {
    upload_fence: vk.Fence,
    cmd_pool: vk.CommandPool,
    cmd_buf: vk.CommandBuffer,

    pub fn init(gc: *const GraphicsContext) !UploadContext {
        const fence = try gc.vkd.createFence(gc.dev, &.{ .flags = .{} }, null);

        const cmd_pool = try gc.vkd.createCommandPool(gc.dev, &.{
            .flags = .{},
            .queue_family_index = gc.graphics_queue.family,
        }, null);

        var cmd_buffer: vk.CommandBuffer = undefined;
        try gc.vkd.allocateCommandBuffers(gc.dev, &.{
            .command_pool = cmd_pool,
            .level = .primary,
            .command_buffer_count = 1,
        }, @ptrCast([*]vk.CommandBuffer, &cmd_buffer));

        return UploadContext{
            .upload_fence = fence,
            .cmd_pool = cmd_pool,
            .cmd_buf = cmd_buffer,
        };
    }

    pub fn deinit(self: UploadContext, gc: *const GraphicsContext) void {
        gc.destroy(self.cmd_pool);
        gc.destroy(self.upload_fence);
    }

    pub fn beginOneTimeCommandBuffer(self: UploadContext, gc: *const GraphicsContext) !vk.CommandBuffer {
        try gc.vkd.beginCommandBuffer(self.cmd_buf, &.{
            .flags = .{ .one_time_submit_bit = true },
            .p_inheritance_info = null,
        });
        return self.cmd_buf;
    }

    pub fn endOneTimeCommandBuffer(self: UploadContext, gc: *const GraphicsContext) !void {
        try gc.vkd.endCommandBuffer(self.cmd_buf);

        // submit command buffer to the queue and execute it
        const submit = vkinit.submitInfo(&self.cmd_buf);
        try gc.vkd.queueSubmit(gc.graphics_queue.handle, 1, @ptrCast([*]const vk.SubmitInfo, &submit), self.upload_fence);

        _ = try gc.vkd.waitForFences(gc.dev, 1, @ptrCast([*]const vk.Fence, &self.upload_fence), vk.TRUE, std.math.maxInt(u64));
        try gc.vkd.resetCommandPool(gc.dev, self.cmd_pool, .{});

        try gc.vkd.resetFences(gc.dev, 1, @ptrCast([*]const vk.Fence, &self.upload_fence));
    }
};

fn createSurfaceGlfw(instance: vk.Instance, window: glfw.Window) !vk.SurfaceKHR {
    var surface: vk.SurfaceKHR = undefined;
    if ((try glfw.createWindowSurface(instance, window, null, &surface)) != vk.Result.success) {
        return error.SurfaceInitFailed;
    }

    return surface;
}

fn initializeCandidate(vki: InstanceDispatch, candidate: DeviceCandidate) !vk.Device {
    const priority = [_]f32{1};
    const qci = [_]vk.DeviceQueueCreateInfo{
        .{
            .flags = .{},
            .queue_family_index = candidate.queues.graphics_family,
            .queue_count = 1,
            .p_queue_priorities = &priority,
        },
        .{
            .flags = .{},
            .queue_family_index = candidate.queues.present_family,
            .queue_count = 1,
            .p_queue_priorities = &priority,
        },
    };

    const queue_count: u32 = if (candidate.queues.graphics_family == candidate.queues.present_family)
        1
    else
        2;

    // required for access to gl_BaseInstance: https://www.khronos.org/registry/vulkan/specs/1.2-extensions/html/vkspec.html#features-shaderDrawParameters
    var physical_features2 = std.mem.zeroInit(vk.PhysicalDeviceFeatures2, .{
        .features = .{
            .multi_draw_indirect = vk.TRUE,
            .sampler_anisotropy = vk.TRUE,
            .pipeline_statistics_query = vk.TRUE, // not available in MoltenVK 1.3
            .draw_indirect_first_instance = vk.TRUE,
        },
        .p_next = &std.mem.zeroInit(vk.PhysicalDeviceVulkan11Features, .{
            .p_next = &std.mem.zeroInit(vk.PhysicalDeviceVulkan12Features, .{
                .sampler_filter_minmax = vk.TRUE, // not available in MoltenVK 1.3
            }),
            .shader_draw_parameters = vk.TRUE,
        }),
    });
    vki.getPhysicalDeviceFeatures2(candidate.pdev, &physical_features2);

    return try vki.createDevice(candidate.pdev, &.{
        .p_next = &physical_features2,
        .flags = .{},
        .queue_create_info_count = queue_count,
        .p_queue_create_infos = &qci,
        .enabled_layer_count = 0,
        .pp_enabled_layer_names = undefined,
        .enabled_extension_count = required_device_extensions.len,
        .pp_enabled_extension_names = @ptrCast([*]const [*:0]const u8, &required_device_extensions),
        .p_enabled_features = null,
    }, null);
}

const DeviceCandidate = struct {
    pdev: vk.PhysicalDevice,
    props: vk.PhysicalDeviceProperties,
    queues: QueueAllocation,
};

const QueueAllocation = struct {
    graphics_family: u32,
    present_family: u32,
};

fn pickPhysicalDevice(
    vki: InstanceDispatch,
    instance: vk.Instance,
    allocator: Allocator,
    surface: vk.SurfaceKHR,
) !DeviceCandidate {
    var device_count: u32 = undefined;
    _ = try vki.enumeratePhysicalDevices(instance, &device_count, null);

    const pdevs = try allocator.alloc(vk.PhysicalDevice, device_count);
    defer allocator.free(pdevs);

    _ = try vki.enumeratePhysicalDevices(instance, &device_count, pdevs.ptr);

    for (pdevs) |pdev| {
        if (try checkSuitable(vki, pdev, allocator, surface)) |candidate| {
            return candidate;
        }
    }

    return error.NoSuitableDevice;
}

fn checkSuitable(
    vki: InstanceDispatch,
    pdev: vk.PhysicalDevice,
    allocator: Allocator,
    surface: vk.SurfaceKHR,
) !?DeviceCandidate {
    const props = vki.getPhysicalDeviceProperties(pdev);

    if (!try checkExtensionSupport(vki, pdev, allocator)) {
        return null;
    }

    if (!try checkSurfaceSupport(vki, pdev, surface)) {
        return null;
    }

    if (try allocateQueues(vki, pdev, allocator, surface)) |allocation| {
        return DeviceCandidate{
            .pdev = pdev,
            .props = props,
            .queues = allocation,
        };
    }

    return null;
}

fn allocateQueues(vki: InstanceDispatch, pdev: vk.PhysicalDevice, allocator: Allocator, surface: vk.SurfaceKHR) !?QueueAllocation {
    var family_count: u32 = undefined;
    vki.getPhysicalDeviceQueueFamilyProperties(pdev, &family_count, null);

    const families = try allocator.alloc(vk.QueueFamilyProperties, family_count);
    defer allocator.free(families);
    vki.getPhysicalDeviceQueueFamilyProperties(pdev, &family_count, families.ptr);

    var graphics_family: ?u32 = null;
    var present_family: ?u32 = null;

    for (families) |properties, i| {
        const family = @intCast(u32, i);

        if (graphics_family == null and properties.queue_flags.graphics_bit) {
            graphics_family = family;
        }

        if (present_family == null and (try vki.getPhysicalDeviceSurfaceSupportKHR(pdev, family, surface)) == vk.TRUE) {
            present_family = family;
        }
    }

    if (graphics_family != null and present_family != null) {
        return QueueAllocation{
            .graphics_family = graphics_family.?,
            .present_family = present_family.?,
        };
    }

    return null;
}

fn checkSurfaceSupport(vki: InstanceDispatch, pdev: vk.PhysicalDevice, surface: vk.SurfaceKHR) !bool {
    var format_count: u32 = undefined;
    _ = try vki.getPhysicalDeviceSurfaceFormatsKHR(pdev, surface, &format_count, null);

    var present_mode_count: u32 = undefined;
    _ = try vki.getPhysicalDeviceSurfacePresentModesKHR(pdev, surface, &present_mode_count, null);

    return format_count > 0 and present_mode_count > 0;
}

fn checkExtensionSupport(
    vki: InstanceDispatch,
    pdev: vk.PhysicalDevice,
    allocator: Allocator,
) !bool {
    var count: u32 = undefined;
    _ = try vki.enumerateDeviceExtensionProperties(pdev, null, &count, null);

    const propsv = try allocator.alloc(vk.ExtensionProperties, count);
    defer allocator.free(propsv);

    _ = try vki.enumerateDeviceExtensionProperties(pdev, null, &count, propsv.ptr);

    for (required_device_extensions) |ext| {
        for (propsv) |props| {
            const len = std.mem.indexOfScalar(u8, &props.extension_name, 0).?;
            const prop_ext_name = props.extension_name[0..len];
            if (std.mem.eql(u8, std.mem.span(ext), prop_ext_name))
                break;
        } else {
            return false;
        }
    }

    return true;
}

fn checkValidationLayerSupport(vkb: BaseDispatch, allocator: Allocator) !bool {
    var layer_cnt: u32 = undefined;
    _ = try vkb.enumerateInstanceLayerProperties(&layer_cnt, null);

    const available_layers = try allocator.alloc(vk.LayerProperties, layer_cnt);
    defer allocator.free(available_layers);

    _ = try vkb.enumerateInstanceLayerProperties(&layer_cnt, available_layers.ptr);

    for (validation_layers) |layer_name| {
        var layer_found = false;

        for (available_layers) |layer_props| {
            if (std.cstr.cmp(layer_name, @ptrCast([*:0]const u8, &layer_props.layer_name)) == 0) {
                layer_found = true;
                break;
            }
        }

        if (!layer_found) return false;
    }

    return true;
}

fn debugCallback(
    message_severity: vk.DebugUtilsMessageSeverityFlagsEXT.IntType,
    message_types: vk.DebugUtilsMessageTypeFlagsEXT.IntType,
    p_callback_data: ?*const vk.DebugUtilsMessengerCallbackDataEXT,
    p_user_data: ?*anyopaque,
) callconv(vk.vulkan_call_conv) vk.Bool32 {
    _ = message_severity;
    _ = message_types;
    _ = p_callback_data;
    _ = p_user_data;

    if (p_callback_data) |data| {
        const level = (vk.DebugUtilsMessageSeverityFlagsEXT{
            .warning_bit_ext = true,
        }).toInt();

        if (message_severity >= level) {
            std.debug.print("{s}\n", .{data.p_message});

            if (data.object_count > 0) {
                std.debug.print("---------- Objects {} -----------\n", .{data.object_count});
                var i: u32 = 0;
                while (i < data.object_count) : (i += 1) {
                    const o: vk.DebugUtilsObjectNameInfoEXT = data.p_objects[i];
                    std.debug.print("\t[{} - {s}]: {s}\n", .{
                        i,
                        @tagName(o.object_type),
                        o.p_object_name,
                    });
                }
                std.debug.print("---------- End Object -----------\n\n", .{});
            }
            if (data.cmd_buf_label_count > 0) {
                std.debug.print("---------- Labels {} ------------\n\n", .{data.object_count});
                var i: u32 = 0;
                while (i < data.cmd_buf_label_count) : (i += 1) {
                    const o: vk.DebugUtilsLabelEXT = data.p_cmd_buf_labels[i];
                    std.debug.print("\t[{}]: {s}", .{
                        i,
                        o.p_label_name,
                    });
                }
                std.debug.print("---------- End Label ------------\n\n", .{});
            }
        }
    }

    return vk.FALSE;
}
