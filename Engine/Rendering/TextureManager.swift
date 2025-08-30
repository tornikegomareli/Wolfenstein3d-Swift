import Foundation

public class TextureManager {
  public static let shared = TextureManager()
  
  private var textures: [Int: Texture] = [:]
  private var weaponTextures: [String: Texture] = [:]
  private var textureLoader: TextureLoader?
  
  private init() {}
  
  public func setTextureLoader(_ loader: TextureLoader) {
    self.textureLoader = loader
    loadDefaultTextures()
  }
  
  
  private func loadDefaultTextures() {
    guard let loader = textureLoader else {
      print("Warning: No texture loader set")
      return
    }
    
    if let wallImage = loader.loadTexture(named: "wall"),
       let wallTexture = Texture(image: wallImage) {
      textures[1] = wallTexture
      textures[3] = wallTexture
      textures[5] = wallTexture
    } else {
      print("Warning: Could not load wall texture")
    }
    
    if let wall2Image = loader.loadTexture(named: "wall2"),
       let wall2Texture = Texture(image: wall2Image) {
      textures[2] = wall2Texture
      textures[4] = wall2Texture
    } else {
      print("Warning: Could not load wall2 texture")
    }
    
    /// Load weapon sprites
    for i in 1...5 {
      let spriteName = "shoot_\(i)"
      if let weaponImage = loader.loadTexture(named: spriteName),
         let weaponTexture = Texture(image: weaponImage) {
        weaponTextures[spriteName] = weaponTexture
      }
    }
  }
  
  public func texture(for wallType: Int) -> Texture? {
    return textures[wallType]
  }
  
  public func loadTexture(named name: String, for wallType: Int) {
    guard let loader = textureLoader,
          let image = loader.loadTexture(named: name),
          let texture = Texture(image: image) else {
      print("Warning: Could not load texture \(name)")
      return
    }
    textures[wallType] = texture
  }
  
  public func weaponTexture(name: String) -> Texture? {
    return weaponTextures[name]
  }
}