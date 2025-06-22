import Foundation

public class Player {
  public var x: Double
  public var y: Double
  
  public var dirX: Double
  public var dirY: Double
  
  public var planeX: Double
  public var planeY: Double
  
  public let moveSpeed: Double
  public let rotationSpeed: Double
  
  public init() {
    self.x = GameConfig.Player.initialX
    self.y = GameConfig.Player.initialY
    self.dirX = GameConfig.Player.initialDirX
    self.dirY = GameConfig.Player.initialDirY
    self.planeX = GameConfig.Camera.planeX
    self.planeY = GameConfig.Camera.planeY
    self.moveSpeed = GameConfig.Player.moveSpeed
    self.rotationSpeed = GameConfig.Player.rotationSpeed
  }
  
  public func move(forward: Double, strafe: Double) -> (newX: Double, newY: Double) {
    let moveX = dirX * forward * moveSpeed
    let moveY = dirY * forward * moveSpeed
    
    let strafeX = planeX * strafe * moveSpeed
    let strafeY = planeY * strafe * moveSpeed
    
    let newX = x + moveX + strafeX
    let newY = y + moveY + strafeY
    
    return (newX, newY)
  }
  
  public func rotate(angle: Double) {
    let oldDirX = dirX
    dirX = dirX * cos(angle) - dirY * sin(angle)
    dirY = oldDirX * sin(angle) + dirY * cos(angle)
    
    let oldPlaneX = planeX
    planeX = planeX * cos(angle) - planeY * sin(angle)
    planeY = oldPlaneX * sin(angle) + planeY * cos(angle)
  }
  
  public func updatePosition(x: Double, y: Double) {
    self.x = x
    self.y = y
  }
}