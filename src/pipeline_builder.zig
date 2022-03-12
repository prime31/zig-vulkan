const std = @import("std");
const vk = @import("vulkan");

const GraphicsContext = @import("graphics_context.zig").GraphicsContext;

pub const PipelineBuilder = struct {
    shader_stages: std.ArrayList(vk.PipelineShaderStageCreateInfo),
    vertex_input_info: vk.PipelineVertexInputStateCreateInfo,
    input_assembly: vk.PipelineInputAssemblyStateCreateInfo,
    viewport: vk.Viewport,
    scissor: vk.Rect2D,
    rasterizer: vk.PipelineRasterizationStateCreateInfo,
    color_blend_attachment: vk.PipelineColorBlendAttachmentState,
    multisampling: vk.PipelineMultisampleStateCreateInfo,
    pipeline_layout: vk.PipelineLayout,

    pub fn init(allocator: std.mem.Allocator, extent: vk.Extent2D, pipeline_layout: vk.PipelineLayout) PipelineBuilder {
        const input_assembly = vk.PipelineInputAssemblyStateCreateInfo{
            .flags = .{},
            .topology = .triangle_list,
            .primitive_restart_enable = vk.FALSE,
        };

        const viewport = vk.Viewport{
            .x = 0,
            .y = 0,
            .width = @intToFloat(f32, extent.width),
            .height = @intToFloat(f32, extent.height),
            .min_depth = 0,
            .max_depth = 1,
        };

        const scissor = vk.Rect2D{
            .offset = .{ .x = 0, .y = 0 },
            .extent = extent,
        };

        const rasterizer = vk.PipelineRasterizationStateCreateInfo{
            .flags = .{},
            .depth_clamp_enable = vk.FALSE,
            .rasterizer_discard_enable = vk.FALSE,
            .polygon_mode = .fill,
            .cull_mode = .{ .back_bit = true },
            .front_face = .clockwise,
            .depth_bias_enable = vk.FALSE,
            .depth_bias_constant_factor = 0,
            .depth_bias_clamp = 0,
            .depth_bias_slope_factor = 0,
            .line_width = 1,
        };

        const color_blend_attachment = vk.PipelineColorBlendAttachmentState{
            .blend_enable = vk.FALSE,
            .src_color_blend_factor = .one,
            .dst_color_blend_factor = .zero,
            .color_blend_op = .add,
            .src_alpha_blend_factor = .one,
            .dst_alpha_blend_factor = .zero,
            .alpha_blend_op = .add,
            .color_write_mask = .{ .r_bit = true, .g_bit = true, .b_bit = true, .a_bit = true },
        };

        const multisampling = vk.PipelineMultisampleStateCreateInfo{
            .flags = .{},
            .rasterization_samples = .{ .@"1_bit" = true },
            .sample_shading_enable = vk.FALSE,
            .min_sample_shading = 1,
            .p_sample_mask = null,
            .alpha_to_coverage_enable = vk.FALSE,
            .alpha_to_one_enable = vk.FALSE,
        };

        return .{
            .shader_stages = std.ArrayList(vk.PipelineShaderStageCreateInfo).init(allocator),
            .vertex_input_info = .{
                .flags = .{},
                .vertex_binding_description_count = 0,
                .p_vertex_binding_descriptions = undefined,
                .vertex_attribute_description_count = 0,
                .p_vertex_attribute_descriptions = undefined,
            },
            .input_assembly = input_assembly,
            .viewport = viewport,
            .scissor = scissor,
            .rasterizer = rasterizer,
            .color_blend_attachment = color_blend_attachment,
            .multisampling = multisampling,
            .pipeline_layout = pipeline_layout,
        };
    }

    pub fn addShaderStage(self: *PipelineBuilder, stage: vk.PipelineShaderStageCreateInfo) !void {
        try self.shader_stages.append(stage);
    }

    pub fn build(self: PipelineBuilder, gc: *const GraphicsContext, render_pass: vk.RenderPass) !vk.Pipeline {
        defer self.shader_stages.deinit();

        const viewport_state = vk.PipelineViewportStateCreateInfo{
            .flags = .{},
            .viewport_count = 1,
            .p_viewports =  @ptrCast([*]const vk.Viewport, &self.viewport),
            .scissor_count = 1,
            .p_scissors = @ptrCast([*]const vk.Rect2D, &self.scissor),
        };

        const color_blending = vk.PipelineColorBlendStateCreateInfo{
            .flags = .{},
            .logic_op_enable = vk.FALSE,
            .logic_op = .copy,
            .attachment_count = 1,
            .p_attachments = @ptrCast([*]const vk.PipelineColorBlendAttachmentState, &self.color_blend_attachment),
            .blend_constants = [_]f32{ 0, 0, 0, 0 },
        };

        const gpci = vk.GraphicsPipelineCreateInfo{
            .flags = .{},
            .stage_count = @intCast(u32, self.shader_stages.items.len),
            .p_stages = @ptrCast([*]const vk.PipelineShaderStageCreateInfo, self.shader_stages.items.ptr),
            .p_vertex_input_state = &self.vertex_input_info,
            .p_input_assembly_state = &self.input_assembly,
            .p_tessellation_state = null,
            .p_viewport_state = &viewport_state,
            .p_rasterization_state = &self.rasterizer,
            .p_multisample_state = &self.multisampling,
            .p_depth_stencil_state = null,
            .p_color_blend_state = &color_blending,
            .p_dynamic_state = null,
            .layout = self.pipeline_layout,
            .render_pass = render_pass,
            .subpass = 0,
            .base_pipeline_handle = .null_handle,
            .base_pipeline_index = -1,
        };

        var pipeline: vk.Pipeline = undefined;
        _ = try gc.vkd.createGraphicsPipelines(
            gc.dev,
            .null_handle,
            1,
            @ptrCast([*]const vk.GraphicsPipelineCreateInfo, &gpci),
            null,
            @ptrCast([*]vk.Pipeline, &pipeline),
        );
        return pipeline;
    }
};
