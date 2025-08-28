import Foundation

public class FrameBuffer {
  
  public let width: Int
  public let height: Int
  public let pixelCount: Int
  
  public private(set) var buffer: UnsafeMutablePointer<UInt32>
  
  
  public init(width: Int, height: Int) {
    self.width = width
    self.height = height
    self.pixelCount = width * height
    
    buffer = UnsafeMutablePointer<UInt32>.allocate(capacity: pixelCount)
  }
  
  deinit {
    buffer.deallocate()
  }
  
  
  public func clear(color: UInt32) {
    buffer.initialize(repeating: color, count: pixelCount)
  }
  
  @inline(__always)
  public func setPixel(x: Int, y: Int, color: UInt32) {
    #if DEBUG
    guard x >= 0, x < width, y >= 0, y < height else { return }
    #endif
    buffer[y * width + x] = color
  }
  
  @inline(__always)
  public func setPixelUnsafe(x: Int, y: Int, color: UInt32) {
    buffer[y * width + x] = color
  }
  
  public func drawVerticalLine(x: Int, startY: Int, endY: Int, color: UInt32) {
    guard x >= 0, x < width else { return }
    
    let safeStartY = max(0, startY)
    let safeEndY = min(height - 1, endY)
    
    guard safeStartY <= safeEndY else { return }
    
    var ptr = buffer.advanced(by: safeStartY * width + x)
    for _ in safeStartY...safeEndY {
      ptr.pointee = color
      ptr = ptr.advanced(by: width)
    }
  }
  
  public func fillColumn(x: Int, ceilingEnd: Int, wallStart: Int, wallEnd: Int,
                         ceilingColor: UInt32, wallColor: UInt32, floorColor: UInt32) {
    guard x >= 0, x < width else { return }
    
    var y = 0
    
    let actualWallStart = max(0, min(wallStart, height))
    let actualWallEnd = max(0, min(wallEnd, height - 1))
    
    while y < actualWallStart {
      buffer[y * width + x] = ceilingColor
      y += 1
    }
    
    while y <= actualWallEnd && y < height {
      buffer[y * width + x] = wallColor
      y += 1
    }
    
    while y < height {
      buffer[y * width + x] = floorColor
      y += 1
    }
  }
  
  /// Fast block fill for performance-critical close wall rendering
  @inline(__always)
  public func fillVerticalBlock(x: Int, startY: Int, endY: Int, color: UInt32) {
    guard x >= 0, x < width else { return }
    let safeStartY = max(0, startY)
    let safeEndY = min(height - 1, endY)
    guard safeStartY <= safeEndY else { return }
    
    /// Use pointer arithmetic for maximum speed
    var ptr = buffer.advanced(by: safeStartY * width + x)
    for _ in safeStartY...safeEndY {
      ptr.pointee = color
      ptr = ptr.advanced(by: width)
    }
  }
  
  
  public func getPixelData() -> [UInt32] {
    return Array(UnsafeBufferPointer(start: buffer, count: pixelCount))
  }
  
  public func withPixelBuffer<T>(_ body: (UnsafePointer<UInt32>, Int) throws -> T) rethrows -> T {
    return try body(buffer, pixelCount)
  }
}