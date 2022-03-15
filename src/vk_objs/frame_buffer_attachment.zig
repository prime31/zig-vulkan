const std = @import("std");
const vk = @import("vulkan");

// not sure if this is a good abstraction
pub const FrameBufferAttachment = struct {
    image: vk.Image,
    view: vk.ImageView,
    mem: vk.DeviceMemory,

    pub fn init() FrameBufferAttachment {
        return .{
            .image = undefined,
            .view = undefined,
            .mem = undefined,
        };
    }
};
