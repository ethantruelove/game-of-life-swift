//
//  GameBoardView.swift
//  Game of Life
//
//  Updated on 3/2/25.
//

import SwiftUI

struct GameBoardView: View {
    @Environment(GameManager.self) var gameManager
    @Environment(BoardViewModel.self) var boardViewModel
    
    var body: some View {        
        SimpleBoardView(
            board: gameManager.board,
            cellSize: boardViewModel.cellSize
        )
        .offset(boardViewModel.offset)
        .onAppear() {
            boardViewModel.scale = boardViewModel.cellSize / boardViewModel.baseCellSize
        }
        .gesture(zoomGesture
            .simultaneously(with: singleFingerDragGesture)
        )
    }
    
    private var singleFingerDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if boardViewModel.editMode == .none {
                    boardViewModel.handlePanGesture(value: value)
                } else {
                    boardViewModel.handleEditGesture(value: value, board: gameManager.board)
                }
            }
            .onEnded { value in
                if boardViewModel.editMode == .none {
                    boardViewModel.panEndGestureHandler()
                }
            }
    }
    
    private var zoomGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                boardViewModel.handleZoomGesture(
                    value: value,
                    boardWidth: gameManager.board.width,
                    boardHeight: gameManager.board.height
                )
            }
            .onEnded { _ in
                boardViewModel.zoomEndGestureHandler()
            }
    }
}

#Preview {
    struct Preview: View {
        @Environment(GameManager.self) private var gameManager
        @Environment(BoardViewModel.self) private var boardViewModel
        
        var body: some View {
            GameBoardView(
                gameManager: _gameManager,
                boardViewModel: _boardViewModel
            )
        }
    }
    
    return Preview()
}
