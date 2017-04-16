//
//  Vertex.swift
//  GraphicsProject
//
// Mitchell Proulx
// 7660132

struct Vertex{
    
    var    x, y, z: Float               // position
    var r, g, b, a: Float               // color
    
    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a]          // returns values in strict order
    }
}
