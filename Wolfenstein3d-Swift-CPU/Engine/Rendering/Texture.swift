// Engine/Rendering/Texture.swift
import UIKit

class Texture {
    // MARK: - Properties
    
    let width: Int
    let height: Int
    private let pixels: UnsafeMutablePointer<UInt32>
    
    // MARK: - Initialization
    
    init?(named imageName: String) {
        guard let image = UIImage(named: imageName),
              let cgImage = image.cgImage else {
            return nil
        }
        
        self.width = cgImage.width
        self.height = cgImage.height
        
        // Allocate pixel buffer
        let pixelCount = width * height
        pixels = UnsafeMutablePointer<UInt32>.allocate(capacity: pixelCount)
        
        // Create bitmap context to read pixel data
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            pixels.deallocate()
            return nil
        }
        
        // Draw image into context to get pixel data
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    deinit {
        pixels.deallocate()
    }
    
    // MARK: - Texture Sampling
    
    func sample(u: Double, v: Double) -> UInt32 {
        // Wrap texture coordinates
        var wrappedU = u.truncatingRemainder(dividingBy: 1.0)
        var wrappedV = v.truncatingRemainder(dividingBy: 1.0)
        
        // Handle negative values
        if wrappedU < 0 { wrappedU += 1.0 }
        if wrappedV < 0 { wrappedV += 1.0 }
        
        // Convert to pixel coordinates
        let x = Int(wrappedU * Double(width))
        let y = Int(wrappedV * Double(height))
        
        // Clamp to texture bounds
        let clampedX = max(0, min(width - 1, x))
        let clampedY = max(0, min(height - 1, y))
        
        return pixels[clampedY * width + clampedX]
    }
    
    func sampleColumn(u: Double, v: Double, height: Int) -> [UInt32] {
        var column = [UInt32]()
        column.reserveCapacity(height)
        
        let vStep = 1.0 / Double(height)
        var currentV = v
        
        for _ in 0..<height {
            column.append(sample(u: u, v: currentV))
            currentV += vStep
        }
        
        return column
    }
    
    // For debugging
    func sampleAtPixel(x: Int, y: Int) -> UInt32 {
        let clampedX = max(0, min(width - 1, x))
        let clampedY = max(0, min(height - 1, y))
        return pixels[clampedY * width + clampedX]
    }
}