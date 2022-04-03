const std = @import("std");
const vk = @import("vulkan");

const GraphicsContext = @import("../graphics_context.zig").GraphicsContext;

const PoolSizes = struct { @"type": vk.DescriptorType, count: f32 };

const pool_sizes = [_]PoolSizes{
    .{ .@"type" = .sampler, .count = 0.5 },
    .{ .@"type" = .combined_image_sampler, .count = 4 },
    .{ .@"type" = .sampled_image, .count = 4 },
    .{ .@"type" = .storage_image, .count = 1 },
    .{ .@"type" = .uniform_texel_buffer, .count = 1 },
    .{ .@"type" = .storage_texel_buffer, .count = 1 },
    .{ .@"type" = .uniform_buffer, .count = 2 },
    .{ .@"type" = .storage_buffer, .count = 2 },
    .{ .@"type" = .uniform_buffer_dynamic, .count = 1 },
    .{ .@"type" = .storage_buffer_dynamic, .count = 1 },
    .{ .@"type" = .input_attachment, .count = 0.5 },
};

pub const DescriptorAllocator = struct {
    const Self = @This();

    gc: *const GraphicsContext,
    used_pools: std.ArrayList(vk.DescriptorPool),
    free_pools: std.ArrayList(vk.DescriptorPool),
    current_pool: vk.DescriptorPool = .null_handle,

    pub fn init(gc: *const GraphicsContext, allocator: std.mem.Allocator) Self {
        return .{
            .gc = gc,
            .used_pools = std.ArrayList(vk.DescriptorPool).init(allocator),
            .free_pools = std.ArrayList(vk.DescriptorPool).init(allocator),
        };
    }

    pub fn deinit(self: Self) void {
        for (self.used_pools) |p| self.gc.destroy(p);
        self.used_pools.deinit();

        for (self.free_pools) |p| self.gc.destroy(p);
        self.free_pools.deinit();
    }

    pub fn createPool(self: Self, count: u32, flags: vk.DescriptorPoolCreateFlags) !vk.DescriptorPool {
        var sizes: [pool_sizes.len]vk.DescriptorPoolSize = undefined;
        for (pool_sizes) |ps, i| {
            sizes[i] = .{ .@"type" = ps.@"type", .count = @floatToInt(u32, count * ps.count) };
        }

        return try self.gc.vkd.createDescriptorPool(self.gc.dev, &.{
            .flags = flags,
            .max_sets = count,
            .pool_size_count = sizes.len,
            .p_pool_sizes = @ptrCast([*]const vk.DescriptorPoolSize, &sizes),
        }, null);
    }

    pub fn grabPool(self: Self) vk.DescriptorPool {
        if (self.free_pools.popOrNull()) |pool| return pool;
        return self.createPool(1000, .{});
    }

    pub fn allocate(self: *Self, layout: vk.DescriptorSetLayout) !vk.DescriptorSet {
        if (self.current_pool == .null_handle) {
            self.current_pool = self.grabPool();
            try self.used_pools.append(self.current_pool);
        }

        const alloc_info = std.mem.zeroInit(vk.DescriptorSetAllocateInfo, .{
            .descriptor_pool = self.current_pool,
            .descriptor_set_count = 1,
            .p_set_layouts = @ptrCast([*]const vk.DescriptorSetLayout, &layout),
        });

        // if creating the DescriptorSet fails with a pool issue try to recover by creating a new pool
        var set: vk.DescriptorSet = undefined;
        self.gc.vkd.allocateDescriptorSets(self.gc.dev, &alloc_info, @ptrCast([*]vk.DescriptorSet, &set)) catch |err| {
            switch (err) {
                .FragmentedPool or .OutOfPoolMemory => {
                    self.current_pool = self.grabPool();
                    try self.used_pools.append(self.current_pool);
                    alloc_info.descriptor_pool = self.current_pool;
                    try self.gc.vkd.allocateDescriptorSets(self.gc.dev, &alloc_info, @ptrCast([*]vk.DescriptorSet, &set));
                },
                else => return err,
            }
        };
        return set;
    }

    pub fn reset(self: *Self) !void {
        for (self.used_pools) |pool| {
            try self.gc.vkd.resetDescriptorPool(self.gc.dev, pool, .{});
            try self.free_pools.append(pool);
        }
        self.used_pools.clearRetainingCapacity();
        self.current_pool = .null_handle;
    }
};

pub const DescriptorLayoutCache = struct {
    const Self = @This();

    gc: *const GraphicsContext,
    layout_cache: std.AutoHashMap(DescriptorLayoutInfo, vk.DescriptorSetLayout),

    const DescriptorLayoutInfo = struct {
        bindings: std.BoundedArray(vk.DescriptorSetLayoutBinding, 5),

        pub fn init() DescriptorLayoutInfo {
            return .{ .bindings = std.BoundedArray(vk.DescriptorSetLayoutBinding, 5).init(0) catch unreachable };
        }
    };

    pub fn init(gc: *const GraphicsContext, allocator: std.mem.Allocator) Self {
        return .{
            .gc = gc,
            .layout_cache = std.AutoHashMap(DescriptorLayoutInfo, vk.DescriptorSetLayout).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        var iter = self.layout_cache.iterator();
        while (iter.next()) |entry| {
            self.gc.vkd.destroyDescriptorSetLayout(self.gc.dev, entry.value_ptr.*, null);
        }
        self.layout_cache.deinit();
    }

    pub fn createDescriptorSetLayout(self: *Self, info: *vk.DescriptorSetLayoutCreateInfo) !vk.DescriptorSetLayout {
        var layout_info = DescriptorLayoutInfo.init();
        var is_sorted = true;
        var last_binding: u32 = 0;

        // copy from the direct info struct into our own one
        var i: usize = 0;
        while (i < info.binding_count) : (i += 1) {
            try layout_info.bindings.append(info.p_bindings[i]);

            // check that the bindings are in strict increasing order
            if (info.p_bindings[i].binding > last_binding) {
                last_binding = info.p_bindings[i].binding;
            } else {
                is_sorted = false;
            }
        }

        if (!is_sorted) {
            const sorter = struct {
                fn sort(_: void, a: vk.DescriptorSetLayoutBinding, b: vk.DescriptorSetLayoutBinding) bool {
                    return a.binding < b.binding;
                }
            }.sort;
            std.sort.sort(vk.DescriptorSetLayoutBinding, layout_info.bindings.slice(), {}, sorter);
        }

        // try to grab from cache
        if (self.layout_cache.get(layout_info)) |set_layout| return set_layout;

        const set_layout = try self.gc.vkd.createDescriptorSetLayout(self.gc.dev, info, null);
        try self.layout_cache.put(layout_info, set_layout);
        return set_layout;
    }
};

pub const DescriptorBuilder = struct {
    const Self = @This();

    alloc: *DescriptorAllocator,
    cache: *DescriptorLayoutCache,
    writes: std.ArrayList(vk.WriteDescriptorSet),
    bindings: std.ArrayList(vk.DescriptorSetLayoutBinding),

    pub fn init(alloc: *DescriptorAllocator, cache: *DescriptorLayoutCache) Self {
        return .{
            .alloc = alloc,
            .cache = cache,
            .writes = std.ArrayList(vk.WriteDescriptorSet).init(std.heap.c_allocator),
            .bindings = std.ArrayList(vk.DescriptorSetLayoutBinding).init(std.heap.c_allocator),
        };
    }

    fn deinit(self: Self) void {
        self.writes.deinit();
        self.bindings.deinit();
    }

    pub fn bindBuffer(self: *Self, binding: u32, buffer_info: *vk.DescriptorBufferInfo, desc_type: vk.DescriptorType, stage_flags: vk.ShaderStageFlags) void {
        // create the descriptor binding for the layout
        self.bindings.append(.{
            .binding = binding,
            .descriptor_type = desc_type,
            .descriptor_count = 1,
            .stage_flags = stage_flags,
            .p_immutable_samplers = null,
        }) catch unreachable;

        // create the descriptor write
        self.writes.append(.{
            .dst_set = .null_handle,
            .dst_binding = binding,
            .dst_array_element = 0,
            .descriptor_count = 1,
            .descriptor_type = desc_type,
            .p_image_info = undefined,
            .p_buffer_info = @ptrCast([*]const vk.DescriptorBufferInfo, buffer_info),
            .p_texel_buffer_view = undefined,
        }) catch unreachable;
    }

    pub fn bindImage(self: *Self, binding: u32, image_info: *vk.DescriptorImageInfo, desc_type: vk.DescriptorType, stage_flags: vk.ShaderStageFlags) void {
        // create the descriptor binding for the layout
        self.bindings.append(.{
            .binding = binding,
            .descriptor_type = desc_type,
            .descriptor_count = 1,
            .stage_flags = stage_flags,
            .p_immutable_samplers = null,
        }) catch unreachable;

        // create the descriptor write
        self.writes.append(.{
            .dst_set = .null_handle,
            .dst_binding = binding,
            .dst_array_element = 0,
            .descriptor_count = 1,
            .descriptor_type = desc_type,
            .p_image_info = @ptrCast([*]const vk.DescriptorImageInfo, image_info),
            .p_buffer_info = null,
            .p_texel_buffer_view = undefined,
        }) catch unreachable;
    }

    pub fn build(self: Self) !vk.DescriptorSet {
        var layout: vk.DescriptorSetLayout = undefined;
        return self.buildWithLayout(&layout);
    }

    pub fn buildWithLayout(self: Self, layout: *vk.DescriptorSetLayout) !vk.DescriptorSet {
        // build layout first
        layout.* = try self.cache.createDescriptorSetLayout(&.{
            .flags = .{},
            .binding_count = self.bindings.items.len,
            .p_bindings = self.bindings.items.ptr,
        });

        const set = try self.alloc.allocate(layout);

        // write descriptor
        for (self.writes.items) |*write| write.dst_set = set;
        self.alloc.gc.vkd.updateDescriptorSets(self.alloc.gc.dev, self.writes.items.len, self.writes.items.ptr, 0, null);

        self.deinit();
        return set;
    }
};

test "descriptors refAllDecls" {
    std.testing.refAllDecls(@This());
    std.debug.print("fook: {}\n", .{ @import("spirv") });
}
