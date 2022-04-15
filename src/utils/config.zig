const std = @import("std");
const glfw = @import("glfw");
const cvars = @import("cvars.zig");
const AutoCVar = cvars.AutoCVar;

pub var disable_cull: AutoCVar(bool) = undefined;
pub var freeze_cull: AutoCVar(bool) = undefined;
pub var occlusion_cull: AutoCVar(bool) = undefined;
pub var cam_lock: AutoCVar(bool) = undefined;
pub var draw_distance: AutoCVar(f32) = undefined;

pub var freeze_shadows: AutoCVar(bool) = undefined;
pub var shadowcast: AutoCVar(bool) = undefined;
pub var shadow_bias: AutoCVar(f32) = undefined;
pub var shadow_slope_bias: AutoCVar(f32) = undefined;
pub var blit_shadow_buffer: AutoCVar(bool) = undefined;

pub fn init(window: glfw.Window) void {
    disable_cull = AutoCVar(bool).init("culling.disable (h)", "Full disables culling", false);
    freeze_cull = AutoCVar(bool).init("culling.freeze", "Locks culling", false);
    occlusion_cull = AutoCVar(bool).init("culling.enable_occlusion", "Perform occlusion culling on GPU", true);
    cam_lock = AutoCVar(bool).init("camera.lock (c)", "Locks the camera", false);
    draw_distance = AutoCVar(f32).initWithFlags("gpu.draw_distance", "Distance cull", 5000, .{ .float_min = 0, .float_max = 50000 });

    freeze_shadows = AutoCVar(bool).init("gpu.freeze_shadows", "Stop the rendering of shadows", false);
    shadowcast = AutoCVar(bool).init("gpu.shadowcast", "Use shadowcasting", true);
    shadow_bias = AutoCVar(f32).initWithFlags("gpu.shadow_bias", "Shadow bias", 5.25, .{ .float_min = 0, .float_max = 20 });
    shadow_slope_bias = AutoCVar(f32).initWithFlags("gpu.slope_bias", "Slope bias", 4.75, .{ .float_min = 0, .float_max = 20 });
    blit_shadow_buffer = AutoCVar(bool).init("gpu.blit_shadow_buffer (v)", "Makes the final blit display the shadow buffer", true);

    window.setKeyCallback(onKeyPress);
}

fn onKeyPress(_: glfw.Window, key: glfw.Key, scancode: i32, action: glfw.Action, _: glfw.Mods) void {
    _ = scancode;

    if (key == glfw.Key.c and action == .release) cam_lock.set(!cam_lock.get());
    if (key == glfw.Key.v and action == .release) blit_shadow_buffer.set(!blit_shadow_buffer.get());
    if (key == glfw.Key.h and action == .release) freeze_cull.set(!freeze_cull.get());
}

pub fn drawImGuiEditor() void {
    cvars.CVar.system().drawImGuiEditor();
}