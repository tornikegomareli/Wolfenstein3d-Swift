import Foundation

public struct Map {
  public let width: Int
  public let height: Int
  private let data: [[Int]]
  
  public init(data: [[Int]]) {
    self.data = data
    self.height = data.count
    self.width = data.first?.count ?? 0
  }
  
  public func getTile(x: Int, y: Int) -> Int {
    guard x >= 0, x < width, y >= 0, y < height else {
      return -1
    }
    return data[x][y]
  }
  
  public func isWall(x: Int, y: Int) -> Bool {
    return getTile(x: x, y: y) > 0
  }
  
  public func isEmpty(x: Int, y: Int) -> Bool {
    return getTile(x: x, y: y) == 0
  }
  
  public func isInBounds(x: Int, y: Int) -> Bool {
    return x >= 0 && x < width && y >= 0 && y < height
  }
}