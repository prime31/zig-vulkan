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

        return ShaderModule{
            .code = @alignCast(@alignOf(u32), std.mem.bytesAsSlice(u32, data)),
            .module = try gc.vkd.createShaderModule(gc.dev, &.{
                .flags = .{},
                .code_size = data.len,
                .p_code = @ptrCast([*]const u32, data),
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
        gc.destroy(self.built_layout);
        self.bindings.deinit();
        // ShaderStage is owned by ShaderCache and will be deinitted there
        self.stages.deinit();
    }

    pub fn addStage(self: *ShaderEffect, shader_module: *ShaderModule, stage: vk.ShaderStageFlags) !void {
        try self.stages.append(.{ .shader_module = shader_module, .stage = stage });
    }

    pub fn fillStages(self: ShaderEffect, pipeline_stages: *std.BoundedArray(vk.PipelineShaderStageCreateInfo, 2)) !void {
        for (self.stages) |s|
            try pipeline_stages.append(s);
    }

    pub fn reflectLayout(self: *ShaderEffect, gc: *const GraphicsContext, overrides: []const ReflectionOverrides) !void {
        var gpa = self.stages.allocator;

        var set_layouts = std.ArrayList(DescriptorSetLayoutData).init(gpa);
        defer set_layouts.deinit();
        defer for (set_layouts.items) |layout| layout.deinit();

        var constant_ranges = std.ArrayList(vk.PushConstantRange).init(gpa);
        defer constant_ranges.deinit();

        for (self.stages.items) |*s| {
            var spvmodule: spv.SpvReflectShaderModule = undefined;
            var res = spv.spvReflectCreateShaderModule(resources.tri_mesh_descriptors_vert.len, @ptrCast([*]const u32, resources.tri_mesh_descriptors_vert), &spvmodule);
            if (res != spv.SPV_REFLECT_RESULT_SUCCESS) return error.CreateFailed;

            var count: u32 = 0;
            res = spv.spvReflectEnumerateDescriptorSets(&spvmodule, &count, null);
            if (res != spv.SPV_REFLECT_RESULT_SUCCESS) return error.EnumerateDescriptorSetsFailed;

            var sets = try gpa.alloc(*spv.SpvReflectDescriptorSet, count);
            defer gpa.free(sets);
            res = spv.spvReflectEnumerateDescriptorSets(&spvmodule, &count, @ptrCast([*c][*c]spv.SpvReflectDescriptorSet, sets.ptr));
            if (res != spv.SPV_REFLECT_RESULT_SUCCESS) return error.EnumerateFailed;

            var i_set: usize = 0;
            while (i_set < sets.len) : (i_set += 1) {
                const refl_set = sets[i_set];
                var layout = try DescriptorSetLayoutData.init(gpa, refl_set.binding_count);

                var i_binding: usize = 0;
                while (i_binding < refl_set.binding_count) : (i_binding += 1) {
                    const refl_binding = refl_set.bindings[0].*;
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

            var pconstants = try gpa.alloc(*spv.SpvReflectBlockVariable, count);
            defer gpa.free(pconstants);
            res = spv.spvReflectEnumeratePushConstantBlocks(&spvmodule, &count, @ptrCast([*c][*c]spv.SpvReflectBlockVariable, pconstants.ptr));
            if (res != spv.SPV_REFLECT_RESULT_SUCCESS) return error.EnumeratePushConstantsFailed;

            if (count > 0) {
                const pcs = std.mem.zeroInit(vk.PushConstantRange, .{
                    .offset = pconstants[0].offset,
                    .size = pconstants[0].size,
                    .stage_flags = s.stage,
                });
                try constant_ranges.append(pcs);
            }
        }

        var merged_layouts: [4]DescriptorSetLayoutData = undefined;
        defer for (merged_layouts) |ly| ly.deinit();

        for (merged_layouts) |*ly, i| {
            ly.* = try DescriptorSetLayoutData.init(gpa, 0);

            ly.set_number = @intCast(u32, i);
            ly.create_info = std.mem.zeroes(vk.DescriptorSetLayoutCreateInfo);

            var binds = std.AutoHashMap(usize, vk.DescriptorSetLayoutBinding).init(gpa);
            defer binds.deinit();

            for (set_layouts.items) |*s| {
                if (s.set_number == i) {
                    for (s.bindings.items) |b| {
                        if (binds.getPtr(i)) |found_bind| {
                            // merge flags
                            found_bind.stage_flags = found_bind.stage_flags.merge(b.stage_flags);
                        } else {
                            try binds.put(i, b);
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
                .flags = .{},
            });

            if (ly.create_info.binding_count > 0) {
                self.set_hashes[i] = std.hash.Wyhash.hash(0, std.mem.asBytes(&ly.create_info));
                self.set_layouts[i] = .null_handle;
            } else {
                self.set_hashes[i] = 0;
                self.set_layouts[i] = .null_handle;
            }
        }

        // we start from just the default empty pipeline layout info
        var pipeline_layout_info = vkinit.pipelineLayoutCreateInfo();
        pipeline_layout_info.p_push_constant_ranges = constant_ranges.items.ptr;
        pipeline_layout_info.push_constant_range_count = @intCast(u32, constant_ranges.items.len);

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
    var gpa = std.testing.allocator;
    const ctx = @import("../tests.zig").initTestContext();
    const gc = ctx.gc;
    defer ctx.deinit();

    var shader_effect = ShaderEffect.init(gpa);
    defer shader_effect.deinit(gc);

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
