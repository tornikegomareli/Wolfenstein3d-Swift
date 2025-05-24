// Models/Map.swift
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
            return -1 // Out of bounds
        }
        return data[x][y]
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