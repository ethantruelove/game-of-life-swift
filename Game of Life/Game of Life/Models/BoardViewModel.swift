//
//  BoardViewModel.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/2/25.
//

import SwiftUI
import Observation

/// The model representing the way to render the board object.
@Observable
class BoardViewModel {
    /// The size the cell should occupy in pixels.
    /// - Note: Cells are always square.
    var cellSize: CGFloat
    /// The base cell to use when resetting the view to original.
    /// - Note: When initializing, `baseCellSize == cellSize`.
    var baseCellSize: CGFloat
    /// The initial offset that the view needs to be at to center the board on screen.
    /// - Note: This is calculated when the view needs a layout.
    var initialOffset: CGSize = .zero
    /// The offset to allow for movement of the board view.
    /// - Note: This will be changed as the user pans and zooms.
    var offset: CGSize = .zero
    /// The previous offset that was committed.
    /// - Note: This will be used for committing pans and zooms. This offset is always
    /// relative to the containing rectangle's grid, not the board's grid.
    var lastOffset: CGSize = .zero
    /// The factor by which to multiply `cellSize`.
    var scale: CGFloat = 1
    /// The last committed scale.
    var lastScale: CGFloat = 1
    /// The width in pixels that the board has access to on screen.
    /// - Note: This will be set by the geometry reader's size attributes.
    var boardViewWidth: CGFloat = 0
    /// The height in pixels that the board has access to on screen.
    /// - Note: This will be set by the geometry reader's size attributes.
    var boardViewHeight: CGFloat = 0
    /// The edit mode the board is currently in.
    var editMode: EditMode = .none
    /// Indicates whether or not the board is currently being panned or zoomed.
    var isInteracting: Bool = false
    /// Indicates whether or not hte board is being zoomed.
    var isZooming: Bool = false
    /// The anchor point to reference when a user is zooming in.
    /// - Note: This indicates the fixed point relative to the screen that the zoom should target towards or away from.
    var zoomAnchorPoint: CGPoint? = nil
    
    /// The size of the containing rectangle that should surround the board view
    /// - Note: This containing view is to allow the user to pan or drag without requirement of interacting with the actual board itself.
    var containerSize: Int {
        var containerSize = Int(max(boardViewWidth / baseCellSize, boardViewHeight / baseCellSize))// * 10
        // ensure that the containing multiple is odd so that the board can be cleanly positioned in a middle index
        if containerSize % 2 == 0 {
            containerSize += 1
        }
        return containerSize
    }
    
    /// The index location that the board should be relative to the `containerSize` multiple
    /// - Note: For example, if `containerSize` is 9, this index would be 4 as half of the containing view (0-3) would be
    /// to the left and half (5-9) would be to the right. Since the `containerSize` is by the max ratio, this guarantees half is defined as
    /// the shortest of the width and the height on screen.
    var containingIndex: CGFloat {
        return CGFloat(containerSize - 1) / 2
    }
    
    /// The initial state to set the model to.
    /// - Parameter cellSize: The number of pixels that the initial cell size should be.
    init(cellSize: CGFloat = 5) {
        self.cellSize = cellSize
        self.baseCellSize = cellSize
    }
    
    /// Reset the view back to its default parameters to center and undo any zooming.
    func resetView() {
        offset = initialOffset
        lastOffset = initialOffset
        scale = 1
        lastScale = 1
        cellSize = baseCellSize
    }
    
    // - TODO: revisit and see if these are redundant params
    /// Resize the board when the user wants a new board size.
    /// - Parameters:
    ///   - width: The width of the board.
    ///   - height: The height of the board.
    ///   - boardWidth: The width of the board.
    ///   - boardHeight: The height of the board.
    func resizeBoard(width: Int, height: Int, boardWidth: Int, boardHeight: Int) {
        baseCellSize = min(boardViewWidth / CGFloat(width), boardViewHeight / CGFloat(height))
        initialOffset = calculateOffsetForContainingView(boardWidth: boardWidth, boardHeight: boardHeight)
        
        resetView()
    }
    
    /// Calculation for what offset the containing view needs to be to properly center the game board on the user's screen
    /// - Parameters:
    ///   - boardWidth: The width of the board by cell count.
    ///   - boardHeight: The height of the board by cell count.
    /// - Returns: The offset factor.
    func calculateOffsetForContainingView(boardWidth: Int, boardHeight: Int) -> CGSize {
        let totalBoardWidth = baseCellSize * CGFloat(boardWidth)
        let totalBoardHeight = baseCellSize * CGFloat(boardHeight)
        let xOffset = (boardViewWidth - totalBoardWidth) / 2
        let yOffset = (boardViewHeight - totalBoardHeight) / 2
        let adjXOffset = xOffset - containingIndex * totalBoardWidth
        let adjYOffset = yOffset - containingIndex * totalBoardHeight
    
        return CGSize(width: adjXOffset, height: adjYOffset)
    }
    
    /// Calculation for how to set the `baseCellSize` and `initialOffset` so that the game board view can
    /// be properly centered and zoomed to show the entire board at initialization.
    /// - Parameters:
    ///   - boardWidth: The board width by cell count.
    ///   - boardHeight: The board height by cell count.
    ///   - viewWidth: The width of the view box in pixels.
    ///   - viewHeight: The height of the view box in pixels.
    func calculateLayout(boardWidth: Int, boardHeight: Int, viewWidth: CGFloat, viewHeight: CGFloat) {
        boardViewWidth = viewWidth
        boardViewHeight = viewHeight
        baseCellSize = min(viewWidth / CGFloat(boardWidth), viewHeight / CGFloat(boardHeight))
        initialOffset = calculateOffsetForContainingView(boardWidth: boardWidth, boardHeight: boardHeight)
        
        resetView()
    }
    
    /// Logic for how to alter the view on a zoom gesture.
    /// - Parameters:
    ///   - value: The magnification gesture's value to use.
    ///   - boardWidth: The width of the board by cell count.
    ///   - boardHeight: The height of the board by cell count.
    func handleZoomGesture(value: MagnifyGesture.Value, boardWidth: Int, boardHeight: Int) {
        let newScale = lastScale * value.magnification
        let maxScale = min(boardViewWidth, boardViewHeight) / baseCellSize // 1 cell per smallest side
        let minScale = 1.0 / 3.0 // 1/3 of original side length (1/9 area on screen)
        
        let oldScale = scale
        if newScale < minScale {
            scale = minScale
        } else if newScale > maxScale {
            scale = maxScale
        } else {
            scale = newScale
        }
        cellSize = baseCellSize * scale
        
        // the anchor point where the zoom should continuously appear to zoom towards or away from
        let anchor = zoomAnchorPoint ?? CGPoint(x: boardViewWidth / 2, y: boardViewHeight / 2)
        
        // project onto the containing view's coordinate space
        let projectedPoint = CGPoint(
            x: anchor.x - offset.width,
            y: anchor.y - offset.height
        )
        
        // calculate the new offset on the containing view's coordinate space based on the updated scale
        let ratio = scale / oldScale
        offset = CGSize(
            width: anchor.x - projectedPoint.x * ratio,
            height: anchor.y - projectedPoint.y * ratio
        )
    }
    
    /// Update the containing view's offset based on the drag gesture.
    /// - Parameter value: The drag gesture's value to use.
    func handlePanGesture(value: DragGesture.Value) {
        offset = CGSize(
            width: lastOffset.width + value.translation.width,
            height: lastOffset.height + value.translation.height
        )
    }
    
    /// Mapping the touch on screen to the containing view's grid space to properly edit
    /// the corresponding cell in the board model itself.
    /// - Parameters:
    ///   - value: The drag gesture's value to use to acquire the touch location.
    ///   - board: The board model to update with the edit modication.
    func handleEditGesture(value: DragGesture.Value, board: Board) {
        // get the touch location on the containing view's grid space
        let gridX = value.location.x - offset.width
        let gridY = value.location.y - offset.height
        
        // calculate the total size of the containing view in pixels
        let totalContainerWidth = cellSize * CGFloat(board.width) * CGFloat(containerSize)
        let totalContainerHeight = cellSize * CGFloat(board.height) * CGFloat(containerSize)
        
        // get the total size of the board view in pixels
        let totalBoardWidth = cellSize * CGFloat(board.width)
        let totalBoardHeight = cellSize * CGFloat(board.height)
        
        // calculate where the board view's top left corner is on the containing view's coordinate space
        let boardStartX = (totalContainerWidth - totalBoardWidth) / 2
        let boardStartY = (totalContainerHeight - totalBoardHeight) / 2
        
        // user the delta between touch and board location to identify which cell was touched
        // in the board view's coordinate space
        let boardX = gridX - boardStartX
        let boardY = gridY - boardStartY
        
        // convert the board view coordinate space to a column and row
        let col = Int(floor(boardX / cellSize))
        let row = Int(floor(boardY / cellSize))
        
        print("Grid: (\(gridX), \(gridY)) Board start: (\(boardStartX), \(boardStartY))")
        print("Board coords: (\(boardX), \(boardY)) -> Cell: (\(col), \(row))")
        
        // ensure that the touch maps to a valid column and row
        // then apply the edit mode accordingly
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
    
    /// Clean up at the end of the zoom gesture
    func zoomEndGestureHandler() {
        lastScale = scale
        lastOffset = offset
    }
    
    /// Clean up at the end of the pan gesture
    func panEndGestureHandler() {
        lastOffset = offset
    }
}
