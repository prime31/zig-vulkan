const std = @import("std");
const ig = @import("imgui");

const INLINE_FLAGS = ig.ImGuiTreeNodeFlags_Leaf | ig.ImGuiTreeNodeFlags_NoTreePushOnOpen | ig.ImGuiTreeNodeFlags_Bullet;

pub fn nullTerm(comptime str: []const u8) [:0]const u8 {
    const fullStr = str ++ [_]u8{0};
    return fullStr[0..str.len :0];
}

pub fn inspect(comptime T: type, ptr: *T) void {
    ig.igPushID_Ptr(ptr);
    defer ig.igPopID();

    inspectStruct(T, ptr, null);
}

pub fn inspectStruct(comptime T: type, ptr: *T, name: ?[:0]const u8) void {
    switch (@typeInfo(T)) {
        .Struct => |info| {
            const label = if (name) |n| n else @typeName(T);

            if (ig.igCollapsingHeader_BoolPtr(label, null, ig.ImGuiTreeNodeFlags_None)) {
                ig.igIndent(10);
                defer ig.igUnindent(10);
                inline for (info.fields) |field| inspectField(field.field_type, &@field(ptr, field.name), nullTerm(field.name));
            }
        },
        .Pointer => inspect(std.meta.Child(T), ptr.*),
        else => @compileError("Invalid type passed to inspect: " ++ @typeName(T)),
    }
}

fn inspectField(comptime FieldType: type, fieldPtr: anytype, name: [:0]const u8) void {
    switch (@typeInfo(FieldType)) {
        .Bool => {},
        .Int => |info| {
            _ = info;
        },
        .Float => {
            ig.igAlignTextToFramePadding();
            ig.igValue_Float(name, fieldPtr.*, null);
        },
        .Array => |info| {
            _ = info;
        },
        .Enum => |info| {
            _ = info;
        },
        .Struct => {
            // ig.igAlignTextToFramePadding();
            inspectStruct(FieldType, fieldPtr, name);
        },
        else => {
            ig.igText("<TODO " ++ @typeName(FieldType) ++ ">@0x%p", fieldPtr);
        },
    }
}

// fn inspectStruct(comptime T: type, ptr: anytype) void {
//     switch (@typeInfo(FieldType)) {

//     }
// }
