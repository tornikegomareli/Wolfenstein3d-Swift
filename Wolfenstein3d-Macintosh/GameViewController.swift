//
//  GameViewController.swift
//  Wolfenstein3d-Macintosh
//
//  Created by Tornike Gomareli on 24.05.25.
//

import AppKit
import Engine

class GameViewController: NSViewController {
    // MARK: - Properties
    
    private var gameView: GameView!
    private var gameEngine: GameEngine!
    private var inputManager: MacInputManager!
    private var gameState: GameState!
    private var platformRenderer: MacPlatformRenderer!
    
    // MARK: - Lifecycle
    
    override func loadView() {
        gameView = GameView(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        self.view = gameView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
        
        // Make the view first responder to receive keyboard events
        view.window?.makeFirstResponder(view)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        startGame()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        stopGame()
    }
    
    // MARK: - Setup
    
    private func setupGame() {
        // Setup texture manager with macOS loader
        TextureManager.shared.setTextureLoader(MacTextureLoader())
        
        // Create game state
        let player = Player()
        let map = DefaultMap.createMap()
        gameState = GameState(player: player, map: map)
        
        // Create platform renderer
        platformRenderer = MacPlatformRenderer()
        
        // Create game engine with macOS display link
        let displayLink = MacDisplayLink()
        gameEngine = GameEngine(gameState: gameState, displayLink: displayLink)
        gameEngine.delegate = self
        
        // Create input manager
        inputManager = MacInputManager()
        inputManager.delegate = gameEngine
    }
    
    // MARK: - Game Control
    
    private func startGame() {
        gameEngine.start()
    }
    
    private func stopGame() {
        gameEngine.stop()
    }
    
    // MARK: - Input Handling
    
    override func keyDown(with event: NSEvent) {
        inputManager.keyDown(event.keyCode)
    }
    
    override func keyUp(with event: NSEvent) {
        inputManager.keyUp(event.keyCode)
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = view.convert(event.locationInWindow, from: nil)
        inputManager.mouseDown(at: location)
        
        /// Trigger shooting animation
        gameEngine.shoot()
    }
    
    override func mouseDragged(with event: NSEvent) {
        let location = view.convert(event.locationInWindow, from: nil)
        inputManager.mouseDragged(to: location)
    }
    
    override func mouseUp(with event: NSEvent) {
        inputManager.mouseUp()
    }
    
    override func scrollWheel(with event: NSEvent) {
        inputManager.scrollWheel(deltaX: event.deltaX, deltaY: event.deltaY)
    }
}

// MARK: - GameEngineDelegate

extension GameViewController: GameEngineDelegate {
    typealias ImageType = NSImage
    
    func gameEngine(_ engine: GameEngine, didRenderFrame frameBuffer: FrameBuffer) {
        // Pass frame buffer directly to view - no image creation needed
        gameView.updateFrame(frameBuffer)
    }
    
    func gameEngineDidStart(_ engine: GameEngine) {
        print("Game started on macOS")
    }
    
    func gameEngineDidStop(_ engine: GameEngine) {
        print("Game stopped on macOS")
    }
}

// MARK: - GameStateObserver

extension GameViewController: GameStateObserver {
    func gameStateDidChange(_ state: GameState) {
        // Handle game state changes if needed
    }
}