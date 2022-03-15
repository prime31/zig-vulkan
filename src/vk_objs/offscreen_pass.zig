const std = @import("std");
const vk = @import("vulkan");

const FrameBufferAttachment = @import("frame_buffer_attachment.zig");

// not sure if this is a good abstraction
pub const OffscreenPass = struct {
    width: i32,
    height: i32,
    color: FrameBufferAttachment,
    depth: FrameBufferAttachment,
    render_pass: vk.RenderPass,
    sampler: vk.Sampler,
    descriptor: vk.DescriptorImageInfo,

    pub fn init() OffscreenPass {
        return .{
            .width = undefined,
            .height = undefined,
            .color = undefined,
            .depth = undefined,
            .render_pass = undefined,
            .sampler = undefined,
            .descriptor = undefined,
        };
    }
};
