#version 450

layout (location = 0) out vec4 outFragColor;

layout (location = 0) in vec3 inColor;
layout (location = 1) in vec2 texCoord;

layout (set = 0, binding = 1) uniform SceneData {
    vec4 fogColor; // w is for exponent
	vec4 fogDistances; // x for min, y for max, zw unused.
	vec4 ambientColor;
	vec4 sunlightDirection; // w for sun power
	vec4 sunlightColor;
} sceneData;

layout(set = 0, binding = 2) uniform sampler2DShadow shadowSampler;
layout(set = 2, binding = 0) uniform sampler2D tex1;

// TODO: fill in shader

void main() {
	vec3 color = texture(tex1, texCoord).xyz * sceneData.ambientColor.xyz;
	outFragColor = vec4(color, 1.0);

	// TODO: dont do this
	outFragColor = vec4(0.8, 0.8, 0.4, 1.0);
}