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
  
  init?(width: Int, height: Int) { // Now failable
    self.screenWidth = width
    self.screenHeight = height
    // Handle FrameBuffer's failable initializer
    guard let fb = FrameBuffer(width: width, height: height) else {
      // Consider logging this error
      return nil
    }
    self.frameBuffer = fb
    
    // It's good practice to ensure minWallDistance is positive if used as a divisor.
    // This check is more for RenderConfig, but good to be aware of.
    if RenderConfig.Rendering.minWallDistance <= 0 {
      // This could lead to division by zero or negative lineHeight.
      // fatalError("RenderConfig.Rendering.minWallDistance must be positive.")
      // Or handle gracefully. For now, assume it's configured correctly.
    }
  }
  
  // MARK: - Public Methods
  
  func render(player: Player, map: Map) -> UIImage? {
    // Clear screen (assumes 0xFF000000 is opaque black in ARGB for FrameBuffer)
    frameBuffer.clear(color: 0xFF000000) // Or RenderConfig.Colors.background
    
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
    // Use Double.greatestFiniteMagnitude for effectively infinite distance if ray is parallel to an axis.
    // Ensure RenderConfig.Rendering.maxRayDistance is set to this or a similar large value.
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
    
    // Perform DDA
    var hit = false
    var side = 0 // 0 for X-side (NS wall), 1 for Y-side (EW wall)
    var wallType = 0
    
    // Limit DDA steps to prevent infinite loops in open maps (optional, but good for robustness)
    // let maxDDASteps = screenWidth + screenHeight // Heuristic limit
    // var ddaSteps = 0
    
    while !hit /* && ddaSteps < maxDDASteps */ {
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
      // ddaSteps += 1
      
      // Check if ray has hit a wall or gone out of bounds
      if !map.isInBounds(x: mapX, y: mapY) {
        wallType = -1 // Special type for out-of-bounds
        hit = true
      } else if map.isWall(x: mapX, y: mapY) {
        wallType = map.getTile(x: mapX, y: mapY)
        hit = true
      }
    }
    
    // Calculate perpendicular distance to avoid fisheye
    let perpWallDist: Double
    let wallX: Double // Where exactly the wall was hit (0.0 to 1.0 on the wall segment)
    
    if side == 0 { // Hit an X-side (NS wall)
      // Simpler calculation for perpWallDist if using sideDistX
      // perpWallDist = sideDistX - deltaDistX
      perpWallDist = (Double(mapX) - player.x + (1.0 - Double(stepX)) / 2.0) / rayDirX
      wallX = player.y + perpWallDist * rayDirY
    } else { // Hit a Y-side (EW wall)
      // perpWallDist = sideDistY - deltaDistY
      perpWallDist = (Double(mapY) - player.y + (1.0 - Double(stepY)) / 2.0) / rayDirY
      wallX = player.x + perpWallDist * rayDirX
    }
    
    // Get fractional part of wallX for texture coordinate
    let wallXFraction = wallX - floor(wallX)
    
    return RaycastResult(
      wallDistance: max(RenderConfig.Rendering.minWallDistance, perpWallDist), // Ensure distance is not too small
      wallType: wallType,
      side: side,
      wallX: wallXFraction
    )
  }
  
  // MARK: - Textured Column Rendering
  
  private func renderTexturedColumn(x: Int, rayResult: RaycastResult) {
    // Calculate line height
    // Ensure rayResult.wallDistance is positive and not excessively small.
    // minWallDistance in RenderConfig should be a small positive float (e.g., 0.01).
    let lineHeight: Int
    if rayResult.wallDistance > RenderConfig.Rendering.minWallDistance {
      lineHeight = Int(Double(screenHeight) / rayResult.wallDistance)
    } else {
      lineHeight = screenHeight // Cap line height if wall is too close or distance is invalid
    }
    
    // Calculate draw positions (start and end Y for the wall slice)
    // Ensure screenHeight/2 doesn't cause issues if screenHeight is odd. Integer division is fine.
    let drawStartUnclamped = -lineHeight / 2 + screenHeight / 2
    let drawEndUnclamped = lineHeight / 2 + screenHeight / 2
    
    let drawStart = max(0, drawStartUnclamped)
    let drawEnd = min(screenHeight - 1, drawEndUnclamped)
    
    // Draw ceiling (solid color)
    if drawStart > 0 {
      frameBuffer.drawVerticalLine(x: x, startY: 0, endY: drawStart - 1, color: RenderConfig.Colors.ceiling)
    }
    
    // Get texture for this wall type
    guard let texture = textureManager.texture(for: rayResult.wallType) else {
      // Fallback to colored rendering if no texture
      renderColoredColumn(x: x, rayResult: rayResult) // Pass original rayResult
      return
    }
    
    // CRITICAL FIX: Ensure lineHeight is positive before using it as a divisor.
    guard lineHeight > 0 else {
      // Wall is too far or too small to be drawn with texture.
      // Ceiling is already drawn. Draw floor.
      if drawEnd < screenHeight - 1 {
        frameBuffer.drawVerticalLine(x: x, startY: drawEnd + 1, endY: screenHeight - 1, color: RenderConfig.Colors.floor)
      }
      return
    }
    
    // Calculate texture X coordinate (already done in rayResult.wallX)
    let texX = rayResult.wallX
    
    // Draw textured wall
    // `step` is how much to advance in texture Y for each screen pixel Y
    let step = 1.0 / Double(lineHeight)
    // `texPos` is the starting Y position in the texture. It's adjusted for cases
    // where the wall slice is partially off-screen.
    var texPos = (Double(drawStart) - Double(screenHeight) / 2.0 + Double(lineHeight) / 2.0) * step
    
    for y in drawStart...drawEnd {
      let texY = texPos
      texPos += step // Increment for the next pixel
      
      var color = texture.sample(u: texX, v: texY)
      
      // Apply shading for side walls (EW walls)
      if rayResult.side == 1 {
        let r = (color >> 16) & 0xFF
        let g = (color >> 8) & 0xFF
        let b = color & 0xFF
        let a = (color >> 24) & 0xFF // Assuming ARGB format (Alpha, Red, Green, Blue)
        
        let darkenedR = r / 2
        let darkenedG = g / 2
        let darkenedB = b / 2
        
        color = (a << 24) | (darkenedR << 16) | (darkenedG << 8) | darkenedB
      }
      frameBuffer.setPixel(x: x, y: y, color: color)
    }
    
    // Draw floor (solid color)
    if drawEnd < screenHeight - 1 {
      frameBuffer.drawVerticalLine(x: x, startY: drawEnd + 1, endY: screenHeight - 1, color: RenderConfig.Colors.floor)
    }
  }
  
  // MARK: - Colored Column Rendering (Fallback)
  
  private func renderColoredColumn(x: Int, rayResult: RaycastResult) {
    let lineHeight: Int
    if rayResult.wallDistance > RenderConfig.Rendering.minWallDistance {
      lineHeight = Int(Double(screenHeight) / rayResult.wallDistance)
    } else {
      lineHeight = screenHeight
    }
    
    let drawStartUnclamped = -lineHeight / 2 + screenHeight / 2
    let drawEndUnclamped = lineHeight / 2 + screenHeight / 2
    
    let drawStart = max(0, drawStartUnclamped)
    let drawEnd = min(screenHeight - 1, drawEndUnclamped)
    
    var wallColor = getWallColor(type: rayResult.wallType)
    
    // Make side walls (EW walls) darker
    if rayResult.side == 1 {
      // Explicitly darken R, G, B components by 50%, preserving Alpha
      // Assumes wallColor is ARGB (Alpha in MSB)
      let r = (wallColor >> 16) & 0xFF
      let g = (wallColor >> 8) & 0xFF
      let b = wallColor & 0xFF
      let a = (wallColor >> 24) & 0xFF
      
      let darkenedR = r / 2
      let darkenedG = g / 2
      let darkenedB = b / 2
      
      wallColor = (a << 24) | (darkenedR << 16) | (darkenedG << 8) | darkenedB
    }
    
    // Use FrameBuffer's fillColumn method
    // Note: The `ceilingEnd` parameter in FrameBuffer.fillColumn was noted as unused
    // in previous FrameBuffer optimization, assuming `wallStart` defines the ceiling's actual end.
    // Here, we provide `drawStart` for both, which aligns with common interpretations.
    frameBuffer.fillColumn(
      x: x,
      ceilingEnd: drawStart, // Effectively defines ceiling up to drawStart - 1
      wallStart: drawStart,  // Wall segment starts at drawStart
      wallEnd: drawEnd,      // Wall segment ends at drawEnd
      ceilingColor: RenderConfig.Colors.ceiling,
      wallColor: wallColor,
      floorColor: RenderConfig.Colors.floor
    )
  }
  
  private func getWallColor(type: Int) -> UInt32 {
    if type == -1 { // Out of bounds
      return RenderConfig.Colors.outOfBoundsColor
    }
    // Use dictionary lookup with a default value if the type is not found.
    return RenderConfig.Colors.wallColors[type] ?? RenderConfig.Colors.defaultWallColor
  }
}
