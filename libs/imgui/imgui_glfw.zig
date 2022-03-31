const vk = @import("vulkan");

pub extern fn ImGui_ImplGlfw_InitForVulkan(window: ?*anyopaque, install_callbacks: bool) bool;
pub extern fn ImGui_ImplGlfw_Shutdown() void;
pub extern fn ImGui_ImplGlfw_NewFrame() void;


pub const ImGui_ImplVulkan_InitInfo = extern struct {
    instance: vk.Instance,
    physical_device: vk.PhysicalDevice,
    device: vk.Device,
    queue_family: u32,
    queue: vk.Queue,
    pipeline_cache: vk.PipelineCache,
    descriptor_pool: vk.DescriptorPool,
    subpass: u32,
    min_image_count: u32 = 2,
    image_count: u32 = 2,
    msaa_samples: vk.SampleCountFlags,
    allocator: ?*vk.AllocationCallbacks = null,
    checkVkResultFn: ?fn (vk.Result) callconv(.C) void,
};

// Called by user code
pub extern fn ImGui_ImplVulkan_Init(info: *ImGui_ImplVulkan_InitInfo, render_pass: vk.RenderPass) bool;
pub extern fn ImGui_ImplVulkan_Shutdown() void;
pub extern fn ImGui_ImplVulkan_NewFrame() void;
pub extern fn ImGui_ImplVulkan_RenderDrawData(draw_data: *anyopaque, command_buffer: vk.CommandBuffer, pipeline: vk.Pipeline) void;
pub extern fn ImGui_ImplVulkan_CreateFontsTexture(command_buffer: vk.CommandBuffer) bool;
pub extern fn ImGui_ImplVulkan_DestroyFontUploadObjects() void;
pub extern fn ImGui_ImplVulkan_SetMinImageCount(min_image_count: u32) void;
pub extern fn ImGui_ImplVulkan_LoadFunctions(loader_func: fn (function_name: [*:0]const u8, user_data: *anyopaque) callconv(.C) vk.PfnVoidFunction, user_data: vk.Instance) callconv(.C) bool;


pub fn shutdown() void {
    ImGui_ImplGlfw_Shutdown();
    ImGui_ImplVulkan_Shutdown();
}

