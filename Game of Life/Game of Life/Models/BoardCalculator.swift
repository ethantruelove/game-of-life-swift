//
//  BoardCalculator.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/4/25.
//


// attribution: https://www.hackingwithswift.com/quick-start/concurrency/how-to-create-and-use-an-actor-in-swift
actor BoardCalculator {
    private var currentGen = -1
    
    func calcNextGen(board: Board, gen: Int) async -> Set<Int>? {
        guard gen >= currentGen else { return nil }
        
        print("Processing \(currentGen)")
        var cellsToCheck = Set<Int>()
        
        for cellIdx in board.cells {
            let (x, y) = board.coordinates(from: cellIdx)
            cellsToCheck.insert(cellIdx)
            
            for dx in -1...1 {
                for dy in -1...1 {
                    let nX = x + dx
                    let nY = y + dy
                    if nX >= 0 && nX < board.width && nY >= 0 && nY < board.height {
                        cellsToCheck.insert(board.index(x: nX, y: nY))
                    }
                }
            }
        }
        
        var nextGenCells = Set<Int>()
        
        for cellIdx in cellsToCheck {
            let (x, y) = board.coordinates(from: cellIdx)
            let isAlive = board.cells.contains(cellIdx)
            let nCount = board.aliveNeighborCount(x: x, y: y)
            
            if isAlive && (nCount == 2 || nCount == 3) {
                nextGenCells.insert(cellIdx)
            } else if !isAlive && nCount == 3 {
                nextGenCells.insert(cellIdx)
            }
        }
        
        guard gen >= currentGen else { return nil }
        return nextGenCells
    }
    
    func startCalc() -> Int {
        currentGen += 1
        return currentGen
    }
}
