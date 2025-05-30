//
//  CollisionDetector.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 24.05.25.
//


// Engine/Physics/CollisionDetector.swift
import Foundation

class CollisionDetector: CollisionDetectorProtocol {
  // MARK: - CollisionDetectorProtocol
  
  func canMoveTo(x: Double, y: Double, in map: Map) -> Bool {
    let mapX = Int(x)
    let mapY = Int(y)
    
    return map.isInBounds(x: mapX, y: mapY) && map.isEmpty(x: mapX, y: mapY)
  }
  
  func checkMovement(from current: CGPoint, to new: CGPoint, in map: Map) -> CGPoint {
    var finalPosition = current
    
    // Check X movement
    if canMoveTo(x: Double(new.x), y: Double(current.y), in: map) {
      finalPosition.x = new.x
    }
    
    // Check Y movement (using potentially updated X for sliding collision)
    if canMoveTo(x: Double(finalPosition.x), y: Double(new.y), in: map) {
      finalPosition.y = new.y
    }
    
    return finalPosition
  }
}
