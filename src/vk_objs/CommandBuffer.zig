const std = @import("std");
const vk = @import("vulkan");

const GraphicsContext = @import("../graphics_context.zig").GraphicsContext;

cmdbuf: vk.CommandBuffer,
gc: *const GraphicsContext,

pub fn init(cmdbuf: vk.CommandBuffer, gc: *const GraphicsContext) @This() {
    return .{ .cmdbuf = cmdbuf, .gc = gc };
}

pub fn begin(self: @This(), p_begin_info: *const vk.CommandBufferBeginInfo) !void {
    return self.gc.vkd.beginCommandBuffer(self.cmdbuf, p_begin_info);
}

pub fn end(self: @This()) !void {
    return self.gc.vkd.endCommandBuffer(self.cmdbuf);
}

pub fn reset(self: @This(), flags: vk.CommandBufferResetFlags) !void {
    return self.gc.vkd.resetCommandBuffer(self.cmdbuf, flags);
}

pub fn bindPipeline(self: @This(), pipeline_bind_point: vk.PipelineBindPoint, pipeline: vk.Pipeline) void {
    self.gc.cmdBindPipeline(self.cmdbuf, pipeline_bind_point, pipeline);
}

pub fn setViewport(self: @This(), first_viewport: u32, viewport_count: u32, p_viewports: [*]const vk.Viewport) void {
    self.gc.cmdSetViewport(self.cmdbuf, first_viewport, viewport_count, p_viewports);
}

pub fn setScissor(self: @This(), first_scissor: u32, scissor_count: u32, p_scissors: [*]const vk.Rect2D) void {
    self.gc.cmdSetScissor(self.cmdbuf, first_scissor, scissor_count, p_scissors);
}

pub fn setLineWidth(self: @This(), line_width: f32) void {
    self.gc.cmdSetLineWidth(self.cmdbuf, line_width);
}

pub fn setDepthBias(self: @This(), depth_bias_constant_factor: f32, depth_bias_clamp: f32, depth_bias_slope_factor: f32) void {
    self.gc.cmdSetDepthBias(self.cmdbuf, depth_bias_constant_factor, depth_bias_clamp, depth_bias_slope_factor);
}

pub fn setBlendConstants(self: @This(), blend_constants: [4]f32) void {
    self.gc.cmdSetBlendConstants(self.cmdbuf, blend_constants);
}

pub fn setDepthBounds(self: @This(), min_depth_bounds: f32, max_depth_bounds: f32) void {
    self.gc.cmdSetDepthBounds(self.cmdbuf, min_depth_bounds, max_depth_bounds);
}

pub fn setStencilCompareMask(self: @This(), face_mask: vk.StencilFaceFlags, compare_mask: u32) void {
    self.gc.cmdSetStencilCompareMask(self.cmdbuf, face_mask, compare_mask);
}

pub fn setStencilWriteMask(self: @This(), face_mask: vk.StencilFaceFlags, write_mask: u32) void {
    self.gc.cmdSetStencilWriteMask(self.cmdbuf, face_mask, write_mask);
}

pub fn setStencilReference(self: @This(), face_mask: vk.StencilFaceFlags, reference: u32) void {
    self.gc.cmdSetStencilReference(self.cmdbuf, face_mask, reference);
}

pub fn bindDescriptorSets(
    self: @This(),
    pipeline_bind_point: vk.PipelineBindPoint,
    layout: vk.PipelineLayout,
    first_set: u32,
    descriptor_set_count: u32,
    p_descriptor_sets: [*]const vk.DescriptorSet,
    dynamic_offset_count: u32,
    p_dynamic_offsets: [*]const u32,
) void {
    self.gc.cmdBindDescriptorSets(
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

pub fn bindIndexBuffer(self: @This(), buffer: vk.Buffer, offset: vk.DeviceSize, index_type: vk.IndexType) void {
    self.gc.cmdBindIndexBuffer(self.cmdbuf, buffer, offset, index_type);
}

pub fn bindVertexBuffers(
    self: @This(),
    first_binding: u32,
    binding_count: u32,
    p_buffers: [*]const vk.Buffer,
    p_offsets: [*]const vk.DeviceSize,
) void {
    self.gc.cmdBindVertexBuffers(self.cmdbuf, first_binding, binding_count, p_buffers, p_offsets);
}

pub fn draw(
    self: @This(),
    vertex_count: u32,
    instance_count: u32,
    first_vertex: u32,
    first_instance: u32,
) void {
    self.gc.cmdDraw(self.cmdbuf, vertex_count, instance_count, first_vertex, first_instance);
}

pub fn drawIndexed(
    self: @This(),
    index_count: u32,
    instance_count: u32,
    first_index: u32,
    vertex_offset: i32,
    first_instance: u32,
) void {
    self.gc.cmdDrawIndexed(self.cmdbuf, index_count, instance_count, first_index, vertex_offset, first_instance);
}

pub fn drawMultiEXT(
    self: @This(),
    draw_count: u32,
    p_vertex_info: [*]const vk.MultiDrawInfoEXT,
    instance_count: u32,
    first_instance: u32,
    stride: u32,
) void {
    self.gc.cmdDrawMultiEXT(self.cmdbuf, draw_count, p_vertex_info, instance_count, first_instance, stride);
}

pub fn drawMultiIndexedEXT(
    self: @This(),
    draw_count: u32,
    p_index_info: [*]const vk.MultiDrawIndexedInfoEXT,
    instance_count: u32,
    first_instance: u32,
    stride: u32,
    p_vertex_offset: ?*const i32,
) void {
    self.gc.cmdDrawMultiIndexedEXT(self.cmdbuf, draw_count, p_index_info, instance_count, first_instance, stride, p_vertex_offset);
}

pub fn drawIndirect(
    self: @This(),
    buffer: vk.Buffer,
    offset: vk.DeviceSize,
    draw_count: u32,
    stride: u32,
) void {
    self.gc.cmdDrawIndirect(self.cmdbuf, buffer, offset, draw_count, stride);
}

pub fn drawIndexedIndirect(
    self: @This(),
    buffer: vk.Buffer,
    offset: vk.DeviceSize,
    draw_count: u32,
    stride: u32,
) void {
    self.gc.cmdDrawIndexedIndirect(self.cmdbuf, buffer, offset, draw_count, stride);
}

pub fn dispatch(self: @This(), group_count_x: u32, group_count_y: u32, group_count_z: u32) void {
    self.gc.cmdDispatch(self.cmdbuf, group_count_x, group_count_y, group_count_z);
}

pub fn dispatchIndirect(self: @This(), buffer: vk.Buffer, offset: vk.DeviceSize) void {
    self.gc.cmdDispatchIndirect(self.cmdbuf, buffer, offset);
}

pub fn subpassShadingHUAWEI(self: @This()) void {
    self.gc.cmdSubpassShadingHUAWEI(self.cmdbuf);
}

pub fn copyBuffer(
    self: @This(),
    src_buffer: vk.Buffer,
    dst_buffer: vk.Buffer,
    region_count: u32,
    p_regions: [*]const vk.BufferCopy,
) void {
    self.gc.vkd.cmdCopyBuffer(self.cmdbuf, src_buffer, dst_buffer, region_count, p_regions);
}

pub fn copyImage(
    self: @This(),
    src_image: vk.Image,
    src_image_layout: vk.ImageLayout,
    dst_image: vk.Image,
    dst_image_layout: vk.ImageLayout,
    region_count: u32,
    p_regions: [*]const vk.ImageCopy,
) void {
    self.gc.vkd.cmdCopyImage(
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
    self: @This(),
    src_image: vk.Image,
    src_image_layout: vk.ImageLayout,
    dst_image: vk.Image,
    dst_image_layout: vk.ImageLayout,
    region_count: u32,
    p_regions: [*]const vk.ImageBlit,
    filter: vk.Filter,
) void {
    self.gc.cmdBlitImage(
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
    self: @This(),
    src_buffer: vk.Buffer,
    dst_image: vk.Image,
    dst_image_layout: vk.ImageLayout,
    region_count: u32,
    p_regions: [*]const vk.BufferImageCopy,
) void {
    self.gc.vkd.cmdCopyBufferToImage(self.cmdbuf, src_buffer, dst_image, dst_image_layout, region_count, p_regions);
}

pub fn copyImageToBuffer(
    self: @This(),
    src_image: vk.Image,
    src_image_layout: vk.ImageLayout,
    dst_buffer: vk.Buffer,
    region_count: u32,
    p_regions: [*]const vk.BufferImageCopy,
) void {
    self.gc.cmdCopyImageToBuffer(self.cmdbuf, src_image, src_image_layout, dst_buffer, region_count, p_regions);
}

pub fn updateBuffer(
    self: @This(),
    dst_buffer: vk.Buffer,
    dst_offset: vk.DeviceSize,
    data_size: vk.DeviceSize,
    p_data: *const anyopaque,
) void {
    self.gc.cmdUpdateBuffer(self.cmdbuf, dst_buffer, dst_offset, data_size, p_data);
}

pub fn fillBuffer(
    self: @This(),
    dst_buffer: vk.Buffer,
    dst_offset: vk.DeviceSize,
    size: vk.DeviceSize,
    data: u32,
) void {
    self.gc.cmdFillBuffer(
        self.cmdbuf,
        dst_buffer,
        dst_offset,
        size,
        data,
    );
}

pub fn clearColorImage(
    self: @This(),
    image: vk.Image,
    image_layout: vk.ImageLayout,
    p_color: *const vk.ClearColorValue,
    range_count: u32,
    p_ranges: [*]const vk.ImageSubresourceRange,
) void {
    self.gc.cmdClearColorImage(self.cmdbuf, image, image_layout, p_color, range_count, p_ranges);
}

pub fn clearDepthStencilImage(
    self: @This(),
    image: vk.Image,
    image_layout: vk.ImageLayout,
    p_depth_stencil: *const vk.ClearDepthStencilValue,
    range_count: u32,
    p_ranges: [*]const vk.ImageSubresourceRange,
) void {
    self.gc.cmdClearDepthStencilImage(self.cmdbuf, image, image_layout, p_depth_stencil, range_count, p_ranges);
}

pub fn clearAttachments(
    self: @This(),
    attachment_count: u32,
    p_attachments: [*]const vk.ClearAttachment,
    rect_count: u32,
    p_rects: [*]const vk.ClearRect,
) void {
    self.gc.cmdClearAttachments(self.cmdbuf, attachment_count, p_attachments, rect_count, p_rects);
}

pub fn resolveImage(
    self: @This(),
    src_image: vk.Image,
    src_image_layout: vk.ImageLayout,
    dst_image: vk.Image,
    dst_image_layout: vk.ImageLayout,
    region_count: u32,
    p_regions: [*]const vk.ImageResolve,
) void {
    self.gc.cmdResolveImage(self.cmdbuf, src_image, src_image_layout, dst_image, dst_image_layout, region_count, p_regions);
}

pub fn setEvent(self: @This(), event: vk.Event, stage_mask: vk.PipelineStageFlags) void {
    self.gc.cmdSetEvent(self.cmdbuf, event, stage_mask);
}

pub fn resetEvent(self: @This(), event: vk.Event, stage_mask: vk.PipelineStageFlags) void {
    self.gc.cmdResetEvent(self.cmdbuf, event, stage_mask);
}

pub fn waitEvents(
    self: @This(),
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
    self.gc.cmdWaitEvents(
        self.cmdbuf,
        event_count,
        p_events,
        src_stage_mask,
        dst_stage_mask,
        memory_barrier_count,
        p_memory_barriers,
        buffer_memory_barrier_count,
        p_buffer_memory_barriers,
        image_memory_barrier_count,
        p_image_memory_barriers,
    );
}

pub fn pipelineBarrier(
    self: @This(),
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
    self.gc.vkd.cmdPipelineBarrier(
        self.cmdbuf,
        src_stage_mask,
        dst_stage_mask,
        dependency_flags,
        memory_barrier_count,
        p_memory_barriers,
        buffer_memory_barrier_count,
        p_buffer_memory_barriers,
        image_memory_barrier_count,
        p_image_memory_barriers,
    );
}

pub fn beginQuery(self: @This(), query_pool: vk.QueryPool, query: u32, flags: vk.QueryControlFlags) void {
    self.gc.cmdBeginQuery(self.cmdbuf, query_pool, query, flags);
}

pub fn endQuery(self: @This(), query_pool: vk.QueryPool, query: u32) void {
    self.gc.cmdEndQuery(self.cmdbuf, query_pool, query);
}

pub fn beginConditionalRenderingEXT(self: @This(), p_conditional_rendering_begin: *const vk.ConditionalRenderingBeginInfoEXT) void {
    self.gc.cmdBeginConditionalRenderingEXT(self.cmdbuf, p_conditional_rendering_begin);
}

pub fn endConditionalRenderingEXT(self: @This()) void {
    self.gc.cmdEndConditionalRenderingEXT(self.cmdbuf);
}

pub fn resetQueryPool(self: @This(), query_pool: vk.QueryPool, first_query: u32, query_count: u32) void {
    self.gc.cmdResetQueryPool(self.cmdbuf, query_pool, first_query, query_count);
}

pub fn writeTimestamp(self: @This(), pipeline_stage: vk.PipelineStageFlags, query_pool: vk.QueryPool, query: u32) void {
    self.gc.cmdWriteTimestamp(self.cmdbuf, pipeline_stage, query_pool, query);
}

pub fn copyQueryPoolResults(
    self: @This(),
    query_pool: vk.QueryPool,
    first_query: u32,
    query_count: u32,
    dst_buffer: vk.Buffer,
    dst_offset: vk.DeviceSize,
    stride: vk.DeviceSize,
    flags: vk.QueryResultFlags,
) void {
    self.gc.cmdCopyQueryPoolResults(self.cmdbuf, query_pool, first_query, query_count, dst_buffer, dst_offset, stride, flags);
}

pub fn pushConstants(self: @This(), layout: vk.PipelineLayout, stage_flags: vk.ShaderStageFlags, offset: u32, size: u32, p_values: *const anyopaque) void {
    self.gc.cmdPushConstants(self.cmdbuf, layout, stage_flags, offset, size, p_values);
}

pub fn beginRenderPass(self: @This(), p_render_pass_begin: *const vk.RenderPassBeginInfo, contents: vk.SubpassContents) void {
    self.gc.cmdBeginRenderPass(self.cmdbuf, p_render_pass_begin, contents);
}

pub fn nextSubpass(self: @This(), contents: vk.SubpassContents) void {
    self.gc.cmdNextSubpass(self.cmdbuf, contents);
}

pub fn endRenderPass(self: @This()) void {
    self.gc.cmdEndRenderPass(self.cmdbuf);
}

pub fn executeCommands(self: @This(), command_buffer_count: u32, p_command_buffers: [*]const vk.CommandBuffer) void {
    self.gc.cmdExecuteCommands(self.cmdbuf, command_buffer_count, p_command_buffers);
}
