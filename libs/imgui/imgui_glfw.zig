const vk = @import("vulkan");

pub extern fn ImGui_ImplGlfw_InitForVulkan(window: ?*anyopaque, install_callbacks: bool) bool;
pub extern fn ImGui_ImplGlfw_Shutdown() void;
pub extern fn ImGui_ImplGlfw_NewFrame() void;


pub const ImGui_ImplVulkan_InitInfo = extern struct {
    instance: vk.Instance, // VkInstance                      Instance;
    physical_device: vk.PhysicalDevice, // VkPhysicalDevice                PhysicalDevice;
    device: vk.Device, // VkDevice                        Device;
    queue_family: u32,
    queue: vk.Queue, //VkQueue                         Queue;
    pipeline_cache: vk.PipelineCache, //VkPipelineCache                 PipelineCache;
    descriptor_pool: vk.DescriptorPool, // VkDescriptorPool                DescriptorPool;
    subpass: u32,
    min_image_count: u32 = 2,
    image_count: u32 = 2,
    msaa_samples: vk.SampleCountFlags, // VkSampleCountFlagBits           MSAASamples; // >= VK_SAMPLE_COUNT_1_BIT (0 -> default to VK_SAMPLE_COUNT_1_BIT)
    allocator: ?*vk.AllocationCallbacks = null,
    checkVkResultFn: ?fn (vk.Result) callconv(.C) void,
};

// Called by user code
pub extern fn ImGui_ImplVulkan_Init(info: *ImGui_ImplVulkan_InitInfo, render_pass: vk.RenderPass) bool;
pub extern fn ImGui_ImplVulkan_Shutdown() void;
pub extern fn ImGui_ImplVulkan_NewFrame() void;
// pub extern fn ImGui_ImplVulkan_RenderDrawData(ImDrawData* draw_data, VkCommandBuffer command_buffer, VkPipeline pipeline = VK_NULL_HANDLE) void;
pub extern fn ImGui_ImplVulkan_CreateFontsTexture(command_buffer: vk.CommandBuffer) bool;
pub extern fn ImGui_ImplVulkan_DestroyFontUploadObjects() void;
pub extern fn ImGui_ImplVulkan_SetMinImageCount(min_image_count: u32) void;


// struct ImGui_ImplVulkan_InitInfo
// {
//     VkInstance                      Instance;
//     VkPhysicalDevice                PhysicalDevice;
//     VkDevice                        Device;
//     uint32_t                        QueueFamily;
//     VkQueue                         Queue;
//     VkPipelineCache                 PipelineCache;
//     VkDescriptorPool                DescriptorPool;
//     uint32_t                        Subpass;
//     uint32_t                        MinImageCount;          // >= 2
//     uint32_t                        ImageCount;             // >= MinImageCount
//     VkSampleCountFlagBits           MSAASamples;            // >= VK_SAMPLE_COUNT_1_BIT (0 -> default to VK_SAMPLE_COUNT_1_BIT)
//     const VkAllocationCallbacks*    Allocator;
//     void                            (*CheckVkResultFn)(VkResult err);
// };

// // Called by user code
// pub extern fn ImGui_ImplVulkan_Init(info: *ImGui_ImplVulkan_InitInfo, render_pass: VkRenderPass) bool;
// pub extern fn ImGui_ImplVulkan_Shutdown() void;
// pub extern fn ImGui_ImplVulkan_NewFrame() void;
// // pub extern fn ImGui_ImplVulkan_RenderDrawData(ImDrawData* draw_data, VkCommandBuffer command_buffer, VkPipeline pipeline = VK_NULL_HANDLE) void;
// pub extern fn ImGui_ImplVulkan_CreateFontsTexture(command_buffer: VkCommandBuffer) bool;
// pub extern fn ImGui_ImplVulkan_DestroyFontUploadObjects() void;
// pub extern fn ImGui_ImplVulkan_SetMinImageCount(min_image_count: u32) void; // To override MinImageCount after initialization (e.g. if swap chain is recreated)