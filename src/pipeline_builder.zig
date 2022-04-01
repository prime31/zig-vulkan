const std = @import("std");
const vk = @import("vulkan");
const vkinit = @import("vkinit.zig");

const GraphicsContext = @import("graphics_context.zig").GraphicsContext;

pub const PipelineBuilder = struct {
    shader_stages: std.ArrayList(vk.PipelineShaderStageCreateInfo),
    vertex_input_info: vk.PipelineVertexInputStateCreateInfo,
    input_assembly: vk.PipelineInputAssemblyStateCreateInfo,
    rasterizer: vk.PipelineRasterizationStateCreateInfo,
    color_blend_attachment: vk.PipelineColorBlendAttachmentState,
    multisampling: vk.PipelineMultisampleStateCreateInfo,
    pipeline_layout: vk.PipelineLayout,
    depth_stencil: ?vk.PipelineDepthStencilStateCreateInfo = null,

    pub fn init(allocator: std.mem.Allocator, pipeline_layout: vk.PipelineLayout) PipelineBuilder {
        return .{
            .shader_stages = std.ArrayList(vk.PipelineShaderStageCreateInfo).init(allocator),
            .vertex_input_info = .{
                .flags = .{},
                .vertex_binding_description_count = 0,
                .p_vertex_binding_descriptions = undefined,
                .vertex_attribute_description_count = 0,
                .p_vertex_attribute_descriptions = undefined,
            },
            .input_assembly = vkinit.pipelineInputAssemblyCreateInfo(.triangle_list),
            .rasterizer = vkinit.pipelineRasterizationStateCreateInfo(.fill),
            .color_blend_attachment = vkinit.pipelineColorBlendAttachmentState(),
            .multisampling = vkinit.pipelineMultisampleStateCreateInfo(),
            .pipeline_layout = pipeline_layout,
        };
    }

    pub fn deinit(self: PipelineBuilder) void {
        self.shader_stages.deinit();
    }

    pub fn addShaderStage(self: *PipelineBuilder, stage: vk.PipelineShaderStageCreateInfo) !void {
        try self.shader_stages.append(stage);
    }

    pub fn build(self: PipelineBuilder, gc: *const GraphicsContext, render_pass: vk.RenderPass) !vk.Pipeline {
        defer self.shader_stages.deinit();

        const viewport_state = vk.PipelineViewportStateCreateInfo{
            .flags = .{},
            .viewport_count = 1,
            .p_viewports =  null,
            .scissor_count = 1,
            .p_scissors = null,
        };

        const dynstate = [_]vk.DynamicState{ .viewport, .scissor };
        const pdsci = vk.PipelineDynamicStateCreateInfo{
            .flags = .{},
            .dynamic_state_count = dynstate.len,
            .p_dynamic_states = &dynstate,
        };

        // color_blending must match the fragment shader output
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
            .p_depth_stencil_state = if (self.depth_stencil) |*ds| ds else null,
            .p_color_blend_state = &color_blending,
            .p_dynamic_state = &pdsci,
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
