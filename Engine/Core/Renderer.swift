import Foundation

public struct RaycastResult {
  let wallDistance: Double
  let wallType: Int
  let side: Int
  let wallX: Double
}

public class Renderer {
  
  public let frameBuffer: FrameBuffer
  private let screenWidth: Int
  private let screenHeight: Int
  private let textureManager: TextureManager
  
  private let renderQueue = DispatchQueue(label: "render.queue", attributes: .concurrent)
  private let stripCount = 8
  
  
  public init(width: Int, height: Int) {
    self.screenWidth = width
    self.screenHeight = height
    self.frameBuffer = FrameBuffer(width: width, height: height)
    self.textureManager = TextureManager.shared
  }
  
  
  public func render(player: Player, map: Map) {
    frameBuffer.clear(color: 0xFF000000)
    
    let columnsPerStrip = screenWidth / stripCount
    
    DispatchQueue.concurrentPerform(iterations: stripCount) { stripIndex in
      let startX = stripIndex * columnsPerStrip
      let endX = (stripIndex == stripCount - 1) ? screenWidth : (stripIndex + 1) * columnsPerStrip
      
      for x in startX..<endX {
        let rayResult = castRay(screenX: x, player: player, map: map)
        
        if RenderConfig.Rendering.useTextures {
          renderTexturedColumn(x: x, rayResult: rayResult)
        } else {
          renderColoredColumn(x: x, rayResult: rayResult)
        }
      }
    }
  }
  
  
  private func castRay(screenX: Int, player: Player, map: Map) -> RaycastResult {
    let cameraX = 2.0 * Double(screenX) / Double(screenWidth) - 1.0
    let rayDirX = player.dirX + player.planeX * cameraX
    let rayDirY = player.dirY + player.planeY * cameraX
    
    var mapX = Int(player.x)
    var mapY = Int(player.y)
    
    let deltaDistX = (rayDirX == 0) ? Double.greatestFiniteMagnitude : abs(1.0 / rayDirX)
    let deltaDistY = (rayDirY == 0) ? Double.greatestFiniteMagnitude : abs(1.0 / rayDirY)
    
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
    
    var hit = false
    var side = 0
    var wallType = 0
    
    while !hit {
      if sideDistX < sideDistY {
        sideDistX += deltaDistX
        mapX += stepX
        side = 0
      } else {
        sideDistY += deltaDistY
        mapY += stepY
        side = 1
      }
      
      if !map.isInBounds(x: mapX, y: mapY) {
        wallType = -1
        hit = true
      } else if map.isWall(x: mapX, y: mapY) {
        wallType = map.getTile(x: mapX, y: mapY)
        hit = true
      }
    }
    
    let perpWallDist: Double
    let wallX: Double
    
    if side == 0 {
      perpWallDist = (Double(mapX) - player.x + (1.0 - Double(stepX)) / 2.0) / rayDirX
      wallX = player.y + perpWallDist * rayDirY
    } else {
      perpWallDist = (Double(mapY) - player.y + (1.0 - Double(stepY)) / 2.0) / rayDirY
      wallX = player.x + perpWallDist * rayDirX
    }
    
    let wallXFraction = wallX - floor(wallX)
    
    return RaycastResult(
      wallDistance: max(RenderConfig.Rendering.minWallDistance, perpWallDist),
      wallType: wallType,
      side: side,
      wallX: wallXFraction
    )
  }
  
  
  private func renderTexturedColumn(x: Int, rayResult: RaycastResult) {
    let lineHeight: Int
    if rayResult.wallDistance > RenderConfig.Rendering.minWallDistance {
      lineHeight = min(Int(Double(screenHeight) / rayResult.wallDistance), screenHeight * 4)
    } else {
      lineHeight = screenHeight * 4
    }
    
    let drawStartUnclamped = -lineHeight / 2 + screenHeight / 2
    let drawEndUnclamped = lineHeight / 2 + screenHeight / 2
    
    let drawStart = max(0, drawStartUnclamped)
    let drawEnd = min(screenHeight - 1, drawEndUnclamped)
    
    if drawStart > 0 {
      frameBuffer.drawVerticalLine(x: x, startY: 0, endY: drawStart - 1, color: RenderConfig.Colors.ceiling)
    }
    
    guard let texture = textureManager.texture(for: rayResult.wallType) else {
      renderColoredColumn(x: x, rayResult: rayResult)
      return
    }
    
    guard lineHeight > 0 else {
      if drawEnd < screenHeight - 1 {
        frameBuffer.drawVerticalLine(x: x, startY: drawEnd + 1, endY: screenHeight - 1, color: RenderConfig.Colors.floor)
      }
      return
    }
    
    let texX = Int(rayResult.wallX * Double(texture.width)) % texture.width
    
    if lineHeight > screenHeight * 2 {
      renderCloseWallColumn(x: x, texX: texX, texture: texture, 
                           drawStart: drawStart, drawEnd: drawEnd, 
                           lineHeight: lineHeight, needsDarkening: rayResult.side == 1)
      
      if drawEnd < screenHeight - 1 {
        frameBuffer.drawVerticalLine(x: x, startY: drawEnd + 1, endY: screenHeight - 1, color: RenderConfig.Colors.floor)
      }
      return
    }
    
    let texStepFixed = (texture.height << 16) / lineHeight
    var texPosFixed = ((drawStart - screenHeight / 2 + lineHeight / 2) * texStepFixed)
    
    let texturePixels = texture.getColumnPixels(x: texX)
    
    let needsDarkening = rayResult.side == 1
    
    if needsDarkening {
      for y in drawStart...drawEnd {
        let texY = min(texture.height - 1, max(0, texPosFixed >> 16))
        let color = texturePixels[texY]
        
        let r = (color >> 17) & 0x7F
        let g = (color >> 9) & 0x7F
        let b = (color >> 1) & 0x7F
        let a = color & 0xFF000000
        
        frameBuffer.setPixel(x: x, y: y, color: a | (r << 16) | (g << 8) | b)
        texPosFixed += texStepFixed
      }
    } else {
      for y in drawStart...drawEnd {
        let texY = min(texture.height - 1, max(0, texPosFixed >> 16))
        frameBuffer.setPixel(x: x, y: y, color: texturePixels[texY])
        texPosFixed += texStepFixed
      }
    }
    
    // Draw floor
    if drawEnd < screenHeight - 1 {
      frameBuffer.drawVerticalLine(x: x, startY: drawEnd + 1, endY: screenHeight - 1, color: RenderConfig.Colors.floor)
    }
  }
  
  
  private func renderColoredColumn(x: Int, rayResult: RaycastResult) {
    let lineHeight: Int
    if rayResult.wallDistance > RenderConfig.Rendering.minWallDistance {
      lineHeight = min(Int(Double(screenHeight) / rayResult.wallDistance), screenHeight * 4)
    } else {
      lineHeight = screenHeight * 4
    }
    
    let drawStartUnclamped = -lineHeight / 2 + screenHeight / 2
    let drawEndUnclamped = lineHeight / 2 + screenHeight / 2
    
    let drawStart = max(0, drawStartUnclamped)
    let drawEnd = min(screenHeight - 1, drawEndUnclamped)
    
    var wallColor = getWallColor(type: rayResult.wallType)
    
    if rayResult.side == 1 {
      let r = (wallColor >> 16) & 0xFF
      let g = (wallColor >> 8) & 0xFF
      let b = wallColor & 0xFF
      let a = (wallColor >> 24) & 0xFF
      
      let darkenedR = r / 2
      let darkenedG = g / 2
      let darkenedB = b / 2
      
      wallColor = (a << 24) | (darkenedR << 16) | (darkenedG << 8) | darkenedB
    }
    
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
  
  
  private func renderCloseWallColumn(x: Int, texX: Int, texture: Texture,
                                    drawStart: Int, drawEnd: Int, 
                                    lineHeight: Int, needsDarkening: Bool) {
    let skipFactor = max(1, lineHeight / (screenHeight * 2))
    let texturePixels = texture.getColumnPixels(x: texX)
    
    let texStepFixed = (texture.height << 16) / lineHeight
    var texPosFixed = ((drawStart - screenHeight / 2 + lineHeight / 2) * texStepFixed)
    
    if needsDarkening {
      var y = drawStart
      while y <= drawEnd {
        let texY = min(texture.height - 1, max(0, texPosFixed >> 16))
        let color = texturePixels[texY]
        
        let r = (color >> 17) & 0x7F
        let g = (color >> 9) & 0x7F
        let b = (color >> 1) & 0x7F
        let a = color & 0xFF000000
        
        let darkenedColor = a | (r << 16) | (g << 8) | b
        
        let fillEnd = min(drawEnd, y + skipFactor - 1)
        for fillY in y...fillEnd {
          frameBuffer.setPixelUnsafe(x: x, y: fillY, color: darkenedColor)
        }
        
        y += skipFactor
        texPosFixed += texStepFixed * skipFactor
      }
    } else {
      var y = drawStart
      while y <= drawEnd {
        let texY = min(texture.height - 1, max(0, texPosFixed >> 16))
        let color = texturePixels[texY]
        
        let fillEnd = min(drawEnd, y + skipFactor - 1)
        for fillY in y...fillEnd {
          frameBuffer.setPixelUnsafe(x: x, y: fillY, color: color)
        }
        
        y += skipFactor
        texPosFixed += texStepFixed * skipFactor
      }
    }
  }
}