import Foundation

/// Protocol for platform-specific image representation
public protocol PlatformImage {
    var width: Int { get }
    var height: Int { get }
    
    /// Returns RGBA pixel data as bytes
    func pixelData() -> [UInt8]
}

/// Protocol for platform-specific display synchronization
public protocol DisplayLink {
    func start(target: Any, selector: Selector)
    func invalidate()
    func setPaused(_ paused: Bool)
    var preferredFramesPerSecond: Int { get set }
}

/// Protocol for platform-specific input handling
public protocol InputSource {
    var movementVector: SIMD2<Float> { get }
    var rotationDelta: Float { get }
    var isInteracting: Bool { get }
}

/// Protocol for platform-specific image creation from pixel data
public protocol PlatformRenderer {
    associatedtype ImageType
    
    /// Creates a platform-specific image from raw pixel data
    func createImage(from pixelData: [UInt32], width: Int, height: Int) -> ImageType?
}

/// Protocol for platform-specific texture loading
public protocol TextureLoader {
    func loadTexture(named name: String) -> PlatformImage?
    func loadTexture(from data: Data) -> PlatformImage?
}