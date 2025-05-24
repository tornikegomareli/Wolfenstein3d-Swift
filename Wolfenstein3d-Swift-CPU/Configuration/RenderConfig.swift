//
//  RenderConfig.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 24.05.25.
//


// Configuration/RenderConfig.swift
import UIKit

struct RenderConfig {
  struct Screen {
    static let width: Int = 320
    static let height: Int = 240
  }
  
  struct Map {
    static let width: Int = 24
    static let height: Int = 24
  }
  
  struct Colors {
    static let ceiling: UInt32 = 0xFF404040
    static let floor: UInt32 = 0xFF808080
    
    static let wallColors: [Int: UInt32] = [
      1: 0xFFFF0000,  // Red
      2: 0xFF00FF00,  // Green
      3: 0xFF0000FF,  // Blue
      4: 0xFFFFFFFF,  // White
      5: 0xFFFFFF00   // Yellow
    ]
    
    static let defaultWallColor: UInt32 = 0xFFFF00FF
    static let outOfBoundsColor: UInt32 = 0xFF000000
  }
  
  struct Rendering {
    static let maxRayDistance: Double = 1e30
    static let minWallDistance: Double = 0.0001
    static let wallDarkeningFactor: UInt32 = 0xFF7F7F7F
  }
}
