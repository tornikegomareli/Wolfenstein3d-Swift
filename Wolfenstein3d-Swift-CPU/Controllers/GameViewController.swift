//
//  GameViewController.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 24.05.25.
//


// Controllers/GameViewController.swift
import UIKit

class GameViewController: UIViewController {
  // MARK: - Properties
  
  private var gameView: GameView!
  private var joystick: JoystickView!
  
  private var gameEngine: GameEngine!
  private var inputManager: InputManager!
  private var motionManager: MotionManager!
  private var gameState: GameState!
  
  private var debugLabel: UILabel?
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupGame()
    setupUI()
    forceOrientation(.landscapeRight)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    positionJoystick()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    startGame()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopGame()
  }
  
  // MARK: - Setup
  
  private func setupGame() {
    // Create game state
    let player = Player()
    let map = DefaultMap.createMap()
    gameState = GameState(player: player, map: map)
    
    // Create game engine
    gameEngine = GameEngine(gameState: gameState)
    gameEngine.delegate = self
    
    // Create input manager
    inputManager = InputManager()
    inputManager.delegate = gameEngine
    
    // Create motion manager
    motionManager = MotionManager()
    motionManager.delegate = self
  }
  
  private func setupUI() {
    view.backgroundColor = .black
    
    // Setup game view
    gameView = GameView(frame: view.bounds)
    gameView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(gameView)
    
    // Setup joystick
    setupJoystick()
    
    // Setup debug label (optional)
    setupDebugLabel()
    
    // Update status bar
    setNeedsStatusBarAppearanceUpdate()
  }
  
  private func setupJoystick() {
    let size = GameConfig.UI.joystickSize
    joystick = JoystickView(frame: CGRect(x: 0, y: 0, width: size, height: size))
    joystick.delegate = self
    view.addSubview(joystick)
  }
  
  private func setupDebugLabel() {
    debugLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 300, height: 30))
    debugLabel?.textColor = .white
    debugLabel?.text = "Wolfenstein 3D Raycaster"
    debugLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    view.addSubview(debugLabel!)
  }
  
  private func positionJoystick() {
    guard let joystick = joystick else { return }
    
    let padding = GameConfig.UI.joystickPadding
    let size = GameConfig.UI.joystickSize
    
    let x = view.safeAreaInsets.left + padding
    let y = view.bounds.height - size - view.safeAreaInsets.bottom - padding
    
    joystick.frame = CGRect(x: x, y: y, width: size, height: size)
  }
  
  // MARK: - Game Control
  
  private func startGame() {
    gameEngine.start()
    motionManager.startTracking()
  }
  
  private func stopGame() {
    gameEngine.stop()
    motionManager.stopTracking()
  }
  
  // MARK: - Orientation
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .landscape
  }
  
  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return .landscapeRight
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var prefersHomeIndicatorAutoHidden: Bool {
    return true
  }
  
  override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
    return .all
  }
}

// MARK: - GameEngineDelegate

extension GameViewController: GameEngineDelegate {
  func gameEngine(_ engine: GameEngine, didRenderFrame image: UIImage) {
    gameView.updateFrame(image)
  }
  
  func gameEngineDidStart(_ engine: GameEngine) {
    debugLabel?.text = "Game Running"
  }
  
  func gameEngineDidStop(_ engine: GameEngine) {
    debugLabel?.text = "Game Stopped"
  }
}

// MARK: - JoystickDelegate

extension GameViewController: JoystickDelegate {
  func joystickDidMove(x: CGFloat, y: CGFloat) {
    inputManager.processJoystickInput(x: x, y: y)
  }
  
  func joystickDidRelease() {
    inputManager.joystickReleased()
  }
}

// MARK: - MotionManagerDelegate

extension GameViewController: MotionManagerDelegate {
  func motionManager(_ manager: MotionManager, didUpdateRotation angle: Double) {
    inputManager.processGyroscopeRotation(angle: angle)
  }
}

// MARK: - GameStateObserver

extension GameViewController: GameStateObserver {
  func gameStateDidChange(_ state: GameState) {
    // Handle game state changes if needed
    switch state.status {
    case .running:
      debugLabel?.textColor = .green
    case .paused:
      debugLabel?.textColor = .yellow
    case .stopped:
      debugLabel?.textColor = .red
    default:
      debugLabel?.textColor = .white
    }
  }
}
