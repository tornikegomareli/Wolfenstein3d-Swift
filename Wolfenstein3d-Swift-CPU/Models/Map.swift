//
//  Map.swift
//  Wolfenstein3d-Swift-CPU
//
//  Created by Tornike Gomareli on 24.05.25.
//


import Foundation

struct Map {
  let width: Int
  let height: Int
  private let data: [[Int]]
  
  init(data: [[Int]]) {
    self.data = data
    self.height = data.count
    self.width = data.first?.count ?? 0
  }
  
  func getTile(x: Int, y: Int) -> Int {
    guard x >= 0, x < width, y >= 0, y < height else {
      return -1
    }
    // `data` is stored row-major where the first index represents the
    // vertical coordinate (y) and the second index represents the horizontal
    // coordinate (x).  The previous implementation accessed `data[x][y]`,
    // effectively transposing the map which resulted in incorrect lookups on
    // non‑square or asymmetric maps.  This also produced subtle rendering
    // glitches because the collision system queried tiles from unexpected
    // positions.  Access the array using `y` first to obtain the correct tile.
    return data[y][x]
  }
  
  func isWall(x: Int, y: Int) -> Bool {
    return getTile(x: x, y: y) > 0
  }
  
  func isEmpty(x: Int, y: Int) -> Bool {
    return getTile(x: x, y: y) == 0
  }
  
  func isInBounds(x: Int, y: Int) -> Bool {
    return x >= 0 && x < width && y >= 0 && y < height
  }
}
