//
//  Player.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 24.05.25.
//


// Models/Player.swift
import Foundation

class Player {
  var x: Double
  var y: Double
  
  var dirX: Double
  var dirY: Double
  
  var planeX: Double
  var planeY: Double
  
  let moveSpeed: Double
  let rotationSpeed: Double
  
  init() {
    self.x = GameConfig.Player.initialX
    self.y = GameConfig.Player.initialY
    self.dirX = GameConfig.Player.initialDirX
    self.dirY = GameConfig.Player.initialDirY
    self.planeX = GameConfig.Camera.planeX
    self.planeY = GameConfig.Camera.planeY
    self.moveSpeed = GameConfig.Player.moveSpeed
    self.rotationSpeed = GameConfig.Player.rotationSpeed
  }
  
  func move(forward: Double, strafe: Double) -> (newX: Double, newY: Double) {
    let moveX = dirX * forward * moveSpeed
    let moveY = dirY * forward * moveSpeed
    
    let strafeX = planeX * strafe * moveSpeed
    let strafeY = planeY * strafe * moveSpeed
    
    let newX = x + moveX + strafeX
    let newY = y + moveY + strafeY
    
    return (newX, newY)
  }
  
  func rotate(angle: Double) {
    let oldDirX = dirX
    dirX = dirX * cos(angle) - dirY * sin(angle)
    dirY = oldDirX * sin(angle) + dirY * cos(angle)
    
    let oldPlaneX = planeX
    planeX = planeX * cos(angle) - planeY * sin(angle)
    planeY = oldPlaneX * sin(angle) + planeY * cos(angle)
  }
  
  func updatePosition(x: Double, y: Double) {
    self.x = x
    self.y = y
  }
}
