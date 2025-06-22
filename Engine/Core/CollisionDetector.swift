import Foundation

public class CollisionDetector: CollisionDetectorProtocol {
  
  public init() {}
  
  public func canMoveTo(x: Double, y: Double, in map: Map) -> Bool {
    let mapX = Int(x)
    let mapY = Int(y)
    
    return map.isInBounds(x: mapX, y: mapY) && map.isEmpty(x: mapX, y: mapY)
  }
  
  public func checkMovement(from current: CGPoint, to new: CGPoint, in map: Map) -> CGPoint {
    var finalPosition = current
    
    if canMoveTo(x: Double(new.x), y: Double(current.y), in: map) {
      finalPosition.x = new.x
    }
    
    if canMoveTo(x: Double(finalPosition.x), y: Double(new.y), in: map) {
      finalPosition.y = new.y
    }
    
    return finalPosition
  }
}