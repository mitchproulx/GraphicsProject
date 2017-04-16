//
//  ViewController.swift
//  GraphicsProject
//
// Mitchell Proulx
// 7660132

import UIKit
import Metal

class ViewController: UIViewController {

    var device: MTLDevice!                      // direct connection to the GPU
    var metalLayer: CAMetalLayer!               // for drawing to the screen
    var pipelineState: MTLRenderPipelineState!  // keeps track of compiled render pipeline
    var commandQueue: MTLCommandQueue!          // ordered list of commands sent to the GPU
    var timer: CADisplayLink!                   // called everytime device screen refreshes
    
    var objectToDraw: Triangle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice() // for access to the GPU
        metalLayer = CAMetalLayer()             // for drawing to screen
        
        metalLayer.framebufferOnly = true       // apple recommends for perfomance issues
        metalLayer.pixelFormat = .bgra8Unorm    // 8 bytes for blue, green, red, alpha (normalized 0-1)
        metalLayer.frame = view.layer.frame     // set frame of the layerto match the frame of the view
        metalLayer.device = device              // specify the device the layer should use
        
        // add layer as a sublayer
        view.layer.addSublayer(metalLayer)
        
        // get the object
        objectToDraw = Triangle(device: device)
        
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
    
    func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
    
    func render() {
        guard let drawable = metalLayer?.nextDrawable() else { return }
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, clearColor: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

