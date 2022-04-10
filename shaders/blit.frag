#version 450

layout (set = 0, binding = 0) uniform sampler2D tex;

layout (location = 0) in vec2 inUV;
layout (location = 0) out vec4 outFragColor;


void main()  {
	outFragColor = texture(tex, inUV);
}

