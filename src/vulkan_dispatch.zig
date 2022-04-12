const std = @import("std");
const vk = @import("vulkan");
const vma = @import("vma");

// TODO: hack that should disable validation if @root wants to or if this is a cross-compile
pub const enableValidationLayers = if (@hasDecl(@import("root"), "disable_validation")) blk: {
    break :blk !@field(@import("root"), "disable_validation");
} else if (@import("builtin").os.tag == .macos)
blk: {
    break :blk true;
} else false;

pub const BaseDispatch = vk.BaseWrapper(allFuncs(vk.BaseCommandFlags));

pub const InstanceDispatch = vk.InstanceWrapper(.{
    // vma
    .getPhysicalDeviceMemoryProperties2 = true,

    // debug
    .createDebugUtilsMessengerEXT = enableValidationLayers,
    .destroyDebugUtilsMessengerEXT = enableValidationLayers,

    .destroyInstance = true,
    .createDevice = true,
    .destroySurfaceKHR = true,
    .enumeratePhysicalDevices = true,
    .getPhysicalDeviceProperties = true,
    .getPhysicalDeviceFeatures2 = true,
    .getPhysicalDeviceProperties2 = true,
    .enumerateDeviceExtensionProperties = true,
    .getPhysicalDeviceSurfaceFormatsKHR = true,
    .getPhysicalDeviceSurfacePresentModesKHR = true,
    .getPhysicalDeviceSurfaceCapabilitiesKHR = true,
    .getPhysicalDeviceQueueFamilyProperties = true,
    .getPhysicalDeviceSurfaceSupportKHR = true,
    .getPhysicalDeviceMemoryProperties = true,
    .getDeviceProcAddr = true,
});

pub const DeviceDispatch = vk.DeviceWrapper(.{
    // vma
    .createImage = true,
    .createSampler = true,
    .destroySampler = true,
    .createBuffer = true,
    .destroyImage = true,
    .destroyBuffer = true,
    .bindImageMemory = true,
    .bindBufferMemory = true,
    .getImageMemoryRequirements2 = true,
    .getBufferMemoryRequirements2 = true,
    .mapMemory = true,
    .freeMemory = true,
    .unmapMemory = true,
    .allocateMemory = true,
    .flushMappedMemoryRanges = true,
    .invalidateMappedMemoryRanges = true,
    .getImageMemoryRequirements = true,
    .bindBufferMemory2 = true,
    .bindImageMemory2 = true,

    .destroyDevice = true,
    .getDeviceQueue = true,
    .createSemaphore = true,
    .createFence = true,
    .destroyFence = true,
    .waitForFences = true,
    .resetFences = true,
    .getFenceStatus = true,
    .createImageView = true,
    .destroyImageView = true,
    .destroySemaphore = true,
    .getSwapchainImagesKHR = true,
    .createSwapchainKHR = true,
    .destroySwapchainKHR = true,
    .acquireNextImageKHR = true,
    .deviceWaitIdle = true,
    .queueSubmit = true,
    .queuePresentKHR = true,
    .createCommandPool = true,
    .destroyCommandPool = true,
    .resetCommandPool = true,
    .allocateCommandBuffers = true,
    .freeCommandBuffers = true,
    .queueWaitIdle = true,
    .createShaderModule = true,
    .destroyShaderModule = true,
    .createPipelineLayout = true,
    .destroyPipelineLayout = true,
    .createRenderPass = true,
    .destroyRenderPass = true,
    .createGraphicsPipelines = true,
    .createComputePipelines = true,
    .destroyPipeline = true,
    .createFramebuffer = true,
    .destroyFramebuffer = true,
    .beginCommandBuffer = true,
    .endCommandBuffer = true,
    .getBufferMemoryRequirements = true,

    .cmdBeginRenderPass = true,
    .cmdEndRenderPass = true,
    .cmdPushConstants = true,
    .cmdPipelineBarrier = true,
    .cmdBindPipeline = true,
    .cmdDraw = true,
    .cmdDrawIndexed = true,
    .cmdDrawIndexedIndirect = true,
    .cmdBindDescriptorSets = true,
    .cmdCopyBufferToImage = true,
    .cmdSetViewport = true,
    .cmdSetScissor = true,
    .cmdClearColorImage = true,
    .cmdBindVertexBuffers = true,
    .cmdBindIndexBuffer = true,
    .cmdCopyBuffer = true,
    .cmdSetDepthBias = true,
    .cmdDispatch = true,
    
    .resetCommandBuffer = true,
    .createDescriptorSetLayout = true,
    .destroyDescriptorSetLayout = true,
    .createDescriptorPool = true,
    .destroyDescriptorPool = true,
    .resetDescriptorPool = true,
    .allocateDescriptorSets = true,
    .freeDescriptorSets = true,
    .updateDescriptorSets = true,
});

pub fn getVmaVulkanFunctions(vki: InstanceDispatch, vkd: DeviceDispatch) vma.VmaVulkanFunctions {
    return .{
        .vkGetInstanceProcAddr = undefined,
        .vkGetDeviceProcAddr = undefined,
        .vkGetPhysicalDeviceProperties = vki.dispatch.vkGetPhysicalDeviceProperties,
        .vkGetPhysicalDeviceMemoryProperties = vki.dispatch.vkGetPhysicalDeviceMemoryProperties,
        .vkAllocateMemory = vkd.dispatch.vkAllocateMemory,
        .vkFreeMemory = vkd.dispatch.vkFreeMemory,
        .vkMapMemory = vkd.dispatch.vkMapMemory,
        .vkUnmapMemory = vkd.dispatch.vkUnmapMemory,
        .vkFlushMappedMemoryRanges = vkd.dispatch.vkFlushMappedMemoryRanges,
        .vkInvalidateMappedMemoryRanges = vkd.dispatch.vkInvalidateMappedMemoryRanges,
        .vkBindBufferMemory = vkd.dispatch.vkBindBufferMemory,
        .vkBindImageMemory = vkd.dispatch.vkBindImageMemory,
        .vkGetBufferMemoryRequirements = vkd.dispatch.vkGetBufferMemoryRequirements,
        .vkGetImageMemoryRequirements = vkd.dispatch.vkGetImageMemoryRequirements,
        .vkCreateBuffer = vkd.dispatch.vkCreateBuffer,
        .vkDestroyBuffer = vkd.dispatch.vkDestroyBuffer,
        .vkCreateImage = vkd.dispatch.vkCreateImage,
        .vkDestroyImage = vkd.dispatch.vkDestroyImage,
        .vkCmdCopyBuffer = vkd.dispatch.vkCmdCopyBuffer,
        .vkGetBufferMemoryRequirements2KHR = vkd.dispatch.vkGetBufferMemoryRequirements2,
        .vkGetImageMemoryRequirements2KHR = vkd.dispatch.vkGetImageMemoryRequirements2,
        .vkBindBufferMemory2KHR = vkd.dispatch.vkBindBufferMemory2,
        .vkBindImageMemory2KHR = vkd.dispatch.vkBindImageMemory2,
        .vkGetPhysicalDeviceMemoryProperties2KHR = vki.dispatch.vkGetPhysicalDeviceMemoryProperties2,
    };
}

pub fn destroy(vkd: DeviceDispatch, dev: vk.Device, resource: anytype) void {
    const ResourceType = @TypeOf(resource);
    const name = @typeName(ResourceType);
    if (ResourceType == vk.Image or ResourceType == vk.Buffer) {
        @panic("Cannot destroy single vk." ++ name ++ ". use " ++ name ++ ".deinit() instead");
    }

    @field(DestroyLookupTable, name)(vkd, dev, resource, null);
}

const DestroyLookupTable = struct {
    const Fence = DeviceDispatch.destroyFence;
    const Sampler = DeviceDispatch.destroySampler;
    const Pipeline = DeviceDispatch.destroyPipeline;
    const ImageView = DeviceDispatch.destroyImageView;
    const Semaphore = DeviceDispatch.destroySemaphore;
    const RenderPass = DeviceDispatch.destroyRenderPass;
    const CommandPool = DeviceDispatch.destroyCommandPool;
    const Framebuffer = DeviceDispatch.destroyFramebuffer;
    const ShaderModule = DeviceDispatch.destroyShaderModule;
    const SwapchainKHR = DeviceDispatch.destroySwapchainKHR;
    const PipelineCache = DeviceDispatch.destroyPipelineCache;
    const PipelineLayout = DeviceDispatch.destroyPipelineLayout;
    const DescriptorPool = DeviceDispatch.destroyDescriptorPool;
    const DescriptorSetLayout = DeviceDispatch.destroyDescriptorSetLayout;
};

fn allFuncs(comptime T: type) T {
    var inst = T{};
    for (std.meta.fields(T)) |field| {
        @field(inst, field.name) = true;
    }
    return inst;
}
