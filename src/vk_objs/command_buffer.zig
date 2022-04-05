const std = @import("std");
const vk = @import("vulkan");

const GraphicsContext = @import("../graphics_context.zig").GraphicsContext;

pub const CommandBuffer = struct {
    cmdbuf: vk.CommandBuffer,
    gc: *const GraphicsContext,

    pub fn init(cmdbuf: vk.CommandBuffer, gc: *const GraphicsContext) CommandBuffer {
        return .{ .cmdbuf = cmdbuf, .gc = gc };
    }

    pub fn begin(self: CommandBuffer, p_begin_info: *const vk.CommandBufferBeginInfo) !void {
        return self.gc.vkd.beginCommandBuffer(self.cmdbuf, p_begin_info);
    }

    pub fn end(self: CommandBuffer) !void {
        return self.gc.vkd.endCommandBuffer(self.cmdbuf);
    }

    pub fn reset(self: CommandBuffer, flags: vk.CommandBufferResetFlags) !void {
        return self.gc.vkd.resetCommandBuffer(
            self.cmdbuf,
            flags,
        );
    }

    pub fn bindPipeline(self: CommandBuffer, pipeline_bind_point: vk.PipelineBindPoint, pipeline: vk.Pipeline) void {
        self.gc.vkd.vkCmdBindPipeline(
            self.cmdbuf,
            pipeline_bind_point,
            pipeline,
        );
    }

    pub fn setViewport(self: CommandBuffer, first_viewport: u32, viewport_count: u32, p_viewports: [*]const vk.Viewport) void {
        self.gc.vkd.vkCmdSetViewport(
            self.cmdbuf,
            first_viewport,
            viewport_count,
            p_viewports,
        );
    }

    pub fn setScissor(self: CommandBuffer, first_scissor: u32, scissor_count: u32, p_scissors: [*]const vk.Rect2D) void {
        self.gc.vkd.vkCmdSetScissor(
            self.cmdbuf,
            first_scissor,
            scissor_count,
            p_scissors,
        );
    }

    pub fn setLineWidth(self: CommandBuffer, line_width: f32) void {
        self.gc.vkd.vkCmdSetLineWidth(
            self.cmdbuf,
            line_width,
        );
    }

    pub fn setDepthBias(self: CommandBuffer, depth_bias_constant_factor: f32, depth_bias_clamp: f32, depth_bias_slope_factor: f32) void {
        self.gc.vkd.vkCmdSetDepthBias(
            self.cmdbuf,
            depth_bias_constant_factor,
            depth_bias_clamp,
            depth_bias_slope_factor,
        );
    }

    pub fn setBlendConstants(self: CommandBuffer, blend_constants: [4]f32) void {
        self.gc.vkd.vkCmdSetBlendConstants(
            self.cmdbuf,
            blend_constants,
        );
    }

    pub fn setDepthBounds(self: CommandBuffer, min_depth_bounds: f32, max_depth_bounds: f32) void {
        self.gc.vkd.vkCmdSetDepthBounds(
            self.cmdbuf,
            min_depth_bounds,
            max_depth_bounds,
        );
    }

    pub fn setStencilCompareMask(self: CommandBuffer, face_mask: vk.StencilFaceFlags, compare_mask: u32) void {
        self.gc.vkd.vkCmdSetStencilCompareMask(
            self.cmdbuf,
            face_mask.toInt(),
            compare_mask,
        );
    }

    pub fn setStencilWriteMask(self: CommandBuffer, face_mask: vk.StencilFaceFlags, write_mask: u32) void {
        self.gc.vkd.vkCmdSetStencilWriteMask(
            self.cmdbuf,
            face_mask.toInt(),
            write_mask,
        );
    }

    pub fn setStencilReference(self: CommandBuffer, face_mask: vk.StencilFaceFlags, reference: u32) void {
        self.gc.vkd.vkCmdSetStencilReference(
            self.cmdbuf,
            face_mask.toInt(),
            reference,
        );
    }

    pub fn bindDescriptorSets(
        self: CommandBuffer,
        pipeline_bind_point: vk.PipelineBindPoint,
        layout: vk.PipelineLayout,
        first_set: u32,
        descriptor_set_count: u32,
        p_descriptor_sets: [*]const vk.DescriptorSet,
        dynamic_offset_count: u32,
        p_dynamic_offsets: [*]const u32,
    ) void {
        self.gc.vkd.vkCmdBindDescriptorSets(
            self.cmdbuf,
            pipeline_bind_point,
            layout,
            first_set,
            descriptor_set_count,
            p_descriptor_sets,
            dynamic_offset_count,
            p_dynamic_offsets,
        );
    }

    pub fn bindIndexBuffer(self: CommandBuffer, buffer: vk.Buffer, offset: vk.DeviceSize, index_type: vk.IndexType) void {
        self.gc.vkd.vkCmdBindIndexBuffer(
            self.cmdbuf,
            buffer,
            offset,
            index_type,
        );
    }

    pub fn bindVertexBuffers(
        self: CommandBuffer,
        first_binding: u32,
        binding_count: u32,
        p_buffers: [*]const vk.Buffer,
        p_offsets: [*]const vk.DeviceSize,
    ) void {
        self.gc.vkd.vkCmdBindVertexBuffers(
            self.cmdbuf,
            first_binding,
            binding_count,
            p_buffers,
            p_offsets,
        );
    }

    pub fn draw(
        self: CommandBuffer,
        vertex_count: u32,
        instance_count: u32,
        first_vertex: u32,
        first_instance: u32,
    ) void {
        self.gc.vkd.vkCmdDraw(
            self.cmdbuf,
            vertex_count,
            instance_count,
            first_vertex,
            first_instance,
        );
    }

    pub fn drawIndexed(
        self: CommandBuffer,
        index_count: u32,
        instance_count: u32,
        first_index: u32,
        vertex_offset: i32,
        first_instance: u32,
    ) void {
        self.gc.vkd.vkCmdDrawIndexed(
            self.cmdbuf,
            index_count,
            instance_count,
            first_index,
            vertex_offset,
            first_instance,
        );
    }

    pub fn drawMultiEXT(
        self: CommandBuffer,
        draw_count: u32,
        p_vertex_info: [*]const vk.MultiDrawInfoEXT,
        instance_count: u32,
        first_instance: u32,
        stride: u32,
    ) void {
        self.gc.vkd.vkCmdDrawMultiEXT(
            self.cmdbuf,
            draw_count,
            p_vertex_info,
            instance_count,
            first_instance,
            stride,
        );
    }

    pub fn drawMultiIndexedEXT(
        self: CommandBuffer,
        draw_count: u32,
        p_index_info: [*]const vk.MultiDrawIndexedInfoEXT,
        instance_count: u32,
        first_instance: u32,
        stride: u32,
        p_vertex_offset: ?*const i32,
    ) void {
        self.gc.vkd.vkCmdDrawMultiIndexedEXT(
            self.cmdbuf,
            draw_count,
            p_index_info,
            instance_count,
            first_instance,
            stride,
            p_vertex_offset,
        );
    }

    pub fn drawIndirect(
        self: CommandBuffer,
        buffer: vk.Buffer,
        offset: vk.DeviceSize,
        draw_count: u32,
        stride: u32,
    ) void {
        self.gc.vkd.vkCmdDrawIndirect(
            self.cmdbuf,
            buffer,
            offset,
            draw_count,
            stride,
        );
    }

    pub fn drawIndexedIndirect(
        self: CommandBuffer,
        buffer: vk.Buffer,
        offset: vk.DeviceSize,
        draw_count: u32,
        stride: u32,
    ) void {
        self.gc.vkd.vkCmdDrawIndexedIndirect(
            self.cmdbuf,
            buffer,
            offset,
            draw_count,
            stride,
        );
    }

    pub fn dispatch(self: CommandBuffer, group_count_x: u32, group_count_y: u32, group_count_z: u32) void {
        self.gc.vkd.vkCmdDispatch(
            self.cmdbuf,
            group_count_x,
            group_count_y,
            group_count_z,
        );
    }

    pub fn dispatchIndirect(self: CommandBuffer, buffer: vk.Buffer, offset: vk.DeviceSize) void {
        self.gc.vkd.vkCmdDispatchIndirect(
            self.cmdbuf,
            buffer,
            offset,
        );
    }

    pub fn subpassShadingHUAWEI(self: CommandBuffer) void {
        self.gc.vkd.vkCmdSubpassShadingHUAWEI(
            self.cmdbuf,
        );
    }

    pub fn copyBuffer(
        self: CommandBuffer,
        src_buffer: vk.Buffer,
        dst_buffer: vk.Buffer,
        region_count: u32,
        p_regions: [*]const vk.BufferCopy,
    ) void {
        self.gc.vkd.vkCmdCopyBuffer(
            self.cmdbuf,
            src_buffer,
            dst_buffer,
            region_count,
            p_regions,
        );
    }

    pub fn copyImage(
        self: CommandBuffer,
        src_image: vk.Image,
        src_image_layout: vk.ImageLayout,
        dst_image: vk.Image,
        dst_image_layout: vk.ImageLayout,
        region_count: u32,
        p_regions: [*]const vk.ImageCopy,
    ) void {
        self.gc.vkd.vkCmdCopyImage(
            self.cmdbuf,
            src_image,
            src_image_layout,
            dst_image,
            dst_image_layout,
            region_count,
            p_regions,
        );
    }

    pub fn blitImage(
        self: CommandBuffer,
        src_image: vk.Image,
        src_image_layout: vk.ImageLayout,
        dst_image: vk.Image,
        dst_image_layout: vk.ImageLayout,
        region_count: u32,
        p_regions: [*]const vk.ImageBlit,
        filter: vk.Filter,
    ) void {
        self.gc.vkd.vkCmdBlitImage(
            self.cmdbuf,
            src_image,
            src_image_layout,
            dst_image,
            dst_image_layout,
            region_count,
            p_regions,
            filter,
        );
    }

    pub fn copyBufferToImage(
        self: CommandBuffer,
        src_buffer: vk.Buffer,
        dst_image: vk.Image,
        dst_image_layout: vk.ImageLayout,
        region_count: u32,
        p_regions: [*]const vk.BufferImageCopy,
    ) void {
        self.gc.vkd.vkCmdCopyBufferToImage(
            self.cmdbuf,
            src_buffer,
            dst_image,
            dst_image_layout,
            region_count,
            p_regions,
        );
    }

    pub fn copyImageToBuffer(
        self: CommandBuffer,
        src_image: vk.Image,
        src_image_layout: vk.ImageLayout,
        dst_buffer: vk.Buffer,
        region_count: u32,
        p_regions: [*]const vk.BufferImageCopy,
    ) void {
        self.gc.vkd.vkCmdCopyImageToBuffer(
            self.cmdbuf,
            src_image,
            src_image_layout,
            dst_buffer,
            region_count,
            p_regions,
        );
    }

    pub fn updateBuffer(
        self: CommandBuffer,
        dst_buffer: vk.Buffer,
        dst_offset: vk.DeviceSize,
        data_size: vk.DeviceSize,
        p_data: *const anyopaque,
    ) void {
        self.gc.vkd.vkCmdUpdateBuffer(
            self.cmdbuf,
            dst_buffer,
            dst_offset,
            data_size,
            p_data,
        );
    }

    pub fn fillBuffer(
        self: CommandBuffer,
        dst_buffer: vk.Buffer,
        dst_offset: vk.DeviceSize,
        size: vk.DeviceSize,
        data: u32,
    ) void {
        self.gc.vkd.vkCmdFillBuffer(
            self.cmdbuf,
            dst_buffer,
            dst_offset,
            size,
            data,
        );
    }

    pub fn clearColorImage(
        self: CommandBuffer,
        image: vk.Image,
        image_layout: vk.ImageLayout,
        p_color: *const vk.ClearColorValue,
        range_count: u32,
        p_ranges: [*]const vk.ImageSubresourceRange,
    ) void {
        self.gc.vkd.vkCmdClearColorImage(
            self.cmdbuf,
            image,
            image_layout,
            p_color,
            range_count,
            p_ranges,
        );
    }

    pub fn clearDepthStencilImage(
        self: CommandBuffer,
        image: vk.Image,
        image_layout: vk.ImageLayout,
        p_depth_stencil: *const vk.ClearDepthStencilValue,
        range_count: u32,
        p_ranges: [*]const vk.ImageSubresourceRange,
    ) void {
        self.gc.vkd.vkCmdClearDepthStencilImage(
            self.cmdbuf,
            image,
            image_layout,
            p_depth_stencil,
            range_count,
            p_ranges,
        );
    }

    pub fn clearAttachments(
        self: CommandBuffer,
        attachment_count: u32,
        p_attachments: [*]const vk.ClearAttachment,
        rect_count: u32,
        p_rects: [*]const vk.ClearRect,
    ) void {
        self.gc.vkd.vkCmdClearAttachments(
            self.cmdbuf,
            attachment_count,
            p_attachments,
            rect_count,
            p_rects,
        );
    }

    pub fn resolveImage(
        self: CommandBuffer,
        src_image: vk.Image,
        src_image_layout: vk.ImageLayout,
        dst_image: vk.Image,
        dst_image_layout: vk.ImageLayout,
        region_count: u32,
        p_regions: [*]const vk.ImageResolve,
    ) void {
        self.gc.vkd.vkCmdResolveImage(
            self.cmdbuf,
            src_image,
            src_image_layout,
            dst_image,
            dst_image_layout,
            region_count,
            p_regions,
        );
    }

    pub fn setEvent(self: CommandBuffer, event: vk.Event, stage_mask: vk.PipelineStageFlags) void {
        self.gc.vkd.vkCmdSetEvent(
            self.cmdbuf,
            event,
            stage_mask.toInt(),
        );
    }

    pub fn resetEvent(self: CommandBuffer, event: vk.Event, stage_mask: vk.PipelineStageFlags) void {
        self.gc.vkd.vkCmdResetEvent(
            self.cmdbuf,
            event,
            stage_mask.toInt(),
        );
    }

    pub fn waitEvents(
        self: CommandBuffer,
        event_count: u32,
        p_events: [*]const vk.Event,
        src_stage_mask: vk.PipelineStageFlags,
        dst_stage_mask: vk.PipelineStageFlags,
        memory_barrier_count: u32,
        p_memory_barriers: [*]const vk.MemoryBarrier,
        buffer_memory_barrier_count: u32,
        p_buffer_memory_barriers: [*]const vk.BufferMemoryBarrier,
        image_memory_barrier_count: u32,
        p_image_memory_barriers: [*]const vk.ImageMemoryBarrier,
    ) void {
        self.gc.vkd.vkCmdWaitEvents(
            self.cmdbuf,
            event_count,
            p_events,
            src_stage_mask.toInt(),
            dst_stage_mask.toInt(),
            memory_barrier_count,
            p_memory_barriers,
            buffer_memory_barrier_count,
            p_buffer_memory_barriers,
            image_memory_barrier_count,
            p_image_memory_barriers,
        );
    }

    pub fn pipelineBarrier(
        self: CommandBuffer,
        src_stage_mask: vk.PipelineStageFlags,
        dst_stage_mask: vk.PipelineStageFlags,
        dependency_flags: vk.DependencyFlags,
        memory_barrier_count: u32,
        p_memory_barriers: [*]const vk.MemoryBarrier,
        buffer_memory_barrier_count: u32,
        p_buffer_memory_barriers: [*]const vk.BufferMemoryBarrier,
        image_memory_barrier_count: u32,
        p_image_memory_barriers: [*]const vk.ImageMemoryBarrier,
    ) void {
        self.gc.vkd.vkCmdPipelineBarrier(
            self.cmdbuf,
            src_stage_mask.toInt(),
            dst_stage_mask.toInt(),
            dependency_flags.toInt(),
            memory_barrier_count,
            p_memory_barriers,
            buffer_memory_barrier_count,
            p_buffer_memory_barriers,
            image_memory_barrier_count,
            p_image_memory_barriers,
        );
    }

    pub fn beginQuery(self: CommandBuffer, query_pool: vk.QueryPool, query: u32, flags: vk.QueryControlFlags) void {
        self.gc.vkd.vkCmdBeginQuery(
            self.cmdbuf,
            query_pool,
            query,
            flags.toInt(),
        );
    }

    pub fn endQuery(self: CommandBuffer, query_pool: vk.QueryPool, query: u32) void {
        self.gc.vkd.vkCmdEndQuery(
            self.cmdbuf,
            query_pool,
            query,
        );
    }

    pub fn beginConditionalRenderingEXT(self: CommandBuffer, p_conditional_rendering_begin: *const vk.ConditionalRenderingBeginInfoEXT) void {
        self.gc.vkd.vkCmdBeginConditionalRenderingEXT(
            self.cmdbuf,
            p_conditional_rendering_begin,
        );
    }

    pub fn endConditionalRenderingEXT(self: CommandBuffer) void {
        self.gc.vkd.vkCmdEndConditionalRenderingEXT(
            self.cmdbuf,
        );
    }

    pub fn resetQueryPool(self: CommandBuffer, query_pool: vk.QueryPool, first_query: u32, query_count: u32) void {
        self.gc.vkd.vkCmdResetQueryPool(
            self.cmdbuf,
            query_pool,
            first_query,
            query_count,
        );
    }

    pub fn writeTimestamp(self: CommandBuffer, pipeline_stage: vk.PipelineStageFlags, query_pool: vk.QueryPool, query: u32) void {
        self.gc.vkd.vkCmdWriteTimestamp(
            self.cmdbuf,
            pipeline_stage.toInt(),
            query_pool,
            query,
        );
    }

    pub fn copyQueryPoolResults(
        self: CommandBuffer,
        query_pool: vk.QueryPool,
        first_query: u32,
        query_count: u32,
        dst_buffer: vk.Buffer,
        dst_offset: vk.DeviceSize,
        stride: vk.DeviceSize,
        flags: vk.QueryResultFlags,
    ) void {
        self.gc.vkd.vkCmdCopyQueryPoolResults(
            self.cmdbuf,
            query_pool,
            first_query,
            query_count,
            dst_buffer,
            dst_offset,
            stride,
            flags.toInt(),
        );
    }

    pub fn pushConstants(
        self: CommandBuffer,
        layout: vk.PipelineLayout,
        stage_flags: vk.ShaderStageFlags,
        offset: u32,
        size: u32,
        p_values: *const anyopaque,
    ) void {
        self.gc.vkd.vkCmdPushConstants(
            self.cmdbuf,
            layout,
            stage_flags.toInt(),
            offset,
            size,
            p_values,
        );
    }

    pub fn beginRenderPass(self: CommandBuffer, p_render_pass_begin: *const vk.RenderPassBeginInfo, contents: vk.SubpassContents) void {
        self.gc.vkd.vkCmdBeginRenderPass(
            self.cmdbuf,
            p_render_pass_begin,
            contents,
        );
    }

    pub fn nextSubpass(self: CommandBuffer, contents: vk.SubpassContents) void {
        self.gc.vkd.vkCmdNextSubpass(
            self.cmdbuf,
            contents,
        );
    }

    pub fn endRenderPass(self: CommandBuffer) void {
        self.gc.vkd.vkCmdEndRenderPass(
            self.cmdbuf,
        );
    }

    pub fn executeCommands(self: CommandBuffer, command_buffer_count: u32, p_command_buffers: [*]const vk.CommandBuffer) void {
        self.gc.vkd.vkCmdExecuteCommands(
            self.cmdbuf,
            command_buffer_count,
            p_command_buffers,
        );
    }
};
