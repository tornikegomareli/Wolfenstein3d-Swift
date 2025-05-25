//
//  Texture.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 25.05.25.
//


// Engine/Rendering/Texture.swift
import UIKit

class Texture {
  
  let width: Int
  let height: Int
  private let pixels: UnsafeMutablePointer<UInt32>
  
  
  init?(named imageName: String) {
    guard let image = UIImage(named: imageName),
          let cgImage = image.cgImage else {
      return nil
    }
    
    self.width = cgImage.width
    self.height = cgImage.height
    
    /// Allocate pixel buffer
    let pixelCount = width * height
    pixels = UnsafeMutablePointer<UInt32>.allocate(capacity: pixelCount)
    
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
    
    /// Draw image into context to get pixel data
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
  }
  
  deinit {
    pixels.deallocate()
  }
  
  
  func sample(u: Double, v: Double) -> UInt32 {
    var wrappedU = u.truncatingRemainder(dividingBy: 1.0)
    var wrappedV = v.truncatingRemainder(dividingBy: 1.0)
    
    if wrappedU < 0 { wrappedU += 1.0 }
    if wrappedV < 0 { wrappedV += 1.0 }
    
    let x = Int(wrappedU * Double(width))
    let y = Int(wrappedV * Double(height))
    
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
  
  func sampleAtPixel(x: Int, y: Int) -> UInt32 {
    let clampedX = max(0, min(width - 1, x))
    let clampedY = max(0, min(height - 1, y))
    return pixels[clampedY * width + clampedX]
  }
}
