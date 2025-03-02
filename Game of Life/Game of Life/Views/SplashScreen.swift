//
//  SplashScreen.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/2/25.
//

import SwiftUI
import Combine

struct SplashScreenView: View {
    let board: Board = createGameOfLifeBoard()
    let cellSize: CGFloat = 15
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        SimpleBoardView(
            board: board,
            cellSize: cellSize,
            backgroundColor: colorScheme == .light ? .white : .black
        )
    }
    
    static func createGameOfLifeBoard() -> Board {
        let board = Board(width: 25, height: 20)
        
        // "GAME"
        let gamePattern: [(Int, Int)] = [
            // G
            (1, 1), (2, 1), (3, 1), (4, 1), (5, 1),
            (1, 2),
            (1, 3), (3, 3), (4, 3), (5, 3),
            (1, 4), (5, 4),
            (1, 5), (2, 5), (3, 5), (4, 5), (5, 5),
            
            // A
            (8, 1), (9, 1), (10, 1),
            (7, 2), (11, 2),
            (7, 3), (8, 3), (9, 3), (10, 3), (11, 3),
            (7, 4), (11, 4),
            (7, 5), (11, 5),
            
            // M
            (13, 1), (17, 1),
            (13, 2), (14, 2), (16, 2), (17, 2),
            (13, 3), (15, 3), (17, 3),
            (13, 4), (17, 4),
            (13, 5), (17, 5),
            
            // E
            (19, 1), (20, 1), (21, 1), (22, 1), (23, 1),
            (19, 2),
            (19, 3), (20, 3), (21, 3),
            (19, 4),
            (19, 5), (20, 5), (21, 5), (22, 5), (23, 5)
        ]
        
        // "OF"
        let ofPattern: [(Int, Int)] = [
            // O
            (8, 7), (9, 7), (10, 7),
            (7, 8), (11, 8),
            (7, 9), (11, 9),
            (7, 10), (11, 10),
            (8, 11), (9, 11), (10, 11),
            
            // F
            (13, 7), (14, 7), (15, 7), (16, 7), (17, 7),
            (13, 8),
            (13, 9), (14, 9), (15, 9),
            (13, 10),
            (13, 11)
        ]
        
        // "LIFE"
        let lifePattern: [(Int, Int)] = [
            // L
            (1, 13),
            (1, 14),
            (1, 15),
            (1, 16),
            (1, 17), (2, 17), (3, 17), (4, 17), (5, 17),
            
            // I
            (7, 13), (8, 13), (9, 13), (10, 13), (11, 13),
            (9, 14),
            (9, 15),
            (9, 16),
            (7, 17), (8, 17), (9, 17), (10, 17), (11, 17),
            
            // F
            (13, 13), (14, 13), (15, 13), (16, 13), (17, 13),
            (13, 14),
            (13, 15), (14, 15), (15, 15),
            (13, 16),
            (13, 17),
            
            // E
            (19, 13), (20, 13), (21, 13), (22, 13), (23, 13),
            (19, 14),
            (19, 15), (20, 15), (21, 15),
            (19, 16),
            (19, 17), (20, 17), (21, 17), (22, 17), (23, 17)
        ]
        
        // Combine all patterns
        let allCells = gamePattern + ofPattern + lifePattern
        
        // Set the cells in the board
        for (x, y) in allCells {
            board.setCell(x: x, y: y, state: true)
        }
        
        return board
    }
}

#Preview {
    SplashScreenView()
}
