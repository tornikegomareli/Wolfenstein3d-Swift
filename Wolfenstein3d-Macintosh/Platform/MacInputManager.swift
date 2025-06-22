//
//  MacInputManager.swift
//  Wolfenstein3d-Macintosh
//
//  Created by Tornike Gomareli on 24.05.25.
//

import AppKit
import Engine

class MacInputManager: InputProviderProtocol, InputSource {
    weak var delegate: InputHandlerProtocol?
    
    // Input state
    private var keysPressed = Set<UInt16>()
    private var mouseLocation: NSPoint = .zero
    private var isMouseLooking = false
    
    // Key codes
    private enum KeyCode: UInt16 {
        case w = 13
        case a = 0
        case s = 1
        case d = 2
        case up = 126
        case down = 125
        case left = 123
        case right = 124
        case shift = 56
        case space = 49
    }
    
    // InputSource protocol
    var movementVector: SIMD2<Float> {
        var forward: Float = 0
        var strafe: Float = 0
        
        // Forward/backward
        if keysPressed.contains(KeyCode.w.rawValue) || keysPressed.contains(KeyCode.up.rawValue) {
            forward = 1
        }
        if keysPressed.contains(KeyCode.s.rawValue) || keysPressed.contains(KeyCode.down.rawValue) {
            forward -= 1
        }
        
        // Strafe left/right
        if keysPressed.contains(KeyCode.a.rawValue) {
            strafe = -1
        }
        if keysPressed.contains(KeyCode.d.rawValue) {
            strafe = 1
        }
        
        return SIMD2<Float>(strafe, forward)
    }
    
    var rotationDelta: Float = 0
    
    var isInteracting: Bool {
        return !keysPressed.isEmpty || isMouseLooking
    }
    
    // MARK: - Keyboard Handling
    
    func keyDown(_ keyCode: UInt16) {
        keysPressed.insert(keyCode)
        updateMovement()
        
        // Handle rotation with arrow keys
        if keyCode == KeyCode.left.rawValue {
            delegate?.handleRotation(angle: -0.05)
        } else if keyCode == KeyCode.right.rawValue {
            delegate?.handleRotation(angle: 0.05)
        }
    }
    
    func keyUp(_ keyCode: UInt16) {
        keysPressed.remove(keyCode)
        updateMovement()
    }
    
    private func updateMovement() {
        let movement = movementVector
        delegate?.handleMovement(forward: Double(movement.y), strafe: Double(movement.x))
    }
    
    // MARK: - Mouse Handling
    
    func mouseDown(at location: NSPoint) {
        mouseLocation = location
        isMouseLooking = true
    }
    
    func mouseDragged(to location: NSPoint) {
        guard isMouseLooking else { return }
        
        let deltaX = location.x - mouseLocation.x
        mouseLocation = location
        
        // Convert mouse movement to rotation with higher sensitivity
        let sensitivity = 0.01
        delegate?.handleRotation(angle: Double(deltaX) * sensitivity)
    }
    
    func mouseUp() {
        isMouseLooking = false
    }
    
    func scrollWheel(deltaX: CGFloat, deltaY: CGFloat) {
        // Could be used for weapon switching or other actions
    }
}