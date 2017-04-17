//
//  ViewController.swift
//  GraphicsProject
//
// Mitchell Proulx
// 7660132
//

import UIKit
import Metal

class ViewController: UIViewController {

    var device: MTLDevice!                      // direct connection to the GPU
    var metalLayer: CAMetalLayer!               // for drawing to the screen
    var pipelineState: MTLRenderPipelineState!  // keeps track of compiled render pipeline
    var commandQueue: MTLCommandQueue!          // ordered list of commands sent to the GPU
    var timer: CADisplayLink!                   // called everytime device screen refreshes
    var projectionMatrix: Matrix4!
    var lastFrameTimestamp: CFTimeInterval = 0.0
    
    //var objectToDraw: Triangle!
    var objectToDraw: Cube!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice() // for access to the GPU
        
        // load projectionMatrix
        projectionMatrix = Matrix4.makePerspectiveView(
            angle: Float(85).radians,
            aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height),
            nearZ: 0.01,
            farZ: 100.0)
        
        metalLayer = CAMetalLayer()             // for drawing to screen
        metalLayer.framebufferOnly = true       // apple recommends for perfomance issues
        metalLayer.pixelFormat = .bgra8Unorm    // 8 bytes for blue, green, red, alpha (normalized 0-1)
        metalLayer.frame = view.layer.frame     // set frame of the layerto match the frame of the view
        metalLayer.device = device              // specify the device the layer should use
        
        // add new layer as a sub layer
        view.layer.addSublayer(metalLayer)
        
        //objectToDraw = Triangle(device: device)
        objectToDraw = Cube(device: device)

        // access any of the precompiled shaders in the project (MTLLibrary)
        let mtlDefaultLibrary = device.newDefaultLibrary()!
        let fragShader_Program = mtlDefaultLibrary.makeFunction(name: "shade_fragment")
        let vertShader_Program = mtlDefaultLibrary.makeFunction(name: "shade_vertex")
        
        // set up render pipeline with vertex & fragement shaders
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertShader_Program
        pipelineStateDescriptor.fragmentFunction = fragShader_Program
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // compile pipeline configuration
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        // tell GPU to execute commands
        commandQueue = device.makeCommandQueue()
        
        // app will call gameloop() when screen refreshes
        timer = CADisplayLink(target: self, selector: #selector(ViewController.gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        
    }
    
    func render() {
        guard let drawable = metalLayer?.nextDrawable() else { return }
        let worldModelMatrix = Matrix4()
        worldModelMatrix.translate(x: 0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAround(x: Float(20).radians, y: 0.0, z: 0.0)
        
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix ,clearColor: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 1
    func newFrame(displayLink: CADisplayLink){
        
        if lastFrameTimestamp == 0.0
        {
            lastFrameTimestamp = displayLink.timestamp
        }
        
        // 2
        let elapsed: CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
        lastFrameTimestamp = displayLink.timestamp
        
        // 3
        gameloop(timeSinceLastUpdate: elapsed)
    }
    
    func gameloop(timeSinceLastUpdate: CFTimeInterval) {
        
        // 4
        objectToDraw.updateWithDelta(delta: timeSinceLastUpdate)
        
        // 5
        autoreleasepool {
            self.render()
        }
    }
}
