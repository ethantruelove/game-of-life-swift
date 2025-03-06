//
//  Board.swift
//  Game of Life
//
//  Created by Ethan Truelove on 2/26/25.
//

import Observation
import SwiftUI

/// A class for handling the state.
/// The current model uses sparse state and tracks alive cell indices.
/// - Note: This is the raw, underlying data model for the game board.
@Observable
class Board {
    let width: Int
    let height: Int
    
    /// Tracks the index of the last cell to be toggled to prevent constantly toggling same cell.
    private var lastToggledIndex: Int = -1
    /// Sparse array containing indices of alive cells.
    var cells: Set<Int> = Set<Int>()
    
    /// The `actor` to use to calculate the next generation.
    private let calc = BoardCalculator()
    
    /// Create a new `Board` object.
    ///
    /// - Parameters:
    ///   - width: The width of the board by number of cells.
    ///   - height: The height of the board by number of cells.
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.cells = Set<Int>()
    }
    
    /// Convert an `(x, y)` coordinate into an index using a simple 1D model.
    ///
    /// - Parameters:
    ///   - x: The x coordinate representing the column graphically.
    ///   - y: The y coordinate representing the row graphically.
    /// - Returns: The index of the cell in 1D space.
    func index(x: Int, y: Int) -> Int {
        guard x >= 0, x < width, y >= 0, y < height else { return -1 }
        return y * width + x
    }
    
    /// Convert an index into `(x, y)` coordinates as it would appear on a graphical board.
    ///
    /// - Parameter index: The index as represented in a 1D space to get the 2D coordinates for.
    /// - Returns: The `(x, y)` coordinate of the cell.
    func coordinates(from index: Int) -> (x: Int, y: Int) {
        return (index % width, index / width)
    }
    
    /// Set the cell's state at an `(x, y)` coordinate.
    ///
    /// - Parameters:
    ///   - x: The x coordinate representing the column graphically.
    ///   - y: The y coordinate representing the row graphically.
    ///   - state: The state the cell will be set to.
    func setCell(x: Int, y: Int, state: Bool) {
        setCell(idx: index(x: x, y: y), state: state)
    }
    
    /// Set the cell's state at an `index`.
    /// - Parameters:
    ///   - idx: The index in the 1D board space to set the state of.
    ///   - state: The state the cell will be set to.
    func setCell(idx: Int, state: Bool) {
        guard idx >= 0 else { return }
        if state {
            cells.insert(idx)
        } else {
            cells.remove(idx)
        }
    }
    
    /// Get the state of the cell located at `(x, y)` coordinates.
    ///
    /// - Parameters:
    ///     - x: The x coordinate representing the column graphically.
    ///     - y: The y coordinate representing the row graphically.
    /// - Returns: The cell state.
    func getCell(x: Int, y: Int) -> Bool {
        getCell(idx: index(x: x, y: y))
    }
    
    /// Get the cell at the 1D index location.
    /// - Parameter idx: The location of the cell as represented by a 1D array.
    /// - Returns: The cell state.
    func getCell(idx: Int) -> Bool {
        guard idx >= 0 else { return false }
        return cells.contains(idx)
    }
    
    /// Flip the state of the cell at the `(x, y)` coordinate.
    /// - Parameters:
    ///   - x: The x coordinate representing the column graphically.
    ///   - y: The y coordinate representing the row graphically.
    func toggleCell(x: Int, y: Int) {
        let toggleIndex = index(x: x, y: y)
        if toggleIndex != lastToggledIndex {
            setCell(idx: toggleIndex, state: !getCell(idx: toggleIndex))
            lastToggledIndex = toggleIndex
        }
    }
    
    /// An asynchronous calculation of the next generation.
    func tickAsync() async {
        let gen = await calc.startCalc()
        if let nextGen = await calc.calcNextGen(board: self, gen: gen) {
            await MainActor.run {
                self.cells = nextGen
            }
        }
    }
    
    /// Return a count of how many of a cell's neighbors are alive (state set to `True`).
    /// - Parameters:
    ///   - x: The x coordinate representing the column graphically.
    ///   - y: The y coordinate representing the row graphically.
    /// - Returns: Number of immediate numbers alive (logically must be between 0 and 8, inclusive).
    func aliveNeighborCount(x: Int, y: Int) -> Int {
        let radius = -1...1
        
        // generate all pairs in radius
        return radius.flatMap {
            dx in radius.map { dy in (dx, dy) }
        }
        // exclude self
        .filter { $0 != (0,0) }
        // increment count if neighbor is in bounds and alive
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
    
    /// Randomize the state of all the cells on the board.
    func randomize() {
        cells.removeAll()
        let total = width * height
        
        for _ in 0..<(total / 4) {
            cells.insert(Int.random(in: 0..<total))
        }
    }
}
