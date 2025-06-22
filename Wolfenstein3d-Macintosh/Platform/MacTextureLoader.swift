//
//  MacTextureLoader.swift
//  Wolfenstein3d-Macintosh
//
//  Created by Tornike Gomareli on 24.05.25.
//

import AppKit
import Engine

/// macOS implementation of TextureLoader protocol
class MacTextureLoader: TextureLoader {
    func loadTexture(named name: String) -> PlatformImage? {
        guard let nsImage = NSImage(named: name) else {
            // Try to load from main bundle if not found in asset catalog
            guard let path = Bundle.main.path(forResource: name, ofType: "png"),
                  let image = NSImage(contentsOfFile: path) else {
                return nil
            }
            return MacPlatformImage(nsImage: image)
        }
        return MacPlatformImage(nsImage: nsImage)
    }
    
    func loadTexture(from data: Data) -> PlatformImage? {
        guard let nsImage = NSImage(data: data) else {
            return nil
        }
        return MacPlatformImage(nsImage: nsImage)
    }
}