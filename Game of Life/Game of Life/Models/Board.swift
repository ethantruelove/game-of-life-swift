//
//  Board.swift
//  Game of Life
//
//  Created by Ethan Truelove on 2/26/25.
//

import Observation
import SwiftUI

@Observable
class Board {
    let width: Int
    let height: Int
    var grid: [Bool]
    var autoplay: Bool
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.grid = Array(repeating: false, count: width * height)
        self.autoplay = false
    }
    
    private func index(x: Int, y: Int) -> Int {
        guard x >= 0, y >= 0, x * y < grid.count else { return -1 }
        return ((y + height) % height) * width + ((x + width) % width)
    }
    
    func setCell(x: Int, y: Int, state: Bool) {
        let ind = index(x: x, y: y)
        guard ind >= 0 else { return }
        grid[ind] = state
    }
    
    func getCell(x: Int, y: Int) -> Bool {
        let ind = index(x: x, y: y)
        guard ind >= 0 else { return false }
        return grid[ind]
    }
    
    func toggleCell(x: Int, y: Int) {
        grid[index(x: x, y: y)].toggle()
    }
    
    func tick() {
        var nextGrid = grid
        for x in 0..<width {
            for y in 0..<height {
                let state = getCell(x: x, y: y)
                let neighbors = aliveNeighborCount(x: x, y: y)
                nextGrid[index(x: x, y: y)] = (state && (neighbors == 2 || neighbors == 3)) || (!state && neighbors == 3)
            }
        }
        
        grid = nextGrid
    }
    
    private func aliveNeighborCount(x: Int, y: Int) -> Int {
        let radius = -1...1
        
        // generate all pairs in radius and reduce state
        let count = radius.flatMap {
            dx in radius.map { dy in (dx, dy) }
        }
        .map { getCell(x: x + $0.0, y: y + $0.1) ? 1 : 0 }
        .reduce(0, +)
        
        // we do not want to count ourself if it happens to be alive
        // introduces some extra check but prevents filtering the whole list for the one known element
        if getCell(x: x, y: y) {
            return count - 1
        }

        return count
    }
    
    func randomize() {
        for i in 0..<grid.count {
            grid[i] = Bool.random()
        }
    }
}
