//
//  RenderEngine.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 24.05.25.
//

import UIKit

class FrameBuffer {
  // MARK: - Properties
  
  let width: Int
  let height: Int
  let pixelCount: Int
  
  private(set) var buffer: UnsafeMutablePointer<UInt32>
  private var context: CGContext!
  
  // MARK: - Initialization
  
  init?(width: Int, height: Int) { // Changed to failable initializer for context creation
    self.width = width
    self.height = height
    self.pixelCount = width * height
    
    // Allocate buffer
    buffer = UnsafeMutablePointer<UInt32>.allocate(capacity: pixelCount)
    
    // Create bitmap context
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let ctx = CGContext(
      data: buffer,
      width: width,
      height: height,
      bitsPerComponent: 8,
      bytesPerRow: width * 4, // Each UInt32 pixel is 4 bytes
      space: colorSpace,
      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Big.rawValue // Common for ARGB UInt32
    ) else {
      // Buffer must be deallocated if context creation fails and init fails
      buffer.deallocate()
      // Return nil if context creation fails
      // Alternatively, you could fatalError, but failable init is safer
      // fatalError("Failed to create CGContext")
      return nil
    }
    self.context = ctx
  }
  
  deinit {
    buffer.deallocate()
  }
  
  // MARK: - Drawing Methods
  
  /// Fills the entire buffer with a single color.
  func clear(color: UInt32) {
    // Optimized: Use `initialize` for potentially faster memory fill.
    buffer.initialize(repeating: color, count: pixelCount)
  }
  
  /// Sets the color of a single pixel.
  @inline(__always) // Suggest inlining for this frequently called, small function
  func setPixel(x: Int, y: Int, color: UInt32) {
    // Bounds checking is essential.
    guard x >= 0, x < width, y >= 0, y < height else { return }
    buffer[y * width + x] = color
  }
  
  /// Draws a vertical line with a single color.
  func drawVerticalLine(x: Int, startY: Int, endY: Int, color: UInt32) {
    // Ensure x is within bounds first to avoid unnecessary calculations.
    guard x >= 0, x < width else { return }
    
    // Clamp Y coordinates to be within the buffer's height.
    let safeStartY = max(0, startY)
    let safeEndY = min(height - 1, endY)
    
    // If the clamped start is after the clamped end, there's nothing to draw.
    guard safeStartY <= safeEndY else { return }
    
    for y in safeStartY...safeEndY {
      buffer[y * width + x] = color
    }
  }
  
  /**
   * Fills a vertical column of pixels with ceiling, wall, and floor colors.
   * Note: The `ceilingEnd` parameter is currently unused in the provided logic.
   * If it's intended to be used, the drawing logic for the ceiling would need adjustment.
   */
  func fillColumn(x: Int, ceilingEnd: Int, wallStart: Int, wallEnd: Int,
                  ceilingColor: UInt32, wallColor: UInt32, floorColor: UInt32) {
    guard x >= 0, x < width else { return }
    
    var y = 0
    
    // Determine the actual boundaries for drawing, clamped to the buffer height.
    let actualWallStart = max(0, min(wallStart, height))
    let actualWallEnd = max(0, min(wallEnd, height - 1)) // wallEnd is inclusive
    
    // Draw ceiling
    // Iterates from y = 0 up to, but not including, actualWallStart.
    while y < actualWallStart {
      buffer[y * width + x] = ceilingColor
      y += 1
    }
    
    // Draw wall
    // Iterates from y = actualWallStart up to, and including, actualWallEnd.
    // Ensures y does not exceed buffer height.
    while y <= actualWallEnd && y < height {
      buffer[y * width + x] = wallColor
      y += 1
    }
    
    // Draw floor
    // Iterates from the pixel after the wall up to the buffer height.
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
