//
//  Node.swift
//  GraphicsProject
//
// Mitchell Proulx
// 7660132
//

import Foundation
import Metal
import QuartzCore

class Node {
    
    let device: MTLDevice
    let name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    var time:CFTimeInterval = 0.0
    
    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0
    
    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale:     Float = 1.0
    
    init(name: String, vertices: Array<Vertex>, device: MTLDevice){

        var vertexData = Array<Float>()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        self.name = name
        self.device = device
        vertexCount = vertices.count
    }
    
    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, parentModelViewMatrix: Matrix4, projectionMatrix: Matrix4, clearColor: MTLClearColor?) {
    
        // configures which texture is being rendered to, what the clear color is
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor =
            MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commandQueue.makeCommandBuffer() // contains 1 or more render commands
        
        // telling the GPU to draw a set of triangles based on the vertex buffer
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder.setCullMode(MTLCullMode.front)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)

        let nodeModelMatrix = self.modelMatrix()
        nodeModelMatrix.multiply(left: parentModelViewMatrix)
        
        // create a buffer with shared CPU/GPU memory
        let uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * nodeModelMatrix.numElements * 2, options: [])
        let bufferPointer = uniformBuffer.contents()
        
        // copy matrix data into the buffer
        memcpy(bufferPointer, nodeModelMatrix.raw, MemoryLayout<Float>.size * nodeModelMatrix.numElements)
        memcpy(bufferPointer + MemoryLayout<Float>.size * nodeModelMatrix.numElements, projectionMatrix.raw, MemoryLayout<Float>.size * nodeModelMatrix.numElements)
        
        // pass copied data to the vertex buffer
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
        renderEncoder.endEncoding()
        
        // commit the commands
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func modelMatrix() -> Matrix4 {
        let matrix = Matrix4()
        matrix.translate(x: positionX, y: positionY, z: positionZ)
        matrix.rotateAround(x: rotationX, y: rotationY, z: rotationZ)
        matrix.scale(x: scale, y: scale, z: scale)
        return matrix
    }
    
    func updateWithDelta(delta: CFTimeInterval){
        time += delta
    }
}
