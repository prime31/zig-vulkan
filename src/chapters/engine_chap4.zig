const std = @import("std");
const vk = @import("vulkan");
const vma = @import("vma");
const resources = @import("resources");
const glfw = @import("glfw");
const vkinit = @import("../vkinit.zig");

const GraphicsContext = @import("../graphics_context.zig").GraphicsContext;
const Swapchain = @import("../swapchain.zig").Swapchain;
const PipelineBuilder = @import("../pipeline_builder.zig").PipelineBuilder;
const Mesh = @import("../mesh.zig").Mesh;
const Vertex = @import("../mesh.zig").Vertex;
const Allocator = std.mem.Allocator;
const Mat4 = @import("mat4.zig").Mat4;
const Vec3 = @import("vec3.zig").Vec3;
const Vec4 = @import("vec4.zig").Vec4;

const FRAME_OVERLAP: usize = 2;

fn toRadians(deg: anytype) @TypeOf(deg) {
    return std.math.pi * deg / 180.0;
}

fn toDegrees(rad: anytype) @TypeOf(rad) {
    return 180.0 * rad / std.math.pi;
}

const FlyCamera = struct {
    window: glfw.Window,
    speed: f32 = 3.5,
    pos: Vec3 = Vec3.new(2, 0.5, 20),
    front: Vec3 = Vec3.new(0, 0, -1),
    up: Vec3 = Vec3.new(0, 1, 0),
    pitch: f32 = 0,
    yaw: f32 = -90,
    last_mouse_x: f32 = 400,
    last_mouse_y: f32 = 300,

    pub fn init(window: glfw.Window) FlyCamera {
        return .{
            .window = window,
        };
    }

    pub fn update(self: *FlyCamera, dt: f64) void {
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

    pub fn getViewMatrix(self: FlyCamera) Mat4 {
        return Mat4.createLookAt(self.pos, self.pos.add(self.front), self.up);
    }
};

const GpuCameraData = struct {
    view: Mat4,
    proj: Mat4,
    view_proj: Mat4,
};

const GpuSceneData = struct {
    fog_color: Vec4 = Vec4.new(1, 0, 0, 1),
    fog_distance: Vec4 = Vec4.new(1, 0, 0, 1),
    ambient_color: Vec4 = Vec4.new(1, 0, 0, 1),
    sun_dir: Vec4 = Vec4.new(1, 0, 0, 1),
    sun_color: Vec4 = Vec4.new(1, 0, 0, 1),
};

const GpuObjectData = struct {
    model: Mat4,
};

const FrameData = struct {
    cmd_pool: vk.CommandPool,
    cmd_buffer: vk.CommandBuffer,
    camera_buffer: vma.AllocatedBuffer,
    global_descriptor: vk.DescriptorSet,
    object_buffer: vma.AllocatedBuffer,
    object_descriptor: vk.DescriptorSet,

    pub fn init(gc: *GraphicsContext, descriptor_set_layout: vk.DescriptorSetLayout, descriptor_pool: vk.DescriptorPool, scene_param_buffer: vma.AllocatedBuffer, object_set_layout: vk.DescriptorSetLayout) !FrameData {
        const cmd_pool = try gc.vkd.createCommandPool(gc.dev, &.{
            .flags = .{ .reset_command_buffer_bit = true },
            .queue_family_index = gc.graphics_queue.family,
        }, null);

        var cmd_buffer: vk.CommandBuffer = undefined;
        try gc.vkd.allocateCommandBuffers(gc.dev, &.{
            .command_pool = cmd_pool,
            .level = .primary,
            .command_buffer_count = 1,
        }, @ptrCast([*]vk.CommandBuffer, &cmd_buffer));

        // descriptor set setup
        var camera_buffer = try createBuffer(gc, @sizeOf(GpuCameraData), .{ .uniform_buffer_bit = true }, .cpu_to_gpu);

        const max_objects: usize = 10_000;
        var object_buffer = try createBuffer(gc, @sizeOf(GpuObjectData) * max_objects, .{ .storage_buffer_bit = true }, .cpu_to_gpu);

        var global_descriptor: vk.DescriptorSet = undefined;
        try gc.vkd.allocateDescriptorSets(gc.dev, &.{
            .descriptor_pool = descriptor_pool,
            .descriptor_set_count = 1,
            .p_set_layouts = @ptrCast([*]const vk.DescriptorSetLayout, &descriptor_set_layout),
        }, @ptrCast([*]vk.DescriptorSet, &global_descriptor));

        // allocate the descriptor set that will point to object buffer
        var object_descriptor: vk.DescriptorSet = undefined;
        try gc.vkd.allocateDescriptorSets(gc.dev, &.{
            .descriptor_pool = descriptor_pool,
            .descriptor_set_count = 1,
            .p_set_layouts = @ptrCast([*]const vk.DescriptorSetLayout, &object_set_layout),
        }, @ptrCast([*]vk.DescriptorSet, &object_descriptor));

        // information about the buffer we want to point at in the descriptor
        const cam_info = vk.DescriptorBufferInfo{
            .buffer = camera_buffer.buffer,
            .offset = 0,
            .range = @sizeOf(GpuCameraData),
        };

        const scene_info = vk.DescriptorBufferInfo{
            .buffer = scene_param_buffer.buffer,
            .offset = 0,
            .range = @sizeOf(GpuSceneData),
        };

        const object_buffer_info = vk.DescriptorBufferInfo{
            .buffer = object_buffer.buffer,
            .offset = 0,
            .range = @sizeOf(GpuObjectData) * max_objects,
        };

        const camera_write = vkinit.writeDescriptorBuffer(.uniform_buffer, global_descriptor, &cam_info, 0);
        const scene_write = vkinit.writeDescriptorBuffer(.uniform_buffer_dynamic, global_descriptor, &scene_info, 1);
        const object_write = vkinit.writeDescriptorBuffer(.storage_buffer, object_descriptor, &object_buffer_info, 0);

        const set_writes = [_]vk.WriteDescriptorSet{ camera_write, scene_write, object_write };
        gc.vkd.updateDescriptorSets(gc.dev, 3, &set_writes, 0, undefined);

        return FrameData{
            .cmd_pool = cmd_pool,
            .cmd_buffer = cmd_buffer,
            .camera_buffer = camera_buffer,
            .global_descriptor = global_descriptor,
            .object_buffer = object_buffer,
            .object_descriptor = object_descriptor,
        };
    }

    pub fn deinit(self: *FrameData, gc: *GraphicsContext) void {
        gc.vkd.freeCommandBuffers(gc.dev, self.cmd_pool, 1, @ptrCast([*]vk.CommandBuffer, &self.cmd_buffer));
        gc.vkd.destroyCommandPool(gc.dev, self.cmd_pool, null);
        self.camera_buffer.deinit(gc.allocator);
        self.object_buffer.deinit(gc.allocator);
    }
};

const Material = struct {
    pipeline: vk.Pipeline,
    pipeline_layout: vk.PipelineLayout,

    pub fn init(pipeline: vk.Pipeline, pipeline_layout: vk.PipelineLayout) Material {
        return .{
            .pipeline = pipeline,
            .pipeline_layout = pipeline_layout,
        };
    }
};

const RenderObject = struct {
    mesh: *Mesh,
    material: *Material,
    transform_matrix: Mat4,
};

var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{ .thread_safe = false }){};
const gpa = general_purpose_allocator.allocator();

const depth_format = vk.Format.d32_sfloat;

const MeshPushConstants = struct {
    data: Vec4 = .{},
    render_matrix: Mat4,
};

pub const EngineChap4 = struct {
    const Self = @This();

    allocator: Allocator,
    window: glfw.Window,
    gc: *GraphicsContext,
    swapchain: Swapchain,
    render_pass: vk.RenderPass,
    framebuffers: []vk.Framebuffer,
    frames: []FrameData,
    frame_num: f32 = 0,
    dt: f64 = 0.0,
    last_frame_time: f64 = 0.0,
    depth_image: vma.AllocatedImage,
    renderables: std.ArrayList(RenderObject),
    materials: std.StringHashMap(Material),
    meshes: std.StringHashMap(Mesh),
    camera: FlyCamera,
    global_set_layout: vk.DescriptorSetLayout,
    descriptor_pool: vk.DescriptorPool,
    gpu_props: vk.PhysicalDeviceProperties,
    scene_params: GpuSceneData,
    scene_param_buffer: vma.AllocatedBuffer,
    object_set_layout: vk.DescriptorSetLayout,

    pub fn init(app_name: [*:0]const u8) !Self {
        try glfw.init(.{});

        var extent = vk.Extent2D{ .width = 800, .height = 600 };
        const window = try glfw.Window.create(extent.width, extent.height, app_name, null, null, .{
            .client_api = .no_api,
        });

        var gc = try gpa.create(GraphicsContext);
        gc.* = try GraphicsContext.init(gpa, app_name, window);

        // swapchain
        var swapchain = try Swapchain.init(gc, gpa, extent, FRAME_OVERLAP);
        const render_pass = try createRenderPass(gc, swapchain);

        // depth image
        const depth_image = try createDepthImage(gc, swapchain);
        const framebuffers = try createFramebuffers(gc, gpa, render_pass, swapchain, depth_image.view.?);

        // descriptors
        const gpu_props = gc.vki.getPhysicalDeviceProperties(gc.pdev);
        const descriptors = createDescriptors(gc, gpu_props);

        // create our FrameDatas
        const frames = try gpa.alloc(FrameData, swapchain.swap_images.len);
        errdefer gpa.free(frames);
        for (frames) |*f| f.* = try FrameData.init(gc, descriptors.layout, descriptors.pool, descriptors.scene_param_buffer, descriptors.object_set_layout);

        return Self{
            .allocator = gpa,
            .window = window,
            .gc = gc,
            .swapchain = swapchain,
            .render_pass = render_pass,
            .framebuffers = framebuffers,
            .frames = frames,
            .depth_image = depth_image,
            .renderables = std.ArrayList(RenderObject).init(gpa),
            .materials = std.StringHashMap(Material).init(gpa),
            .meshes = std.StringHashMap(Mesh).init(gpa),
            .camera = FlyCamera.init(window),
            .global_set_layout = descriptors.layout,
            .descriptor_pool = descriptors.pool,
            .gpu_props = gpu_props,
            .scene_params = .{},
            .scene_param_buffer = descriptors.scene_param_buffer,
            .object_set_layout = descriptors.object_set_layout,
        };
    }

    pub fn deinit(self: *Self) void {
        self.gc.vkd.deviceWaitIdle(self.gc.dev) catch return;

        self.scene_param_buffer.deinit(self.gc.allocator);
        self.gc.vkd.destroyDescriptorSetLayout(self.gc.dev, self.object_set_layout, null);
        self.gc.vkd.destroyDescriptorSetLayout(self.gc.dev, self.global_set_layout, null);
        self.gc.vkd.destroyDescriptorPool(self.gc.dev, self.descriptor_pool, null);

        self.depth_image.deinit(self.gc.allocator);
        self.gc.vkd.destroyImageView(self.gc.dev, self.depth_image.view.?, null);

        var iter = self.meshes.valueIterator();
        while (iter.next()) |mesh| mesh.*.deinit(self.gc.allocator);

        for (self.frames) |*frame| frame.deinit(self.gc);
        self.allocator.free(self.frames);

        for (self.framebuffers) |fb| self.gc.vkd.destroyFramebuffer(self.gc.dev, fb, null);
        self.allocator.free(self.framebuffers);

        var mat_iter = self.materials.valueIterator();
        while (mat_iter.next()) |mat| {
            self.gc.vkd.destroyPipeline(self.gc.dev, mat.pipeline, null);
            self.gc.vkd.destroyPipelineLayout(self.gc.dev, mat.pipeline_layout, null);
        }
        self.gc.vkd.destroyRenderPass(self.gc.dev, self.render_pass, null);

        self.swapchain.deinit();

        self.gc.deinit();
        self.allocator.destroy(self.gc);

        self.window.destroy();
        glfw.terminate();

        self.renderables.deinit();
        self.materials.deinit();
        self.meshes.deinit();
        _ = general_purpose_allocator.deinit();
        // _ = general_purpose_allocator.detectLeaks();
    }

    pub fn loadContent(self: *Self) !void {
        try self.loadMeshes();
        try self.initPipelines();
        try self.initScene();
    }

    pub fn run(self: *Self) !void {
        while (!self.window.shouldClose()) {
            var curr_frame_time = glfw.getTime();
            self.dt = curr_frame_time - self.last_frame_time;
            self.last_frame_time = curr_frame_time;

            self.camera.update(self.dt);

            // wait for the last frame to complete before filling our CommandBuffer
            const state = self.swapchain.waitForFrame() catch |err| switch (err) {
                error.OutOfDateKHR => Swapchain.PresentState.suboptimal,
                else => |narrow| return narrow,
            };

            const frame = self.frames[self.swapchain.frame_index % self.swapchain.swap_images.len];
            try self.draw(self.framebuffers[self.swapchain.image_index], frame);

            try self.swapchain.present(frame.cmd_buffer);

            // TODO: why does this have to be after present?
            if (state == .suboptimal) {
                try self.swapchain.waitForAllFences();

                const size = try self.window.getSize();
                var extent = vk.Extent2D{ .width = size.width, .height = size.height };
                try self.swapchain.recreate(extent);

                for (self.framebuffers) |fb| self.gc.vkd.destroyFramebuffer(self.gc.dev, fb, null);
                self.allocator.free(self.framebuffers);

                self.depth_image.deinit(self.gc.allocator);
                self.gc.vkd.destroyImageView(self.gc.dev, self.depth_image.view.?, null);
                self.depth_image = try createDepthImage(self.gc, self.swapchain);
                self.framebuffers = try createFramebuffers(self.gc, self.allocator, self.render_pass, self.swapchain, self.depth_image.view.?);
            }

            self.frame_num += 1;
            try glfw.pollEvents();
        }
    }

    fn loadMeshes(self: *Self) !void {
        var tri_mesh = Mesh.init(gpa);
        try tri_mesh.vertices.append(.{ .position = .{ 1, 1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0.6, 0.6, 0.6 } });
        try tri_mesh.vertices.append(.{ .position = .{ -1, 1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0.6, 0.6, 0.6 } });
        try tri_mesh.vertices.append(.{ .position = .{ 0, -1, 0 }, .normal = .{ 0, 0, 0 }, .color = .{ 0.6, 0.6, 0.6 } });

        var monkey_mesh = Mesh.initFromObj(gpa, "src/chapters/monkey_flat.obj");
        var cube_thing_mesh = Mesh.initFromObj(gpa, "src/chapters/cube_thing.obj");

        try uploadMesh(self.gc, &tri_mesh);
        try uploadMesh(self.gc, &monkey_mesh);
        try uploadMesh(self.gc, &cube_thing_mesh);

        try self.meshes.put("triangle", tri_mesh);
        try self.meshes.put("monkey", monkey_mesh);
        try self.meshes.put("cube_thing", cube_thing_mesh);
    }

    fn initPipelines(self: *Self) !void {
        var push_constant = vk.PushConstantRange{
            .stage_flags = .{ .vertex_bit = true },
            .offset = 0,
            .size = @sizeOf(MeshPushConstants),
        };

        // push-constant setup
        var pip_layout_info = vkinit.pipelineLayoutCreateInfo();
        pip_layout_info.push_constant_range_count = 1;
        pip_layout_info.p_push_constant_ranges = @ptrCast([*]const vk.PushConstantRange, &push_constant);

        // hook the global set layout and object set layout
        const set_layouts = [_]vk.DescriptorSetLayout{ self.global_set_layout, self.object_set_layout };
        pip_layout_info.set_layout_count = 2;
        pip_layout_info.p_set_layouts = @ptrCast([*]const vk.DescriptorSetLayout, &set_layouts);

        const pipeline_layout = try self.gc.vkd.createPipelineLayout(self.gc.dev, &pip_layout_info, null);
        const pipeline = try createPipeline(self.gc, self.allocator, self.render_pass, pipeline_layout, resources.default_lit_frag);
        const material = Material{
            .pipeline = pipeline,
            .pipeline_layout = pipeline_layout,
        };
        try self.materials.put("defaultmesh", material);

        const pipeline_layout2 = try self.gc.vkd.createPipelineLayout(self.gc.dev, &pip_layout_info, null);
        const pipeline2 = try createPipeline(self.gc, self.allocator, self.render_pass, pipeline_layout2, resources.default_lit_frag);
        const material2 = Material{
            .pipeline = pipeline2,
            .pipeline_layout = pipeline_layout2,
        };
        try self.materials.put("redmesh", material2);
    }

    fn initScene(self: *Self) !void {
        var monkey = RenderObject{
            .mesh = self.meshes.getPtr("monkey").?,
            .material = self.materials.getPtr("defaultmesh").?,
            .transform_matrix = Mat4.createTranslation(Vec3.new(0, 2, 0)),
        };
        try self.renderables.append(monkey);

        var x: f32 = 0;
        while (x < 20) : (x += 1) {
            var y: f32 = 0;
            while (y < 20) : (y += 1) {
                var matrix = Mat4.createTranslation(.{ .x = x, .y = 0, .z = y });
                var scale_matrix = Mat4.createScale(.{ .x = 0.4, .y = 0.4, .z = 0.4 });

                const mesh_material = if (@mod(x, 2) == 0) self.materials.getPtr("defaultmesh").? else self.materials.getPtr("redmesh").?;
                const mesh = if (@mod(x, 2) == 0 and @mod(x, 6) == 0) self.meshes.getPtr("cube_thing").? else self.meshes.getPtr("triangle").?;
                var object = RenderObject{
                    .mesh = mesh,
                    .material = mesh_material,
                    .transform_matrix = Mat4.mul(matrix, scale_matrix),
                };
                try self.renderables.append(object);

                matrix = Mat4.createTranslation(.{ .x = x, .y = 0.8, .z = y });
                scale_matrix = Mat4.createScale(.{ .x = 0.2, .y = 0.2, .z = 0.2 });

                object = RenderObject{
                    .mesh = mesh,
                    .material = mesh_material,
                    .transform_matrix = Mat4.mul(matrix, scale_matrix),
                };
                try self.renderables.append(object);

                matrix = Mat4.createTranslation(.{ .x = x, .y = -0.8, .z = y });
                object = RenderObject{
                    .mesh = mesh,
                    .material = mesh_material,
                    .transform_matrix = Mat4.mul(matrix, scale_matrix),
                };
                try self.renderables.append(object);
            }
        }
    }

    fn draw(self: *Self, framebuffer: vk.Framebuffer, frame: FrameData) !void {
        const cmdbuf = frame.cmd_buffer;
        const clear = vk.ClearValue{
            .color = .{ .float_32 = .{ 0.6, 0.5, 0, 1 } },
        };

        const depth_clear = vk.ClearValue{
            .depth_stencil = .{ .depth = 1, .stencil = 0 },
        };

        const clear_values = [_]vk.ClearValue{ clear, depth_clear };

        // This needs to be a separate definition - see https://github.com/ziglang/zig/issues/7627.
        const render_area = vk.Rect2D{
            .offset = .{ .x = 0, .y = 0 },
            .extent = self.swapchain.extent,
        };

        const viewport = vk.Viewport{
            .x = 0,
            .y = 0,
            .width = @intToFloat(f32, self.swapchain.extent.width),
            .height = @intToFloat(f32, self.swapchain.extent.height),
            .min_depth = 0,
            .max_depth = 1,
        };

        try self.gc.vkd.resetCommandBuffer(cmdbuf, .{});
        try self.gc.vkd.beginCommandBuffer(cmdbuf, &.{
            .flags = .{ .one_time_submit_bit = true },
            .p_inheritance_info = null,
        });

        self.gc.vkd.cmdSetViewport(cmdbuf, 0, 1, @ptrCast([*]const vk.Viewport, &viewport));
        self.gc.vkd.cmdSetScissor(cmdbuf, 0, 1, @ptrCast([*]const vk.Rect2D, &render_area));

        self.gc.vkd.cmdBeginRenderPass(cmdbuf, &.{
            .render_pass = self.render_pass,
            .framebuffer = framebuffer,
            .render_area = render_area,
            .clear_value_count = clear_values.len,
            .p_clear_values = @ptrCast([*]const vk.ClearValue, &clear_values),
        }, .@"inline");

        try self.drawRenderObjects(frame);

        self.gc.vkd.cmdEndRenderPass(cmdbuf);
        try self.gc.vkd.endCommandBuffer(cmdbuf);
    }

    fn drawRenderObjects(self: *Self, frame: FrameData) !void {
        const cmdbuf = frame.cmd_buffer;

        var view = self.camera.getViewMatrix();
        var proj = Mat4.createPerspective(toRadians(70.0), @intToFloat(f32, self.swapchain.extent.width) / @intToFloat(f32, self.swapchain.extent.height), 0.1, 200);
        proj.fields[1][1] *= -1;
        var view_proj = Mat4.mul(proj, view);

        // fill a GPU camera data struct
        const cam_data = GpuCameraData{
            .view = view,
            .proj = proj,
            .view_proj = view_proj,
        };

        // and copy it to the buffer
        const cam_data_ptr = try self.gc.allocator.mapMemory(GpuCameraData, frame.camera_buffer.allocation);
        cam_data_ptr.* = cam_data;
        self.gc.allocator.unmapMemory(frame.camera_buffer.allocation);

        // scene params
        const framed = self.frame_num / 12;
        self.scene_params.ambient_color = Vec4.new((std.math.sin(framed) + 1) * 0.5, 1, (std.math.cos(framed) + 1) * 0.5, 1);

        const frame_index = @floatToInt(usize, self.frame_num) % FRAME_OVERLAP;
        const data_offset = padUniformBufferSize(self.gpu_props, @sizeOf(GpuSceneData)) * frame_index;
        const scene_data_ptr = (try self.gc.allocator.mapMemoryAtOffset(GpuSceneData, self.scene_param_buffer.allocation, data_offset));
        scene_data_ptr.* = self.scene_params;
        self.gc.allocator.unmapMemory(self.scene_param_buffer.allocation);

        // object SSBO
        const object_data_ptr = try self.gc.allocator.mapMemory(GpuObjectData, frame.object_buffer.allocation);
        for (self.renderables.items) |*object, i| {
            var rot = Mat4.createAngleAxis(.{ .y = 1 }, toRadians(25.0) * self.frame_num * 0.04 + @intToFloat(f32, i));
            object_data_ptr[i].model = object.transform_matrix.mul(rot);
        }
        self.gc.allocator.unmapMemory(frame.object_buffer.allocation);

        var last_mesh: *Mesh = @intToPtr(*Mesh, @ptrToInt(&self));
        var last_material: *Material = @intToPtr(*Material, @ptrToInt(&self));

        for (self.renderables.items) |*object, i| {
            // only bind the pipeline if it doesnt match with the already bound one
            if (object.material != last_material) {
                last_material = object.material;
                self.gc.vkd.cmdBindPipeline(cmdbuf, .graphics, object.material.pipeline);

                // offset for our scene buffer
                const uniform_offset = padUniformBufferSize(self.gpu_props, @sizeOf(GpuSceneData)) * frame_index;

                // bind the descriptor set when changing pipeline
                self.gc.vkd.cmdBindDescriptorSets(cmdbuf, .graphics, object.material.pipeline_layout, 0, 1, @ptrCast([*]const vk.DescriptorSet, &frame.global_descriptor), 1, @ptrCast([*]const u32, &uniform_offset));

                // bind the object data descriptor
                self.gc.vkd.cmdBindDescriptorSets(cmdbuf, .graphics, object.material.pipeline_layout, 1, 1, @ptrCast([*]const vk.DescriptorSet, &frame.object_descriptor), 0, undefined);
            }

            var model = object.transform_matrix;
            var rot = Mat4.createAngleAxis(.{ .y = 1 }, toRadians(25.0) * self.frame_num * 0.04);
            model = model.mul(rot);

            var constants = MeshPushConstants{
                .render_matrix = model,
            };
            self.gc.vkd.cmdPushConstants(cmdbuf, object.material.pipeline_layout, .{ .vertex_bit = true }, 0, @sizeOf(MeshPushConstants), &constants);

            // only bind the mesh if its a different one from last bind
            if (object.mesh != last_mesh) {
                last_mesh = object.mesh;
                // bind the mesh vertex buffer with offset 0
                var offset: vk.DeviceSize = 0;
                self.gc.vkd.cmdBindVertexBuffers(cmdbuf, 0, 1, @ptrCast([*]const vk.Buffer, &object.mesh.vert_buffer.buffer), @ptrCast([*]const vk.DeviceSize, &offset));
            }

            self.gc.vkd.cmdDraw(cmdbuf, @intCast(u32, object.mesh.vertices.items.len), 1, 0, @intCast(u32, i));
        }
    }
};

fn createRenderPass(gc: *const GraphicsContext, swapchain: Swapchain) !vk.RenderPass {
    const color_attachment = vk.AttachmentDescription{
        .flags = .{},
        .format = swapchain.surface_format.format,
        .samples = .{ .@"1_bit" = true },
        .load_op = .clear,
        .store_op = .store,
        .stencil_load_op = .dont_care,
        .stencil_store_op = .dont_care,
        .initial_layout = .@"undefined",
        .final_layout = .present_src_khr,
    };

    const color_attachment_ref = vk.AttachmentReference{
        .attachment = 0,
        .layout = .color_attachment_optimal,
    };

    const depth_attachment = vk.AttachmentDescription{
        .flags = .{},
        .format = depth_format,
        .samples = .{ .@"1_bit" = true },
        .load_op = .clear,
        .store_op = .store,
        .stencil_load_op = .clear,
        .stencil_store_op = .dont_care,
        .initial_layout = .@"undefined",
        .final_layout = .depth_stencil_attachment_optimal,
    };

    const depth_attachment_ref = vk.AttachmentReference{
        .attachment = 1,
        .layout = .depth_stencil_attachment_optimal,
    };

    const subpass = vk.SubpassDescription{
        .flags = .{},
        .pipeline_bind_point = .graphics,
        .input_attachment_count = 0,
        .p_input_attachments = undefined,
        .color_attachment_count = 1,
        .p_color_attachments = @ptrCast([*]const vk.AttachmentReference, &color_attachment_ref),
        .p_resolve_attachments = null,
        .p_depth_stencil_attachment = &depth_attachment_ref,
        .preserve_attachment_count = 0,
        .p_preserve_attachments = undefined,
    };

    const dependency = vk.SubpassDependency{
        .src_subpass = vk.SUBPASS_EXTERNAL,
        .dst_subpass = 0,
        .src_stage_mask = .{
            .color_attachment_output_bit = true,
        },
        .src_access_mask = .{},
        .dst_stage_mask = .{
            .color_attachment_output_bit = true,
        },
        .dst_access_mask = .{
            .color_attachment_write_bit = true,
        },
        .dependency_flags = .{},
    };

    const depth_dependency = vk.SubpassDependency{
        .src_subpass = vk.SUBPASS_EXTERNAL,
        .dst_subpass = 0,
        .src_stage_mask = .{
            .early_fragment_tests_bit = true,
            .late_fragment_tests_bit = true,
        },
        .src_access_mask = .{},
        .dst_stage_mask = .{
            .early_fragment_tests_bit = true,
            .late_fragment_tests_bit = true,
        },
        .dst_access_mask = .{
            .depth_stencil_attachment_write_bit = true,
        },
        .dependency_flags = .{},
    };

    var attachments: [2]vk.AttachmentDescription = [_]vk.AttachmentDescription{ color_attachment, depth_attachment };
    var dependencies: [2]vk.SubpassDependency = [_]vk.SubpassDependency{ dependency, depth_dependency };
    return try gc.vkd.createRenderPass(gc.dev, &.{
        .flags = .{},
        .attachment_count = 2,
        .p_attachments = @ptrCast([*]const vk.AttachmentDescription, &attachments),
        .subpass_count = 1,
        .p_subpasses = @ptrCast([*]const vk.SubpassDescription, &subpass),
        .dependency_count = 1,
        .p_dependencies = @ptrCast([*]const vk.SubpassDependency, &dependencies),
    }, null);
}

fn createDepthImage(gc: *const GraphicsContext, swapchain: Swapchain) !vma.AllocatedImage {
    const depth_extent = vk.Extent3D{ .width = swapchain.extent.width, .height = swapchain.extent.height, .depth = 1 };
    const dimg_info = vkinit.imageCreateInfo(depth_format, depth_extent, .{ .depth_stencil_attachment_bit = true });

    // we want to allocate it from GPU local memory
    var malloc_info = std.mem.zeroInit(vma.VmaAllocationCreateInfo, .{
        .flags = .{},
        .usage = .gpu_only,
        .requiredFlags = .{ .device_local_bit = true },
    });
    var depth_image = try gc.allocator.createImage(&dimg_info, &malloc_info, null);

    const dview_info = vkinit.imageViewCreateInfo(depth_format, depth_image.image, .{ .depth_bit = true });
    depth_image.view = try gc.vkd.createImageView(gc.dev, &dview_info, null);

    return depth_image;
}

fn createFramebuffers(gc: *const GraphicsContext, allocator: Allocator, render_pass: vk.RenderPass, swapchain: Swapchain, depth_image_view: vk.ImageView) ![]vk.Framebuffer {
    const framebuffers = try allocator.alloc(vk.Framebuffer, swapchain.swap_images.len);
    errdefer allocator.free(framebuffers);

    var i: usize = 0;
    errdefer for (framebuffers[0..i]) |fb| gc.vkd.destroyFramebuffer(gc.dev, fb, null);

    for (framebuffers) |*fb| {
        var attachments = [2]vk.ImageView{ swapchain.swap_images[i].view, depth_image_view };
        fb.* = try gc.vkd.createFramebuffer(gc.dev, &.{
            .flags = .{},
            .render_pass = render_pass,
            .attachment_count = 2,
            .p_attachments = @ptrCast([*]const vk.ImageView, &attachments),
            .width = swapchain.extent.width,
            .height = swapchain.extent.height,
            .layers = 1,
        }, null);
        i += 1;
    }

    return framebuffers;
}

fn createShaderModule(gc: *const GraphicsContext, data: [*]const u32, len: usize) !vk.ShaderModule {
    return try gc.vkd.createShaderModule(gc.dev, &.{
        .flags = .{},
        .code_size = len,
        .p_code = data,
    }, null);
}

fn createShaderStageCreateInfo(shader_module: vk.ShaderModule, stage: vk.ShaderStageFlags) vk.PipelineShaderStageCreateInfo {
    return .{
        .flags = .{},
        .stage = stage,
        .module = shader_module,
        .p_name = "main",
        .p_specialization_info = null,
    };
}

fn createPipeline(
    gc: *const GraphicsContext,
    allocator: std.mem.Allocator,
    render_pass: vk.RenderPass,
    pipeline_layout: vk.PipelineLayout,
    frag_shader_bytes: [:0]const u8,
) !vk.Pipeline {
    const vert = try createShaderModule(gc, @ptrCast([*]const u32, resources.tri_mesh_descriptors_vert), resources.tri_mesh_descriptors_vert.len);
    const frag = try createShaderModule(gc, @ptrCast([*]const u32, @alignCast(@alignOf(u32), frag_shader_bytes)), frag_shader_bytes.len);

    defer gc.vkd.destroyShaderModule(gc.dev, vert, null);
    defer gc.vkd.destroyShaderModule(gc.dev, frag, null);

    var builder = PipelineBuilder.init(allocator, pipeline_layout);
    builder.depth_stencil = vkinit.pipelineDepthStencilCreateInfo(true, true, .less_or_equal);

    builder.vertex_input_info.vertex_attribute_description_count = Vertex.attribute_description.len;
    builder.vertex_input_info.p_vertex_attribute_descriptions = &Vertex.attribute_description;
    builder.vertex_input_info.vertex_binding_description_count = 1;
    builder.vertex_input_info.p_vertex_binding_descriptions = @ptrCast([*]const vk.VertexInputBindingDescription, &Vertex.binding_description);

    try builder.addShaderStage(createShaderStageCreateInfo(vert, .{ .vertex_bit = true }));
    try builder.addShaderStage(createShaderStageCreateInfo(frag, .{ .fragment_bit = true }));
    return try builder.build(gc, render_pass);
}

fn padUniformBufferSize(gpu_props: vk.PhysicalDeviceProperties, size: usize) usize {
    const min_ubo_alignment = gpu_props.limits.min_uniform_buffer_offset_alignment;
    var aligned_size = size;
    if (min_ubo_alignment > 0)
        aligned_size = (aligned_size + min_ubo_alignment - 1) & ~(min_ubo_alignment - 1);
    return aligned_size;
}

fn createBuffer(gc: *const GraphicsContext, size: usize, usage: vk.BufferUsageFlags, memory_usage: vma.VmaMemoryUsage) !vma.AllocatedBuffer {
    const buffer_info = std.mem.zeroInit(vk.BufferCreateInfo, .{
        .flags = .{},
        .size = size,
        .usage = usage,
    });

    const alloc_flags: vma.AllocationCreateFlags = blk: {
        // for `auto*` `memory_usage` flags must include one of `host_access_sequential_write/host_access_random` flags. We prefer sequential here.
        if (memory_usage == .auto or memory_usage == .auto_prefer_device or memory_usage == .auto_prefer_host)
            break :blk .{ .host_access_sequential_write = true };
        break :blk .{};
    };

    const malloc_info = std.mem.zeroInit(vma.VmaAllocationCreateInfo, .{
        .flags = alloc_flags,
        .usage = memory_usage,
        .requiredFlags = .{ .host_visible_bit = true, .host_coherent_bit = true },
    });

    return try gc.allocator.createBuffer(&buffer_info, &malloc_info, null);
}

fn createDescriptors(gc: *const GraphicsContext, gpu_props: vk.PhysicalDeviceProperties) struct { layout: vk.DescriptorSetLayout, pool: vk.DescriptorPool, scene_param_buffer: vma.AllocatedBuffer, object_set_layout: vk.DescriptorSetLayout } {
    // binding for camera data at 0
    const cam_bind = vkinit.descriptorSetLayoutBinding(.uniform_buffer, .{ .vertex_bit = true }, 0);

    // binding for scene data at 1
    const scene_bind = vkinit.descriptorSetLayoutBinding(.uniform_buffer_dynamic, .{ .vertex_bit = true, .fragment_bit = true }, 1);
    const bindings = [_]vk.DescriptorSetLayoutBinding{ cam_bind, scene_bind };

    var set_info = vk.DescriptorSetLayoutCreateInfo{
        .flags = .{},
        .binding_count = 2,
        .p_bindings = &bindings,
    };
    var global_set_layout = gc.vkd.createDescriptorSetLayout(gc.dev, &set_info, null) catch unreachable;

    // binding for object data at 0
    const object_bind = vkinit.descriptorSetLayoutBinding(.storage_buffer, .{ .vertex_bit = true }, 0);
    const set_info_object = vk.DescriptorSetLayoutCreateInfo{
        .flags = .{},
        .binding_count = 1,
        .p_bindings = @ptrCast([*]const vk.DescriptorSetLayoutBinding, &object_bind),
    };
    const object_set_layout = gc.vkd.createDescriptorSetLayout(gc.dev, &set_info_object, null) catch unreachable;

    const sizes = [_]vk.DescriptorPoolSize{
        .{
            .@"type" = .uniform_buffer,
            .descriptor_count = 10,
        },
        .{
            .@"type" = .uniform_buffer_dynamic,
            .descriptor_count = 10,
        },
        .{
            .@"type" = .storage_buffer,
            .descriptor_count = 10,
        },
    };
    var descriptor_pool = gc.vkd.createDescriptorPool(gc.dev, &.{
        .flags = .{},
        .max_sets = 10,
        .pool_size_count = 3,
        .p_pool_sizes = &sizes,
    }, null) catch unreachable;

    const scene_param_buffer_size = FRAME_OVERLAP * padUniformBufferSize(gpu_props, @sizeOf(GpuSceneData));
    const scene_param_buffer = createBuffer(gc, scene_param_buffer_size, .{ .uniform_buffer_bit = true }, .cpu_to_gpu) catch unreachable;

    return .{
        .layout = global_set_layout,
        .pool = descriptor_pool,
        .scene_param_buffer = scene_param_buffer,
        .object_set_layout = object_set_layout,
    };
}

fn uploadMesh(gc: *const GraphicsContext, mesh: *Mesh) !void {
    mesh.vert_buffer = try createBuffer(gc, mesh.vertices.items.len * @sizeOf(Vertex), .{ .vertex_buffer_bit = true }, .auto_prefer_device);
    const verts = try gc.allocator.mapMemory(Vertex, mesh.vert_buffer.allocation);
    std.mem.copy(Vertex, verts[0..mesh.vertices.items.len], mesh.vertices.items);
    gc.allocator.unmapMemory(mesh.vert_buffer.allocation);
}
