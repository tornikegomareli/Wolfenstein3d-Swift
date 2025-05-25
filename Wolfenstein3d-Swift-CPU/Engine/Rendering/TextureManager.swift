// Engine/Rendering/TextureManager.swift
import Foundation

class TextureManager {
    // MARK: - Singleton
    
    static let shared = TextureManager()
    
    // MARK: - Properties
    
    private var textures: [Int: Texture] = [:]
    
    // MARK: - Initialization
    
    private init() {
        loadDefaultTextures()
    }
    
    // MARK: - Texture Loading
    
    private func loadDefaultTextures() {
        // Load wall textures
        // Wall type 1, 3, 5 use wall.png
        if let wallTexture = Texture(named: "wall") {
            textures[1] = wallTexture
            textures[3] = wallTexture
            textures[5] = wallTexture
        } else {
            print("Warning: Could not load wall.png texture")
        }
        
        // Wall type 2, 4 use wall2.png
        if let wall2Texture = Texture(named: "wall2") {
            textures[2] = wall2Texture
            textures[4] = wall2Texture
        } else {
            print("Warning: Could not load wall2.png texture")
        }
    }
    
    // MARK: - Public Methods
    
    func texture(for wallType: Int) -> Texture? {
        return textures[wallType]
    }
    
    func loadTexture(named name: String, for wallType: Int) {
        if let texture = Texture(named: name) {
            textures[wallType] = texture
        }
    }
}