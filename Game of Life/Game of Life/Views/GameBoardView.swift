//
//  GameBoardView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 2/27/25.
//

import SwiftUI

struct GameBoardView: View {
    @Binding var board: Board
    @Binding var cellSize: CGFloat
    @Binding var editMode: Bool
    @Binding var initialOffset: CGSize
    @Binding var offset: CGSize
    @Binding var lastScale: CGFloat
    let baseCellSize: CGFloat
    
    @State private var scale: CGFloat = 1
    @State private var lastOffset = CGSize.zero
    
    @State private var twoFingerDrag = false
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellSize), spacing: 0), count: board.width), spacing: 0) {
            ForEach(0..<board.width * board.height, id: \.self) { index in
                let x = index % board.width
                let y = index / board.width
                
                Rectangle()
                    .fill(board.getCell(x: x, y: y) ? Color("alive") : Color("dead"))
                    .frame(width: cellSize, height: cellSize)
                    .border(Color.gray, width: 0.5)
            }
        }
        //.frame(width: CGFloat(board.width) * cellSize, height: CGFloat(board.height) * cellSize)
        .offset(offset)
        .onAppear() {
            scale = cellSize / baseCellSize
        }
        // single finger drag dependent on edit mode
        .gesture(zoomGesture
            .simultaneously(with: singleFingerDragGesture)
        )
    }
    
    // help with multi gestures and tracking lastOffset and lastScale
    // attribution: https://medium.com/@carlos.camyoh/zooming-and-dragging-simultaneously-on-an-image-using-swiftui-ios-15-6fbb0007ae2c
    private func handleEditGesture(_ value: DragGesture.Value) {
        let totalCellWidth = CGFloat(board.width) * cellSize
        let totalCellHeight = CGFloat(board.height) * cellSize

        let touchX = value.location.x
        let touchY = value.location.y
        
        // only factor in the initialOffset if the board is zoomed out enough to have offset spacing
        let gridX = totalCellWidth > UIScreen.main.bounds.width ? touchX - offset.width : touchX - offset.width - initialOffset.width
        let gridY = totalCellHeight > UIScreen.main.bounds.height ? touchY - offset.height : touchY - offset.height - initialOffset.height
        
        let col = Int(floor(gridX / totalCellWidth * CGFloat(board.width)))
        let row = Int(floor(gridY / totalCellHeight * CGFloat(board.height)))
        
        print("Determined touch of cell: (\(col), \(row))")
        
        if col >= 0, col < board.width, row >= 0, row < board.height {
            board.toggleCell(x: col, y: row)
        }
    }
    
    private func handlePanGesture(_ value: DragGesture.Value) {
        print("handling pan old offset width \(offset.width) height \(offset.height)")
        print("translation width \(value.translation.width) height \(value.translation.height)")
        print("last offset width \(lastOffset.width) height \(lastOffset.height)")
        offset = CGSize(
            width: lastOffset.width + value.translation.width,
            height: lastOffset.height + value.translation.height
        )
    }
    
    private var singleFingerDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if editMode {
                    handleEditGesture(value)
                } else {
                    handlePanGesture(value)
                }
            }
            .onEnded { value in
                if !editMode {
                    lastOffset = offset
                }
            }
    }
    
    private var zoomGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newScale = lastScale * value.magnification
                // prevent more than 10x zoom and prevent zoom out such that new view area < 10% of eligible screen space
                // proposedArea = SOME_SCALE * CGFloat(board.width) * baseCellSize
                // validArea = UIScreen.main.bounds.width * UIScreen.main.bounds.height
                let boundaryScale = 0.01 * UIScreen.main.bounds.width * UIScreen.main.bounds.height / (CGFloat(board.width * board.height) * baseCellSize)
                print(boundaryScale)
                scale = min(max(newScale, boundaryScale), 10)
                let oldCellSize = cellSize
                cellSize = baseCellSize * scale
                updateInitialOffsetForZoom(oldCellSize: oldCellSize, newCellSize: cellSize)
            }
            .onEnded { _ in
                lastScale = scale
            }
    }
    
    private func updateInitialOffsetForZoom(oldCellSize: CGFloat, newCellSize: CGFloat) {
        // Calculate how much the grid dimensions have changed
        let oldGridWidth = CGFloat(board.width) * oldCellSize
        let newGridWidth = CGFloat(board.width) * newCellSize
        let oldGridHeight = CGFloat(board.height) * oldCellSize
        let newGridHeight = CGFloat(board.height) * newCellSize
        
        // Calculate the difference in dimensions
        let widthDifference = newGridWidth - oldGridWidth
        let heightDifference = newGridHeight - oldGridHeight
        
        // Update the initialOffset to account for the change in dimensions
        // We divide by 2 because the grid expands/contracts from the center
        initialOffset = CGSize(
            width: initialOffset.width == 0 ? 0 : initialOffset.width - (widthDifference / 2),
            height: initialOffset.height == 0 ? 0 : initialOffset.height - (heightDifference / 2)
        )
        
        print("Zoom update - Old size: \(oldCellSize), New size: \(newCellSize)")
        print("New initialOffset: \(initialOffset)")
    }
}
