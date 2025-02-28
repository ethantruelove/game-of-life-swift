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
    
    // help with multi gestures
    // attribution: https://medium.com/@carlos.camyoh/zooming-and-dragging-simultaneously-on-an-image-using-swiftui-ios-15-6fbb0007ae2c
    private func handleEditGesture(_ value: DragGesture.Value) {
        let offsetX = value.location.x - offset.width
        let offsetY = value.location.y - offset.height
        
        let col = Int(offsetX / cellSize)
        let row = Int(offsetY / cellSize)
        
        if row >= 0, row < board.height, col >= 0, col < board.width {
            board.toggleCell(x: col, y: row)
        }
    }
    
    private func handlePanGesture(_ value: DragGesture.Value) {
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
                scale = min(max(newScale, 0.5), 10)
                cellSize = baseCellSize * scale
            }
            .onEnded { _ in
                lastScale = scale
            }
    }
}
