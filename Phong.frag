#version 330 core

// Interpolated values from the vertex shaders
in vec2 UV;
in vec3 Position_worldspace;
in vec3 EyeDirection_cameraspace;
in vec3 LightDirection_cameraspace;
in vec3 Normal_cameraspace;
//in vec3 Normal_worldspace;

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


void main(){

	float GRS = Position_worldspace.y;


	// Some properties
	// should put them as uniforms
	vec3 LightColor = vec3(1,1,1);
	float LightPower = 1.0;
	float shininess = 1;

	// Material properties
	vec3 MaterialDiffuseColor = texture( DiffuseTextureSampler,vec2(UV.x,UV.y)).rgb;
	vec3 MaterialSpecularColor = vec3(1,1,1);
	float mulitplier = 10;//Idk how to do tiling

	if (GRS > 23 )//sampling texture way to big. 
	{
		MaterialDiffuseColor = texture( SnowTextureSampler,vec2(UV.x,UV.y)*mulitplier).rgb;
		MaterialSpecularColor = texture( SnowSTextureSampler,vec2(UV.x,UV.y)*mulitplier).rgb;
	}
	else if (GRS > 21)
	{
		float alpha = (GRS - 21) / 2;// this is a number between 0 and 1 when it is 1 it is close to snow
		MaterialDiffuseColor = mix(texture( RockTextureSampler,vec2(UV.x,UV.y)*mulitplier).rgb,texture( SnowTextureSampler,vec2(UV.x,UV.y)*mulitplier).rgb,alpha);
		MaterialSpecularColor = mix(texture( RockSTextureSampler,vec2(UV.x,UV.y)*mulitplier).rgb,texture( SnowSTextureSampler,vec2(UV.x,UV.y)*mulitplier).rgb,alpha);
	}
	else if (GRS > 12 )
	{
		MaterialDiffuseColor = texture( RockTextureSampler,vec2(UV.x,UV.y)*mulitplier).rgb;
		MaterialSpecularColor = texture( RockSTextureSampler,vec2(UV.x,UV.y)*mulitplier).rgb;
	}
	else if (GRS > 10)
	{
		float alpha = (GRS - 10) / 2;// this is a number between 0 and 1 when it is 1 it is close to snow
		MaterialDiffuseColor = mix(texture( GrassTextureSampler,vec2(UV.x,UV.y)*mulitplier).rgb,texture( RockTextureSampler,vec2(UV.x,UV.y)*mulitplier).rgb,alpha);
		MaterialSpecularColor = mix(texture( GrassSTextureSampler,vec2(UV.x,UV.y)*mulitplier).rgb,texture( RockSTextureSampler,vec2(UV.x,UV.y)*mulitplier).rgb,alpha);
	}
	else
	{
		MaterialDiffuseColor = texture( GrassTextureSampler,vec2(UV.x,UV.y)*mulitplier).rgb;
		MaterialSpecularColor = texture( GrassSTextureSampler,vec2(UV.x,UV.y)*mulitplier).rgb;
	}

	vec3 MaterialAmbientColor = vec3(0.1,0.1,0.1) * MaterialDiffuseColor;




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