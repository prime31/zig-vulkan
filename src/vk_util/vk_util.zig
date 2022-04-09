const Mat4 = @import("../chapters/mat4.zig").Mat4;
const Vec4 = @import("../chapters/vec4.zig").Vec4;

pub const PushBuffer = @import("push_buffer.zig").PushBuffer;
pub const DeletionQueue = @import("deletion_queue.zig").DeletionQueue;
pub const PipelineBuilder = @import("pipeline_builder.zig").PipelineBuilder;
pub usingnamespace @import("shaders.zig");
pub usingnamespace @import("descriptors.zig");
pub usingnamespace @import("material_system.zig");

pub const GpuObjectData = struct {
    model: Mat4,
    origin_rad: Vec4,
    extents: Vec4,
};

pub const MeshPassType = enum(u8) {
    forward,
    transparency,
    directional_shadow,
};

/// given a pointer returns a C-style pointer to many retaining constness
pub fn ptrToMany(value: anytype) PointerToMany(@TypeOf(value)) {
    return @ptrCast(PointerToMany(@TypeOf(value)), value);
}

fn PointerToMany(comptime T: type) type {
    const info = @typeInfo(T).Pointer;
    const InnerType = @Type(.{
        .Pointer = .{
            .size = .Many,
            .is_const = info.is_const,
            .is_volatile = info.is_volatile,
            .alignment = info.alignment,
            .address_space = info.address_space,
            .child = info.child,
            .is_allowzero = info.is_allowzero,
            .sentinel = null,
        },
    });
    return InnerType;
}