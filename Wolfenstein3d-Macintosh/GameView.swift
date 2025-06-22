//
//  GameView.swift
//  Wolfenstein3d-Macintosh
//
//  Created by Tornike Gomareli on 24.05.25.
//

import AppKit
import Engine

class GameView: NSView {
    private var frameBuffer: FrameBuffer?
    private let bufferLock = NSLock()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        layer?.magnificationFilter = .nearest
        layer?.contentsGravity = .resize
        
        layerContentsRedrawPolicy = .duringViewResize
        canDrawConcurrently = true
    }
    
    func updateFrame(_ buffer: FrameBuffer) {
        bufferLock.lock()
        frameBuffer = buffer
        bufferLock.unlock()
        
        // Update display directly without scheduling
        updateDisplay()
    }
    
    private func updateDisplay() {
        guard let frameBuffer = frameBuffer,
              let layer = self.layer else { return }
        
        frameBuffer.withPixelBuffer { pixels, count in
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            
            // Create CGImage directly from buffer without copy
            guard let provider = CGDataProvider(dataInfo: nil,
                                               data: pixels,
                                               size: count * 4,
                                               releaseData: { _, _, _ in }) else { return }
            
            guard let cgImage = CGImage(width: frameBuffer.width,
                                       height: frameBuffer.height,
                                       bitsPerComponent: 8,
                                       bitsPerPixel: 32,
                                       bytesPerRow: frameBuffer.width * 4,
                                       space: colorSpace,
                                       bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo),
                                       provider: provider,
                                       decode: nil,
                                       shouldInterpolate: false,
                                       intent: .defaultIntent) else { return }
            
            // Update layer contents directly
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            if Thread.isMainThread {
                layer.contents = cgImage
            } else {
                DispatchQueue.main.sync {
                    layer.contents = cgImage
                }
            }
            CATransaction.commit()
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        // Do nothing - we're updating the layer directly
    }
    
    override func layout() {
        super.layout()
        // Layer automatically resizes with view
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
}