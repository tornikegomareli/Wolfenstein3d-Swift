import UIKit
import Engine

/// iOS implementation of DisplayLink protocol wrapping CADisplayLink
class IOSDisplayLink: DisplayLink {
    private var displayLink: CADisplayLink?
    
    var preferredFramesPerSecond: Int = 60 {
        didSet {
            displayLink?.preferredFramesPerSecond = preferredFramesPerSecond
        }
    }
    
    func start(target: Any, selector: Selector) {
        displayLink = CADisplayLink(target: target, selector: selector)
        displayLink?.preferredFramesPerSecond = preferredFramesPerSecond
        displayLink?.add(to: .current, forMode: .default)
    }
    
    func invalidate() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func setPaused(_ paused: Bool) {
        displayLink?.isPaused = paused
    }
}