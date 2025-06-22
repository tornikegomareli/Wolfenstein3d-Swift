import Foundation

public struct GameConfig {
  public struct Player {
    public static let initialX: Double = 22.0
    public static let initialY: Double = 12.0
    public static let initialDirX: Double = -1.0
    public static let initialDirY: Double = 0.0
    public static let moveSpeed: Double = 0.1
    public static let rotationSpeed: Double = 0.05
  }
  
  public struct Camera {
    public static let planeX: Double = 0.0
    public static let planeY: Double = 0.66
  }
  
  public struct Input {
    public static let joystickDeadzone: Double = 0.1
    public static let gyroSensitivity: Double = 1.5
    public static let gyroThreshold: Double = 0.005
    public static let gyroUpdateInterval: Double = 1.0 / 60.0
  }
}