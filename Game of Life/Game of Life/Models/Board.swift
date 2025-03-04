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
    private var lastToggledIndex: Int = -1
    var cells: Set<Int>
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.cells = Set<Int>()
    }
    
    private func index(x: Int, y: Int) -> Int {
        guard x >= 0, x < width, y >= 0, y < height else { return -1 }
        return y * width + x
    }
    
    private func coordinates(from index: Int) -> (x: Int, y: Int) {
        return (index % width, index / width)
    }
    
    func setCell(x: Int, y: Int, state: Bool) {
        setCell(idx: index(x: x, y: y), state: state)
    }
    
    func setCell(idx: Int, state: Bool) {
        guard idx >= 0 else { return }
        if state {
            cells.insert(idx)
        } else {
            cells.remove(idx)
        }
    }
    
    func getCell(x: Int, y: Int) -> Bool {
        getCell(idx: index(x: x, y: y))
    }
    
    func getCell(idx: Int) -> Bool {
        guard idx >= 0 else { return false }
        return cells.contains(idx)
    }
    
    func toggleCell(x: Int, y: Int) {
        let toggleIndex = index(x: x, y: y)
        if toggleIndex != lastToggledIndex {
            setCell(idx: toggleIndex, state: !getCell(idx: toggleIndex))
            lastToggledIndex = toggleIndex
        }
    }
    
    func tickAsync() async {
        // attribution: https://www.avanderlee.com/concurrency/detached-tasks/
        let nextGeneration = await Task.detached() { [self] in
            var cellsToCheck = Set<Int>()
            
            for cellIdx in cells {
                let (x, y) = coordinates(from: cellIdx)
                cellsToCheck.insert(cellIdx)
                
                for dx in -1...1 {
                    for dy in -1...1 {
                        let nX = x + dx
                        let nY = y + dy
                        if nX >= 0 && nX < width && nY >= 0 && nY < height {
                            cellsToCheck.insert(index(x: nX, y: nY))
                        }
                    }
                }
            }
            
            var nextGen = Set<Int>()
            
            for cellIdx in cellsToCheck {
                let (x, y) = coordinates(from: cellIdx)
                let isAlive = cells.contains(cellIdx)
                let nCount = aliveNeighborCount(x: x, y: y)
                
                if isAlive && (nCount == 2 || nCount == 3) {
                    nextGen.insert(cellIdx)
                } else if !isAlive && nCount == 3 {
                    nextGen.insert(cellIdx)
                }
            }
            
            return nextGen
        }.value
        
        await MainActor.run {
            self.cells = nextGeneration
        }
    }
    
    private func aliveNeighborCount(x: Int, y: Int) -> Int {
        let radius = -1...1
        
        // generate all pairs in radius and reduce state
        return radius.flatMap {
            dx in radius.map { dy in (dx, dy) }
        }
        .filter { $0 != (0,0) }
        .map {
            let nIdx = index(x: x + $0.0, y: y + $0.1)
            if nIdx >= 0 && cells.contains(nIdx) {
                return 1
            } else {
                return 0
            }
        }
        .reduce(0, +)
    }
    
    func randomize() {
        cells.removeAll()
        let total = width * height
        while cells.count < total / 4 {
            cells.insert(Int.random(in: 0..<total))
        }
    }
}
