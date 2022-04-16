const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;

pub const Mat4 = extern struct {
    fields: [4][4]f32 = undefined, // [col][row]

    pub const zero = Mat4{
        .fields = [4][4]f32{
            [4]f32{ 0, 0, 0, 0 },
            [4]f32{ 0, 0, 0, 0 },
            [4]f32{ 0, 0, 0, 0 },
            [4]f32{ 0, 0, 0, 0 },
        },
    };

    pub const identity = Mat4{
        .fields = [4][4]f32{
            [4]f32{ 1, 0, 0, 0 },
            [4]f32{ 0, 1, 0, 0 },
            [4]f32{ 0, 0, 1, 0 },
            [4]f32{ 0, 0, 0, 1 },
        },
    };

    pub fn mul(a: Mat4, b: Mat4) Mat4 {
        var result: Mat4 = undefined;
        inline for ([_]comptime_int{ 0, 1, 2, 3 }) |col| {
            inline for ([_]comptime_int{ 0, 1, 2, 3 }) |row| {
                var sum: f32 = 0.0;
                inline for ([_]comptime_int{ 0, 1, 2, 3 }) |i| {
                    sum += a.fields[i][row] * b.fields[col][i];
                }
                result.fields[col][row] = sum;
            }
        }
        return result;
    }

    // taken from GLM implementation
    pub fn createPerspective(fov: f32, aspect: f32, near: f32, far: f32) Mat4 {
        std.debug.assert(std.math.fabs(aspect - 0.001) > 0);
        const tanHalfFov = std.math.tan(fov / 2);

        var result = Mat4.zero;
        result.fields[0][0] = 1.0 / (aspect * tanHalfFov);
        result.fields[1][1] = 1.0 / (tanHalfFov);
        result.fields[2][2] = -(far + near) / (far - near);
        result.fields[2][3] = -1.0;
        result.fields[3][2] = -(2.0 * far * near) / (far - near);
        return result;
    }

    pub fn createTranslation(translation: Vec3) Mat4 {
        var result = identity;
        result.fields[3][0] = translation.x;
        result.fields[3][1] = translation.y;
        result.fields[3][2] = translation.z;
        return result;
    }

    pub fn createScale(scale: Vec3) Mat4 {
        var result = identity;
        result.fields[0][0] = scale.x;
        result.fields[1][1] = scale.y;
        result.fields[2][2] = scale.z;
        return result;
    }

    pub fn createLook(eye: Vec3, direction: Vec3, up: Vec3) Mat4 {
        const f = direction.normalize();
        const s = Vec3.cross(up, f).normalize();
        const u = Vec3.cross(f, s);

        var result = Mat4.identity;
        result.fields[0][0] = s.x;
        result.fields[1][0] = s.y;
        result.fields[2][0] = s.z;
        result.fields[0][1] = u.x;
        result.fields[1][1] = u.y;
        result.fields[2][1] = u.z;
        result.fields[0][2] = f.x;
        result.fields[1][2] = f.y;
        result.fields[2][2] = f.z;
        result.fields[3][0] = -Vec3.dot(s, eye);
        result.fields[3][1] = -Vec3.dot(u, eye);
        result.fields[3][2] = -Vec3.dot(f, eye);
        return result;
    }

    pub fn createLookAt(eye: Vec3, center: Vec3, up: Vec3) Mat4 {
        return createLook(eye, Vec3.sub(eye, center), up);
    }

    pub fn createWorld(pos: Vec3, forward: Vec3, up: Vec3) Mat4 {
        const z = forward.normalize();
        var x = Vec3.cross(forward, up);
        var y = Vec3.cross(x, forward);
        x = x.normalize();
        y = y.normalize();

        var result = identity;

        // right
        result.fields[0][0] = x.x;
        result.fields[0][1] = x.y;
        result.fields[0][2] = x.z;

        // up
        result.fields[1][0] = y.x;
        result.fields[1][1] = y.y;
        result.fields[1][2] = y.z;

        // forward
        result.fields[2][0] = -z.x;
        result.fields[2][1] = -z.y;
        result.fields[2][2] = -z.z;

        // translation
        result.fields[3][0] = pos.x;
        result.fields[3][1] = pos.y;
        result.fields[3][2] = pos.z;
        return result;
    }

    pub fn createAngleAxis(axis: Vec3, angle: f32) Mat4 {
        var cos = std.math.cos(angle);
        var sin = std.math.sin(angle);
        var x = axis.x;
        var y = axis.y;
        var z = axis.z;

        return .{
            .fields = [4][4]f32{
                [4]f32{ cos + x * x * (1 - cos), x * y * (1 - cos) - z * sin, x * z * (1 - cos) + y * sin, 0 },
                [4]f32{ y * x * (1 - cos) + z * sin, cos + y * y * (1 - cos), y * z * (1 - cos) - x * sin, 0 },
                [4]f32{ z * x * (1 * cos) - y * sin, z * y * (1 - cos) + x * sin, cos + z * z * (1 - cos), 0 },
                [4]f32{ 0, 0, 0, 1 },
            },
        };
    }

    pub fn createOrthographic(left: f32, right: f32, bottom: f32, top: f32, near: f32, far: f32) Mat4 {
        var result = Mat4.identity;
        result.fields[0][0] = 2 / (right - left);
        result.fields[1][1] = 2 / (top - bottom);
        result.fields[2][2] = 1 / (far - near);
        result.fields[3][0] = -(right + left) / (right - left);
        result.fields[3][1] = -(top + bottom) / (top - bottom);
        result.fields[3][2] = -near / (far - near);
        return result;
    }

    // https://github.com/g-truc/glm/blob/master/glm/ext/matrix_clip_space.inl#L16
    pub fn createOrthographicLH_Z0(left: f32, right: f32, bottom: f32, top: f32, near: f32, far: f32) Mat4 {
        var result = Mat4.identity;
        result.fields[0][0] = 2 / (right - left);
        result.fields[1][1] = 2 / (top - bottom);
        result.fields[2][2] = 1 / (far - near);
        result.fields[3][0] = -(right + left) / (right - left);
        result.fields[3][1] = -(top + bottom) / (top - bottom);
        result.fields[3][2] = -near / (far - near);
        return result;
    }

    pub fn createRotate(angle: f32, axis: Vec3) Mat4 {
        const rot = createAngleAxis(axis, angle);
        return identity.mul(rot);
    }

    pub fn rotate(self: Mat4, angle: f32, axis: Vec3) Mat4 {
        const rot = createAngleAxis(axis, angle);
        return self.mul(rot);
    }

    pub fn transpose(a: Mat4) Mat4 {
        var result: Mat4 = undefined;
        inline for ([_]comptime_int{ 0, 1, 2, 3 }) |row| {
            inline for ([_]comptime_int{ 0, 1, 2, 3 }) |col| {
                result.fields[row][col] = a.fields[col][row];
            }
        }
        return result;
    }

    pub fn inv(mat: Mat4) Mat4 {
        var inv_mat: Mat4 = undefined;

        var s: [6]f32 = undefined;
        var c: [6]f32 = undefined;

        s[0] = mat.fields[0][0] * mat.fields[1][1] - mat.fields[1][0] * mat.fields[0][1];
        s[1] = mat.fields[0][0] * mat.fields[1][2] - mat.fields[1][0] * mat.fields[0][2];
        s[2] = mat.fields[0][0] * mat.fields[1][3] - mat.fields[1][0] * mat.fields[0][3];
        s[3] = mat.fields[0][1] * mat.fields[1][2] - mat.fields[1][1] * mat.fields[0][2];
        s[4] = mat.fields[0][1] * mat.fields[1][3] - mat.fields[1][1] * mat.fields[0][3];
        s[5] = mat.fields[0][2] * mat.fields[1][3] - mat.fields[1][2] * mat.fields[0][3];

        c[0] = mat.fields[2][0] * mat.fields[3][1] - mat.fields[3][0] * mat.fields[2][1];
        c[1] = mat.fields[2][0] * mat.fields[3][2] - mat.fields[3][0] * mat.fields[2][2];
        c[2] = mat.fields[2][0] * mat.fields[3][3] - mat.fields[3][0] * mat.fields[2][3];
        c[3] = mat.fields[2][1] * mat.fields[3][2] - mat.fields[3][1] * mat.fields[2][2];
        c[4] = mat.fields[2][1] * mat.fields[3][3] - mat.fields[3][1] * mat.fields[2][3];
        c[5] = mat.fields[2][2] * mat.fields[3][3] - mat.fields[3][2] * mat.fields[2][3];

        const determ = 1.0 / (s[0] * c[5] - s[1] * c[4] + s[2] * c[3] + s[3] * c[2] - s[4] * c[1] + s[5] * c[0]);

        inv_mat.fields[0][0] =
            (mat.fields[1][1] * c[5] - mat.fields[1][2] * c[4] + mat.fields[1][3] * c[3]) * determ;
        inv_mat.fields[0][1] =
            (-mat.fields[0][1] * c[5] + mat.fields[0][2] * c[4] - mat.fields[0][3] * c[3]) * determ;
        inv_mat.fields[0][2] =
            (mat.fields[3][1] * s[5] - mat.fields[3][2] * s[4] + mat.fields[3][3] * s[3]) * determ;
        inv_mat.fields[0][3] =
            (-mat.fields[2][1] * s[5] + mat.fields[2][2] * s[4] - mat.fields[2][3] * s[3]) * determ;

        inv_mat.fields[1][0] =
            (-mat.fields[1][0] * c[5] + mat.fields[1][2] * c[2] - mat.fields[1][3] * c[1]) * determ;
        inv_mat.fields[1][1] =
            (mat.fields[0][0] * c[5] - mat.fields[0][2] * c[2] + mat.fields[0][3] * c[1]) * determ;
        inv_mat.fields[1][2] =
            (-mat.fields[3][0] * s[5] + mat.fields[3][2] * s[2] - mat.fields[3][3] * s[1]) * determ;
        inv_mat.fields[1][3] =
            (mat.fields[2][0] * s[5] - mat.fields[2][2] * s[2] + mat.fields[2][3] * s[1]) * determ;

        inv_mat.fields[2][0] =
            (mat.fields[1][0] * c[4] - mat.fields[1][1] * c[2] + mat.fields[1][3] * c[0]) * determ;
        inv_mat.fields[2][1] =
            (-mat.fields[0][0] * c[4] + mat.fields[0][1] * c[2] - mat.fields[0][3] * c[0]) * determ;
        inv_mat.fields[2][2] =
            (mat.fields[3][0] * s[4] - mat.fields[3][1] * s[2] + mat.fields[3][3] * s[0]) * determ;
        inv_mat.fields[2][3] =
            (-mat.fields[2][0] * s[4] + mat.fields[2][1] * s[2] - mat.fields[2][3] * s[0]) * determ;

        inv_mat.fields[3][0] =
            (-mat.fields[1][0] * c[3] + mat.fields[1][1] * c[1] - mat.fields[1][2] * c[0]) * determ;
        inv_mat.fields[3][1] =
            (mat.fields[0][0] * c[3] - mat.fields[0][1] * c[1] + mat.fields[0][2] * c[0]) * determ;
        inv_mat.fields[3][2] =
            (-mat.fields[3][0] * s[3] + mat.fields[3][1] * s[1] - mat.fields[3][2] * s[0]) * determ;
        inv_mat.fields[3][3] =
            (mat.fields[2][0] * s[3] - mat.fields[2][1] * s[1] + mat.fields[2][2] * s[0]) * determ;

        return inv_mat;
    }

    pub fn toArray(m: Mat4) [16]f32 {
        var result: [16]f32 = undefined;
        var i: usize = 0;
        inline for ([_]comptime_int{ 0, 1, 2, 3 }) |col| {
            inline for ([_]comptime_int{ 0, 1, 2, 3 }) |row| {
                result[i] = m.fields[col][row];
                i += 1;
            }
        }
        return result;
    }
};
