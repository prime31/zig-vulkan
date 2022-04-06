const Mat4 = @import("../chapters/mat4.zig").Mat4;

pub const PushBuffer = @import("push_buffer.zig").PushBuffer;
pub const DeletionQueue = @import("deletion_queue.zig").DeletionQueue;
pub usingnamespace @import("shaders.zig");
pub usingnamespace @import("descriptors.zig");
pub usingnamespace @import("material_system.zig");

pub const GpuObjectData = struct {
    model: Mat4,
    origin_rad: Mat4,
    extents: Mat4,
};

const MeshObject = struct {
    mesh: *Mesh,
    material: vkutil.Material,
    custom_sort_key: u32,
    transform_matrix: Mat4,
    bounds: RenderBounds,
    draw_forward_pass: u1,
    draw_shadow_pass: u1,
};