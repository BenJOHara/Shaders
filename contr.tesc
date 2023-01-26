#version 410 core

//Determine the amount of tessellation that a primitive should have.
//Perform any special transformations on the input patch data.

//basically: in 4 vertices, 
//out an amount of vertices determined by height map resolution
layout (vertices=4) out;

in vec2 UV[];//[32]
in vec3 Position_modelspace[];
in vec3 Normal_modelspace[];

out vec2 UV_tess[];
out vec3 Position_modelspace_tess[];
out vec3 Normal_modelspace_tess[];

uniform int HeightMapWidth;
uniform int HeightMapHeight;
uniform int numPoints;


void main(){
    
    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
    UV_tess[gl_InvocationID] = UV[gl_InvocationID];
    Position_modelspace_tess[gl_InvocationID] = Position_modelspace[gl_InvocationID];
    Normal_modelspace_tess[gl_InvocationID] = Normal_modelspace[gl_InvocationID];

    int res = HeightMapWidth*HeightMapHeight;

//need a point for every pixel in the height map, there are res pixels.
//starts with numPoints, so for each patch needs res/numpoints
// so res/numPoints = inner + outer

    int outer = min(32, max ( int(floor(res / (numPoints * numPoints * 10))), 1));//Limited to 8 cus my laptop is bad
    int inner = outer;

    gl_TessLevelOuter[0] = outer;//so nothing happens?
    gl_TessLevelOuter[1] = outer;
    gl_TessLevelOuter[2] = outer;
    gl_TessLevelOuter[3] = outer;
    gl_TessLevelInner[0] = inner;
    gl_TessLevelInner[1] = inner;

}