//
//  MacPlatformImage.swift
//  Wolfenstein3d-Macintosh
//
//  Created by Tornike Gomareli on 24.05.25.
//

import AppKit
import Engine

/// macOS implementation of PlatformImage protocol wrapping NSImage
class MacPlatformImage: PlatformImage {
    private let nsImage: NSImage
    
    var width: Int {
        guard let representation = nsImage.representations.first else { return 0 }
        return representation.pixelsWide
    }
    
    var height: Int {
        guard let representation = nsImage.representations.first else { return 0 }
        return representation.pixelsHigh
    }
    
    init(nsImage: NSImage) {
        self.nsImage = nsImage
    }
    
    func pixelData() -> [UInt8] {
        guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
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