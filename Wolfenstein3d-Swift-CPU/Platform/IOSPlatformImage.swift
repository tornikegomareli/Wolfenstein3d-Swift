import UIKit
import Engine

/// iOS implementation of PlatformImage protocol wrapping UIImage
class IOSPlatformImage: PlatformImage {
    private let uiImage: UIImage
    
    var width: Int {
        return Int(uiImage.size.width * uiImage.scale)
    }
    
    var height: Int {
        return Int(uiImage.size.height * uiImage.scale)
    }
    
    init(uiImage: UIImage) {
        self.uiImage = uiImage
    }
    
    func pixelData() -> [UInt8] {
        guard let cgImage = uiImage.cgImage else {
            return []
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: height * bytesPerRow)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return []
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return pixelData
    }
}