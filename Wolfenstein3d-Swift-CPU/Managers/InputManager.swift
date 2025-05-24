//
//  InputManager.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 24.05.25.
//


import UIKit

class InputManager: InputProviderProtocol {
  
  weak var delegate: InputHandlerProtocol?
  
  private var moveX: CGFloat = 0
  private var moveY: CGFloat = 0
  private var isMoving = false
  
  
  func processJoystickInput(x: CGFloat, y: CGFloat) {
    moveX = x
    moveY = y
    isMoving = abs(x) > GameConfig.Input.joystickDeadzone ||
    abs(y) > GameConfig.Input.joystickDeadzone
    
    if isMoving {
      delegate?.handleMovement(forward: Double(-moveY), strafe: Double(moveX))
    }
  }
  
  func joystickReleased() {
    moveX = 0
    moveY = 0
    isMoving = false
  }
  
  func processGyroscopeRotation(angle: Double) {
    if abs(angle) > GameConfig.Input.gyroThreshold {
      delegate?.handleRotation(angle: angle * GameConfig.Input.gyroSensitivity)
    }
  }
  
  
  func isPlayerMoving() -> Bool {
    return isMoving
  }
  
  func getCurrentMovement() -> (x: CGFloat, y: CGFloat) {
    return (moveX, moveY)
  }
}
