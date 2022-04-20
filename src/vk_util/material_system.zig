const std = @import("std");
const vk = @import("vulkan");
const vkinit = @import("../vkinit.zig");
const vkutil = @import("vk_util.zig");
const assets = @import("../assetlib/assets.zig");

const Vertex = @import("../mesh.zig").Vertex;
const MeshPassType = vkutil.MeshPassType;
const Engine = @import("../engine.zig").Engine;
const GraphicsContext = @import("../graphics_context.zig").GraphicsContext;
const ShaderEffect = @import("shaders.zig").ShaderEffect;
const PipelineBuilder = vkutil.PipelineBuilder;

pub const MaterialSystem = struct {
    engine: *Engine,
    forward_builder: PipelineBuilder,
    shadow_builder: PipelineBuilder,
    template_cache: std.StringHashMap(EffectTemplate),
    materials: std.StringHashMap(Material),
    material_cache: std.HashMap(MaterialData, Material, MaterialDataHashContext, 80),
    // tmp until I figure out who owns ShaderEffect since one ShaderEffect can be used in many EffectTemplates
    tmp_effect_cache: std.ArrayList(ShaderEffect),
    // tmp until I figure out who owns ShaderPass since one ShaderPass can be used in many EffectTemplates
    tmp_pass_cache: std.ArrayList(ShaderPass),

    pub fn init(engine: *Engine) !MaterialSystem {
        var self = MaterialSystem{
            .engine = engine,
            .forward_builder = PipelineBuilder.init(),
            .shadow_builder = PipelineBuilder.init(),
            .template_cache = std.StringHashMap(EffectTemplate).init(engine.gc.gpa),
            .materials = std.StringHashMap(Material).init(engine.gc.gpa),
            .material_cache = std.HashMap(MaterialData, Material, MaterialDataHashContext, 80).init(engine.gc.gpa),
            .tmp_effect_cache = std.ArrayList(ShaderEffect).init(engine.gc.gpa),
            .tmp_pass_cache = std.ArrayList(ShaderPass).init(engine.gc.gpa),
        };

        try self.fillBuilders();
        try self.buildDefaultTemplates();
        return self;
    }

    pub fn deinit(self: *MaterialSystem) void {
        // TODO: see tmp_effect_cache/tmp_pass_cache comment

        // var template_cache_iter = self.template_cache.valueIterator();
        // while (template_cache_iter.next()) |et| et.deinit(self.engine.gc);
        self.template_cache.deinit();

        for (self.tmp_effect_cache.items) |*se| se.deinit(self.engine.gc);
        self.tmp_effect_cache.deinit();

        for (self.tmp_pass_cache.items) |*sp| sp.deinit(self.engine.gc);
        self.tmp_pass_cache.deinit();

        var iter = self.material_cache.iterator();
        while (iter.next()) |entry| {
            entry.key_ptr.deinit();
            entry.value_ptr.deinit();
        }

        self.materials.deinit();
        self.material_cache.deinit();
    }

    fn fillBuilders(self: *MaterialSystem) !void {
        // forward builder
        self.forward_builder.vertex_description = Vertex.vertex_description;
        self.forward_builder.depth_stencil = vkinit.pipelineDepthStencilCreateInfo(true, true, .less);

        // shadow builder
        self.shadow_builder.vertex_description = Vertex.vertex_description;
        self.shadow_builder.rasterizer.cull_mode = .{ .front_bit = true };
        self.shadow_builder.rasterizer.depth_bias_enable = vk.TRUE;
        self.shadow_builder.depth_stencil = vkinit.pipelineDepthStencilCreateInfo(true, true, .less_or_equal);
    }

    // doesnt actually work because this seems to only update the template material i think
    pub fn hotReloadTexturedLitShader(self: *MaterialSystem) !void {
        var textured_lit = try self.buildEffect("tri_mesh_ssbo_instanced_vert", "textured_lit_frag");
        var textured_lit_pass = try self.buildShader(self.engine.render_pass, &self.forward_builder, textured_lit);
        try self.tmp_pass_cache.append(textured_lit_pass);
        self.template_cache.getPtr("texturedPBR_opaque").?.pass_shaders.set(.forward, textured_lit_pass);
    }

    fn buildDefaultTemplates(self: *MaterialSystem) !void {
        // default effects
        var textured_lit = try self.buildEffect("tri_mesh_ssbo_instanced_vert", "textured_lit_frag");
        var default_lit = try self.buildEffect("tri_mesh_ssbo_instanced_vert", "default_lit_frag");
        var opaque_shadowcast = try self.buildEffect("tri_mesh_ssbo_instanced_shadowcast_vert", null);

        // passes
        var textured_lit_pass = try self.buildShader(self.engine.render_pass, &self.forward_builder, textured_lit);
        var default_lit_pass = try self.buildShader(self.engine.render_pass, &self.forward_builder, default_lit);
        var opaque_shadowcast_pass = try self.buildShader(self.engine.shadow_pass, &self.shadow_builder, opaque_shadowcast);

        try self.tmp_pass_cache.append(textured_lit_pass);
        try self.tmp_pass_cache.append(default_lit_pass);
        try self.tmp_pass_cache.append(opaque_shadowcast_pass);

        {
            var default_textured = EffectTemplate.init(.@"opaque");
            default_textured.pass_shaders.set(.forward, textured_lit_pass);
            default_textured.pass_shaders.set(.directional_shadow, opaque_shadowcast_pass);
            try self.template_cache.put("texturedPBR_opaque", default_textured);
        }

        {
            self.forward_builder.color_blend_attachment.blend_enable = vk.TRUE;
            self.forward_builder.color_blend_attachment.color_blend_op = .add;
            self.forward_builder.color_blend_attachment.src_color_blend_factor = .src_alpha;
            self.forward_builder.color_blend_attachment.dst_color_blend_factor = .one;

            self.forward_builder.color_blend_attachment.color_write_mask = .{ .r_bit = true, .g_bit = true, .b_bit = true };
            self.forward_builder.depth_stencil.?.depth_write_enable = vk.FALSE;
            self.forward_builder.rasterizer.cull_mode = .{ .front_bit = false, .back_bit = false };

            // passes
            const transparent_lit_pass = try self.buildShader(self.engine.render_pass, &self.forward_builder, textured_lit);
            try self.tmp_pass_cache.append(transparent_lit_pass);

            var default_textured = EffectTemplate.init(.transparent);
            default_textured.pass_shaders.set(.transparency, transparent_lit_pass);
            try self.template_cache.put("texturedPBR_transparent", default_textured);
        }

        {
            var default_colored = EffectTemplate.init(.@"opaque");
            default_colored.pass_shaders.set(.forward, default_lit_pass);
            default_colored.pass_shaders.set(.directional_shadow, opaque_shadowcast_pass);
            try self.template_cache.put("colored_opaque", default_colored);
        }
    }

    // TODO: rename to buildShaderEffect
    fn buildEffect(self: *MaterialSystem, comptime vert_res_path: []const u8, comptime frag_res_path: ?[]const u8) !ShaderEffect {
        const overrides = &[_]ShaderEffect.ReflectionOverrides{
            .{ .name = "sceneData", .overriden_type = .uniform_buffer_dynamic },
            .{ .name = "cameraData", .overriden_type = .uniform_buffer_dynamic },
        };

        var effect = ShaderEffect.init(self.engine.gc.gpa);
        try effect.addStage(self.engine.shader_cache.getShader(vert_res_path), .{ .vertex_bit = true });
        if (frag_res_path) |frag|
            try effect.addStage(self.engine.shader_cache.getShader(frag), .{ .fragment_bit = true });

        try effect.reflectLayout(self.engine.gc, overrides[0..]);
        try self.tmp_effect_cache.append(effect);
        return effect;
    }

    // TODO: rename to buildShaderPass
    fn buildShader(self: MaterialSystem, render_pass: vk.RenderPass, builder: *PipelineBuilder, effect: ShaderEffect) !ShaderPass {
        try builder.setShaders(&effect);
        return ShaderPass.init(effect, try builder.build(self.engine.gc, render_pass));
    }

    pub fn buildMaterial(self: *MaterialSystem, name: []const u8, info: MaterialData) !Material {
        if (self.material_cache.get(info)) |mat| {
            try self.materials.put(name, mat);
            // we have to deinit the MaterialData since MaterialSystem.deinit wont catch it for cache hits
            info.deinit();
            return mat;
        }

        var material = Material.init(self.engine.gc.gpa, self.template_cache.getPtr(info.base_template).?);
        try material.textures.appendSlice(info.textures.items);
        // not handled yet
        material.pass_sets.set(.directional_shadow, .null_handle);

        var db = vkutil.DescriptorBuilder.init(self.engine.gc.gpa, &self.engine.descriptor_allocator, &self.engine.descriptor_layout_cache);
        defer db.deinit();

        for (info.textures.items) |tex, i| {
            const image_buffer_info = vk.DescriptorImageInfo{
                .sampler = tex.sampler,
                .image_view = tex.view,
                .image_layout = .shader_read_only_optimal,
            };
            db.bindImage(@intCast(u32, i), &image_buffer_info, .combined_image_sampler, .{ .fragment_bit = true });
        }

        // TODO: why are we building the same descriptor set twice?
        _ = try db.build(material.pass_sets.getPtr(.forward));
        _ = try db.build(material.pass_sets.getPtr(.transparency));

        // add material to cache
        try self.material_cache.put(info, material);
        try self.materials.put(name, material);

        return material;
    }

    pub fn getMaterial(self: MaterialSystem, name: []const u8) ?*Material {
        return self.materials.getPtr(name);
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
    pip_layout: vk.PipelineLayout,
    shader_stage: vk.PipelineShaderStageCreateInfo,

    pub fn init(layout: vk.PipelineLayout, module: vk.ShaderModule) ComputePipelineBuilder {
        return .{
            .pip_layout = layout,
            .shader_stage = vkinit.pipelineShaderStageCreateInfo(module, .{ .compute_bit = true }),
        };
    }

    pub fn buildPipeline(self: ComputePipelineBuilder, gc: *const GraphicsContext) !vk.Pipeline {
        const pip_info = std.mem.zeroInit(vk.ComputePipelineCreateInfo, .{
            .stage = self.shader_stage,
            .layout = self.pip_layout,
        });
        var pipeline: vk.Pipeline = undefined;
        _ = try gc.vkd.createComputePipelines(gc.dev, .null_handle, 1, vkutil.ptrToMany(&pip_info), null, vkutil.ptrToMany(&pipeline));
        return pipeline;
    }
};

pub const ShaderPass = struct {
    effect: ShaderEffect = undefined,
    pip: vk.Pipeline = .null_handle,
    pip_layout: vk.PipelineLayout = .null_handle,

    pub fn init(effect: ShaderEffect, pipeline: vk.Pipeline) ShaderPass {
        return .{
            .effect = effect,
            .pip = pipeline,
            .pip_layout = effect.built_layout,
        };
    }

    pub fn deinit(self: ShaderPass, gc: *const GraphicsContext) void {
        // ShaderEffect owns the PipelineLayout and ShaderCache and it is owned by EffectTemplate for now...
        gc.destroy(self.pip);
    }

    pub fn eql(self: ShaderPass, other: ShaderPass) bool {
        // TODO: do we need to check the ShaderEffect as well?
        return self.pip == other.pip and self.pip_layout == other.pip_layout;
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

        pub fn set(self: *Self, mesh_pass_type: MeshPassType, value: T) void {
            self.data[@intCast(u64, @enumToInt(mesh_pass_type))] = value;
        }

        pub fn get(self: Self, mesh_pass_type: MeshPassType) T {
            return switch (mesh_pass_type) {
                .forward => self.data[0],
                .transparency => self.data[1],
                .directional_shadow => self.data[2],
            };
        }

        pub fn getPtr(self: *Self, mesh_pass_type: MeshPassType) *T {
            return switch (mesh_pass_type) {
                .forward => &self.data[0],
                .transparency => &self.data[1],
                .directional_shadow => &self.data[2],
            };
        }

        pub fn clear(self: *Self, value: T) void {
            for (std.enums.values(MeshPassType)) |mpt|
                self.data[@enumToInt(mpt)] = value;
        }
    };
}

pub const EffectTemplate = struct {
    pass_shaders: PerPassData(ShaderPass) = .{},
    default_parameters: *ShaderParameters = undefined,
    transparency: assets.TransparencyMode,

    pub fn init(transparency: assets.TransparencyMode) EffectTemplate {
        var pass_shaders = PerPassData(ShaderPass){};
        pass_shaders.clear(.{});

        return .{ .pass_shaders = pass_shaders, .transparency = transparency };
    }

    pub fn deinit(self: EffectTemplate, gc: *const GraphicsContext) void {
        if (self.pass_shaders.getOpt(.forward)) |*sp| sp.effect.deinit(gc);
        if (self.pass_shaders.getOpt(.transparency)) |*sp| sp.effect.deinit(gc);
        if (self.pass_shaders.getOpt(.directional_shadow)) |*sp| sp.effect.deinit(gc);
    }
};

pub const MaterialData = struct {
    textures: std.ArrayList(SampledTexture),
    parameters: *ShaderParameters = undefined,
    base_template: []const u8,

    fn hash(self: MaterialData) u64 {
        const result = std.hash.Wyhash.hash(0, self.base_template);
        const tex_hash = std.hash.Wyhash.hash(0, std.mem.sliceAsBytes(self.textures.items));
        return result ^ tex_hash;
    }

    fn eql(self: MaterialData, other: MaterialData) bool {
        if (!std.mem.eql(u8, self.base_template, other.base_template) or self.textures.items.len != other.textures.items.len) {
            return false;
        }

        return std.mem.eql(u8, std.mem.sliceAsBytes(self.textures.items), std.mem.sliceAsBytes(other.textures.items));
    }

    pub fn init(gpa: std.mem.Allocator, base_template: []const u8) MaterialData {
        return .{
            .textures = std.ArrayList(SampledTexture).init(gpa),
            .base_template = base_template,
        };
    }

    pub fn deinit(self: MaterialData) void {
        self.textures.deinit();
    }

    pub fn addTexture(self: *MaterialData, sampler: vk.Sampler, view: vk.ImageView) !void {
        try self.textures.append(.{ .sampler = sampler, .view = view });
    }
};

pub const Material = struct {
    original: *EffectTemplate,
    pass_sets: PerPassData(vk.DescriptorSet) = .{},
    textures: std.ArrayList(SampledTexture),
    params: *ShaderParameters = undefined,

    pub fn init(gpa: std.mem.Allocator, base_template: *EffectTemplate) Material {
        var pass_sets = PerPassData(vk.DescriptorSet){};
        pass_sets.clear(.null_handle);

        return .{
            .original = base_template,
            .pass_sets = pass_sets,
            .textures = std.ArrayList(SampledTexture).init(gpa),
        };
    }

    pub fn deinit(self: Material) void {
        self.textures.deinit();
    }
};

const MaterialDataHashContext = struct {
    pub fn hash(_: @This(), key: MaterialData) u64 {
        return key.hash();
    }

    pub fn eql(_: @This(), a: MaterialData, b: MaterialData) bool {
        return a.eql(b);
    }
};
