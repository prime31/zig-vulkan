const std = @import("std");
const vk = @import("vulkan");
const vma = @import("vma");
const glfw = @import("glfw");
const dispatch = @import("vulkan_dispatch.zig");

const Allocator = std.mem.Allocator;
const BaseDispatch = dispatch.BaseDispatch;
const InstanceDispatch = dispatch.InstanceDispatch;
const DeviceDispatch = dispatch.DeviceDispatch;
const enableValidationLayers = dispatch.enableValidationLayers;

const required_device_extensions = [_][*:0]const u8{vk.extension_info.khr_swapchain.name} ++ if (@import("builtin").os.tag == .macos) [_][*:0]const u8{vk.extension_info.khr_portability_subset.name} else [_][*:0]const u8{};
const required_instance_extensions = if (enableValidationLayers) [_][*:0]const u8{vk.extension_info.ext_debug_utils.name} else [_][*:0]const u8{};
const validation_layers = [_][*:0]const u8{"VK_LAYER_KHRONOS_validation"};

pub const GraphicsContext = struct {
    vkb: BaseDispatch,
    vki: InstanceDispatch,
    vkd: DeviceDispatch,

    instance: vk.Instance,
    surface: vk.SurfaceKHR,
    pdev: vk.PhysicalDevice,
    props: vk.PhysicalDeviceProperties,
    mem_props: vk.PhysicalDeviceMemoryProperties,

    dev: vk.Device,
    graphics_queue: Queue,
    present_queue: Queue,
    allocator: vma.Allocator,
    debug_message: if (enableValidationLayers) vk.DebugUtilsMessengerEXT else void,

    pub fn init(allocator: Allocator, app_name: [*:0]const u8, window: glfw.Window) !GraphicsContext {
        var self: GraphicsContext = undefined;
        const vk_proc = @ptrCast(fn (instance: vk.Instance, procname: [*:0]const u8) callconv(.C) vk.PfnVoidFunction, glfw.getInstanceProcAddress);
        self.vkb = try BaseDispatch.load(vk_proc);

        const glfw_exts = try glfw.getRequiredInstanceExtensions();

        const app_info = vk.ApplicationInfo{
            .p_application_name = app_name,
            .application_version = vk.makeApiVersion(0, 0, 0, 0),
            .p_engine_name = app_name,
            .engine_version = vk.makeApiVersion(0, 0, 0, 0),
            .api_version = vk.API_VERSION_1_1,
        };

        // validation
        if (enableValidationLayers and !try checkValidationLayerSupport(self.vkb, allocator))
            std.debug.panic("Validation layers enabled but validationLayerSupport returned false", .{});

        var instance_exts = blk: {
            if (enableValidationLayers) {
                var exts = try std.ArrayList([*:0]const u8).initCapacity(
                    allocator,
                    glfw_exts.len + required_instance_extensions.len,
                );

                try exts.appendSlice(glfw_exts);
                for (required_instance_extensions) |e| try exts.append(e);

                break :blk exts.toOwnedSlice();
            }

            break :blk glfw_exts;
        };
        defer if (enableValidationLayers) allocator.free(instance_exts);

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

        const candidate = try pickPhysicalDevice(self.vki, self.instance, allocator, self.surface);
        self.pdev = candidate.pdev;
        self.props = candidate.props;
        self.dev = try initializeCandidate(self.vki, candidate);
        self.vkd = try DeviceDispatch.load(self.dev, self.vki.dispatch.vkGetDeviceProcAddr);
        errdefer self.vkd.destroyDevice(self.dev, null);

        self.graphics_queue = Queue.init(self.vkd, self.dev, candidate.queues.graphics_family);
        self.present_queue = Queue.init(self.vkd, self.dev, candidate.queues.present_family);

        self.mem_props = self.vki.getPhysicalDeviceMemoryProperties(self.pdev);

        // initialize the memory allocator
        var allocator_info = std.mem.zeroInit(vma.VmaAllocatorCreateInfo, .{
            .flags = .{},
            .physicalDevice = self.pdev,
            .device = self.dev,
            .pVulkanFunctions = &dispatch.getVmaVulkanFunction(self.vki, self.vkd),
            .instance = self.instance,
            .vulkanApiVersion = vk.API_VERSION_1_2,
        });
        self.allocator = try vma.Allocator.init(&allocator_info);

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
                    .performance_bit_ext = true,
                },
                .pfn_user_callback = debugCallback,
                .p_user_data = null,
            }, null);
        }

        return self;
    }

    pub fn deinit(self: GraphicsContext) void {
        self.allocator.deinit();
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

fn createSurfaceGlfw(instance: vk.Instance, window: glfw.Window) !vk.SurfaceKHR {
    var surface: vk.SurfaceKHR = undefined;
    if ((try glfw.createWindowSurface(instance, window, null, &surface)) != @enumToInt(vk.Result.success)) {
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

    return try vki.createDevice(candidate.pdev, &.{
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
