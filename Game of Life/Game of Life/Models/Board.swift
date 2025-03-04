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

    private let calc = BoardCalculator()
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.cells = Set<Int>()
    }
    
    func index(x: Int, y: Int) -> Int {
        guard x >= 0, x < width, y >= 0, y < height else { return -1 }
        return y * width + x
    }
    
    func coordinates(from index: Int) -> (x: Int, y: Int) {
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
        let gen = await calc.startCalc()
        if let nextGen = await calc.calcNextGen(board: self, gen: gen) {
            await MainActor.run {
                self.cells = nextGen
            }
        }
    }
    
    func aliveNeighborCount(x: Int, y: Int) -> Int {
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
