//
//  Shaders.metal
//  GraphicsProject
//
// Mitchell Proulx
// 7660132

/* 
 - You can include multiple shaders in a single Metal file.
 - You can also split your shaders across multiple Metal files
 - Shaders are precompiled
*/

#include <metal_stdlib>
using namespace metal;

struct VertexIn{
    packed_float3 position;
    packed_float4 color;
};

struct VertexOut{
    float4 position [[position]];
    float4 color;
};

vertex VertexOut shade_vertex(const device VertexIn* vertex_array [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
    
    VertexIn VertexIn = vertex_array[vid];
    
    VertexOut VertexOut;
    VertexOut.position = float4(VertexIn.position,1);
    VertexOut.color = VertexIn.color;
    
    return VertexOut;
}

fragment half4 shade_fragment(VertexOut interpolated [[stage_in]]) {
    return half4(interpolated.color[0], interpolated.color[1], interpolated.color[2], interpolated.color[3]);
}
