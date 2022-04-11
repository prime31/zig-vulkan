const std = @import("std");
const Mat4 = @import("mat4.zig").Mat4;
const Vec4 = @import("vec4.zig").Vec4;

pub const Vec3 = extern struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,

    pub fn new(x: f32, y: f32, z: f32) Vec3 {
        return .{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn length2(a: Vec3) f32 {
        return Vec3.dot(a, a);
    }

    pub fn length(a: Vec3) f32 {
        return std.math.sqrt(a.length2());
    }

    pub fn dot(a: Vec3, b: Vec3) f32 {
        var result: f32 = 0;
        inline for (@typeInfo(Vec3).Struct.fields) |fld| {
            result += @field(a, fld.name) * @field(b, fld.name);
        }
        return result;
    }

    pub fn scale(a: Vec3, b: f32) Vec3 {
        var result: Vec3 = undefined;
        inline for (@typeInfo(Vec3).Struct.fields) |fld| {
            @field(result, fld.name) = @field(a, fld.name) * b;
        }
        return result;
    }

    /// multiplies all components from `a` with the components of `b`.
    pub fn mul(a: Vec3, b: Vec3) Vec3 {
        var result: Vec3 = undefined;
        inline for (@typeInfo(Vec3).Struct.fields) |fld| {
            @field(result, fld.name) = @field(a, fld.name) * @field(b, fld.name);
        }
        return result;
    }

    pub fn cross(a: Vec3, b: Vec3) Vec3 {
        return Vec3{
            .x = a.y * b.z - a.z * b.y,
            .y = a.z * b.x - a.x * b.z,
            .z = a.x * b.y - a.y * b.x,
        };
    }

    pub fn normalize(vec: Vec3) Vec3 {
        return vec.scale(1.0 / vec.length());
    }

    pub fn add(a: Vec3, b: Vec3) Vec3 {
        var result: Vec3 = undefined;
        inline for (@typeInfo(Vec3).Struct.fields) |fld| {
            @field(result, fld.name) = @field(a, fld.name) + @field(b, fld.name);
        }
        return result;
    }

    pub fn sub(a: Vec3, b: Vec3) Vec3 {
        var result: Vec3 = undefined;
        inline for (@typeInfo(Vec3).Struct.fields) |fld| {
            @field(result, fld.name) = @field(a, fld.name) - @field(b, fld.name);
        }
        return result;
    }

    pub fn transform(self: Vec3, mat: Mat4) Vec3 {
        var res = Vec4.new(self.x, self.y, self.z, 1).transform(mat);
        return Vec3.new(res.x, res.y, res.z);
    }

    /// returns a new vector where each component is the minimum of the components of the input vectors.
    pub fn componentMin(a: Vec3, b: Vec3) Vec3 {
        var result: Vec3 = undefined;
        inline for (@typeInfo(Vec3).Struct.fields) |fld| {
            @field(result, fld.name) = std.math.min(@field(a, fld.name), @field(b, fld.name));
        }
        return result;
    }

    /// returns a new vector where each component is the maximum of the components of the input vectors.
    pub fn componentMax(a: Vec3, b: Vec3) Vec3 {
        var result: Vec3 = undefined;
        inline for (@typeInfo(Vec3).Struct.fields) |fld| {
            @field(result, fld.name) = std.math.max(@field(a, fld.name), @field(b, fld.name));
        }
        return result;
    }
};
