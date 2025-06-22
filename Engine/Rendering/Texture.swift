import Foundation

public class Texture {
  
  public let width: Int
  public let height: Int
  private let pixels: UnsafeMutablePointer<UInt32>
  private var columnCache: [[UInt32]]?
  
  public init(width: Int, height: Int, pixels: [UInt32]) {
    self.width = width
    self.height = height
    
    let pixelCount = width * height
    self.pixels = UnsafeMutablePointer<UInt32>.allocate(capacity: pixelCount)
    self.pixels.initialize(from: pixels, count: min(pixels.count, pixelCount))
  }
  
  public init?(image: PlatformImage) {
    self.width = image.width
    self.height = image.height
    
    let pixelCount = width * height
    pixels = UnsafeMutablePointer<UInt32>.allocate(capacity: pixelCount)
    
    let pixelData = image.pixelData()
    for i in 0..<pixelCount {
      let baseIndex = i * 4
      if baseIndex + 3 < pixelData.count {
        let r = UInt32(pixelData[baseIndex])
        let g = UInt32(pixelData[baseIndex + 1])
        let b = UInt32(pixelData[baseIndex + 2])
        let a = UInt32(pixelData[baseIndex + 3])
        pixels[i] = (a << 24) | (r << 16) | (g << 8) | b
      }
    }
  }
  
  deinit {
    pixels.deallocate()
  }
  
  
  public func sample(u: Double, v: Double) -> UInt32 {
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
  
  public func sampleColumn(u: Double, v: Double, height: Int) -> [UInt32] {
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
  
  public func sampleAtPixel(x: Int, y: Int) -> UInt32 {
    let clampedX = max(0, min(width - 1, x))
    let clampedY = max(0, min(height - 1, y))
    return pixels[clampedY * width + clampedX]
  }
  
  public func getColumnPixels(x: Int) -> [UInt32] {
    if columnCache == nil {
      var cache = [[UInt32]]()
      cache.reserveCapacity(width)
      
      for col in 0..<width {
        var column = [UInt32]()
        column.reserveCapacity(height)
        for row in 0..<height {
          column.append(pixels[row * width + col])
        }
        cache.append(column)
      }
      columnCache = cache
    }
    
    let clampedX = max(0, min(width - 1, x))
    guard clampedX < columnCache!.count else {
      var column = [UInt32]()
      column.reserveCapacity(height)
      for row in 0..<height {
        column.append(pixels[row * width + clampedX])
      }
      return column
    }
    
    return columnCache![clampedX]
  }
}