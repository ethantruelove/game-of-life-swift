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
    var initialOffset: CGSize = .zero
    var offset: CGSize = .zero
    var lastOffset: CGSize = .zero
    var scale: CGFloat = 1
    var lastScale: CGFloat = 1
    var boardViewWidth: CGFloat = 0
    var boardViewHeight: CGFloat = 0
    var editMode: EditMode = .none
    var isInteracting: Bool = false
    var isZooming: Bool = false
    var zoomAnchorPoint: CGPoint? = nil
    
    var containerSize: Int {
        return Int(max(boardViewWidth / baseCellSize, boardViewHeight / baseCellSize) * 10)
    }
    
    var containingIndex: CGFloat {
        return (CGFloat(containerSize) - 1) / 2
    }
    
    init(cellSize: CGFloat = 5) {
        self.cellSize = cellSize
        self.baseCellSize = cellSize
    }
    
    func resetView() {
        offset = initialOffset
        lastOffset = initialOffset
        scale = 1
        lastScale = 1
        cellSize = baseCellSize
    }
    
    func resizeBoard(width: Int, height: Int, boardWidth: Int, boardHeight: Int) {
        baseCellSize = min(boardViewWidth / CGFloat(width), boardViewHeight / CGFloat(height))
        cellSize = baseCellSize

        initialOffset = calculateOffsetForContainingView(boardWidth: boardWidth, boardHeight: boardHeight)
        offset = initialOffset
        lastOffset = initialOffset
        scale = 1
        lastScale = 1
    }
    
    func calculateOffsetForContainingView(boardWidth: Int, boardHeight: Int) -> CGSize {
        let totalBoardWidth = baseCellSize * CGFloat(boardWidth)
        let totalBoardHeight = baseCellSize * CGFloat(boardHeight)
        
        let xOffset = (boardViewWidth - totalBoardWidth) / 2
        let yOffset = (boardViewHeight - totalBoardHeight) / 2
        
        let containerOffset = CGFloat(containerSize - 1) / 2
        let adjXOffset = xOffset - containerOffset * totalBoardWidth
        let adjYOffset = yOffset - containerOffset * totalBoardHeight
    
        return CGSize(width: adjXOffset, height: adjYOffset)
    }
    
    func calculateLayout(boardWidth: Int, boardHeight: Int, viewWidth: CGFloat, viewHeight: CGFloat) {
        boardViewWidth = viewWidth
        boardViewHeight = viewHeight
        baseCellSize = min(viewWidth / CGFloat(boardWidth), viewHeight / CGFloat(boardHeight))
        cellSize = baseCellSize
        
        initialOffset = calculateOffsetForContainingView(boardWidth: boardWidth, boardHeight: boardHeight)
        offset = initialOffset
        lastOffset = initialOffset
    }
    
    func handleZoomGesture(value: MagnifyGesture.Value, boardWidth: Int, boardHeight: Int) {
        let newScale = lastScale * value.magnification
        let maxScale = min(boardViewWidth, boardViewHeight) / baseCellSize // 1 cell per smallest side
        let minScale = 1.0 / 3.0 // 1/3 of original side length (1/9 area)
        
        let oldScale = scale
        if newScale < minScale {
            scale = minScale
        } else if newScale > maxScale {
            scale = maxScale
        } else {
            scale = newScale
        }
        cellSize = baseCellSize * scale
        
        let anchor = zoomAnchorPoint ?? CGPoint(x: boardViewWidth / 2, y: boardViewHeight / 2)
        
        let projectedPoint = CGPoint(
            x: anchor.x - offset.width,
            y: anchor.y - offset.height
        )
        
        let ratio = scale / oldScale
        offset = CGSize(
            width: anchor.x - projectedPoint.x * ratio,
            height: anchor.y - projectedPoint.y * ratio
        )
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
        lastOffset = offset
    }
    
    func panEndGestureHandler() {
        lastOffset = offset
    }
}
