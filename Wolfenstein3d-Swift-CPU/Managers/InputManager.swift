import UIKit
import Engine

class InputManager: InputProviderProtocol {
  weak var delegate: InputHandlerProtocol?
  
  private var moveX: CGFloat = 0
  private var moveY: CGFloat = 0
  private var isMoving = false
  
  func processJoystickInput(x: CGFloat, y: CGFloat) {
    moveX = x
    moveY = y
    isMoving = abs(x) > CGFloat(GameConfig.Input.joystickDeadzone) ||
    abs(y) > CGFloat(GameConfig.Input.joystickDeadzone)
    
    if isMoving {
      delegate?.handleMovement(forward: Double(-moveY), strafe: Double(moveX))
    }
  }
  
  func joystickReleased() {
    moveX = 0
    moveY = 0
    isMoving = false
    delegate?.handleMovement(forward: 0, strafe: 0)
  }
  
  func processGyroscopeRotation(angle: Double) {
    if abs(angle) > GameConfig.Input.gyroThreshold {
      delegate?.handleRotation(angle: angle * GameConfig.Input.gyroSensitivity)
    }
  }
  
  func processTouchLook(deltaX: CGFloat, deltaY: CGFloat) {
    if abs(deltaX) > 0 {
      delegate?.handleRotation(angle: Double(deltaX))
    }
    
  }
  
  func isPlayerMoving() -> Bool {
    return isMoving
  }
  
  func getCurrentMovement() -> (x: CGFloat, y: CGFloat) {
    return (moveX, moveY)
  }
}
