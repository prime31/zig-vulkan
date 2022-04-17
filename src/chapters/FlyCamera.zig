const std = @import("std");
const vk = @import("vulkan");
const glfw = @import("glfw");
const config = @import("../utils/config.zig");

const Mat4 = @import("mat4.zig").Mat4;
const Vec3 = @import("vec3.zig").Vec3;
const Vec4 = @import("vec4.zig").Vec4;

fn toRadians(deg: anytype) @TypeOf(deg) {
    return std.math.pi * deg / 180.0;
}

const Self = @This();

window: glfw.Window,
speed: f32 = 3.5,
pos: Vec3 = Vec3.new(2, 0.5, 20),
front: Vec3 = Vec3.new(0, 0, -1),
up: Vec3 = Vec3.new(0, 1, 0),
pitch: f32 = 0,
yaw: f32 = -90,
last_mouse_x: f32 = 400,
last_mouse_y: f32 = 300,

pub fn init(window: glfw.Window) Self {
    return .{
        .window = window,
    };
}

pub fn update(self: *Self, dt: f64) void {
    if (!config.cam_lock.get()) {
        var cursor_pos = self.window.getCursorPos() catch unreachable;
        var x_offset = @floatCast(f32, cursor_pos.xpos) - self.last_mouse_x;
        var y_offset = self.last_mouse_y - @floatCast(f32, cursor_pos.ypos); // reversed since y-coordinates range from bottom to top
        self.last_mouse_x = @floatCast(f32, cursor_pos.xpos);
        self.last_mouse_y = @floatCast(f32, cursor_pos.ypos);

        var sensitivity: f32 = 0.2;
        x_offset *= sensitivity * 1.5; // bit more sensitivity for x
        y_offset *= sensitivity;

        self.yaw += x_offset;
        self.pitch += y_offset;
        self.pitch = std.math.clamp(self.pitch, -90, 90);

        var direction = Vec3.new(0, 0, 0);
        direction.x = std.math.cos(toRadians(self.yaw)) * std.math.cos(toRadians(self.pitch));
        direction.y = std.math.sin(toRadians(self.pitch));
        direction.z = std.math.sin(toRadians(self.yaw)) * std.math.cos(toRadians(self.pitch));
        self.front = direction.normalize();
    }

    // wasd
    var spd = self.speed * @floatCast(f32, dt);

    if (self.window.getKey(.w) == .press) {
        self.pos = self.pos.add(self.front.scale(spd));
    } else if (self.window.getKey(.s) == .press) {
        self.pos = self.pos.sub(self.front.scale(spd));
    }
    if (self.window.getKey(.a) == .press) {
        self.pos = self.pos.sub(Vec3.normalize(self.front.cross(self.up)).scale(spd));
    } else if (self.window.getKey(.d) == .press) {
        self.pos = self.pos.add(Vec3.normalize(self.front.cross(self.up)).scale(spd));
    }
    if (self.window.getKey(.e) == .press) {
        self.pos.y += spd;
    } else if (self.window.getKey(.q) == .press) {
        self.pos.y -= spd;
    }
}

pub fn getViewMatrix(self: Self) Mat4 {
    return Mat4.createLookAt(self.pos, self.pos.add(self.front), self.up);
}

pub fn getProjMatrix(_: Self, extent: vk.Extent2D) Mat4 {
    var proj = Mat4.createPerspective(toRadians(70.0), @intToFloat(f32, extent.width) / @intToFloat(f32, extent.height), 0.1, 5000);
    proj.fields[1][1] *= -1;
    return proj;
}

pub fn getReversedProjMatrix(_: Self, extent: vk.Extent2D) Mat4 {
    var proj = Mat4.createPerspective(toRadians(70.0), @intToFloat(f32, extent.width) / @intToFloat(f32, extent.height), 5000, 0.1);
    proj.fields[1][1] *= -1;
    return proj;
}

// pub fn getRotationMatrix(_: Self, extent: vk.Extent2D) Mat4 {
//     var proj = Mat4.createPerspective(toRadians(70.0), @intToFloat(f32, extent.width) / @intToFloat(f32, extent.height), 0.1, 5000);
//     proj.fields[1][1] *= -1;
//     return proj;
// }
