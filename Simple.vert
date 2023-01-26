#version 330 core

// Input vertex data, different for all executions of this shader.
layout(location = 0) in vec3 vertexPosition_modelspace;
layout(location = 1) in vec2 vertexUV;
layout(location = 2) in vec3 vertexNormal_modelspace;

// Output data ; will be interpolated for each fragment.
out vec2 UV;
out vec3 Position_worldspace;
out vec3 EyeDirection_cameraspace;
out vec3 LightDirection_cameraspace;
out vec3 Normal_cameraspace;
out vec3 Normal_worldspace;

out vec3 LightDirection_tangentspace;
out vec3 EyeDirection_tangentspace;

// Values that stay constant for the whole mesh.
uniform sampler2D HeightMapTextureSampler;
uniform vec2 HeightMapData;
uniform mat4 MVP;
uniform mat4 V;
uniform mat4 M;
uniform mat3 M3x3;
uniform mat3 MV3x3;
uniform vec3 LightPosition_worldspace;


float getVertexHeight(vec2 vertexUV){
	// Get texture colour from HeightMap.
	vec4 HeightMapTextureColour = texture(HeightMapTextureSampler, vertexUV);
	float vertexHeight = (HeightMapTextureColour.r * 256 * 256) + (HeightMapTextureColour.g * 256) + (HeightMapTextureColour.b);
	return vertexHeight / 256;
}

vec3 calcNormal(vec2 vertexUV){

	float mulitplier = HeightMapData.x;
	vec2 vertexUVLeft = vec2(vertexUV.x - 1 / mulitplier, vertexUV.y);
	vec2 vertexUVRight = vec2(vertexUV.x + 1 / mulitplier, vertexUV.y);
	vec2 vertexUVUp = vec2(vertexUV.x, vertexUV.y + 1 / mulitplier);
	vec2 vertexUVDown = vec2(vertexUV.x, vertexUV.y - 1 / mulitplier);
	vec2 vertexUVUpLeft = vec2(vertexUV.x - 1 / mulitplier, vertexUV.y + 1 / mulitplier);
	vec2 vertexUVUpRight = vec2(vertexUV.x + 1 / mulitplier, vertexUV.y + 1 / mulitplier);
	vec2 vertexUVDownLeft = vec2(vertexUV.x - 1 / mulitplier, vertexUV.y - 1 / mulitplier);
	vec2 vertexUVDownRight = vec2(vertexUV.x + 1 / mulitplier, vertexUV.y - 1 / mulitplier);

//average
	float normalx = (getVertexHeight(vertexUVLeft) - getVertexHeight(vertexUVRight) + getVertexHeight(vertexUVUpLeft) - 
		getVertexHeight(vertexUVUpRight) + getVertexHeight(vertexUVDownLeft) - getVertexHeight(vertexUVDownRight))/3;
	float normalz = (getVertexHeight(vertexUVUp) - getVertexHeight(vertexUVDown) + getVertexHeight(vertexUVUpLeft) - 
		getVertexHeight(vertexUVDownLeft) + getVertexHeight(vertexUVUpRight) - getVertexHeight(vertexUVDownRight))/3;	

	return vec3(normalx, vertexNormal_modelspace.y , normalz);//getVertexHeight(vertexUV)
}

void main(){

	// Get texture colour from HeightMap.
	
	vec3 vertexPosition_modelspaceHeight = vec3(vertexPosition_modelspace.x, getVertexHeight(vertexUV), vertexPosition_modelspace.z);
	
	vec3 normal_height = calcNormal(vertexUV);


	//Idk how the normal thing works.
	//vec3 vertexNormal_modelspaceHeight.x = ;
	//vertexPosition_modelspaceHeight = vertexPosition_modelspace;
	// Output position of the vertex, in clip space : MVP * position
	gl_Position =  MVP * vec4(vertexPosition_modelspaceHeight,1);
	
	// Position of the vertex, in worldspace : M * position
	Position_worldspace = (M * vec4(vertexPosition_modelspaceHeight,1)).xyz;
	
	// Vector that goes from the vertex to the camera, in camera space.
	// In camera space, the camera is at the origin (0,0,0).
	vec3 vertexPosition_cameraspace = ( V * M * vec4(vertexPosition_modelspaceHeight,1)).xyz;
	EyeDirection_cameraspace = vec3(0,0,0) - vertexPosition_cameraspace;

	// Vector that goes from the vertex to the light, in camera space. M is ommited because it's identity.
	vec3 LightPosition_cameraspace = ( V * vec4(LightPosition_worldspace,1)).xyz;
	LightDirection_cameraspace = -LightPosition_cameraspace;// + EyeDirection_cameraspace;
	
	// UV of the vertex. No special space for this one.
	UV = vertexUV;
	
	Normal_worldspace = normal_height;
	// model to camera = ModelView
	Normal_cameraspace = MV3x3 * normal_height;
	
	
}

