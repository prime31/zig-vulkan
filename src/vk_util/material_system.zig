const std = @import("std");
const vk = @import("vulkan");
const vkinit = @import("../vkinit.zig");
const vkutil = @import("vk_util.zig");
const assets = @import("../assetlib/assets.zig");

const Vertex = @import("../mesh.zig").Vertex;
const MeshPassType = vkutil.MeshPassType;
const Engine = @import("../engine.zig").Engine;
const ShaderEffect = @import("shaders.zig").ShaderEffect;
const PipelineBuilder = vkutil.PipelineBuilder;

pub const MaterialSystem = struct {
    engine: *Engine,
    forward_builder: PipelineBuilder,
    shadow_builder: PipelineBuilder,
    template_cache: std.StringHashMap(EffectTemplate),
    materials: std.StringHashMap(Material),
    material_cache: std.HashMap(MaterialData, Material, MaterialDataHashContext, 80),

    pub fn init(engine: *Engine) !MaterialSystem {
        var self = MaterialSystem{
            .engine = engine,
            .forward_builder = PipelineBuilder.init(),
            .shadow_builder = PipelineBuilder.init(),
            .template_cache = std.StringHashMap(EffectTemplate).init(engine.gc.gpa),
            .materials = std.StringHashMap(Material).init(engine.gc.gpa),
            .material_cache = std.HashMap(MaterialData, Material, MaterialDataHashContext, 80).init(engine.gc.gpa),
        };

        try self.fillBuilders();
        try self.buildDefaultTemplates();
        return self;
    }

    pub fn deinit(self: *MaterialSystem) void {
        self.template_cache.deinit();
        self.materials.deinit();
        self.material_cache.deinit();
    }

    fn buildDefaultTemplates(self: *MaterialSystem) !void {
        var textured_lit = try self.buildEffect("tri_mesh_ssbo_instanced_vert", "textured_lit_frag");
        // TODO: dont just deinit effects randomly
        textured_lit.deinit(self.engine.gc);
    }

    fn fillBuilders(self: *MaterialSystem) !void {
        // forward builder
        self.forward_builder.vertex_description = Vertex.vertex_description;
        self.shadow_builder.depth_stencil = vkinit.pipelineDepthStencilCreateInfo(true, true, .greater_or_equal);

        // shadow builder
        self.shadow_builder.vertex_description = Vertex.vertex_description;
        self.shadow_builder.rasterizer.cull_mode = .{ .front_bit = true };
        self.shadow_builder.rasterizer.depth_bias_enable = vk.TRUE;
        self.shadow_builder.depth_stencil = vkinit.pipelineDepthStencilCreateInfo(true, true, .less);
    }

    fn buildEffect(self: MaterialSystem, comptime vert_res_path: []const u8, comptime frag_res_path: ?[]const u8) !ShaderEffect {
        const overrides = &[_]ShaderEffect.ReflectionOverrides {
            .{ .name = "sceneData", .overriden_type = .uniform_buffer_dynamic },
            .{ .name = "cameraData", .overriden_type = .uniform_buffer_dynamic },
        };

        var effect = ShaderEffect.init(self.engine.gc.gpa);
        try effect.addStage(self.engine.shader_cache.getShader(vert_res_path), .{ .vertex_bit = true });
        if (frag_res_path) |frag|
            try effect.addStage(self.engine.shader_cache.getShader(frag), .{ .fragment_bit = true });

        try effect.reflectLayout(self.engine.gc, overrides[0..]);
        return effect;
    }

    fn buildShader(self: MaterialSystem, render_pass: vk.RenderPass, builder: *PipelineBuilder, effect: *ShaderEffect) !ShaderPass {
        builder.setShaders(effect);
        return ShaderPass.init(effect, try builder.build(self.engine.gc, render_pass));
    }
};

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

    pub fn init(effect: ShaderEffect, pipeline: vk.Pipeline) ShaderPass {
        return .{
            .effect = effect,
            .pip = pipeline,
            .pip_layout = effect.built_layout,
        };
    }
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

pub const Material = struct {
    original: EffectTemplate,
    pass_sets: PerPassData(vk.DescriptorSet) = .{},
    textures: std.ArrayList(SampledTexture),
    params: *ShaderParameters,
};

const MaterialDataHashContext = struct {
    pub fn hash(_: @This(), key: MaterialData) u64 {
        return key.hash();
    }

    pub fn eql(_: @This(), a: MaterialData, b: MaterialData) bool {
        return a.eql(b);
    }
};
