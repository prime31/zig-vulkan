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

// VkSubmitInfo vkinit::submit_info(VkCommandBuffer* cmd)
// {
// 	VkSubmitInfo info = {};
// 	info.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO;
// 	info.pNext = nullptr;

// 	info.waitSemaphoreCount = 0;
// 	info.pWaitSemaphores = nullptr;
// 	info.pWaitDstStageMask = nullptr;
// 	info.commandBufferCount = 1;
// 	info.pCommandBuffers = cmd;
// 	info.signalSemaphoreCount = 0;
// 	info.pSignalSemaphores = nullptr;

// 	return info;
// }

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

// VkPipelineShaderStageCreateInfo vkinit::pipeline_shader_stage_create_info(VkShaderStageFlagBits stage, VkShaderModule shaderModule)
// {
// 	VkPipelineShaderStageCreateInfo info{};
// 	info.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
// 	info.pNext = nullptr;

// 	//shader stage
// 	info.stage = stage;
// 	//module containing the code for this shader stage
// 	info.module = shaderModule;
// 	//the entry point of the shader
// 	info.pName = "main";
// 	return info;
// }

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
pub fn pipelineInputAssempblyCreateInfo(topology: vk.PrimitiveTopology) vk.PipelineInputAssemblyStateCreateInfo {
    return .{
        .flags = .{},
        .topology = topology,
        .primitive_restart_enable = vk.FALSE,
    };
}

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

// VkDescriptorSetLayoutBinding vkinit::descriptorset_layout_binding(VkDescriptorType type, VkShaderStageFlags stageFlags, uint32_t binding)
// {
// 	VkDescriptorSetLayoutBinding setbind = {};
// 	setbind.binding = binding;
// 	setbind.descriptorCount = 1;
// 	setbind.descriptorType = type;
// 	setbind.pImmutableSamplers = nullptr;
// 	setbind.stageFlags = stageFlags;

// 	return setbind;
// }
// VkWriteDescriptorSet vkinit::write_descriptor_buffer(VkDescriptorType type, VkDescriptorSet dstSet, VkDescriptorBufferInfo* bufferInfo , uint32_t binding)
// {
// 	VkWriteDescriptorSet write = {};
// 	write.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
// 	write.pNext = nullptr;

// 	write.dstBinding = binding;
// 	write.dstSet = dstSet;
// 	write.descriptorCount = 1;
// 	write.descriptorType = type;
// 	write.pBufferInfo = bufferInfo;

// 	return write;
// }

// VkWriteDescriptorSet vkinit::write_descriptor_image(VkDescriptorType type, VkDescriptorSet dstSet, VkDescriptorImageInfo* imageInfo, uint32_t binding)
// {
// 	VkWriteDescriptorSet write = {};
// 	write.sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
// 	write.pNext = nullptr;

// 	write.dstBinding = binding;
// 	write.dstSet = dstSet;
// 	write.descriptorCount = 1;
// 	write.descriptorType = type;
// 	write.pImageInfo = imageInfo;

// 	return write;
// }

// VkSamplerCreateInfo vkinit::sampler_create_info(VkFilter filters, VkSamplerAddressMode samplerAdressMode /*= VK_SAMPLER_ADDRESS_MODE_REPEAT*/)
// {
// 	VkSamplerCreateInfo info = {};
// 	info.sType = VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO;
// 	info.pNext = nullptr;

// 	info.magFilter = filters;
// 	info.minFilter = filters;
// 	info.addressModeU = samplerAdressMode;
// 	info.addressModeV = samplerAdressMode;
// 	info.addressModeW = samplerAdressMode;

// 	return info;
// }
