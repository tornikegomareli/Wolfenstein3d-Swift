// Engine/Protocols/EngineProtocols.swift
import UIKit

// MARK: - Engine Protocols

protocol GameEngineProtocol: AnyObject {
    var isRunning: Bool { get }
    func start()
    func stop()
    func update(deltaTime: TimeInterval)
}

protocol RenderEngineProtocol: AnyObject {
    func render(player: Player, map: Map) -> UIImage?
}

// MARK: - Input Protocols

protocol InputHandlerProtocol: AnyObject {
    func handleMovement(forward: Double, strafe: Double)
    func handleRotation(angle: Double)
}

protocol InputProviderProtocol: AnyObject {
    var delegate: InputHandlerProtocol? { get set }
}

// MARK: - Collision Protocols

protocol CollisionDetectorProtocol: AnyObject {
    func canMoveTo(x: Double, y: Double, in map: Map) -> Bool
    func checkMovement(from current: CGPoint, to new: CGPoint, in map: Map) -> CGPoint
}

// MARK: - State Management Protocols

protocol GameStateObserver: AnyObject {
    func gameStateDidChange(_ state: GameState)
}

protocol GameStateSubject: AnyObject {
    func addObserver(_ observer: GameStateObserver)
    func removeObserver(_ observer: GameStateObserver)
    func notifyObservers()
}