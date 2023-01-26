#version 330 core

// Input vertex data, different for all executions of this shader.
layout(location = 0) in vec3 vertexPosition_modelspace;
layout(location = 1) in vec2 vertexUV;
layout(location = 2) in vec3 vertexNormal_modelspace;

// Output data ; will be interpolated for each fragment.
out vec2 UV;
out vec3 Position_modelspace;
out vec3 Normal_modelspace;

// Values that stay constant for the whole mesh.
uniform mat3 M3x3;

void main(){
	UV = vertexUV;
	Position_modelspace = vertexPosition_modelspace;
	Normal_modelspace = vertexNormal_modelspace;
	gl_Position = vec4( vertexPosition_modelspace, 1.);
}

