// Configuration/RenderConfig.swift
import UIKit

struct RenderConfig {
    // Screen Settings
    struct Screen {
        static let width: Int = 320  // Lower for better performance
        static let height: Int = 240
    }
    
    // Map Settings
    struct Map {
        static let width: Int = 24
        static let height: Int = 24
    }
    
    // Color Palette
    struct Colors {
        static let ceiling: UInt32 = 0xFF404040
        static let floor: UInt32 = 0xFF808080
        
        // Wall colors by type
        static let wallColors: [Int: UInt32] = [
            1: 0xFFFF0000,  // Red
            2: 0xFF00FF00,  // Green
            3: 0xFF0000FF,  // Blue
            4: 0xFFFFFFFF,  // White
            5: 0xFFFFFF00   // Yellow
        ]
        
        static let defaultWallColor: UInt32 = 0xFFFF00FF  // Purple
        static let outOfBoundsColor: UInt32 = 0xFF000000  // Black
    }
    
    // Rendering Settings
    struct Rendering {
        static let maxRayDistance: Double = 1e30
        static let minWallDistance: Double = 0.0001
        static let wallDarkeningFactor: UInt32 = 0xFF7F7F7F
    }
}