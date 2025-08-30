import Foundation

public enum GameStatus {
  case ready
  case running
  case paused
  case stopped
}

public class GameState: GameStateSubject {
  public var status: GameStatus = .ready {
    didSet {
      if oldValue != status {
        notifyObservers()
      }
    }
  }
  
  public var player: Player
  public var map: Map
  public var weapon: Weapon
  public var frameCount: Int = 0
  public var lastUpdateTime: TimeInterval = 0
  
  private var observers: [GameStateObserver] = []
  
  public init(player: Player, map: Map) {
    self.player = player
    self.map = map
    self.weapon = Weapon()
  }
  
  public func addObserver(_ observer: GameStateObserver) {
    observers.append(observer)
  }
  
  public func removeObserver(_ observer: GameStateObserver) {
    observers.removeAll { $0 === observer }
  }
  
  public func notifyObservers() {
    observers.forEach { $0.gameStateDidChange(self) }
  }
}