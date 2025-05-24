// Engine/Rendering/FrameBuffer.swift
import UIKit

class FrameBuffer {
    // MARK: - Properties
    
    let width: Int
    let height: Int
    let pixelCount: Int
    
    private(set) var buffer: UnsafeMutablePointer<UInt32>
    private var context: CGContext!
    
    // MARK: - Initialization
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.pixelCount = width * height
        
        // Allocate buffer
        buffer = UnsafeMutablePointer<UInt32>.allocate(capacity: pixelCount)
        
        // Create bitmap context
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        context = CGContext(
            data: buffer,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
    }
    
    deinit {
        buffer.deallocate()
    }
    
    // MARK: - Drawing Methods
    
    func clear(color: UInt32) {
        for i in 0..<pixelCount {
            buffer[i] = color
        }
    }
    
    func setPixel(x: Int, y: Int, color: UInt32) {
        guard x >= 0, x < width, y >= 0, y < height else { return }
        buffer[y * width + x] = color
    }
    
    func drawVerticalLine(x: Int, startY: Int, endY: Int, color: UInt32) {
        let safeStartY = max(0, startY)
        let safeEndY = min(height - 1, endY)
        
        for y in safeStartY...safeEndY {
            buffer[y * width + x] = color
        }
    }
    
    func fillColumn(x: Int, ceilingEnd: Int, wallStart: Int, wallEnd: Int, 
                    ceilingColor: UInt32, wallColor: UInt32, floorColor: UInt32) {
        guard x >= 0, x < width else { return }
        
        var y = 0
        
        // Draw ceiling
        while y < wallStart && y < height {
            buffer[y * width + x] = ceilingColor
            y += 1
        }
        
        // Draw wall
        while y <= wallEnd && y < height {
            buffer[y * width + x] = wallColor
            y += 1
        }
        
        // Draw floor
        while y < height {
            buffer[y * width + x] = floorColor
            y += 1
        }
    }
    
    // MARK: - Image Generation
    
    func generateImage() -> UIImage? {
        guard let cgImage = context.makeImage() else { return nil }
        return UIImage(cgImage: cgImage)
    }
}