const Mat4 = @import("mat4.zig").Mat4;

pub const Vec4 = extern struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
    w: f32 = 0,

    pub fn new(x: f32, y: f32, z: f32, w: f32) Vec4 {
        return .{ .x = x, .y = y, .z = z, .w = w };
    }

    pub fn newFromArr(arr: [4]f32) Vec4 {
        return .{ .x = arr[0], .y = arr[1], .z = arr[2], .w = arr[3] };
    }

    pub fn add(a: Vec4, b: Vec4) Vec4 {
        var result: Vec4 = undefined;
        inline for (@typeInfo(Vec4).Struct.fields) |fld| {
            @field(result, fld.name) = @field(a, fld.name) + @field(b, fld.name);
        }
        return result;
    }

    // https://github.com/kooparse/zalgebra/blob/main/src/mat4.zig#L114
    pub fn transform(self: Vec4, mat: Mat4) Vec4 {
        const x = (mat.fields[0][0] * self.x) + (mat.fields[1][0] * self.y) + (mat.fields[2][0] * self.z) + (mat.fields[3][0] * self.w);
        const y = (mat.fields[0][1] * self.x) + (mat.fields[1][1] * self.y) + (mat.fields[2][1] * self.z) + (mat.fields[3][1] * self.w);
        const z = (mat.fields[0][2] * self.x) + (mat.fields[1][2] * self.y) + (mat.fields[2][2] * self.z) + (mat.fields[3][2] * self.w);
        const w = (mat.fields[0][3] * self.x) + (mat.fields[1][3] * self.y) + (mat.fields[2][3] * self.z) + (mat.fields[3][3] * self.w);

        return Vec4.new(x, y, z, w);
    }

    fn getField(vec: Vec4, comptime index: comptime_int) f32 {
        switch (index) {
            0 => return vec.x,
            1 => return vec.y,
            2 => return vec.z,
            3 => return vec.w,
            else => @compileError("index out of bounds!"),
        }
    }
};
