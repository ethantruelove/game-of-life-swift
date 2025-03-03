//
//  SimpleBoardView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/2/25.
//

import SwiftUI

struct SimpleBoardView: View {
    let board: Board
    let cellSize: CGFloat
    let backgroundColor: Color
    
    init(board: Board, cellSize: CGFloat, backgroundColor: Color = Color("background")) {
        self.board = board
        self.cellSize = cellSize
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        // atttribution: https://swdevnotes.com/swift/2022/better-performance-with-canvas-in-swiftui/
        // attribution: https://swdevnotes.com/swift/2023/conways-game-of-life-with-swiftui/
        Canvas { context, size in
            let backgroundRect = CGRect(origin: .zero, size: size)
            context.fill(
                Path(backgroundRect),
                with: .color(backgroundColor)
            )
            
            
            for idx in board.cells {
                let col = idx % board.width
                let row = idx / board.width
                
                if board.getCell(x: col, y: row) {
                    let rect = CGRect(
                        x: CGFloat(col) * cellSize,
                        y: CGFloat(row) * cellSize,
                        width: cellSize,
                        height: cellSize
                    )
                    
                    context.fill(
                        Path(rect),
                        with: .color(Color("alive"))
                    )
                }
            }
        }
        .frame(width: CGFloat(board.width) * cellSize, height: CGFloat(board.height) * cellSize)
    }
}

#Preview {
    struct Preview: View {
        var board: Board = Board(width: 20, height: 20)
        
        init() {
            board.randomize()
        }
        
        var body: some View {
            SimpleBoardView(
                board: board,
                cellSize: 15,
                backgroundColor: Color("background")
            )
        }
    }
    
    return Preview()
}
