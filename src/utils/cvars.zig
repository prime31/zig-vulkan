const std = @import("std");

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

pub const CVarFlags = packed struct {
    noedit: bool = false,
    edit_read_only: bool = false,
    advanced: bool = false,

    edit_checkbox: bool = false,
    edit_float_drag: bool = false,

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

    pub fn fromType(comptime T: type) CVarType {
        return switch (T) {
            f32 => .float,
            u32 => .uint32,
            u64 => .uint64,
            i32 => .int32,
            i64 => .int64,
            []const u8 => .string,
            else => unreachable,
        };
    }
};

const CVarParameter = struct {
    arr_index: usize = std.math.maxInt(u64),
    cvar_type: CVarType = .int32,
    flags: CVarFlags = .{},
    name: []const u8,
    desc: []const u8,
};

fn CVarStorage(comptime T: type) type {
    return struct{
        current: T,
        parameter: *CVarParameter,
    };
}

fn CVarArray(comptime T: type) type {
    return struct{
        const Self = @This();

        cvars: std.BoundedArray(CVarStorage(T), max_cvar_size) = .{},
        last_index: usize = 0,

        pub fn add(self: *Self, param: *CVarParameter, current: T) void {
            param.arr_index = self.cvars.len;
            self.cvars.append(.{
                .current = current,
                .parameter = param,
            }) catch unreachable;
        }

        pub fn getPtr(self: *Self, index: usize) *CVarStorage(T) {
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
    return struct{
        const Self = @This();

        index: usize,

        pub fn init(comptime name: []const u8, desc: []const u8, current: T) Self {
            var param = CVar.system().create(T, name, desc, current).?;
            return .{
                .index = param.arr_index,
            };
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
    };
}

pub const CVar = struct {
    const Self = @This();
    var instance: ?Self = null;

    array_map: std.AutoHashMap(u32, usize),
    cvars: std.AutoHashMap(u32, CVarParameter),

    pub fn system() *Self {
        if (instance) |*i| return i;

        instance = Self{
            .array_map = std.AutoHashMap(u32, usize).init(std.heap.c_allocator),
            .cvars = std.AutoHashMap(u32, CVarParameter).init(std.heap.c_allocator),
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

    fn createParameter(self: *Self, comptime name: []const u8, desc: []const u8) ?*CVarParameter {
        const name_hash = hashStringFnv(u32, name);
        if (self.cvars.contains(name_hash)) return null;
        
        self.cvars.put(name_hash, .{
            .name = name,
            .desc = desc,
        }) catch unreachable;
        return self.cvars.getPtr(name_hash).?;
    }

    pub fn create(self: *Self, comptime T: type, comptime name: []const u8, desc: []const u8, current: T) ?*CVarParameter {
        if (self.createParameter(name, desc)) |param| {
            param.cvar_type = CVarType.fromType(T);

            var arr = self.getArray(T);
            arr.add(param, current);
            return param;
        }
        return null;
    }

    fn getStoragePtr(self: *Self, comptime T: type, comptime name: []const u8) ?*CVarStorage(T) {
        const name_hash = hashStringFnv(u32, name);
        if (self.cvars.getPtr(name_hash)) |param| {
            return self.getArray(T).getPtr(param.arr_index);
        }
        return null;
    }

    pub fn setCurrent(self: *Self, comptime T: type, comptime name: []const u8, current: T) CVarParameter {
        if (self.getStoragePtr(name)) |storage| {
            storage.current = current;
        }
    }

    pub fn getCurrent(self: *Self, comptime T: type, comptime name: []const u8) ?T {
        if (self.getStoragePtr(T, name)) |storage| {
            return storage.current;
        }
        return null;
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