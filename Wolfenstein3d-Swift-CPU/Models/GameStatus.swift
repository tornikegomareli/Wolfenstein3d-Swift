//
//  GameStatus.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 24.05.25.
//


import Foundation

enum GameStatus {
  case ready
  case running
  case paused
  case stopped
}

class GameState: GameStateSubject {
  var status: GameStatus = .ready {
    didSet {
      if oldValue != status {
        notifyObservers()
      }
    }
  }
  
  var player: Player
  var map: Map
  var frameCount: Int = 0
  var lastUpdateTime: TimeInterval = 0
  
  private var observers: [GameStateObserver] = []
  
  init(player: Player, map: Map) {
    self.player = player
    self.map = map
  }
  
  
  func addObserver(_ observer: GameStateObserver) {
    observers.append(observer)
  }
  
  func removeObserver(_ observer: GameStateObserver) {
    observers.removeAll { $0 === observer }
  }
  
  func notifyObservers() {
    observers.forEach { $0.gameStateDidChange(self) }
  }
}
