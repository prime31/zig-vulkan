const std = @import("std");
const vk = @import("vulkan");

// render assets (textures and materials)
pub const Texture = struct {
	name: []const u8,
	path: []const u8,
};

pub const TextureSampler = struct {
    name: []const u8,
    create_info: vk.SamplerCreateInfo = std.mem.zeroInit(vk.SamplerCreateInfo),
};

pub const SampledTexture = struct {
	texture: []const u8,
	sampler: []const u8,
};

// template requires shaders (ShaderEffect), RenderPass and PipelineBuilder (ShaderPass)
pub const MaterialTemplate = struct {
	name: []const u8,
	vert: ?[]const u8,
	frag: []const u8,
};

pub const MaterialVariant = struct {
	name: []const u8,
	template: []const u8,
	textures: []SampledTexture,
	// buffers: []Buffer, // TODO: material variants can have a buffer of per-object data associated with them
};

pub const RenderTexture = struct {
	name: []const u8,
	width_scale: f32 = 1,
	height_scale: f32 = 1,
	format: u0,
	image_type: vk.ImageType = .@"2d",
	depends_on: ?[]const u8, // parent framebuffer which could be some other named RenderTexture or null for the swapchain back buffer
};



// (https://youtu.be/xq22zjb8eB8?t=183)
pub const LayerConfig = struct {
	name: []const u8,
	layers: []Layer,
};

// in practice a Layer is either a target for the shader system to render into or it is the execution point for a ResourceGenerator
pub const Layer = struct {
	name: []const u8,
	depth_sort: enum (u1) { back_to_front, front_to_back } = .back_to_front,
	render_targets: [][]const u8,
	depth_stencil_target: ?[]const u8 = null,
	resource_generator: ?[]const u8 = null,
	clear_flags: u3, // bit flag hinting if color, depth or stencil should be cleared for this layer
};

pub const ResourceGenerator = struct {
	name: []const u8,
	modifiers: []Modifier,
};

pub const Modifier = struct {
    name: []const u8,
    makeFn: fn (self: *Step) anyerror!void,
};

// renders a single triangle covering the entire viewport using the named shader
pub const FullscreenPassModifier = struct {
    step: Step,
    render_targets: [][]const u8,
    material: []const u8,
};


// http://bitsquid.blogspot.com/2017/03/stingray-renderer-walkthrough-7-data.html
// simple_layer_config = [
	// Populate gbuffers
	// { name = "gbuffer" render_targets="gbuffer0 gbuffer1" depth_stencil_target="ds_buffer" sort="FRONT_BACK" }

	// Kick resource generator ‘linearize_depth’ 
	// { name = "linearize_depth" resource_generator = "linearize_depth" }

	// Render decals affecting albedo term
	// { name = "decal_albedo" render_targets="gbuffer0" depth_stencil_target="ds_buffer" sort="BACK_FRONT" }

	// Kick resource generator ‘deferred_shading’
	// { name = "deferred_shading" resource_generator = "deferred_shading" }
// ]


// layer_configs = {
//     simple_deferred = [
//         { name="gbuffer" render_targets=["gbuffer0", "gbuffer1", "gbuffer2"] 
//             depth_stencil_target="depth_stencil_buffer" sort="FRONT_BACK" profiling_scope="gbuffer" }

//         { resource_generator="lighting" profiling_scope="lighting" }

//         { name="emissive" render_targets=["hdr0"] 
//             depth_stencil_target="depth_stencil_buffer" sort="FRONT_BACK" profiling_scope="emissive" }

//         { name="skydome" render_targets=["hdr0"] 
//             depth_stencil_target="depth_stencil_buffer" sort="BACK_FRONT" profiling_scope="skydome" }

//         { name="hdr_transparent" render_targets=["hdr0"] 
//             depth_stencil_target="depth_stencil_buffer" sort="BACK_FRONT" profiling_scope="hdr_transparent" }

//         { resource_generator="post_processing" profiling_scope="post_processing" }

//         { name="ldr_transparent" render_targets=["output_target"] 
//             depth_stencil_target="depth_stencil_buffer" sort="BACK_FRONT" profiling_scope="transparent" }
//     ]
// }


// auto_exposure = {
//     modifiers = [
//         { type="dynamic_branch" render_settings={ auto_exposure_enabled=true } profiling_scope="auto_exposure"
//             pass = [
//                 { type="fullscreen_pass" shader="quantize_luma" inputs=["hdr0"] 
//                     outputs=["quantized_luma"]  profiling_scope="quantize_luma" }

//                 { type="compute_kernel" shader="compute_histogram" thread_count=[40 1 1] inputs=["quantized_luma"] 
//                     uavs=["histogram"] profiling_scope="compute_histogram" }

//                 { type="compute_kernel" shader="adapt_exposure" thread_count=[1 1 1] inputs=["quantized_luma"] 
//                     uavs=["current_exposure" "current_exposure_pos" "target_exposure_pos"] profiling_scope="adapt_exposure" }
//             ]
//         }
//     ]   
// }