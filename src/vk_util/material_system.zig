const std = @import("std");
const vk = @import("vulkan");
const vkutil = @import("vk_util.zig");
const assets = @import("../assetlib/assets.zig");

const MeshPassType = vkutil.MeshPassType;
const ShaderEffect = @import("shaders.zig").ShaderEffect;
const PipelineBuilder = @import("../pipeline_builder.zig").PipelineBuilder;

pub const VertexAttributeTemplate = enum {
    default_vertex,
    default_vertex_pos_only,
};

pub const EffectBuilder = struct {
    vertex_attribute: VertexAttributeTemplate,
    effect: ShaderEffect,
    topology: vk.PrimitiveTopology,
    rasterizer_info: vk.PipelineRasterizationStateCreateInfo,
    color_blend_attachment_info: vk.PipelineColorBlendStateCreateInfo,
    depth_stencil_info: vk.PipelineDepthStencilStateCreateInfo,
};

pub const ComputePipelineBuilder = struct {
    shader_stage: vk.PipelineShaderStageCreateInfo,
    pip_layout: vk.PipelineLayout,

    pub fn buildPipeline(self: ComputePipelineBuilder) void {
        _ = self;
    }
};

pub const ShaderPass = struct {
    effect: ShaderEffect,
    pip: vk.Pipeline,
    pip_layout: vk.PipelineLayout,
};

pub const SampledTexture = struct {
    sampler: vk.Sampler,
    view: vk.ImageView,
};

pub const ShaderParameters = struct {};

pub fn PerPassData(comptime T: type) type {
    return struct {
        const Self = @This();

        data: [3]T = undefined,

        pub fn set(self: *Self, mesh_pass_type: MeshPassType, value: T) T {
            self.data[mesh_pass_type] = value;
        }

        pub fn get(self: Self, mesh_pass_type: MeshPassType) T {
            return switch (mesh_pass_type) {
                .none => unreachable,
                .forward => self.data[0],
                .transparent => self.data[1],
                .directional_shadow => self.data[2],
            };
        }

        pub fn getOpt(self: Self, mesh_pass_type: MeshPassType) ?T {
            return switch (mesh_pass_type) {
                .none => null,
                .forward => self.data[0],
                .transparent => self.data[1],
                .directional_shadow => self.data[2],
            };
        }

        pub fn clear(self: Self, value: T) void {
            inline for (std.enums.values(MeshPassType)) |mpt|
                self.data[@enumToInt(mpt)] = value;
        }
    };
}

pub const EffectTemplate = struct {
    pass_shaders: PerPassData(ShaderPass),
    default_parameters: *ShaderParameters,
    transparency: assets.TransparencyMode,
};

pub const MaterialData = struct {
    textures: std.ArrayList(SampledTexture),
    parameters: *ShaderParameters,
    base_template: []const u8,

    pub fn hash(self: MaterialData) u64 {
        const result = std.hash.Wyhash.hash(0, self.base_template);
        const tex_hash = std.hash.Wyhash.hash(0, std.mem.sliceAsBytes(self.textures.items));
        return result ^ tex_hash;
    }

    pub fn eql(self: MaterialData, other: MaterialData) bool {
        if (!std.mem.eql(u8, self.base_template, other.base_template) or self.textures.items.len != other.textures.items.len) {
            return false;
        }

        return std.mem.eql(u8, std.mem.sliceAsBytes(self.textures.items), std.mem.sliceAsBytes(other.textures.items));
    }
};

pub const Material = struct { original: EffectTemplate, pass_sets: PerPassData(vk.DescriptorSet) = .{}, textures: std.ArrayList(SampledTexture), params: *ShaderParameters };

pub const MaterialSystem = struct {
    forward_builder: PipelineBuilder,
    shadow_builder: PipelineBuilder,
    template_cache: std.StringHashMap(EffectTemplate),
    materials: std.StringHashMap(Material),
    material_cache: std.HashMap(MaterialData, Material, MaterialDataHashContext, 80),
};

const MaterialDataHashContext = struct {
    pub fn hash(_: @This(), key: MaterialData) u64 {
        return key.hash();
    }

    pub fn eql(_: @This(), a: MaterialData, b: MaterialData) bool {
        return a.eql(b);
    }
};
