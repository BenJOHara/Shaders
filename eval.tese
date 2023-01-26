#version 410 core

layout (quads, fractional_odd_spacing, ccw) in;


in vec2 UV_tess[];
in vec3 Position_modelspace_tess[];
in vec3 Normal_modelspace_tess[];

out vec2 UV;
out vec3 Position_worldspace;
out vec3 EyeDirection_cameraspace;
out vec3 LightDirection_cameraspace;
out vec3 Normal_cameraspace;


//out vec3 LightDirection_tangentspace;
//out vec3 EyeDirection_tangentspace;

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
	// Get vertex height from HeightMap.
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

	return vec3(normalx, 1 , normalz);//getVertexHeight(vertexUV)
}

void main(){
    //coords of the current vertex
    float u = gl_TessCoord.x;
    float v = gl_TessCoord.y;

    vec2 uv0 = UV_tess[0];//need to make this my own stole it
    vec2 uv1 = UV_tess[1];
    vec2 uv2 = UV_tess[2];
    vec2 uv3 = UV_tess[3];

    vec2 leftUV = uv0 + v * (uv3 - uv0);
    vec2 rightUV = uv1 + v * (uv2 - uv1);
    vec2 texCoord = leftUV + u * (rightUV - leftUV);

    vec4 pos0 = gl_in[0].gl_Position;
    vec4 pos1 = gl_in[1].gl_Position;
    vec4 pos2 = gl_in[2].gl_Position;
    vec4 pos3 = gl_in[3].gl_Position;

    vec4 leftPos = pos0 + v * (pos3 - pos0);
    vec4 rightPos = pos1 + v * (pos2 - pos1);
    vec4 pos = leftPos + u * (rightPos - leftPos);

    float height =  getVertexHeight(texCoord);

    pos.y = height;

    gl_Position = MVP * pos; // Matrix transformations go here
    Position_worldspace = pos.xyz;
    
	vec3 vertexPosition_cameraspace = ( V * M * vec4( pos.x, getVertexHeight(texCoord),pos.z,1)).xyz;
	EyeDirection_cameraspace = vec3(0,0,0) - vertexPosition_cameraspace;
    
    
	vec3 LightPosition_cameraspace = ( V * vec4(LightPosition_worldspace,1)).xyz;
	LightDirection_cameraspace = -LightPosition_cameraspace;// + EyeDirection_cameraspace;

    vec3 normal_height = calcNormal(texCoord);
    Normal_cameraspace = MV3x3 * normal_height;
    UV = texCoord;
}
        