import UIKit
import Engine

class GameViewController: UIViewController {
  private var gameView: GameView!
  private var joystick: JoystickView!
  private var touchLookView: TouchLookView!
  
  private var gameEngine: GameEngine!
  private var inputManager: InputManager!
  private var gameState: GameState!
  private var platformRenderer: IOSPlatformRenderer!
  
  private var debugLabel: UILabel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupGame()
    setupUI()
    forceOrientation(.landscapeRight)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    positionJoystick()
    positionTouchLookView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    startGame()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopGame()
  }
  
  private func setupGame() {
    TextureManager.shared.setTextureLoader(IOSTextureLoader())
    
    let player = Player()
    let map = DefaultMap.createMap()
    gameState = GameState(player: player, map: map)
    
    platformRenderer = IOSPlatformRenderer()
    
    let displayLink = IOSDisplayLink()
    gameEngine = GameEngine(gameState: gameState, displayLink: displayLink)
    gameEngine.delegate = self
    
    inputManager = InputManager()
    inputManager.delegate = gameEngine
  }
  
  private func setupUI() {
    view.backgroundColor = .black
    
    gameView = GameView(frame: view.bounds)
    gameView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(gameView)
    
    setupJoystick()
    setupTouchLookView()
    
    setupDebugLabel()
    
    setNeedsStatusBarAppearanceUpdate()
  }
  
  private func setupJoystick() {
    let size = UIConfig.UI.joystickSize
    joystick = JoystickView(frame: CGRect(x: 0, y: 0, width: size, height: size))
    joystick.delegate = self
    view.addSubview(joystick)
  }
  
  private func setupTouchLookView() {
    touchLookView = TouchLookView(frame: view.bounds)
    touchLookView.delegate = self
    touchLookView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.insertSubview(touchLookView, belowSubview: joystick)
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
    
    let padding = UIConfig.UI.joystickPadding
    let size = UIConfig.UI.joystickSize
    
    let x = view.safeAreaInsets.left + padding
    let y = view.bounds.height - size - view.safeAreaInsets.bottom - padding
    
    joystick.frame = CGRect(x: x, y: y, width: size, height: size)
  }
  
  private func positionTouchLookView() {
    touchLookView?.frame = view.bounds
  }
  
  private func startGame() {
    gameEngine.start()
  }
  
  private func stopGame() {
    gameEngine.stop()
  }
  
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

extension GameViewController: GameEngineDelegate {
  typealias ImageType = UIImage
  
  func gameEngine(_ engine: GameEngine, didRenderFrame frameBuffer: FrameBuffer) {
    if let image = platformRenderer.createImage(from: frameBuffer) {
      gameView.updateFrame(image)
    }
  }
  
  func gameEngineDidStart(_ engine: GameEngine) {
    debugLabel?.text = "Game Running"
  }
  
  func gameEngineDidStop(_ engine: GameEngine) {
    debugLabel?.text = "Game Stopped"
  }
}

extension GameViewController: JoystickDelegate {
  func joystickDidMove(x: CGFloat, y: CGFloat) {
    inputManager.processJoystickInput(x: x, y: y)
  }
  
  func joystickDidRelease() {
    inputManager.joystickReleased()
  }
}

extension GameViewController: TouchLookDelegate {
  func touchLookDidMove(deltaX: CGFloat, deltaY: CGFloat) {
    inputManager.processTouchLook(deltaX: deltaX, deltaY: deltaY)
  }
}

extension GameViewController: GameStateObserver {
  func gameStateDidChange(_ state: GameState) {
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