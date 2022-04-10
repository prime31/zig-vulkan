const std = @import("std");
const vk = @import("vulkan");

pub fn commandPoolCreateInfo(queue_family_index: u32, flags: vk.CommandPoolCreateFlags) vk.CommandPoolCreateInfo {
    return .{
        .flags = flags,
        .queue_family_index = queue_family_index,
    };
}

// VkFramebufferCreateInfo vkinit::framebuffer_create_info(VkRenderPass renderPass, VkExtent2D extent)
// {
// 	VkFramebufferCreateInfo info = {};
// 	info.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO;
// 	info.pNext = nullptr;

// 	info.renderPass = renderPass;
// 	info.attachmentCount = 1;
// 	info.width = extent.width;
// 	info.height = extent.height;
// 	info.layers = 1;

// 	return info;
// }

pub fn submitInfo(cmd_buffer: *const vk.CommandBuffer) vk.SubmitInfo {
    return .{
        .wait_semaphore_count = 0,
        .p_wait_semaphores = undefined,
        .p_wait_dst_stage_mask = undefined,
        .command_buffer_count = 1,
        .p_command_buffers = @ptrCast([*]const vk.CommandBuffer, cmd_buffer),
        .signal_semaphore_count = 0,
        .p_signal_semaphores = undefined,
    };
}

// VkPresentInfoKHR vkinit::present_info()
// {
// 	VkPresentInfoKHR info = {};
// 	info.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;
// 	info.pNext = nullptr;

// 	info.swapchainCount = 0;
// 	info.pSwapchains = nullptr;
// 	info.pWaitSemaphores = nullptr;
// 	info.waitSemaphoreCount = 0;
// 	info.pImageIndices = nullptr;

// 	return info;
// }

// VkRenderPassBeginInfo vkinit::renderpass_begin_info(VkRenderPass renderPass, VkExtent2D windowExtent, VkFramebuffer framebuffer)
// {
// 	VkRenderPassBeginInfo info = {};
// 	info.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
// 	info.pNext = nullptr;

// 	info.renderPass = renderPass;
// 	info.renderArea.offset.x = 0;
// 	info.renderArea.offset.y = 0;
// 	info.renderArea.extent = windowExtent;
// 	info.clearValueCount = 1;
// 	info.pClearValues = nullptr;
// 	info.framebuffer = framebuffer;

// 	return info;
// }

pub fn pipelineShaderStageCreateInfo(shader_module: vk.ShaderModule, stage: vk.ShaderStageFlags) vk.PipelineShaderStageCreateInfo {
    return .{
        .flags = .{},
        .stage = stage,
        .module = shader_module,
        .p_name = "main",
        .p_specialization_info = null,
    };
}

/// vertex input controls how to read vertices from vertex buffers
pub fn pipelineVertexInputStateCreateInfo() vk.PipelineVertexInputStateCreateInfo {
    return .{
        .flags = .{},
        .vertex_binding_description_count = 0,
        .p_vertex_binding_descriptions = undefined,
        .vertex_attribute_description_count = 0,
        .p_vertex_attribute_descriptions = undefined,
    };
}

/// input assembly is the configuration for drawing triangle lists, strips, or individual points
pub fn pipelineInputAssemblyCreateInfo(topology: vk.PrimitiveTopology) vk.PipelineInputAssemblyStateCreateInfo {
    return .{
        .flags = .{},
        .topology = topology,
        .primitive_restart_enable = vk.FALSE,
    };
}

/// defaults to no clockwise front face, no culling and no depth bias
pub fn pipelineRasterizationStateCreateInfo(polygon_mode: vk.PolygonMode) vk.PipelineRasterizationStateCreateInfo {
    return .{
        .flags = .{},
        .depth_clamp_enable = vk.FALSE,
        .rasterizer_discard_enable = vk.FALSE, // rasterizer discard allows objects with holes, default to no
        .polygon_mode = polygon_mode,
        .cull_mode = .{}, // no backface cull
        .front_face = .clockwise,
        .depth_bias_enable = vk.FALSE, // no depth bias
        .depth_bias_constant_factor = 0,
        .depth_bias_clamp = 0,
        .depth_bias_slope_factor = 0,
        .line_width = 1,
    };
}

pub fn pipelineMultisampleStateCreateInfo() vk.PipelineMultisampleStateCreateInfo {
    return .{
        .flags = .{},
        .rasterization_samples = .{ .@"1_bit" = true }, // multisampling defaulted to no multisampling (1 sample per pixel)
        .sample_shading_enable = vk.FALSE,
        .min_sample_shading = 1,
        .p_sample_mask = null,
        .alpha_to_coverage_enable = vk.FALSE,
        .alpha_to_one_enable = vk.FALSE,
    };
}

pub fn pipelineColorBlendAttachmentState() vk.PipelineColorBlendAttachmentState {
    return .{
        .blend_enable = vk.FALSE,
        .src_color_blend_factor = .one,
        .dst_color_blend_factor = .zero,
        .color_blend_op = .add,
        .src_alpha_blend_factor = .one,
        .dst_alpha_blend_factor = .zero,
        .alpha_blend_op = .add,
        .color_write_mask = .{ .r_bit = true, .g_bit = true, .b_bit = true, .a_bit = true },
    };
}

pub fn pipelineLayoutCreateInfo() vk.PipelineLayoutCreateInfo {
    return .{
        .flags = .{},
        .set_layout_count = 0,
        .p_set_layouts = undefined,
        .push_constant_range_count = 0,
        .p_push_constant_ranges = undefined,
    };
}

pub fn imageCreateInfo(format: vk.Format, extent: vk.Extent3D, usage_flags: vk.ImageUsageFlags) vk.ImageCreateInfo {
    return .{
        .flags = .{},
        .image_type = .@"2d",
        .format = format,
        .extent = extent,
        .mip_levels = 1,
        .array_layers = 1,
        .samples = .{ .@"1_bit" = true },
        .tiling = .optimal,
        .usage = usage_flags,
        .sharing_mode = .exclusive,
        .queue_family_index_count = 0,
        .p_queue_family_indices = undefined,
        .initial_layout = .@"undefined",
    };
}

pub fn imageViewCreateInfo(format: vk.Format, image: vk.Image, aspect_flags: vk.ImageAspectFlags) vk.ImageViewCreateInfo {
    return .{
        .flags = .{},
        .image = image,
        .view_type = .@"2d",
        .format = format,
        .components = .{ .r = .identity, .g = .identity, .b = .identity, .a = .identity },
        .subresource_range = .{
            .aspect_mask = aspect_flags,
            .base_mip_level = 0,
            .level_count = 1,
            .base_array_layer = 0,
            .layer_count = 1,
        },
    };
}

pub fn pipelineDepthStencilCreateInfo(depth_test: bool, depth_write: bool, compare_op: vk.CompareOp) vk.PipelineDepthStencilStateCreateInfo {
    return .{
        .flags = .{},
        .depth_test_enable = if (depth_test) vk.TRUE else vk.FALSE,
        .depth_write_enable = if (depth_write) vk.TRUE else vk.FALSE,
        .depth_compare_op = if (depth_test) compare_op else .always,
        .depth_bounds_test_enable = vk.FALSE,
        .stencil_test_enable = vk.FALSE,
        .front = std.mem.zeroes(vk.StencilOpState),
        .back = std.mem.zeroes(vk.StencilOpState),
        .min_depth_bounds = 0,
        .max_depth_bounds = 1,
    };
}

pub fn descriptorSetLayoutBinding(desc_type: vk.DescriptorType, stage_flags: vk.ShaderStageFlags, binding: u32) vk.DescriptorSetLayoutBinding {
    return .{
        .binding = binding,
        .descriptor_type = desc_type,
        .descriptor_count = 1,
        .stage_flags = stage_flags,
        .p_immutable_samplers = null,
    };
}

pub fn writeDescriptorBuffer(desc_type: vk.DescriptorType, dst_set: vk.DescriptorSet, buffer_info: *const vk.DescriptorBufferInfo, binding: u32) vk.WriteDescriptorSet {
    return .{
        .dst_set = dst_set,
        .dst_binding = binding,
        .dst_array_element = 0,
        .descriptor_count = 1,
        .descriptor_type = desc_type,
        .p_image_info = undefined,
        .p_buffer_info = @ptrCast([*]const vk.DescriptorBufferInfo, buffer_info),
        .p_texel_buffer_view = undefined,
    };
}

pub fn writeDescriptorImage(descriptor_type: vk.DescriptorType, dst_set: vk.DescriptorSet, image_info: *const vk.DescriptorImageInfo, binding: u32) vk.WriteDescriptorSet {
    return std.mem.zeroInit(vk.WriteDescriptorSet, .{
        .dst_binding = binding,
        .dst_set = dst_set,
        .descriptor_count = 1,
        .descriptor_type = descriptor_type,
        .p_image_info = @ptrCast([*]const vk.DescriptorImageInfo, image_info),
    });
}

pub fn samplerCreateInfo(filters: vk.Filter, sampler_address_mode: vk.SamplerAddressMode) vk.SamplerCreateInfo {
    return std.mem.zeroInit(vk.SamplerCreateInfo, .{
        .mag_filter = filters,
        .min_filter = filters,
        .address_mode_u = sampler_address_mode,
        .address_mode_v = sampler_address_mode,
        .address_mode_w = sampler_address_mode,
    });
}
