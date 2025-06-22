import UIKit
import Engine

/// iOS implementation of TextureLoader protocol
class IOSTextureLoader: TextureLoader {
    func loadTexture(named name: String) -> PlatformImage? {
        guard let uiImage = UIImage(named: name) else {
            return nil
        }
        return IOSPlatformImage(uiImage: uiImage)
    }
    
    func loadTexture(from data: Data) -> PlatformImage? {
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        return IOSPlatformImage(uiImage: uiImage)
    }
}