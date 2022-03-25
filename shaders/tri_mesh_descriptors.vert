#version 450

layout (location = 0) in vec3 vPosition;
layout (location = 1) in vec3 vNormal;
layout (location = 2) in vec3 vColor;

layout (location = 0) out vec3 outColor;

// descriptor set bound at slot 0, and it’s binding 0 within that descriptor set
layout (set = 0, binding = 0) uniform CameraBuffer {
	mat4 view;
	mat4 proj;
	mat4 view_proj;
} camera_data;

layout (push_constant) uniform constants {
	vec4 data;
	mat4 render_matrix;
} PushConstants;

void main() {
	mat4 transform_matrix = camera_data.view_proj * PushConstants.render_matrix;
	gl_Position = transform_matrix * vec4(vPosition, 1.0);
	outColor = vColor;
}