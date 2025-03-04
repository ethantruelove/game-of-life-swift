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
        var containerSize = Int(max(boardViewWidth / baseCellSize, boardViewHeight / baseCellSize))// * 10
        if containerSize % 2 == 0 {
            containerSize += 1
        }
        return containerSize
    }
    
    var containingIndex: CGFloat {
        return CGFloat(containerSize - 1) / 2
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
        initialOffset = calculateOffsetForContainingView(boardWidth: boardWidth, boardHeight: boardHeight)
        
        resetView()
    }
    
    func calculateOffsetForContainingView(boardWidth: Int, boardHeight: Int) -> CGSize {
        let totalBoardWidth = baseCellSize * CGFloat(boardWidth)
        let totalBoardHeight = baseCellSize * CGFloat(boardHeight)
        let xOffset = (boardViewWidth - totalBoardWidth) / 2
        let yOffset = (boardViewHeight - totalBoardHeight) / 2
        let adjXOffset = xOffset - containingIndex * totalBoardWidth
        let adjYOffset = yOffset - containingIndex * totalBoardHeight
    
        return CGSize(width: adjXOffset, height: adjYOffset)
    }
    
    func calculateLayout(boardWidth: Int, boardHeight: Int, viewWidth: CGFloat, viewHeight: CGFloat) {
        boardViewWidth = viewWidth
        boardViewHeight = viewHeight
        baseCellSize = min(viewWidth / CGFloat(boardWidth), viewHeight / CGFloat(boardHeight))
        initialOffset = calculateOffsetForContainingView(boardWidth: boardWidth, boardHeight: boardHeight)
        
        resetView()
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
        let gridX = value.location.x - offset.width
        let gridY = value.location.y - offset.height
        
        let totalContainerWidth = cellSize * CGFloat(board.width) * CGFloat(containerSize)
        let totalContainerHeight = cellSize * CGFloat(board.height) * CGFloat(containerSize)
        
        let totalBoardWidth = cellSize * CGFloat(board.width)
        let totalBoardHeight = cellSize * CGFloat(board.height)
        
        let boardStartX = (totalContainerWidth - totalBoardWidth) / 2
        let boardStartY = (totalContainerHeight - totalBoardHeight) / 2
        
        let boardX = gridX - boardStartX
        let boardY = gridY - boardStartY
        
        let col = Int(floor(boardX / cellSize))
        let row = Int(floor(boardY / cellSize))
        
        print("Grid: (\(gridX), \(gridY)) Board start: (\(boardStartX), \(boardStartY))")
        print("Board coords: (\(boardX), \(boardY)) -> Cell: (\(col), \(row))")
        
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
