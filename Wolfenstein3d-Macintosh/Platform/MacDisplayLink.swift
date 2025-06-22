//
//  MacDisplayLink.swift
//  Wolfenstein3d-Macintosh
//
//  Created by Tornike Gomareli on 24.05.25.
//

import Foundation
import CoreVideo
import Engine

/// macOS implementation of DisplayLink protocol using CVDisplayLink
class MacDisplayLink: DisplayLink {
    private var displayLink: CVDisplayLink?
    private weak var target: AnyObject?
    private var selector: Selector?
    
    var preferredFramesPerSecond: Int = 60 {
        didSet {
            // Note: CVDisplayLink runs at display refresh rate
            // Frame skipping would need to be implemented if lower FPS is desired
        }
    }
    
    deinit {
        invalidate()
    }
    
    func start(target: Any, selector: Selector) {
        self.target = target as AnyObject
        self.selector = selector
        
        let displayLinkCallback: CVDisplayLinkOutputCallback = { (displayLink, inNow, inOutputTime, flagsIn, flagsOut, displayLinkContext) in
            let context = unsafeBitCast(displayLinkContext, to: MacDisplayLink.self)
            
            // Call directly on display thread for better performance
            if let target = context.target,
               let selector = context.selector {
                _ = target.perform(selector)
            }
            
            return kCVReturnSuccess
        }
        
        CVDisplayLinkCreateWithActiveCGDisplays(&displayLink)
        
        if let displayLink = displayLink {
            CVDisplayLinkSetOutputCallback(displayLink, displayLinkCallback, Unmanaged.passUnretained(self).toOpaque())
            CVDisplayLinkStart(displayLink)
        }
    }
    
    func invalidate() {
        if let displayLink = displayLink {
            CVDisplayLinkStop(displayLink)
            self.displayLink = nil
        }
        target = nil
        selector = nil
    }
    
    func setPaused(_ paused: Bool) {
        guard let displayLink = displayLink else { return }
        
        if paused {
            CVDisplayLinkStop(displayLink)
        } else {
            CVDisplayLinkStart(displayLink)
        }
    }
}