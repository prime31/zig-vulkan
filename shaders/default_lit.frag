#version 450

layout (location = 0) out vec4 outFragColor;

layout (location = 0) in vec3 inColor;
layout (location = 1) in vec2 texCoord;
layout (location = 2) in vec3 inNormal;
layout (location = 3) in vec3 inWorldPos;
layout (location = 4) in vec4 inShadowCoord;

layout (set = 0, binding = 1) uniform SceneData {
	vec4 cameraPos;
    vec4 fogColor; // w is for exponent
	vec4 fogDistances; // x for min, y for max, zw unused.
	vec4 ambientColor;
	vec4 sunlightDirection; // w for sun power
	vec4 sunlightColor;
} sceneData;

layout (set = 0, binding = 2) uniform sampler2DShadow shadowSampler;


void main() {
	float lightAngle = clamp(dot(inNormal, -sceneData.sunlightDirection.xyz), 0.f, 1.f);

	vec3 lightColor = sceneData.sunlightColor.xyz * lightAngle;
	vec3 ambient = inColor.rgb * sceneData.ambientColor.xyz;
	vec3 diffuse = lightColor * inColor.rgb;

	outFragColor = vec4(diffuse + ambient, 1);
}