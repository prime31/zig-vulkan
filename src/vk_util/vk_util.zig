const std = @import("std");
const vk = @import("vulkan");

const Mat4 = @import("../chapters/mat4.zig").Mat4;
const Vec3 = @import("../chapters/vec3.zig").Vec3;
const Vec4 = @import("../chapters/vec4.zig").Vec4;

pub const PushBuffer = @import("push_buffer.zig").PushBuffer;
pub const DeletionQueue = @import("deletion_queue.zig").DeletionQueue;
pub const PipelineBuilder = @import("pipeline_builder.zig").PipelineBuilder;
pub usingnamespace @import("shaders.zig");
pub usingnamespace @import("descriptors.zig");
pub usingnamespace @import("material_system.zig");

pub const GpuCameraData = extern struct {
    view: Mat4,
    proj: Mat4,
    view_proj: Mat4,
};

pub const GpuObjectData = extern struct {
    model: Mat4,
    origin_rad: Vec4,
    extents: Vec4,
};

pub const GpuSceneData = extern struct {
    fog_color: Vec4 = Vec4.new(1, 0, 0, 1),
    fog_distance: Vec4 = Vec4.new(1, 0, 0, 1),
    ambient_color: Vec4 = Vec4.new(1, 0, 0, 1),
    sun_dir: Vec4 = Vec4.new(1, 0, 0, 1),
    sun_color: Vec4 = Vec4.new(0, 0, 1, 1),
    sun_shadow_mat: Mat4 = undefined,
};

pub const CullParams = extern struct {
    viewmat: Mat4,
    projmat: Mat4,
    occlusion_cull: bool,
    frustum_cull: bool,
    draw_dist: f32,
    aabb: bool,
    aabbmin: Vec3 = Vec3.new(0, 0, 0),
    aabbmax: Vec3 = Vec3.new(0, 0, 0),
};

pub const MeshPassType = enum(u8) {
    forward,
    transparency,
    directional_shadow,
};

pub const PipelineAndPipelineLayout = struct {
    pipeline: vk.Pipeline = undefined,
    layout: vk.PipelineLayout = undefined,
};

/// given a pointer returns a C-style pointer to many retaining constness
pub fn ptrToMany(value: anytype) PointerToMany(@TypeOf(value)) {
    return @ptrCast(PointerToMany(@TypeOf(value)), value);
}

fn PointerToMany(comptime T: type) type {
    std.debug.assert(@typeInfo(T) == .Pointer);

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