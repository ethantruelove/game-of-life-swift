//
//  BoardCalculator.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/4/25.
//


// attribution: https://www.hackingwithswift.com/quick-start/concurrency/how-to-create-and-use-an-actor-in-swift

/// An actor to use to handle offloading of board generation calculations to not impact main thread for UI handling.
actor BoardCalculator {
    /// Starts at -1 as `startCalc()` should always be called prior to `calcNextGen`, which will increment by 1.
    /// This will be used to validate and make sure that if multiple calls are made, we only commit the newest one.
    private var currentGen = -1
    
    
    /// Calculate the next generation of cells.
    /// - Parameters:
    ///   - board: The `Board` object to calculate on.
    ///   - gen: The generation to calculate.
    /// - Returns: Returns the next generation of cells or `nil` if it's an outdated calculation.
    func calcNextGen(board: Board, gen: Int) async -> Set<Int>? {
        // implies that a more recent computation was started, and this one should not be completed.
        guard gen >= currentGen else { return nil }
        
        print("Processing \(currentGen)")
        var cellsToCheck = Set<Int>()
        
        // find the neighbors of all live cells and build this set
        // we can ignore any dead cells with no live neighbors
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
        
        // apply Conway's rules according to the number of live cells a given cell has
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
        
        // Implies that a more recent computation was started, and this one should not be completed.
        guard gen >= currentGen else { return nil }
        return nextGenCells
    }
    
    /// Increment the current generation to provide a pseudo ID for the calculation process.
    /// - Returns: The current generation to be processed.
    func startCalc() -> Int {
        currentGen += 1
        return currentGen
    }
}
