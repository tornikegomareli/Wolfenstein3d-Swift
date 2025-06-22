import Foundation

public struct RenderConfig {
  public struct Screen {
    #if os(iOS)
    public static let width: Int = 320
    public static let height: Int = 240
    #else
    public static let width: Int = 640
    public static let height: Int = 480
    #endif
  }
  
  public struct Map {
    public static let width: Int = 24
    public static let height: Int = 24
  }
  
  public struct Colors {
    public static let ceiling: UInt32 = 0xFF404040
    public static let floor: UInt32 = 0xFF808080
    
    public static let wallColors: [Int: UInt32] = [
      1: 0xFFFF0000,
      2: 0xFF00FF00,
      3: 0xFF0000FF,
      4: 0xFFFFFFFF,
      5: 0xFFFFFF00
    ]
    
    public static let defaultWallColor: UInt32 = 0xFFFF00FF
    public static let outOfBoundsColor: UInt32 = 0xFF000000
  }
  
  public struct Rendering {
    public static let maxRayDistance: Double = 1e30
    public static let minWallDistance: Double = 0.0001
    public static let wallDarkeningFactor: UInt32 = 0xFF7F7F7F
    public static let useTextures: Bool = true
    public static let closeWallThreshold: Double = 0.5
  }
}