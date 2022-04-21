#version 450

layout (location = 0) out vec4 outFragColor;

layout (location = 0) in vec3 inColor;
layout (location = 1) in vec2 texCoord;
layout (location = 2) in vec3 inNormal;
layout (location = 3) in vec4 inShadowCoord;

layout (set = 0, binding = 1) uniform SceneData {
    vec4 fogColor; // w is for exponent
	vec4 fogDistances; // x for min, y for max, zw unused.
	vec4 ambientColor;
	vec4 sunlightDirection; // w for sun power
	vec4 sunlightColor;
} sceneData;

// layout (set = 0, binding = 2) uniform sampler2DShadow shadowSampler;
layout (set = 0, binding = 2) uniform sampler2D shadowSampler;
layout (set = 2, binding = 0) uniform sampler2D tex1;


float textureProj(vec4 P, vec2 offset) {
	float shadow = 1.0;
	vec4 shadowCoord = P / P.w;
	shadowCoord.st = shadowCoord.st * 0.5 + 0.5;
	
	if (shadowCoord.z > -1.0 && shadowCoord.z < 1.0) {
		vec3 sc = vec3(vec2(shadowCoord.st + offset), shadowCoord.z);
		// shadow = texture(shadowSampler, sc);
		shadow = texture(shadowSampler, shadowCoord.st + offset).r;
	}
	return shadow;
}

// 9 imad (+ 6 iops with final shuffle)
uvec3 pcg3d(uvec3 v) {
    v = v * 1664525u + 1013904223u;

    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;

    v ^= v >> 16u;

    v.x += v.y * v.z;
    v.y += v.z * v.x;
    v.z += v.x * v.y;

    return v;
}

float filterPCF(vec4 sc) {
	ivec2 texDim = textureSize(shadowSampler, 0);
	float scale = 2;
	float dx = scale * 1.0 / float(texDim.x);
	float dy = scale * 1.0 / float(texDim.y);

	float shadowFactor = 0.0;
	int count = 0;
	int range = 2;

	vec2 s = gl_FragCoord.xy;
	
	uvec4 u = uvec4(s, uint(s.x) ^ uint(s.y), uint(s.x) + uint(s.y));
    vec3 rand = pcg3d(u.xyz);//vec3(1,0,0);//
	rand = normalize(rand);


	//sc.x += dx * rand.z;
    //sc.y += dy * rand.y;
	vec2 dirA = normalize(rand.xy);
	vec2 dirB = normalize(vec2(-dirA.y, dirA.x));
	
	dirA *= dx;
	dirB *= dy;
	for (int x = -range; x <= range; x++) {
		for (int y = -range; y <= range; y++) {
			shadowFactor += textureProj(sc, dirA * x + dirB * y);
			count++;
		}	
	}
	return shadowFactor / count;
}

// https://github.com/SaschaWillems/Vulkan/blob/master/data/shaders/glsl/shadowmapping/scene.frag
float textureProj2(vec4 shadowCoord, vec2 off) {
	float shadow = 1.0;

	shadowCoord.st = shadowCoord.st * 0.5 + 0.5;
	if (shadowCoord.z > -1.0 && shadowCoord.z < 1.0) {
		float dist = texture(shadowSampler, shadowCoord.st + off).r;//texture(shadowSampler, vec3(vec2(shadowCoord.st + off), shadowCoord.z));
		if (shadowCoord.w > 0.0 && dist < shadowCoord.z) 
			shadow = 0.1; // #define ambient 0.1
	}
	return shadow;
}

float filterPCF2(vec4 sc) {
	ivec2 texDim = textureSize(shadowSampler, 0);
	float scale = 1.5;
	float dx = scale * 1.0 / float(texDim.x);
	float dy = scale * 1.0 / float(texDim.y);

	float shadowFactor = 0.0;
	int count = 0;
	int range = 1;
	
	for (int x = -range; x <= range; x++) {
		for (int y = -range; y <= range; y++) {
			shadowFactor += textureProj2(sc, vec2(dx * x, dy * y));
			count++;
		}
	
	}
	return shadowFactor / count;
}

// https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping
float shadowCalculation(vec4 fragPosLightSpace) {
	// perform perspective divide
	vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;

	// transform to [0,1] range
	projCoords.xy = projCoords.xy * 0.5 + 0.5;

	// get closest depth value from light's perspective (using [0,1] range fragPosLight as coords)
	float closestDepth = texture(shadowSampler, projCoords.xy).r;

	// get depth of current fragment from light's perspective
	float currentDepth = projCoords.z;

	float bias = 0.005;
	float shadow = currentDepth - bias > closestDepth  ? 0.8 : 0.0;

	return shadow;
}


void main() {
	vec3 color = texture(tex1, texCoord).xyz;
	float lightAngle = clamp(dot(inNormal, -sceneData.sunlightDirection.xyz), 0.f, 1.f);

	float shadow = 0;
	if (sceneData.sunlightColor.w > 0.01)
		shadow = 1;
	else if (lightAngle > 0.01) // only attempt shadowsample in normals that point towards light
		shadow = mix(0.0f, 1.0f, filterPCF(inShadowCoord / inShadowCoord.w));

	vec3 lightColor = sceneData.sunlightColor.xyz * lightAngle;
	vec3 ambient = color * sceneData.ambientColor.xyz;
	vec3 diffuse = lightColor * color * shadow;

	// TODO: should ambient be multipled by some small value to tone it down?
	// from learn opengl
	// ambient = 0.15 * lightColor
	// (ambient + (1.0 - shadow) * (diffuse + specular)) * color;
	outFragColor = vec4(diffuse + ambient * 0.2, texture(tex1, texCoord).a);


	vec2 shadowUV = inShadowCoord.st * 0.5 + 0.5;
	shadow = textureProj2(inShadowCoord / inShadowCoord.w, vec2(0.0));
	shadow = filterPCF2(inShadowCoord / inShadowCoord.w);

	// shadow = texture(shadowSampler, inShadowCoord.st).r < inShadowCoord.z ? 0.5 : 1.0;
	// outFragColor = vec4(shadow_r, shadow_r, shadow_r, 1);



	shadow = 0;
	if (lightAngle > 0.01)
		shadow = shadowCalculation(inShadowCoord);
	// shadow = 1.0 - textureProj2(inShadowCoord / inShadowCoord.w, vec2(0.0));
	// shadow = 1.0 - textureProj2(inShadowCoord / inShadowCoord.w, vec2(0.0));
	// if (lightAngle > 0.01)
		shadow = mix(0.8f, 0.0f, filterPCF2(inShadowCoord / inShadowCoord.w));
		
	// outFragColor = vec4(color * (1.0 - shadow), 1);
	shadow = filterPCF2(inShadowCoord / inShadowCoord.w);
	// shadow = shadowCalculation(inShadowCoord);

	vec3 N = normalize(inNormal);
	vec3 L = normalize(sceneData.sunlightDirection.xyz);
	vec3 diffuse2 = max(dot(N, L), 0.1 /* ambient define from above */) * color;

	outFragColor = vec4(diffuse2 * shadow * lightAngle, 1.0);
}