const std = @import("std");
const vk = @import("vulkan");
const vma = @import("vma");
const tiny = @import("tiny");
const shapes = @import("shapes");
const assets = @import("assetlib/assets.zig");

const Vec3 = @import("chapters/vec3.zig").Vec3;
const GraphicsContext = @import("graphics_context.zig").GraphicsContext;

pub const VertexInputDescription = struct {
    bindings: []const vk.VertexInputBindingDescription = &[_]vk.VertexInputBindingDescription{},
    attributes: []const vk.VertexInputAttributeDescription = &[_]vk.VertexInputAttributeDescription{},
    flags: vk.PipelineVertexInputStateCreateFlags = .{},
};

pub const Vertex = extern struct {
    pub const vertex_description: VertexInputDescription = .{
        .bindings = &[_]vk.VertexInputBindingDescription{
            .{
                .binding = 0,
                .stride = @sizeOf(Vertex),
                .input_rate = .vertex,
            },
        },
        .attributes = &[_]vk.VertexInputAttributeDescription{
            .{
                .binding = 0,
                .location = 0,
                .format = .r32g32b32_sfloat,
                .offset = @offsetOf(Vertex, "position"),
            },
            .{
                .binding = 0,
                .location = 1,
                .format = .r32g32b32_sfloat,
                .offset = @offsetOf(Vertex, "normal"),
            },
            .{
                .binding = 0,
                .location = 2,
                .format = .r32g32b32_sfloat,
                .offset = @offsetOf(Vertex, "color"),
            },
            .{
                .binding = 0,
                .location = 3,
                .format = .r32g32_sfloat,
                .offset = @offsetOf(Vertex, "uv"),
            },
        },
    };

    position: [3]f32,
    normal: [3]f32,
    color: [3]f32,
    uv: [2]f32,
};

pub const RenderBounds = struct {
    origin: Vec3 = .{},
    radius: f32 = 0,
    extents: Vec3 = .{},
    valid: bool = false,

    pub fn initWithMeshBounds(bounds: assets.MeshBounds) RenderBounds {
        var self = RenderBounds{};

        self.origin.x = bounds.origin[0];
        self.origin.y = bounds.origin[1];
        self.origin.z = bounds.origin[2];

        self.extents.x = bounds.extents[0];
        self.extents.y = bounds.extents[1];
        self.extents.z = bounds.extents[2];

        self.radius = bounds.radius;
        self.valid = true;

        return self;
    }
};

pub const Mesh = struct {
    bounds: RenderBounds = .{},
    vertices: std.ArrayList(Vertex),
    indices: []u32,
    index_count: u32 = 0,
    vert_buffer: vma.AllocatedBufferUntyped = undefined,
    index_buffer: vma.AllocatedBufferUntyped = undefined,

    pub fn init(allocator: std.mem.Allocator) Mesh {
        var indices = allocator.alloc(u32, 3) catch unreachable;
        indices[0] = 0;
        indices[1] = 1;
        indices[2] = 2;
        return .{ .vertices = std.ArrayList(Vertex).init(allocator), .indices = indices, .index_count = 3 };
    }

    pub fn initFromObj(gpa: std.mem.Allocator, filename: []const u8) !Mesh {
        const tiny_mesh = tiny.obj_load_indexed(filename.ptr);
        defer tiny.obj_free_indexed(tiny_mesh);

        var vertices = try std.ArrayList(Vertex).initCapacity(gpa, tiny_mesh.num_vertices);

        var i: usize = 0;
        while (i < tiny_mesh.num_vertices) : (i += 1) {
            var vert: Vertex = undefined;
            vert.position[0] = tiny_mesh.vertices[i].x;
            vert.position[1] = tiny_mesh.vertices[i].y;
            vert.position[2] = tiny_mesh.vertices[i].z;

            vert.normal[0] = tiny_mesh.normals[i].x;
            vert.normal[1] = tiny_mesh.normals[i].y;
            vert.normal[2] = tiny_mesh.normals[i].z;

            vert.uv[0] = tiny_mesh.uvs[i].u;
            vert.uv[1] = tiny_mesh.uvs[i].v;

            vert.color[0] = tiny_mesh.colors[i].x;
            vert.color[1] = tiny_mesh.colors[i].y;
            vert.color[2] = tiny_mesh.colors[i].z;

            vertices.appendAssumeCapacity(vert);
        }

        var indices = try gpa.alloc(u32, tiny_mesh.num_indices);
        std.mem.copy(u32, indices, tiny_mesh.indices[0..tiny_mesh.num_indices]);

        return Mesh{
            .bounds = RenderBounds.initWithMeshBounds(assets.calculateBounds(Vertex, vertices.items)),
            .vertices = vertices,
            .indices = indices,
            .index_count = @intCast(u32, indices.len),
        };
    }

    pub fn initFromAsset(gpa: std.mem.Allocator, filename: []const u8) !Mesh {
        const mesh_asset = try assets.load(assets.MeshInfo, filename);
        const mesh_buffers = try assets.unpackMesh(Vertex, gpa, mesh_asset);

        var vertices = std.ArrayList(Vertex).fromOwnedSlice(gpa, mesh_buffers.vert);

        return Mesh{
            .bounds = RenderBounds.initWithMeshBounds(mesh_asset.info.bounds),
            .vertices = vertices,
            .indices = mesh_buffers.index,
            .index_count = @intCast(u32, mesh_buffers.index.len),
        };
    }

    pub fn initProcSphere(gpa: std.mem.Allocator, slices: i32, stacks: i32) !Mesh {
        var mesh = shapes.initParametricSphere(slices, stacks);
        defer mesh.deinit();

        mesh.unweld();
        mesh.computeNormals();

        var vertices = try std.ArrayList(Vertex).initCapacity(gpa, mesh.positions.len);
        for (mesh.positions) |pos, i| {
            var vert: Vertex = undefined;
            vert.position = pos;
            vert.normal = if (mesh.normals) |norms| norms[i] else [3]f32{0.5, 0.5, 0.5};
            vert.uv = if (mesh.texcoords) |uvs| uvs[i] else [2]f32{0, 1};
            vert.color = if (mesh.normals) |norms| norms[i] else [3]f32{0.5, 0.5, 0.5};
            vertices.appendAssumeCapacity(vert);
        }

        var indices = try gpa.alloc(u32, mesh.indices.len);
        for (mesh.indices) |idx, i| indices[i] = idx;

        return Mesh{
            .bounds = RenderBounds.initWithMeshBounds(assets.calculateBounds(Vertex, vertices.items)),
            .vertices = vertices,
            .indices = indices,
            .index_count = @intCast(u32, mesh.indices.len),
        };
    }

    pub fn initProcRock(gpa: std.mem.Allocator, seed: i32, num_subdivisions: i32) !Mesh {
        var mesh = shapes.initRock(seed, num_subdivisions);
        defer mesh.deinit();

        mesh.unweld();
        mesh.computeNormals();

        var vertices = try std.ArrayList(Vertex).initCapacity(gpa, mesh.positions.len);
        for (mesh.positions) |pos, i| {
            var vert: Vertex = undefined;
            vert.position = pos;
            vert.normal = if (mesh.normals) |norms| norms[i] else [3]f32{0.5, 0.5, 0.5};
            vert.uv = if (mesh.texcoords) |uvs| uvs[i] else [2]f32{0, 1};
            vert.color = if (mesh.normals) |norms| norms[i] else [3]f32{0.5, 0.5, 0.5};
            vertices.appendAssumeCapacity(vert);
        }

        var indices = try gpa.alloc(u32, mesh.indices.len);
        for (mesh.indices) |idx, i| indices[i] = idx;

        return Mesh{
            .bounds = RenderBounds.initWithMeshBounds(assets.calculateBounds(Vertex, vertices.items)),
            .vertices = vertices,
            .indices = indices,
            .index_count = @intCast(u32, mesh.indices.len),
        };
    }

    pub fn deinit(self: Mesh, allocator: vma.Allocator) void {
        self.vert_buffer.deinit(allocator);
        self.index_buffer.deinit(allocator);
        self.vertices.deinit();
        self.vertices.allocator.free(self.indices);
    }

    pub fn recalculateBounds(self: *Mesh) void {
        if (!self.bounds.valid) {
            self.bounds = RenderBounds.initWithMeshBounds(assets.calculateBounds(Vertex, self.vertices.items));
            self.bounds.valid = true;
        }
    }
};
