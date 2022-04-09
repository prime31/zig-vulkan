const std = @import("std");
const vk = @import("vulkan");
const spv = @import("spirv");
const vkinit = @import("../vkinit.zig");
const resources = @import("resources");

const GraphicsContext = @import("../graphics_context.zig").GraphicsContext;

const print = std.debug.print;

pub const ShaderModule = struct {
    code: []const u32,
    module: vk.ShaderModule = .null_handle,

    pub fn init(gc: *const GraphicsContext, comptime res_path: []const u8) !ShaderModule {
        const data = @field(resources, res_path);
        const code = @alignCast(@alignOf(u32), std.mem.bytesAsSlice(u32, data));

        return ShaderModule{
            .code = code,
            .module = try gc.vkd.createShaderModule(gc.dev, &.{
                .flags = .{},
                .code_size = data.len,
                .p_code = code.ptr,
            }, null),
        };
    }

    pub fn deinit(self: ShaderModule, gc: *const GraphicsContext) void {
        gc.destroy(self.module);
    }
};

pub const ShaderEffect = struct {
    pub const ReflectionOverrides = struct {
        name: []const u8,
        overriden_type: vk.DescriptorType,
    };

    const ShaderStage = struct {
        shader_module: *ShaderModule,
        stage: vk.ShaderStageFlags,

        pub fn deinit(self: ShaderStage, gc: *const GraphicsContext) void {
            self.shader_module.deinit(gc);
        }
    };

    bindings: std.StringHashMap(ReflectedBinding),
    set_layouts: [4]vk.DescriptorSetLayout = [_]vk.DescriptorSetLayout{.null_handle} ** 4,
    set_hashes: [4]u64 = undefined,
    stages: std.ArrayList(ShaderStage),
    built_layout: vk.PipelineLayout = .null_handle,

    pub fn init(allocator: std.mem.Allocator) ShaderEffect {
        return .{
            .bindings = std.StringHashMap(ReflectedBinding).init(allocator),
            .stages = std.ArrayList(ShaderStage).init(allocator),
        };
    }

    pub fn deinit(self: *ShaderEffect, gc: *const GraphicsContext) void {
        // ShaderStage.shader_module is owned by ShaderCache and will be deinitted there
        gc.destroy(self.built_layout);
        self.bindings.deinit();
        self.stages.deinit();

        for (self.set_layouts) |sl|
            if (sl != .null_handle) gc.destroy(sl);
    }

    pub fn addStage(self: *ShaderEffect, shader_module: *ShaderModule, stage: vk.ShaderStageFlags) !void {
        try self.stages.append(.{ .shader_module = shader_module, .stage = stage });
    }

    pub fn fillStages(self: ShaderEffect, pipeline_stages: *std.BoundedArray(vk.PipelineShaderStageCreateInfo, 2)) !void {
        for (self.stages.items) |s|
            try pipeline_stages.append(vkinit.pipelineShaderStageCreateInfo(s.shader_module.module, s.stage));
    }

    pub fn reflectLayout(self: *ShaderEffect, gc: *const GraphicsContext, overrides: []const ReflectionOverrides) !void {
        var set_layouts = std.ArrayList(DescriptorSetLayoutData).init(gc.scratch);
        var constant_ranges = std.BoundedArray(vk.PushConstantRange, 4){};

        for (self.stages.items) |*s| {
            var spvmodule: spv.SpvReflectShaderModule = undefined;
            var res = spv.spvReflectCreateShaderModule(s.shader_module.code.len * @sizeOf(u32), s.shader_module.code.ptr, &spvmodule);
            if (res != spv.SPV_REFLECT_RESULT_SUCCESS) return error.CreateFailed;

            var count: u32 = 0;
            res = spv.spvReflectEnumerateDescriptorSets(&spvmodule, &count, null);
            if (res != spv.SPV_REFLECT_RESULT_SUCCESS) return error.EnumerateDescriptorSetsFailed;

            var sets = try gc.scratch.alloc(*spv.SpvReflectDescriptorSet, count);
            res = spv.spvReflectEnumerateDescriptorSets(&spvmodule, &count, @ptrCast([*c][*c]spv.SpvReflectDescriptorSet, sets.ptr));
            if (res != spv.SPV_REFLECT_RESULT_SUCCESS) return error.EnumerateFailed;

            var i_set: usize = 0;
            while (i_set < sets.len) : (i_set += 1) {
                const refl_set = sets[i_set];
                var layout = try DescriptorSetLayoutData.init(gc.scratch, refl_set.binding_count);

                var i_binding: usize = 0;
                while (i_binding < refl_set.binding_count) : (i_binding += 1) {
                    const refl_binding = refl_set.bindings[i_binding].*;
                    var layout_binding = &layout.bindings.items[i_binding];
                    layout_binding.binding = refl_binding.binding;
                    layout_binding.descriptor_type = @intToEnum(vk.DescriptorType, refl_binding.descriptor_type);

                    // handle overrides
                    for (overrides) |ov| {
                        if (std.mem.eql(u8, ov.name, std.mem.sliceTo(refl_binding.name, 0)))
                            layout_binding.descriptor_type = ov.overriden_type;
                    }

                    layout_binding.descriptor_count = 1;
                    var i_dim: usize = 0;
                    while (i_dim < refl_binding.array.dims_count) : (i_dim += 1) {
                        layout_binding.descriptor_count *= refl_binding.array.dims[i_dim];
                    }
                    layout_binding.stage_flags = vk.ShaderStageFlags.fromInt(spvmodule.shader_stage);

                    const reflected = ReflectedBinding{
                        .binding = layout_binding.binding,
                        .set = refl_set.set,
                        .descriptor_type = layout_binding.descriptor_type,
                    };
                    try self.bindings.put(std.mem.sliceTo(refl_binding.name, 0), reflected);
                }

                layout.set_number = refl_set.set;
                layout.create_info = std.mem.zeroInit(vk.DescriptorSetLayoutCreateInfo, .{
                    .binding_count = refl_set.binding_count,
                    .p_bindings = layout.bindings.items.ptr,
                });

                try set_layouts.append(layout);
            }

            // pushconstants
            res = spv.spvReflectEnumeratePushConstantBlocks(&spvmodule, &count, null);
            if (res != spv.SPV_REFLECT_RESULT_SUCCESS) return error.EnumeratePushConstantsFailed;

            var pconstants = try gc.scratch.alloc(*spv.SpvReflectBlockVariable, count);
            res = spv.spvReflectEnumeratePushConstantBlocks(&spvmodule, &count, @ptrCast([*c][*c]spv.SpvReflectBlockVariable, pconstants.ptr));
            if (res != spv.SPV_REFLECT_RESULT_SUCCESS) return error.EnumeratePushConstantsFailed;

            if (count > 0) {
                const pcs = vk.PushConstantRange{
                    .offset = pconstants[0].offset,
                    .size = pconstants[0].size,
                    .stage_flags = s.stage,
                };
                try constant_ranges.append(pcs);
            }
        }

        var merged_layouts: [4]DescriptorSetLayoutData = undefined;
        for (merged_layouts) |*ly, i| {
            ly.* = try DescriptorSetLayoutData.init(gc.scratch, 0);
            ly.set_number = @intCast(u32, i);

            var binds = std.AutoHashMap(usize, vk.DescriptorSetLayoutBinding).init(gc.scratch);

            for (set_layouts.items) |*s| {
                if (s.set_number == i) {
                    for (s.bindings.items) |b| {
                        if (binds.getPtr(b.binding)) |found_bind| {
                            // merge flags
                            found_bind.stage_flags = found_bind.stage_flags.merge(b.stage_flags);
                        } else {
                            try binds.put(b.binding, b);
                        }
                    }
                }
            }

            var bind_iter = binds.valueIterator();
            while (bind_iter.next()) |bind_v| {
                try ly.bindings.append(bind_v.*);
            }

            // sort the bindings, for hash purposes
            const sorter = struct {
                fn sort(_: void, a: vk.DescriptorSetLayoutBinding, b: vk.DescriptorSetLayoutBinding) bool {
                    return a.binding < b.binding;
                }
            }.sort;
            std.sort.sort(vk.DescriptorSetLayoutBinding, ly.bindings.items, {}, sorter);

            ly.create_info = std.mem.zeroInit(vk.DescriptorSetLayoutCreateInfo, .{
                .binding_count = @intCast(u32, ly.bindings.items.len),
                .p_bindings = ly.bindings.items.ptr,
                .flags = .{},
            });

            if (ly.create_info.binding_count > 0) {
                self.set_hashes[i] = std.hash.Wyhash.hash(0, std.mem.asBytes(&ly.create_info));
                self.set_layouts[i] = try gc.vkd.createDescriptorSetLayout(gc.dev, &ly.create_info, null);
            } else {
                self.set_hashes[i] = 0;
            }
        }

        // we start from just the default empty pipeline layout info
        var pipeline_layout_info = vkinit.pipelineLayoutCreateInfo();
        pipeline_layout_info.p_push_constant_ranges = &constant_ranges.buffer;
        pipeline_layout_info.push_constant_range_count = @intCast(u32, constant_ranges.len);

        var compacted_layouts: [4]vk.DescriptorSetLayout = undefined;
        var s: u32 = 0;
        for (compacted_layouts) |*cl, i| {
            if (self.set_layouts[i] != .null_handle) {
                cl.* = self.set_layouts[i];
                s += 1;
            }
        }

        pipeline_layout_info.set_layout_count = s;
        pipeline_layout_info.p_set_layouts = &compacted_layouts;

        self.built_layout = try gc.vkd.createPipelineLayout(gc.dev, &pipeline_layout_info, null);
    }
};

const DescriptorSetLayoutData = struct {
    set_number: u32 = 0,
    create_info: vk.DescriptorSetLayoutCreateInfo = undefined,
    bindings: std.ArrayList(vk.DescriptorSetLayoutBinding),

    pub fn init(allocator: std.mem.Allocator, binding_size: usize) !DescriptorSetLayoutData {
        var bindings = try std.ArrayList(vk.DescriptorSetLayoutBinding).initCapacity(allocator, binding_size);
        bindings.expandToCapacity();

        for (bindings.items) |*b| b.* = std.mem.zeroes(vk.DescriptorSetLayoutBinding);

        return DescriptorSetLayoutData{
            .bindings = bindings,
        };
    }

    pub fn deinit(self: DescriptorSetLayoutData) void {
        self.bindings.deinit();
    }
};

const ReflectedBinding = struct {
    set: u32,
    binding: u32,
    descriptor_type: vk.DescriptorType,
};

pub const ShaderCache = struct {
    gc: *const GraphicsContext,
    module_cache: std.StringHashMap(ShaderModule),

    pub fn init(gc: *const GraphicsContext) ShaderCache {
        return .{
            .gc = gc,
            .module_cache = std.StringHashMap(ShaderModule).init(gc.gpa),
        };
    }

    pub fn deinit(self: *ShaderCache) void {
        var iter = self.module_cache.valueIterator();
        while (iter.next()) |sm| sm.deinit(self.gc);
        self.module_cache.deinit();
    }

    pub fn getShader(self: *ShaderCache, comptime res_path: []const u8) *ShaderModule {
        if (!self.module_cache.contains(res_path)) {
            self.module_cache.put(res_path, ShaderModule.init(self.gc, res_path) catch unreachable) catch unreachable;
        }
        return self.module_cache.getPtr(res_path).?;
    }
};

test "shaders reflection" {
    var ctx = @import("../tests.zig").initTestContext();
    const gc = ctx.gc;
    const gpa = gc.gpa;
    defer ctx.deinit();

    var shader_effect = ShaderEffect.init(gpa);
    defer {
        for (shader_effect.stages.items) |s| s.deinit(gc);
        shader_effect.deinit(gc);
    }

    var overrides: []ShaderEffect.ReflectionOverrides = &[_]ShaderEffect.ReflectionOverrides{};

    try shader_effect.stages.append(.{
        .shader_module = &try ShaderModule.init(gc, "tri_mesh_descriptors_vert"),
        .stage = .{ .vertex_bit = true },
    });
    try shader_effect.stages.append(.{
        .shader_module = &try ShaderModule.init(gc, "default_lit_frag"),
        .stage = .{ .fragment_bit = true },
    });

    try shader_effect.reflectLayout(gc, overrides);
}
