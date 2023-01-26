#version 330 core

// Interpolated values from the vertex shaders
in vec2 UV;
in vec3 Position_worldspace;
in vec3 EyeDirection_cameraspace;
in vec3 LightDirection_cameraspace;
in vec3 Normal_cameraspace;
in vec3 Normal_worldspace;

// Ouput data
out vec3 color;

// Values that stay constant for the whole mesh.
uniform sampler2D DiffuseTextureSampler;
uniform sampler2D SnowTextureSampler;
uniform sampler2D RockTextureSampler;
uniform sampler2D GrassTextureSampler;
uniform sampler2D SnowSTextureSampler;
uniform sampler2D RockSTextureSampler;
uniform sampler2D GrassSTextureSampler;
uniform mat4 V;
uniform mat4 M;
uniform mat3 MV3x3;
uniform vec3 LightPosition_worldspace;


int isGRS(float y){//make it less harsh somehow

	float nY = normalize( Normal_worldspace).y;//normal cacluation not working
	if(y > 30 || nY > 0.9){//
		return 2;//snow
	}
	else if(y > 17 ||nY > 0.7){//
		return 1;//rock
	}
	else{
		return 0;//grass
	}
}

void main(){

	int GRS = isGRS(Position_worldspace.y);


	// Some properties
	// should put them as uniforms
	vec3 LightColor = vec3(1,1,1);
	float LightPower = 1.0;
	float shininess = 1;

	// Material properties
	vec3 MaterialDiffuseColor = texture( DiffuseTextureSampler,vec2(UV.x,UV.y)).rgb;

	if (GRS == 0)
	{
		MaterialDiffuseColor = texture( GrassTextureSampler,vec2(UV.x,UV.y)).rgb;
	}
	else if (GRS == 1)
	{
		MaterialDiffuseColor = texture( RockTextureSampler,vec2(UV.x,UV.y)).rgb;
	}
	else if (GRS == 2)
	{
		MaterialDiffuseColor = texture( SnowTextureSampler,vec2(UV.x,UV.y)).rgb;
	}

	vec3 MaterialAmbientColor = vec3(0.1,0.1,0.1) * MaterialDiffuseColor;
	vec3 MaterialSpecularColor = vec3(1,1,1);

	if (GRS == 0)
	{
		MaterialSpecularColor = texture( GrassSTextureSampler,vec2(UV.x,UV.y)).rgb;
	}
	else if (GRS == 1)
	{
		MaterialSpecularColor = texture( RockSTextureSampler,vec2(UV.x,UV.y)).rgb;
	}
	else if (GRS == 2)
	{
		MaterialSpecularColor = texture( SnowSTextureSampler,vec2(UV.x,UV.y)).rgb;
	}

	// Distance to the light
	//float distance = length( LightPosition_worldspace - Position_worldspace );

	// Normal of the computed fragment, in camera space
	vec3 n = Normal_cameraspace;
	// Direction of the light (from the fragment to the light)
	vec3 l = normalize(LightDirection_cameraspace);
	vec3 e = normalize(EyeDirection_cameraspace);

	//Diffuse
	float cosTheta = clamp( dot( n,l ), 0,1 );
	vec3 diffuse = MaterialDiffuseColor * LightColor * LightPower * cosTheta ;// (distance*distance) ;
	
	//Specular
	// Eye vector (towards the camera)
	vec3 E = normalize(EyeDirection_cameraspace);
	// Direction in which the triangle reflects the light
	vec3 B = normalize(l + e);

	float cosB = clamp(dot(n,B),0,1);
	cosB = clamp(pow(cosB,shininess),0,1);
	cosB = cosB * cosTheta * (shininess+2)/(2*radians(180.0f));
	vec3 specular = MaterialSpecularColor *LightPower*cosB;//(distance*distance);
	
	color = 
		// Ambient : simulates indirect lighting
		MaterialAmbientColor +
		// Diffuse : "color" of the object
		diffuse +
		specular;
		// Specular : reflective highlight, like a mirror

}