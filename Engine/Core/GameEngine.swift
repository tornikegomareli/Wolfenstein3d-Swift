import Foundation

public protocol GameEngineDelegate: AnyObject {
  associatedtype ImageType
  func gameEngine(_ engine: GameEngine, didRenderFrame frameBuffer: FrameBuffer)
  func gameEngineDidStart(_ engine: GameEngine)
  func gameEngineDidStop(_ engine: GameEngine)
}

public class GameEngine: GameEngineProtocol {
  public weak var delegate: AnyObject?
  
  private let collisionDetector: CollisionDetectorProtocol
  private let gameState: GameState
  private var displayLink: DisplayLink
  private let renderer: Renderer
  
  private var frameTimer = Date().timeIntervalSince1970
  private var frameCount = 0
  
  public private(set) var isRunning = false
  
  private var currentForward: Double = 0
  private var currentStrafe: Double = 0
  
  
  public init(gameState: GameState, displayLink: DisplayLink) {
    self.gameState = gameState
    self.displayLink = displayLink
    self.collisionDetector = CollisionDetector()
    self.renderer = Renderer(width: RenderConfig.Screen.width, height: RenderConfig.Screen.height)
  }
  
  public func start() {
    guard !isRunning else { return }
    
    isRunning = true
    gameState.status = .running
    
    displayLink.preferredFramesPerSecond = 60
    displayLink.start(target: self, selector: #selector(gameLoop))
    
    if let delegate = delegate as? any GameEngineDelegate {
      delegate.gameEngineDidStart(self)
    }
  }
  
  public func stop() {
    guard isRunning else { return }
    
    isRunning = false
    gameState.status = .stopped
    
    displayLink.invalidate()
    
    if let delegate = delegate as? any GameEngineDelegate {
      delegate.gameEngineDidStop(self)
    }
  }
  
  public func update(deltaTime: TimeInterval) {
    gameState.lastUpdateTime = deltaTime
    gameState.frameCount += 1
  }
  
  private func applyMovement() {
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
  
  
  @objc private func gameLoop() {
    guard isRunning else { return }
    
    let currentTime = Date().timeIntervalSince1970
    let deltaTime = currentTime - gameState.lastUpdateTime
    update(deltaTime: deltaTime)
    
    applyMovement()
    
    gameState.weapon.update(deltaTime: deltaTime)
    
    renderer.render(player: gameState.player, map: gameState.map, weapon: gameState.weapon)
    
    if let delegate = delegate as? any GameEngineDelegate {
      delegate.gameEngine(self, didRenderFrame: renderer.frameBuffer)
    }
    
    frameCount += 1
    let now = Date().timeIntervalSince1970
    if now - frameTimer >= 1.0 {
      print("FPS: \(frameCount)")
      frameCount = 0
      frameTimer = now
    }
  }
  
  public func shoot() {
    gameState.weapon.startShooting()
  }
}

extension GameEngine: InputHandlerProtocol {
  public func handleMovement(forward: Double, strafe: Double) {
    currentForward = forward
    currentStrafe = strafe
  }
  
  public func handleRotation(angle: Double) {
    gameState.player.rotate(angle: angle)
  }
}
