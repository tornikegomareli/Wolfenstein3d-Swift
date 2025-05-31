//
//  GameEngine.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 24.05.25.
//


// Engine/Core/GameEngine.swift
import UIKit

protocol GameEngineDelegate: AnyObject {
  func gameEngine(_ engine: GameEngine, didRenderFrame image: UIImage)
  func gameEngineDidStart(_ engine: GameEngine)
  func gameEngineDidStop(_ engine: GameEngine)
}

class GameEngine: GameEngineProtocol {
  weak var delegate: GameEngineDelegate?
  
  private let renderEngine: RenderEngineProtocol
  private let collisionDetector: CollisionDetectorProtocol
  private let gameState: GameState
  
  private var frameTimer = CACurrentMediaTime()
  private var frameCount = 0
  
  private var displayLink: CADisplayLink?
  private(set) var isRunning = false
  
  // Store current movement values
  private var currentForward: Double = 0
  private var currentStrafe: Double = 0
  
  // MARK: - Initialization
  
  init(gameState: GameState) {
    self.gameState = gameState
    self.renderEngine = RenderEngine()
    self.collisionDetector = CollisionDetector()
  }
  
  func start() {
    guard !isRunning else { return }
    
    isRunning = true
    gameState.status = .running
    
    displayLink = CADisplayLink(target: self, selector: #selector(gameLoop))
    displayLink?.add(to: .current, forMode: .default)
    
    delegate?.gameEngineDidStart(self)
  }
  
  func stop() {
    guard isRunning else { return }
    
    isRunning = false
    gameState.status = .stopped
    
    displayLink?.invalidate()
    displayLink = nil
    
    delegate?.gameEngineDidStop(self)
  }
  
  func update(deltaTime: TimeInterval) {
    // Update game state if needed
    gameState.lastUpdateTime = deltaTime
    gameState.frameCount += 1
  }
  
  private func applyMovement() {
    // Only apply movement if there is any
    if abs(currentForward) > 0.01 || abs(currentStrafe) > 0.01 {
      let (newX, newY) = gameState.player.move(forward: currentForward, strafe: currentStrafe)
      
      let currentPos = CGPoint(x: gameState.player.x, y: gameState.player.y)
      let newPos = CGPoint(x: newX, y: newY)
      
      let finalPos = collisionDetector.checkMovement(
        from: currentPos,
        to: newPos,
        in: gameState.map
      )
      
      gameState.player.updatePosition(x: Double(finalPos.x), y: Double(finalPos.y))
    }
  }
  
  // MARK: - Game Loop
  
  @objc private func gameLoop() {
    guard isRunning else { return }
    
    // Update game state
    update(deltaTime: displayLink?.timestamp ?? 0)
    
    // Apply continuous movement if joystick is being held
    applyMovement()
    
    // Render frame
    if let image = renderEngine.render(player: gameState.player, map: gameState.map) {
      delegate?.gameEngine(self, didRenderFrame: image)
    }
    
    frameCount += 1
    let now = CACurrentMediaTime()
    if now - frameTimer >= 1.0 {
      print("FPS: \(frameCount)")
      frameCount = 0
      frameTimer = now
    }
  }
}

// MARK: - Input Handler

extension GameEngine: InputHandlerProtocol {
  func handleMovement(forward: Double, strafe: Double) {
    // Store the movement values to be applied continuously in the game loop
    currentForward = forward
    currentStrafe = strafe
  }
  
  func handleRotation(angle: Double) {
    gameState.player.rotate(angle: angle)
  }
}
