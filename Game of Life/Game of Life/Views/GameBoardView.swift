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
        GeometryReader { geometry in
            ZStack {
                Color("dead").opacity(0.001)
                    .edgesIgnoringSafeArea(.all)
                SimpleBoardView(
                    board: gameManager.board,
                    cellSize: boardViewModel.cellSize
                )
                .offset(boardViewModel.offset)
            }
            .onAppear() {
                boardViewModel.calculateLayout(
                    boardWidth: gameManager.board.width,
                    boardHeight: gameManager.board.height,
                    viewWidth: geometry.size.width,
                    viewHeight: geometry.size.height
                )
            }
            .onChange(of: geometry.size) {
                boardViewModel.calculateLayout(
                    boardWidth: gameManager.board.width,
                    boardHeight: gameManager.board.height,
                    viewWidth: geometry.size.width,
                    viewHeight: geometry.size.height
                )
            }
            .gesture(zoomGesture
                .simultaneously(with: singleFingerDragGesture)
            )
        }
    }
    
    private var singleFingerDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                print("DRAGGING")
                boardViewModel.isInteracting = true
                
                if boardViewModel.editMode == .none {
                    boardViewModel.handlePanGesture(value: value)
                } else {
                    boardViewModel.handleEditGesture(value: value, board: gameManager.board)
                }
            }
            .onEnded { value in
                boardViewModel.isInteracting = false
                if boardViewModel.editMode == .none {
                    boardViewModel.panEndGestureHandler()
                }
            }
    }
    
    private var zoomGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                if !boardViewModel.isInteracting {
                    boardViewModel.zoomAnchorPoint = CGPoint(x: value.startLocation.x, y: value.startLocation.y)
                }
                boardViewModel.isInteracting = true
                boardViewModel.handleZoomGesture(
                    value: value,
                    boardWidth: gameManager.board.width,
                    boardHeight: gameManager.board.height
                )
            }
            .onEnded { _ in
                boardViewModel.isInteracting = false
                boardViewModel.zoomEndGestureHandler()
                boardViewModel.zoomAnchorPoint = nil
                boardViewModel.lastOffset = boardViewModel.offset
            }
    }
}

#Preview {
    let gameManager = GameManager(width: 30, height: 30)
    let boardViewModel = BoardViewModel(
        cellSize: 10
    )
    
    GameBoardView()
        .environment(gameManager)
        .environment(boardViewModel)
}
