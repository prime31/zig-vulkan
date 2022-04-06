const std = @import("std");
const vk = @import("vulkan");
const vma = @import("vma");
const vkinit = @import("vkinit.zig");
const vkutil = @import("vk_util/vk_util.zig");

const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;

const GraphicsContext = @import("graphics_context.zig").GraphicsContext;
const Material = vkutil.Material;
const ShaderPass = vkutil.ShaderPass;
const Mesh = @import("mesh.zig").Mesh;
const MeshObject = @import("mesh.zig").MeshObject;
const RenderBounds = @import("mesh.zig").RenderBounds;
const Vertex = @import("mesh.zig").Vertex;
const Mat4 = @import("chapters/mat4.zig").Mat4;

pub const MeshPassType = enum(u8) {
    none,
    forward,
    transparent,
    directional_shadow,
};

pub const RenderScene = struct {
    const Self = @This();

    renderables: ArrayList(RenderObject),
    meshes: ArrayList(DrawMesh),
    materials: ArrayList(Material),
    dirty_objects: ArrayList(RenderObject),
    forward_pass: MeshPassType = .forward,
    transparent_forward_pass: MeshPassType = .transparent,
    shadow_pass: MeshPassType = .directional_shadow,
    material_convert: AutoHashMap(*Material, Handle(Material)),
    mesh_convert: AutoHashMap(*Mesh, Handle(DrawMesh)),
    merged_vertex_buffer: vma.AllocatedBuffer(Vertex),
    merged_index_buffer: vma.AllocatedBuffer(u32),
    object_data_buffer: vma.AllocatedBuffer(vkutil.GpuObjectData),

    pub fn init(gpa: std.mem.Allocator) Self {
        return .{
            .renderables = ArrayList(RenderObject).init(gpa),
            .meshes = ArrayList(DrawMesh).init(gpa),
            .materials = ArrayList(Material).init(gpa),
            .dirty_objects = ArrayList(RenderObject).init(gpa),
            .material_convert = AutoHashMap(*Material, Handle(Material)).init(gpa),
            .mesh_convert = AutoHashMap(*Mesh, Handle(DrawMesh)).init(gpa),
            .merged_vertex_buffer = vma.AllocatedBuffer(Vertex).init(gpa),
            .merged_index_buffer = vma.AllocatedBuffer(u32).init(gpa),
            .object_data_buffer = vma.AllocatedBuffer(vkutil.GpuObjectData).init(gpa),
        };
    }

    pub fn deinit(self: Self) void {
        self.renderables.deinit();
        self.meshes.deinit();
        self.materials.deinit();
        self.dirty_objects.deinit();
        self.material_convert.deinit();
        self.mesh_convert.deinit();
        self.merged_vertex_buffer.deinit();
        self.merged_index_buffer.deinit();
        self.object_data_buffer.deinit();
    }

    pub fn registerObject(self: Self, object: MeshObject) Handle(RenderObject) {
        return .{};
    }

    pub fn registerObjectBatch(self: Self, first: *MeshObject, count: u32) void {}

    pub fn updateTransform(self: Self, object_id: Handle(RenderObject), local_to_world: Mat4) void {}

    pub fn fillObjectData(self: Self, data: *GpuObjectData) void {}

    pub fn fillIndirectArray(self: Self, data: *GpuIndirectObject, pass: *MeshPass) void {}

    pub fn fillInstancesArray(self: Self, data: *GpuInstance, pas: MeshPass) void {}

    pub fn writeObject(target: *GpuObjectData, object_id: Handle(RenderObject)) void {}

    pub fn clearDirtyObjects(self: Self) void {}

    pub fn buildBatches(self: Self) void {}

    pub fn mergeMeshes(self: Self, engine: anytype) void {}

    pub fn refreshPass(self: Self, pass: *MeshPass) void {}

    pub fn buildIndirectBatches(self: Self, pass: *MeshPass, out_batches: ArrayList(IndirectBatch), in_batches: ArrayList(RenderBatch)) void {}

    pub fn getObject(self: Self, object_id: Handle(RenderObject)) *RenderObject {}

    pub fn getMesh(self: Self, object_id: Handle(DrawMesh)) *DrawMesh {}

    pub fn getMeshPass(self: Self, name: MeshPassType) *MeshPass {}

    pub fn getMaterial(self: Self, object_id: Handle(Material)) *Material {}

    pub fn getMaterialHandle(self: Self, m: Material) Handle(Material) {}

    pub fn getMeshHandle(self: Self, m: *Mesh) Handle(Mesh) {}
};

pub fn Handle(comptime T: type) type {
    _ = T;
    return struct {
        handle: u32,
    };
}

pub const MeshObject = struct {
    mesh: *Mesh,
    material: Material,
    custom_sort_key: u32,
    transform_matrix: Mat4,
    bounds: RenderBounds,
    draw_forward_pass: u1,
    draw_shadow_pass: u1,
};

pub const GpuObjectData = struct {
    model: Mat4,
};

const GpuIndirectObject = struct {
    command: vk.DrawIndexedIndirectCommand,
    object_id: u32,
    batch_id: u32,
};

const DrawMesh = struct {
    first_vert: u32,
    first_index: u32,
    index_count: u32,
    vert_count: u32,
    is_merged: bool,
    original: *Mesh,
};

const RenderObject = struct {
    mesh_id: Handle(DrawMesh),
    material: Handle(Material),
    update_index: u32,
    custom_sort_key: u32 = 0,
    pass_indices: vkutil.PerPassData(u32),
    transform_matrix: Mat4,
    bounds: RenderBounds,
};

const GpuInstance = struct {
    object_id: u32,
    batch_id: u32,
};

// RenderScene internal types
const PassMaterial = struct {
    material_set: vk.DescriptorSet,
    shader_pass: ShaderPass,

    pub fn eql(self: PassMaterial, other: PassMaterial) bool {
        return self.material_set == other.material_set and self.shader_pass == other.shader_pass;
    }
};

const PassObject = struct {
    material: PassMaterial,
    mesh_id: Handle(DrawMesh),
    original: Handle(RenderObject),
    built_batch: i32,
    custom_key: u32,
};

const RenderBatch = struct {
    object: Handle(PassObject),
    sort_key: u64,
};

const IndirectBatch = struct {
    mesh_id: Handle(DrawMesh),
    material: PassMaterial,
    first: u32,
    count: u32,
};

const Multibatch = struct {
    first: u32,
    count: u32,
};

const MeshPass = struct {
    multibatches: ArrayList(Multibatch),
    batches: ArrayList(IndirectBatch),
    unbatched_objects: ArrayList(RenderObject),
    flat_batches: ArrayList(RenderBatch),
    objects: ArrayList(PassObject),
    reusable_objects: ArrayList(PassObject),
    objects_to_delete: ArrayList(PassObject),

    compacted_instance_buffer: vma.AllocatedBuffer(u32),
    pass_objects_buffer: vma.AllocatedBuffer(GpuInstance),

    draw_indirect_buffer: vma.AllocatedBuffer(GpuIndirectObject),
    clear_indirect_buffer: vma.AllocatedBuffer(GpuIndirectObject),

    mesh_pass_type: MeshPassType,
    needs_indirect_flush: bool = true,
    needs_instance_flush: bool = true,

    pub fn get(self: MeshPass, handle: Handle(PassObject)) *PassObject {
        return &self.objects[handle.handle];
    }
};
