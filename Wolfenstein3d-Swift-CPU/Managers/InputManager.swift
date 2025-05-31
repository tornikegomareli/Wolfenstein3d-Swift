// Managers/InputManager.swift
import UIKit

class InputManager: InputProviderProtocol {
  // MARK: - Properties
  
  weak var delegate: InputHandlerProtocol?
  
  private var moveX: CGFloat = 0
  private var moveY: CGFloat = 0
  private var isMoving = false
  
  // MARK: - Public Methods
  
  func processJoystickInput(x: CGFloat, y: CGFloat) {
    moveX = x
    moveY = y
    isMoving = abs(x) > GameConfig.Input.joystickDeadzone ||
    abs(y) > GameConfig.Input.joystickDeadzone
    
    if isMoving {
      // Y is inverted: joystick up = negative Y, but forward = positive
      delegate?.handleMovement(forward: Double(-moveY), strafe: Double(moveX))
    }
  }
  
  func joystickReleased() {
    moveX = 0
    moveY = 0
    isMoving = false
    // Reset movement when joystick is released
    delegate?.handleMovement(forward: 0, strafe: 0)
  }
  
  func processGyroscopeRotation(angle: Double) {
    if abs(angle) > GameConfig.Input.gyroThreshold {
      delegate?.handleRotation(angle: angle * GameConfig.Input.gyroSensitivity)
    }
  }
  
  func processTouchLook(deltaX: CGFloat, deltaY: CGFloat) {
    // Convert touch delta to rotation
    // Horizontal movement rotates the player
    if abs(deltaX) > 0 {
      delegate?.handleRotation(angle: Double(deltaX))
    }
    
    // Note: deltaY could be used for vertical look if implementing full 3D look
    // For now, Wolfenstein 3D style only uses horizontal rotation
  }
  
  // MARK: - State Queries
  
  func isPlayerMoving() -> Bool {
    return isMoving
  }
  
  func getCurrentMovement() -> (x: CGFloat, y: CGFloat) {
    return (moveX, moveY)
  }
}
