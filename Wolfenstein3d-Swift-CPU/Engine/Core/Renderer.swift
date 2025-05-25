// Engine/Rendering/Renderer.swift
import UIKit

struct RaycastResult {
  let wallDistance: Double
  let wallType: Int
  let side: Int // 0 = NS, 1 = EW
  let wallX: Double // Where exactly the wall was hit [0.0, 1.0]
}

class Renderer {
  // MARK: - Properties
  
  private let frameBuffer: FrameBuffer
  private let screenWidth: Int
  private let screenHeight: Int
  private let textureManager = TextureManager.shared
  
  // MARK: - Initialization
  
  init(width: Int, height: Int) {
    self.screenWidth = width
    self.screenHeight = height
    self.frameBuffer = FrameBuffer(width: width, height: height)
  }
  
  // MARK: - Public Methods
  
  func render(player: Player, map: Map) -> UIImage? {
    // Clear screen
    frameBuffer.clear(color: 0xFF000000)
    
    // Render each column
    for x in 0..<screenWidth {
      let rayResult = castRay(screenX: x, player: player, map: map)
      
      if RenderConfig.Rendering.useTextures {
        renderTexturedColumn(x: x, rayResult: rayResult)
      } else {
        renderColoredColumn(x: x, rayResult: rayResult)
      }
    }
    
    return frameBuffer.generateImage()
  }
  
  // MARK: - Raycasting
  
  private func castRay(screenX: Int, player: Player, map: Map) -> RaycastResult {
    // Calculate ray position and direction
    let cameraX = 2.0 * Double(screenX) / Double(screenWidth) - 1.0
    let rayDirX = player.dirX + player.planeX * cameraX
    let rayDirY = player.dirY + player.planeY * cameraX
    
    // Current map position
    var mapX = Int(player.x)
    var mapY = Int(player.y)
    
    // Calculate step and initial sideDist
    let deltaDistX = rayDirX == 0 ? RenderConfig.Rendering.maxRayDistance : abs(1.0 / rayDirX)
    let deltaDistY = rayDirY == 0 ? RenderConfig.Rendering.maxRayDistance : abs(1.0 / rayDirY)
    
    var sideDistX: Double
    var sideDistY: Double
    var stepX: Int
    var stepY: Int
    
    if rayDirX < 0 {
      stepX = -1
      sideDistX = (player.x - Double(mapX)) * deltaDistX
    } else {
      stepX = 1
      sideDistX = (Double(mapX) + 1.0 - player.x) * deltaDistX
    }
    
    if rayDirY < 0 {
      stepY = -1
      sideDistY = (player.y - Double(mapY)) * deltaDistY
    } else {
      stepY = 1
      sideDistY = (Double(mapY) + 1.0 - player.y) * deltaDistY
    }
    
    // Perform DDA
    var hit = false
    var side = 0
    var wallType = 0
    
    while !hit {
      // Jump to next map square
      if sideDistX < sideDistY {
        sideDistX += deltaDistX
        mapX += stepX
        side = 0
      } else {
        sideDistY += deltaDistY
        mapY += stepY
        side = 1
      }
      
      // Check if ray has hit a wall
      if !map.isInBounds(x: mapX, y: mapY) {
        wallType = -1
        hit = true
      } else if map.isWall(x: mapX, y: mapY) {
        wallType = map.getTile(x: mapX, y: mapY)
        hit = true
      }
    }
    
    // Calculate perpendicular distance
    let perpWallDist: Double
    let wallX: Double
    
    if side == 0 {
      perpWallDist = (Double(mapX) - player.x + Double(1 - stepX) / 2.0) / rayDirX
      wallX = player.y + perpWallDist * rayDirY
    } else {
      perpWallDist = (Double(mapY) - player.y + Double(1 - stepY) / 2.0) / rayDirY
      wallX = player.x + perpWallDist * rayDirX
    }
    
    // Get fractional part of wallX for texture coordinate
    let wallXFraction = wallX - floor(wallX)
    
    return RaycastResult(
      wallDistance: perpWallDist,
      wallType: wallType,
      side: side,
      wallX: wallXFraction
    )
  }
  
  // MARK: - Textured Column Rendering
  
  private func renderTexturedColumn(x: Int, rayResult: RaycastResult) {
    // Calculate line height
    let lineHeight: Int
    if rayResult.wallDistance > RenderConfig.Rendering.minWallDistance {
      lineHeight = Int(Double(screenHeight) / rayResult.wallDistance)
    } else {
      lineHeight = screenHeight
    }
    
    // Calculate draw positions
    let drawStart = max(0, -lineHeight / 2 + screenHeight / 2)
    let drawEnd = min(screenHeight - 1, lineHeight / 2 + screenHeight / 2)
    
    // Get texture for this wall type
    guard let texture = textureManager.texture(for: rayResult.wallType) else {
      // Fallback to colored rendering if no texture
      renderColoredColumn(x: x, rayResult: rayResult)
      return
    }
    
    // Calculate texture coordinate
    let texX = rayResult.wallX
    
    // Draw ceiling
    for y in 0..<drawStart {
      frameBuffer.setPixel(x: x, y: y, color: RenderConfig.Colors.ceiling)
    }
    
    // Draw textured wall
    let wallHeight = drawEnd - drawStart + 1
    if wallHeight > 0 {
      let step = 1.0 / Double(lineHeight)
      let texStartY = (Double(drawStart) - Double(screenHeight) / 2.0 + Double(lineHeight) / 2.0) * step
      
      for y in drawStart...drawEnd {
        let texY = texStartY + Double(y - drawStart) * step
        var color = texture.sample(u: texX, v: texY)
        
        // Apply shading for side walls
        if rayResult.side == 1 {
          // Darken the color
          let r = (color >> 16) & 0xFF
          let g = (color >> 8) & 0xFF
          let b = color & 0xFF
          let a = (color >> 24) & 0xFF
          
          let darkenedR = r / 2
          let darkenedG = g / 2
          let darkenedB = b / 2
          
          color = (a << 24) | (darkenedR << 16) | (darkenedG << 8) | darkenedB
        }
        
        frameBuffer.setPixel(x: x, y: y, color: color)
      }
    }
    
    // Draw floor
    for y in (drawEnd + 1)..<screenHeight {
      frameBuffer.setPixel(x: x, y: y, color: RenderConfig.Colors.floor)
    }
  }
  
  // MARK: - Colored Column Rendering (Fallback)
  
  private func renderColoredColumn(x: Int, rayResult: RaycastResult) {
    // Calculate line height
    let lineHeight: Int
    if rayResult.wallDistance > RenderConfig.Rendering.minWallDistance {
      lineHeight = Int(Double(screenHeight) / rayResult.wallDistance)
    } else {
      lineHeight = screenHeight
    }
    
    // Calculate draw positions
    let drawStart = max(0, -lineHeight / 2 + screenHeight / 2)
    let drawEnd = min(screenHeight - 1, lineHeight / 2 + screenHeight / 2)
    
    // Get wall color
    var wallColor = getWallColor(type: rayResult.wallType)
    
    // Make side walls darker
    if rayResult.side == 1 {
      wallColor = (wallColor >> 1) & RenderConfig.Rendering.wallDarkeningFactor
    }
    
    // Draw column
    frameBuffer.fillColumn(
      x: x,
      ceilingEnd: drawStart,
      wallStart: drawStart,
      wallEnd: drawEnd,
      ceilingColor: RenderConfig.Colors.ceiling,
      wallColor: wallColor,
      floorColor: RenderConfig.Colors.floor
    )
  }
  
  private func getWallColor(type: Int) -> UInt32 {
    if type == -1 {
      return RenderConfig.Colors.outOfBoundsColor
    }
    return RenderConfig.Colors.wallColors[type] ?? RenderConfig.Colors.defaultWallColor
  }
}
