//
//  RenderEngine.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 24.05.25.
//


// Engine/Core/RenderEngine.swift
import UIKit

class RenderEngine: RenderEngineProtocol {
  // MARK: - Properties
  
  private let renderer: Renderer
  
  // MARK: - Initialization
  
  init() {
    self.renderer = Renderer(
      width: RenderConfig.Screen.width,
      height: RenderConfig.Screen.height
    )
  }
  
  // MARK: - RenderEngineProtocol
  
  func render(player: Player, map: Map) -> UIImage? {
    return renderer.render(player: player, map: map)
  }
}
