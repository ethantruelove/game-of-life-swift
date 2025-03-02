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
    @Binding var editMode: EditMode
    @Binding var initialOffset: CGSize
    @Binding var offset: CGSize
    @Binding var lastOffset: CGSize
    @Binding var scale: CGFloat
    @Binding var lastScale: CGFloat
    let baseCellSize: CGFloat
    
    var body: some View {
        // idea to switch to Canvas for representation
        // atttribution: https://swdevnotes.com/swift/2022/better-performance-with-canvas-in-swiftui/
        // attribution: https://swdevnotes.com/swift/2023/conways-game-of-life-with-swiftui/
        Canvas { context, size in
            let backgroundRect = CGRect(origin: .zero, size: size)
            context.fill(
                Path(backgroundRect),
                with: .color(Color(red: 0.95, green: 0.95, blue: 0.95))
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
        .offset(offset)
        .onAppear() {
            scale = cellSize / baseCellSize
        }
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
        // y coordinate is from top of view (does not have access to full height) so no need for initial offset
        let gridY = touchY - offset.height
        
        let col = Int(floor(gridX / totalCellWidth * CGFloat(board.width)))
        let row = Int(floor(gridY / totalCellHeight * CGFloat(board.height)))
        
        print("-----------")
        print("Touching \(value.location)")
        print("Offset \(offset) Initial offset \(initialOffset)")
        print("Determined touch of cell: (\(col), \(row))")
        
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
    
    private func handlePanGesture(_ value: DragGesture.Value) {
//        print("handling pan old offset width \(offset.width) height \(offset.height)")
//        print("translation width \(value.translation.width) height \(value.translation.height)")
//        print("last offset width \(lastOffset.width) height \(lastOffset.height)")
        offset = CGSize(
            width: lastOffset.width + value.translation.width,
            height: lastOffset.height + value.translation.height
        )
    }
    
    private var singleFingerDragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if editMode == .none {
                    handlePanGesture(value)
                } else {
                    handleEditGesture(value)
                }
            }
            .onEnded { value in
                if editMode == .none {
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
                //let boundaryScale = 0.01 * UIScreen.main.bounds.width * UIScreen.main.bounds.height / (CGFloat(board.width * board.height) * baseCellSize)
                //print(boundaryScale)
                //scale = min(max(newScale, boundaryScale), 10)
                scale = min(max(newScale, 0.1), 10)
                print("New Scale \(scale) last scale \(lastScale)")
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
        
//        print("Zoom update - Old size: \(oldCellSize), New size: \(newCellSize)")
//        print("New initialOffset: \(initialOffset)")
    }
}

// reminder for Binding previews
// attribution: https://www.reddit.com/r/SwiftUI/comments/17aruvw/preview_with_binding_properties/
#Preview {
    struct Preview: View {
        @State private var board: Board = Board(width: 15, height: 25)
        @State private var cellSize: CGFloat = 25
        @State private var editMode: EditMode = .none
        @State private var initialOffset: CGSize = .zero
        @State private var offset: CGSize = .zero
        @State private var lastOffset: CGSize = .zero
        @State private var scale: CGFloat = 1
        @State private var lastScale: CGFloat = 1
        let baseCellSize: CGFloat = 25
        
        init() {
            board.randomize()
        }
        
        var body: some View {
            GameBoardView(
                board: $board,
                cellSize: $cellSize,
                editMode: $editMode,
                initialOffset: $initialOffset,
                offset: $offset,
                lastOffset: $lastOffset,
                scale: $scale,
                lastScale: $lastScale,
                baseCellSize: baseCellSize
            )
        }
    }
    
    return Preview()
}
