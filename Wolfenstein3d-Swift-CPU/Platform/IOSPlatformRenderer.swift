import UIKit
import Engine

/// iOS implementation of PlatformRenderer protocol for creating UIImages
class IOSPlatformRenderer: PlatformRenderer {
    typealias ImageType = UIImage
    
    func createImage(from pixelData: [UInt32], width: Int, height: Int) -> UIImage? {
        let pixelCount = width * height
        guard pixelData.count >= pixelCount else { return nil }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var mutablePixelData = pixelData
        guard let context = CGContext(
            data: &mutablePixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
            return nil
        }
        
        guard let cgImage = context.makeImage() else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    /// Create image directly from FrameBuffer
    func createImage(from frameBuffer: FrameBuffer) -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        return frameBuffer.withPixelBuffer { buffer, count in
            guard let context = CGContext(
                data: UnsafeMutableRawPointer(mutating: buffer),
                width: frameBuffer.width,
                height: frameBuffer.height,
                bitsPerComponent: 8,
                bytesPerRow: frameBuffer.width * 4,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            ) else {
                return nil
            }
            
            guard let cgImage = context.makeImage() else {
                return nil
            }
            
            return UIImage(cgImage: cgImage)
        }
    }
}