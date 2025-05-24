//
//  GameEngineProtocol.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 24.05.25.
//


import UIKit

protocol GameEngineProtocol: AnyObject {
  var isRunning: Bool { get }
  func start()
  func stop()
  func update(deltaTime: TimeInterval)
}

protocol RenderEngineProtocol: AnyObject {
  func render(player: Player, map: Map) -> UIImage?
}


protocol InputHandlerProtocol: AnyObject {
  func handleMovement(forward: Double, strafe: Double)
  func handleRotation(angle: Double)
}

protocol InputProviderProtocol: AnyObject {
  var delegate: InputHandlerProtocol? { get set }
}


protocol CollisionDetectorProtocol: AnyObject {
  func canMoveTo(x: Double, y: Double, in map: Map) -> Bool
  func checkMovement(from current: CGPoint, to new: CGPoint, in map: Map) -> CGPoint
}


protocol GameStateObserver: AnyObject {
  func gameStateDidChange(_ state: GameState)
}

protocol GameStateSubject: AnyObject {
  func addObserver(_ observer: GameStateObserver)
  func removeObserver(_ observer: GameStateObserver)
  func notifyObservers()
}
