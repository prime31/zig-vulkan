const std = @import("std");
const ig = @import("imgui");

fn hashStringFnv(comptime ReturnType: type, comptime str: []const u8) ReturnType {
    std.debug.assert(ReturnType == u32 or ReturnType == u64);

    const prime = if (ReturnType == u32) @as(u32, 16777619) else @as(u64, 1099511628211);
    var value = if (ReturnType == u32) @as(u32, 2166136261) else @as(u64, 14695981039346656037);
    for (str) |c| {
        value = (value ^ @intCast(u32, c)) *% prime;
    }
    return value;
}

const max_cvar_size: usize = 10;

pub const CVarFlags = struct {
    noedit: bool = false,
    readonly: bool = false,

    float_drag: bool = true,
    float_min: f32 = std.math.f32_min,
    float_max: f32 = std.math.f32_max,

    pub fn as(self: CVarFlags, T: type) T {
        return @bitCast(T, self);
    }
};

const CVarType = enum {
    uint32,
    uint64,
    int32,
    int64,
    float,
    string,
    bool,

    pub fn fromType(comptime T: type) CVarType {
        return switch (T) {
            f32 => .float,
            u32 => .uint32,
            u64 => .uint64,
            i32 => .int32,
            i64 => .int64,
            []const u8 => .string,
            bool => .bool,
            else => unreachable,
        };
    }
};

const CVarParameter = struct {
    arr_index: usize = std.math.maxInt(u64),
    cvar_type: CVarType,
    flags: CVarFlags = .{},
    name: [:0]const u8,
    desc: [:0]const u8,
};

fn CVarStorage(comptime T: type) type {
    return struct {
        current: T,
        parameter: CVarParameter,
    };
}

fn CVarArray(comptime T: type) type {
    return struct {
        const Self = @This();

        cvars: std.BoundedArray(CVarStorage(T), max_cvar_size) = .{},

        pub fn add(self: *Self, comptime name: [:0]const u8, desc: [:0]const u8, current: T) usize {
            const arr_index = self.cvars.len;
            self.cvars.append(.{
                .current = current,
                .parameter = .{
                    .arr_index = arr_index,
                    .cvar_type = CVarType.fromType(T),
                    .name = name,
                    .desc = desc,
                },
            }) catch unreachable;

            return arr_index;
        }

        pub fn getStoragePtr(self: *Self, index: usize) *CVarStorage(T) {
            return &self.cvars.buffer[index];
        }

        pub fn getCurrent(self: Self, index: usize) T {
            return self.cvars.get(index).current;
        }

        pub fn getCurrentPtr(self: *Self, index: usize) *T {
            return &self.cvars.buffer[index].current;
        }

        pub fn setCurrent(self: *Self, current: T, index: usize) void {
            self.cvars.buffer[index].current = current;
        }
    };
}

pub fn AutoCVar(comptime T: type) type {
    return struct {
        const Self = @This();

        index: usize,

        pub fn init(comptime name: [:0]const u8, desc: [:0]const u8, current: T) Self {
            return .{
                .index = CVar.system().create(T, name, desc, current).?,
            };
        }

        pub fn initWithFlags(comptime name: [:0]const u8, desc: [:0]const u8, current: T, flags: CVarFlags) Self {
            const cvar = Self{
                .index = CVar.system().create(T, name, desc, current).?,
            };
            cvar.setEditFlags(flags);
            return cvar;
        }

        pub fn get(self: Self) T {
            return CVar.system().getArray(T).getCurrent(self.index);
        }

        pub fn getPtr(self: Self) *T {
            return CVar.system().getArray(T).getCurrentPtr(self.index);
        }

        pub fn set(self: Self, current: T) void {
            CVar.system().getArray(T).setCurrent(current, self.index);
        }

        pub fn setEditFlags(self: Self, flags: CVarFlags) void {
            CVar.system().getArray(T).getStoragePtr(self.index).parameter.flags = flags;
        }
    };
}

pub const CVar = struct {
    const Self = @This();
    var instance: ?Self = null;

    array_map: std.AutoHashMap(u32, usize),
    cvars: std.AutoHashMap(u32, usize), // maps from hashed-name to index in CVarArray

    pub fn system() *Self {
        if (instance) |*i| return i;

        instance = Self{
            .array_map = std.AutoHashMap(u32, usize).init(std.heap.c_allocator),
            .cvars = std.AutoHashMap(u32, usize).init(std.heap.c_allocator),
        };
        return &instance.?;
    }

    fn getArray(self: *Self, comptime T: type) *CVarArray(T) {
        const type_id = hashStringFnv(u32, @typeName(T));
        if (self.array_map.getEntry(type_id)) |kv| {
            return @intToPtr(*CVarArray(T), kv.value_ptr.*);
        }

        var arr = std.heap.c_allocator.create(CVarArray(T)) catch unreachable;
        arr.* = .{};
        var arr_ptr = @ptrToInt(arr);
        _ = self.array_map.put(type_id, arr_ptr) catch unreachable;

        return arr;
    }

    fn getArrayOpt(self: *Self, comptime T: type) ?*CVarArray(T) {
        const type_id = hashStringFnv(u32, @typeName(T));
        if (self.array_map.getEntry(type_id)) |kv| {
            return @intToPtr(*CVarArray(T), kv.value_ptr.*);
        }
        return null;
    }

    pub fn create(self: *Self, comptime T: type, comptime name: [:0]const u8, desc: [:0]const u8, current: T) ?usize {
        const name_hash = hashStringFnv(u32, name);
        if (self.cvars.contains(name_hash)) return null;

        var arr = self.getArray(T);
        const arr_index = arr.add(name, desc, current);
        self.cvars.put(name_hash, arr_index) catch unreachable;
        return arr.getStoragePtr(arr_index).parameter.arr_index;
    }

    fn getStoragePtr(self: *Self, comptime T: type, comptime name: [:0]const u8) ?*CVarStorage(T) {
        const name_hash = hashStringFnv(u32, name);
        if (self.cvars.get(name_hash)) |arr_index| {
            return self.getArray(T).getStoragePtr(arr_index);
        }
        return null;
    }

    pub fn setCurrent(self: *Self, comptime T: type, comptime name: [:0]const u8, current: T) void {
        if (self.getStoragePtr(T, name)) |storage| {
            storage.current = current;
        }
    }

    pub fn getCurrent(self: *Self, comptime T: type, comptime name: [:0]const u8) ?T {
        if (self.getStoragePtr(T, name)) |storage| {
            return storage.current;
        }
        return null;
    }

    pub fn drawImGuiEditor(self: *Self) void {
        if (ig.igCollapsingHeader_BoolPtr("CVars", null, ig.ImGuiTreeNodeFlags_None)) {
            ig.igIndent(10);
            defer ig.igUnindent(10);

            // TODO: loop through CVarTypes here instead of hardcoding this
            if (self.getArrayOpt(bool)) |arr| drawImGuiArray(bool, arr);
            if (self.getArrayOpt(f32)) |arr| drawImGuiArray(f32, arr);
        }
    }

    fn drawImGuiArray(comptime T: type, arr: *CVarArray(T)) void {
        for (arr.cvars.slice()) |_, i| {
            var storage = arr.getStoragePtr(i);
            const flags = storage.parameter.flags;

            if (flags.readonly)
                ig.igBeginDisabled(true);

            switch (T) {
                bool => _ = ig.igCheckbox(storage.parameter.name, &storage.current),
                f32 => _ = ig.igDragFloat(storage.parameter.name, &storage.current, 0.1, flags.float_min, flags.float_max, null, ig.ImGuiSliderFlags_None),
                else => {},
            }

            if (flags.readonly)
                ig.igEndDisabled();

            if (ig.igIsItemHovered(ig.ImGuiHoveredFlags_None))
                ig.igSetTooltip("%s", storage.parameter.desc.ptr);
        }
    }
};

test "cvars" {
    const auto_float = AutoCVar(f32).init("float.poop", "whatever man", 66.66);
    try std.testing.expectEqual(auto_float.get(), CVar.system().getCurrent(f32, "float.poop").?);

    const auto_int = AutoCVar(u32).init("int.poop", "whatever man", 5);
    try std.testing.expectEqual(auto_int.get(), CVar.system().getCurrent(u32, "int.poop").?);

    _ = CVar.system().create(f32, "shit.floater", "some thing", 55.5).?;
    try std.testing.expectEqual(CVar.system().getCurrent(f32, "shit.floater").?, 55.5);

    auto_float.set(44.44);
    try std.testing.expectEqual(auto_float.get(), 44.44);
    try std.testing.expectEqual(CVar.system().getCurrent(f32, "float.poop").?, 44.44);
}
