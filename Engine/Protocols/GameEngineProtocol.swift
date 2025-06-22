import Foundation

public protocol GameEngineProtocol: AnyObject {
  var isRunning: Bool { get }
  func start()
  func stop()
  func update(deltaTime: TimeInterval)
}

public protocol RenderEngineProtocol: AnyObject {
  associatedtype ImageType
  func render(player: Player, map: Map) -> ImageType?
}

public protocol InputHandlerProtocol: AnyObject {
  func handleMovement(forward: Double, strafe: Double)
  func handleRotation(angle: Double)
}

public protocol InputProviderProtocol: AnyObject {
  var delegate: InputHandlerProtocol? { get set }
}

public protocol CollisionDetectorProtocol: AnyObject {
  func canMoveTo(x: Double, y: Double, in map: Map) -> Bool
  func checkMovement(from current: CGPoint, to new: CGPoint, in map: Map) -> CGPoint
}

public protocol GameStateObserver: AnyObject {
  func gameStateDidChange(_ state: GameState)
}

public protocol GameStateSubject: AnyObject {
  func addObserver(_ observer: GameStateObserver)
  func removeObserver(_ observer: GameStateObserver)
  func notifyObservers()
}

/// Platform-independent point structure
public struct CGPoint {
  public var x: Double
  public var y: Double
  
  public init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }
}