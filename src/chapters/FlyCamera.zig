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
pos: Vec3 = Vec3.new(0, 0, 20),
front: Vec3 = Vec3.new(0, 0, 1),
up: Vec3 = Vec3.new(0, 1, 0),
pitch: f32 = 0,
yaw: f32 = 0,
last_mouse_x: f32 = 400,
last_mouse_y: f32 = 300,
sprint: bool = false,


pub fn init(window: glfw.Window) Self {
    return .{
        .window = window,
    };
}

pub fn update(self: *Self, dt: f64) void {
    if (!config.cam_lock.get()) {
        var cursor_pos = self.window.getCursorPos() catch unreachable;
        var x_offset = self.last_mouse_x - @floatCast(f32, cursor_pos.xpos);
        var y_offset = self.last_mouse_y - @floatCast(f32, cursor_pos.ypos); // reversed since y-coordinates range from bottom to top
        self.last_mouse_x = @floatCast(f32, cursor_pos.xpos);
        self.last_mouse_y = @floatCast(f32, cursor_pos.ypos);

        var sensitivity: f32 = 0.01;
        x_offset *= sensitivity * 1.5; // bit more sensitivity for x
        y_offset *= sensitivity;

        self.yaw += x_offset;
        self.pitch += y_offset;
        self.pitch = std.math.clamp(self.pitch, -90, 90);

        // var direction = Vec3.new(0, 0, 0);
        // direction.x = std.math.cos(toRadians(self.yaw)) * std.math.cos(toRadians(self.pitch));
        // direction.y = std.math.sin(toRadians(self.pitch));
        // direction.z = std.math.sin(toRadians(self.yaw)) * std.math.cos(toRadians(self.pitch));
        // self.front = direction.normalize();
    }

    // wasd
    var spd = self.speed * @floatCast(f32, dt);
    _ = spd;
    var input_axis = Vec3.new(0, 0, 0);
    self.sprint = false;

    if (self.window.getKey(.w) == .press) {
        input_axis.x = -1;
    } else if (self.window.getKey(.s) == .press) {
        input_axis.x = 1;
    }
    if (self.window.getKey(.a) == .press) {
        input_axis.y = -1;
    } else if (self.window.getKey(.d) == .press) {
        input_axis.y = 1;
    }
    if (self.window.getKey(.e) == .press) {
        input_axis.z = 1;
    } else if (self.window.getKey(.q) == .press) {
        input_axis.z = -1;
    }

    if (self.window.getKey(.left_shift) == .press)
        self.sprint = true;

    const cam_vel = 0.05;
    var forward = Vec3.new(0, 0, cam_vel);
    var right = Vec3.new(cam_vel, 0, 0);
    const up = Vec3.new(0, cam_vel, 0);

    const cam_rot = self.getRotationMatrix();
    forward = forward.transform(cam_rot);
    right = right.transform(cam_rot);

    const vel_x = forward.scale(input_axis.x);
    const vel_y = right.scale(input_axis.y);
    const vel_z = up.scale(input_axis.z);

    var velocity = Vec3.new(0, 0, 0);
    velocity = vel_x.add(vel_y).add(vel_z);
    velocity = velocity.scale(100 * @floatCast(f32, dt));
    self.pos = self.pos.add(velocity);
}

pub fn getViewMatrix(self: Self) Mat4 {
    const wtf = Mat4.createTranslation(self.pos).mul(self.getRotationMatrix());
    return wtf.inv();

    // return Mat4.createLookAt(self.pos, self.pos.add(self.front), self.up);
}

pub fn getProjMatrix(_: Self, extent: vk.Extent2D) Mat4 {
    var proj = Mat4.createPerspective(toRadians(70.0), @intToFloat(f32, extent.width) / @intToFloat(f32, extent.height), 0.1, 500);
    proj.fields[1][1] *= -1;
    return proj;
}

pub fn getReversedProjMatrix(_: Self, extent: vk.Extent2D) Mat4 {
    var proj = Mat4.createPerspective(toRadians(70.0), @intToFloat(f32, extent.width) / @intToFloat(f32, extent.height), 500, 0.1);
    proj.fields[1][1] *= -1;
    return proj;
}

pub fn getRotationMatrix(self: Self) Mat4 {
    const yaw_rot = Mat4.createRotate(self.yaw, Vec3.new(0, -1, 0));
    return yaw_rot.rotate(self.pitch, Vec3.new(-1, 0, 0));
}
