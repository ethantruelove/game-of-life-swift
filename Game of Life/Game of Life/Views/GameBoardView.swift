//
//  GameBoardView.swift
//  Game of Life
//
//  Updated on 3/2/25.
//

import SwiftUI

/// A view to handle the rendering and processing of the entire game board
struct GameBoardView: View {
    /// The global `GameManager` to use.
    @Environment(GameManager.self) var gameManager
    /// The global `BoardViewModel` to use.
    @Environment(BoardViewModel.self) var boardViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // pad the simple board view with the containing rectangle to allow panning and zooming virtually anywhere on screen
                Rectangle()
                    .foregroundStyle(Color("dead"))
                    .frame(width: boardViewModel.cellSize * CGFloat(gameManager.board.width * boardViewModel.containerSize), height: boardViewModel.cellSize * CGFloat(gameManager.board.height * boardViewModel.containerSize))
                    .edgesIgnoringSafeArea(.all)
                SimpleBoardView(
                    board: gameManager.board,
                    cellSize: boardViewModel.cellSize
                )
            }
            .offset(boardViewModel.offset)
            // size the board view appropriately at launch
            .onAppear() {
                boardViewModel.calculateLayout(
                    boardWidth: gameManager.board.width,
                    boardHeight: gameManager.board.height,
                    viewWidth: geometry.size.width,
                    viewHeight: geometry.size.height
                )
            }
            // whenever screen size or orientation changes, resize the layout
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
    
    /// The gesture handler for single finger dragging
    private var singleFingerDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                // indicate to hide UI
                boardViewModel.isInteracting = true
                
                // perform panning if edit mode is none, otherwise apply the edit
                if boardViewModel.editMode == .none {
                    boardViewModel.handlePanGesture(value: value)
                } else {
                    boardViewModel.handleEditGesture(value: value, board: gameManager.board)
                }
            }
            // indicate to show UI and clean up if panned
            .onEnded { value in
                boardViewModel.isInteracting = false
                if boardViewModel.editMode == .none {
                    boardViewModel.panEndGestureHandler()
                }
            }
    }
    
    /// The gesture handler for zooming
    private var zoomGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                // only set the anchor point at the very start of the zoom gesture to maintain continuous point relative to screen coordinates
                if !boardViewModel.isZooming {
                    boardViewModel.zoomAnchorPoint = CGPoint(x: value.startLocation.x, y: value.startLocation.y)
                }
                boardViewModel.isZooming = true
                // indicate to hide UI
                boardViewModel.isInteracting = true
                boardViewModel.handleZoomGesture(
                    value: value,
                    boardWidth: gameManager.board.width,
                    boardHeight: gameManager.board.height
                )
            }
            // clean up state and reset relevant properties
            .onEnded { _ in
                boardViewModel.isZooming = false
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
