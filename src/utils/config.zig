const std = @import("std");
const ig = @import("imgui");
const glfw = @import("glfw");

const Engine = @import("../engine.zig").Engine;

pub var disable_cull = false;
pub var freeze_cull = false;
pub var occlusion_cull = false;
pub var cam_lock = false;
pub var draw_distance: f32 = 500;

pub var freeze_shadows = false;
pub var shadowcast = true;
pub var shadow_bias: f32 = 5.25;
pub var shadow_slope_bias: f32 = 4.75;
pub var blit_shadow_buffer = true;

pub var lock_dir_light_to_camera = false;
pub var lock_mouse = false;

var win: glfw.Window = undefined;

pub fn init(window: glfw.Window) void {
    window.setKeyCallback(onKeyPress);
    win = window;
}

fn onKeyPress(_: glfw.Window, key: glfw.Key, scancode: i32, action: glfw.Action, _: glfw.Mods) void {
    _ = scancode;

    if (key == glfw.Key.c and action == .release) cam_lock = !cam_lock;
    if (key == glfw.Key.v and action == .release) blit_shadow_buffer = !blit_shadow_buffer;
    if (key == glfw.Key.h and action == .release) freeze_cull = !freeze_cull;
    if (key == glfw.Key.l and action == .release) lock_dir_light_to_camera = !lock_dir_light_to_camera;
    if (key == glfw.Key.m and action == .release) {
        lock_mouse = !lock_mouse;
        win.setInputModeCursor(if (lock_mouse) .disabled else .normal) catch unreachable;
    }
}

pub fn drawImGuiEditor(engine: *Engine) void {
    if (ig.igCollapsingHeader_BoolPtr("Config", null, ig.ImGuiTreeNodeFlags_None)) {
        ig.igIndent(10);
        defer ig.igUnindent(10);

        _ = ig.igCheckbox("Lock directional light to camera (l)", &lock_dir_light_to_camera);
        if (ig.igCheckbox("Lock mouse (m)", &lock_mouse)) {
            win.setInputModeCursor(if (lock_mouse) .disabled else .normal) catch unreachable;
        }

        checkbox("culling.disable", "Fully disables culling", &disable_cull);
        checkbox("culling.freeze (h)", "Locks culling", &freeze_cull);
        checkbox("culling.enable_occlusion", "Perform occlusion culling on GPU", &occlusion_cull);
        checkbox("camera.lock (c}", "Locks the camera mouse movement", &cam_lock);
        checkbox("gpu.draw_distance", "Distance cull", &disable_cull);

        checkbox("gpu.freeze_shadows", "Stop the rendering of shadows", &freeze_shadows);
        checkbox("gpu.shadowcast", "Use Shadowcasting", &shadowcast);
        checkbox("gpu.blit_shadow_buffer (v)", "Makes the final blit display the shadow buffer", &blit_shadow_buffer);
        slider("gpu.shadow_bias", null, &shadow_bias, 0, 20);
        slider("gpu.slope_bias", null, &shadow_slope_bias, 0, 20);
    }

    if (lock_dir_light_to_camera) {
        engine.main_light.light_pos = engine.camera.pos;
        engine.main_light.light_dir = engine.camera.front;
    }
}

fn checkbox(label: [*c]const u8, tooltip: ?[*c]const u8, value: [*c]bool) void {
    _ = ig.igCheckbox(label, value);
    if (ig.igIsItemHovered(ig.ImGuiHoveredFlags_None) and tooltip != null) ig.igSetTooltip(tooltip.?);
}

fn slider(label: [*c]const u8, tooltip: ?[*c]const u8, value: [*c]f32, min: f32, max: f32) void {
    _ = ig.igDragFloat(label, value, 0.1, min, max, null, ig.ImGuiSliderFlags_None);
    if (ig.igIsItemHovered(ig.ImGuiHoveredFlags_None) and tooltip != null) ig.igSetTooltip(tooltip.?);
}