//
//  GameConfig.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 24.05.25.
//


import Foundation

struct GameConfig {
  struct Player {
    static let initialX: Double = 22.0
    static let initialY: Double = 12.0
    static let initialDirX: Double = -1.0
    static let initialDirY: Double = 0.0
    static let moveSpeed: Double = 0.1
    static let rotationSpeed: Double = 0.05
  }
  
  struct Camera {
    static let planeX: Double = 0.0
    static let planeY: Double = 0.66 // FOV
  }
  
  struct Input {
    static let joystickDeadzone: Double = 0.1
    static let gyroSensitivity: Double = 1.5
    static let gyroThreshold: Double = 0.005
    static let gyroUpdateInterval: Double = 1.0 / 60.0
  }
  
  struct UI {
    static let joystickSize: CGFloat = 150
    static let joystickKnobSize: CGFloat = 60
    static let joystickPadding: CGFloat = 50
    static let joystickAlpha: CGFloat = 0.5
  }
}
