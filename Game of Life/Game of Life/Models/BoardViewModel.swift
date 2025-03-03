//
//  BoardViewModel.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/2/25.
//

import SwiftUI
import Observation

@Observable
class BoardViewModel {
    var cellSize: CGFloat
    var baseCellSize: CGFloat
    var initialOffset: CGSize
    var offset: CGSize
    var lastOffset: CGSize
    var scale: CGFloat
    var lastScale: CGFloat
    var boardViewWidth: CGFloat
    var boardViewHeight: CGFloat
    var editMode: EditMode = .none
    
    init(cellSize: CGFloat = 5) {
        self.cellSize = cellSize
        self.baseCellSize = cellSize
        self.initialOffset = .zero
        self.offset = .zero
        self.lastOffset = .zero
        self.scale = 1
        self.lastScale = 1
        self.boardViewWidth = 0
        self.boardViewHeight = 0
    }
    
    func resetView() {
        offset = .zero
        lastOffset = .zero
        scale = 1
        lastScale = 1
        cellSize = baseCellSize
    }
    
    func resizeBoard(width: Int, height: Int) {
        offset = .zero
        lastOffset = .zero
        scale = 1
        lastScale = 1
        
        baseCellSize = min(boardViewWidth / CGFloat(width), boardViewHeight / CGFloat(height))
        cellSize = baseCellSize
    }
    
    func calculateInitialLayout(boardWidth: Int, boardHeight: Int, viewWidth: CGFloat, viewHeight: CGFloat) {
        boardViewWidth = viewWidth
        boardViewHeight = viewHeight
        
        let screenWidth = viewWidth
        let screenHeight = viewHeight * 0.75
        let gridWidth = CGFloat(boardWidth) * cellSize
        let gridHeight = CGFloat(boardHeight) * cellSize
        
        initialOffset = CGSize(
            width: max(0, (screenWidth - gridWidth) / 2),
            height: max(0, (screenHeight - gridHeight) / 2)
        )
        
        let minWidth = viewWidth / CGFloat(boardWidth)
        let minHeight = viewHeight / CGFloat(boardHeight)
        baseCellSize = min(minWidth, minHeight)
        cellSize = baseCellSize
    }
    
    func updateInitialOffsetForZoom(oldCellSize: CGFloat, newCellSize: CGFloat, boardWidth: Int, boardHeight: Int) {
        let oldGridWidth = CGFloat(boardWidth) * oldCellSize
        let newGridWidth = CGFloat(boardWidth) * newCellSize
        let oldGridHeight = CGFloat(boardHeight) * oldCellSize
        let newGridHeight = CGFloat(boardHeight) * newCellSize
        
        let widthDifference = newGridWidth - oldGridWidth
        let heightDifference = newGridHeight - oldGridHeight
        
        initialOffset = CGSize(
            width: initialOffset.width == 0 ? 0 : initialOffset.width - (widthDifference / 2),
            height: initialOffset.height == 0 ? 0 : initialOffset.height - (heightDifference / 2)
        )
    }
    
    func handleZoomGesture(value: MagnifyGesture.Value, boardWidth: Int, boardHeight: Int) {
        let newScale = lastScale * value.magnification
        scale = min(max(newScale, 0.1), 10)
        
        let oldCellSize = cellSize
        cellSize = baseCellSize * scale
        updateInitialOffsetForZoom(oldCellSize: oldCellSize, newCellSize: cellSize, boardWidth: boardWidth, boardHeight: boardHeight)
    }
    
    func handlePanGesture(value: DragGesture.Value) {
        offset = CGSize(
            width: lastOffset.width + value.translation.width,
            height: lastOffset.height + value.translation.height
        )
    }
    
    // attribution: https://medium.com/@carlos.camyoh/zooming-and-dragging-simultaneously-on-an-image-using-swiftui-ios-15-6fbb0007ae2c
    func handleEditGesture(value: DragGesture.Value, board: Board) {
        let totalCellWidth = CGFloat(board.width) * cellSize
        let totalCellHeight = CGFloat(board.height) * cellSize
        
        let touchX = value.location.x
        let touchY = value.location.y
        
        let gridX = touchX - offset.width
        let gridY = touchY - offset.height
        
        let col = Int(floor(gridX / totalCellWidth * CGFloat(board.width)))
        let row = Int(floor(gridY / totalCellHeight * CGFloat(board.height)))
        
        if col >= 0, col < board.width, row >= 0, row < board.height {
            switch editMode {
            case .fill:
                board.setCell(x: col, y: row, state: true)
            case .erase:
                board.setCell(x: col, y: row, state: false)
            case .toggle:
                board.toggleCell(x: col, y: row)
            case .none:
                break
            }
        }
    }
    
    func zoomEndGestureHandler() {
        lastScale = scale
    }
    
    func panEndGestureHandler() {
        lastOffset = offset
    }
}
