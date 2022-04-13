#version 450

layout (location = 0) out vec4 outFragColor;

layout (location = 0) in vec3 inColor;
layout (location = 1) in vec2 texCoord;
// layout (location = 2) in vec3 inNormal;
// layout (location = 3) in vec4 inShadowCoord;

layout (set = 0, binding = 1) uniform SceneData {
    vec4 fogColor; // w is for exponent
	vec4 fogDistances; // x for min, y for max, zw unused.
	vec4 ambientColor;
	vec4 sunlightDirection; // w for sun power
	vec4 sunlightColor;
} sceneData;

layout (set = 0, binding = 2) uniform sampler2DShadow shadowSampler;
layout (set = 2, binding = 0) uniform sampler2D tex1;


void main() {
	vec3 inNormal = vec3(1.0);
	
	vec3 color = texture(tex1, texCoord).xyz;
	float lightAngle = clamp(dot(inNormal, -sceneData.sunlightDirection.xyz), 0.f, 1.f);

	// TODO: handle shadow sampling

	vec3 lightColor = sceneData.sunlightColor.xyz * lightAngle;
	vec3 ambient = color * sceneData.ambientColor.xyz;
	vec3 diffuse = lightColor * color;

	outFragColor = vec4(diffuse + ambient, texture(tex1, texCoord).a);


	// vec3 color = texture(tex1, texCoord).xyz * sceneData.ambientColor.xyz;
	// outFragColor = vec4(color, 1.0);
}