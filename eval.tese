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
out vec3 Normal_worldspace;


//out vec3 LightDirection_tangentspace;
//out vec3 EyeDirection_tangentspace;

// Values that stay constant for the whole mesh.
uniform sampler2D HeightMapTextureSampler;
uniform int HeightMapWidth;
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

vec3 calcNormal(vec2 vertexUV){//estimate normal from heightmap

	float mulitplier = HeightMapWidth / 128 ;
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

    //normalx = getVertexHeight(vertexUVLeft) - getVertexHeight(vertexUVRight);
    //normalz = getVertexHeight(vertexUVUp) - getVertexHeight(vertexUVDown);

	return normalize( vec3(normalx, 1 , normalz));//getVertexHeight(vertexUV)
}

void main(){
    //coords of the current vertex
    

    //interpolate to find values at xy 
    float x = gl_TessCoord.x;
    float y = gl_TessCoord.y;


    vec2 uvTL = UV_tess[0];
    vec2 uvTR = UV_tess[1];
    vec2 uvBR = UV_tess[2];
    vec2 uvBL = UV_tess[3];


    //find uv at xy
    vec2 uv = mix(mix(uvTL, uvBL, y), mix(uvTR, uvBR, y), x);

    vec4 pos0 = gl_in[0].gl_Position;
    vec4 pos1 = gl_in[1].gl_Position;
    vec4 pos2 = gl_in[2].gl_Position;
    vec4 pos3 = gl_in[3].gl_Position;

    //find  position at xy
    vec4 pos = mix(mix(pos0, pos3, y), mix(pos1, pos2, y), x);
    
    float height =  getVertexHeight(uv);

    pos.y = height;


    //set everything ready for fragment shader
    gl_Position = MVP * pos; // Matrix transformations go here
    Position_worldspace = pos.xyz;
    
	vec3 vertexPosition_cameraspace = ( V * M * vec4( pos.x, getVertexHeight(uv),pos.z,1)).xyz;
	EyeDirection_cameraspace = vec3(0,0,0) - vertexPosition_cameraspace;
    
	vec3 LightPosition_cameraspace = ( V * vec4(LightPosition_worldspace,1)).xyz;
	LightDirection_cameraspace = -LightPosition_cameraspace;// + EyeDirection_cameraspace;

    vec3 normal_height = calcNormal(uv);
    Normal_worldspace = normal_height;
    Normal_cameraspace = MV3x3 * normal_height;
    UV = uv;
}
        