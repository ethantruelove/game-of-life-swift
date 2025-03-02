//
//  BoardSizePopoverView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/1/25.
//

import SwiftUI

struct BoardSizePopoverView: View {
    @Binding var board: Board
    @Binding var offset: CGSize
    @Binding var lastOffset: CGSize
    @Binding var scale: CGFloat
    @Binding var lastScale: CGFloat
    @Binding var cellSize: CGFloat
    @Binding var baseCellSize: CGFloat
    @Binding var boardViewWidth: CGFloat
    @Binding var boardViewHeight: CGFloat
    
    @Binding var showPopover: Bool
    @Binding var newWidth: String
    @Binding var newHeight: String
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                // attribution: https://developer.apple.com/documentation/swiftui/textfield
                HStack {
                    Text("Width:")
                        .padding(.trailing, 5)
                    TextField("Width", text: $newWidth)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
                
                HStack {
                    Text("Height:")
                    TextField("Height", text: $newHeight)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                }
            }
            
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            HStack {
                Button("Cancel") {
                    showPopover = false
                }
                .buttonStyle(.bordered)
                
                Button("Apply") {
                    if let width = Int(newWidth), let height = Int(newHeight) {
                        if width >= 1 && width <= 10000 && height >= 1 && height <= 10000 {
                            board = Board(width: width, height: height)
                            board.randomize()
                            offset = .zero
                            lastOffset = .zero
                            
                            baseCellSize = min(boardViewWidth / CGFloat(board.width), boardViewHeight / CGFloat(board.height))
                            cellSize = baseCellSize
                            print("Resizing cellSize to \(cellSize) with base cell size \(baseCellSize)")
                            
                            scale = 1
                            lastScale = 1
                            
                            Settings.shared.setBoardWidth(width)
                            Settings.shared.setBoardHeight(height)
                            
                            showPopover = false
                        } else {
                            errorMessage = "Width and height must be between 1 and 10,000"
                            showError = true
                        }
                    } else {
                        errorMessage = "Please enter valid numbers"
                        showError = true
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        //.frame(minWidth: 250)
    }
}

#Preview {
    struct Preview: View {
        @State var board: Board = Board(width: 10, height: 10)
        @State var offset: CGSize = .zero
        @State var lastOffset: CGSize = .zero
        @State var scale: CGFloat = 1
        @State var lastScale: CGFloat = 1
        
        @State var cellSize: CGFloat = 10
        @State var baseCellSize: CGFloat = 10
        @State var boardViewHeight: CGFloat = 600
        @State var boardViewWidth: CGFloat = 400
        
        @State var showPopover: Bool = false
        @State var newWidth: String = ""
        @State var newHeight: String = ""
        
        @State private var showError = false
        @State private var errorMessage = ""
        
        init() {
            board.randomize()
        }
        
        var body: some View {
            BoardSizePopoverView(
                board: $board,
                offset: $offset,
                lastOffset: $lastOffset,
                scale: $scale,
                lastScale: $lastScale,
                cellSize: $cellSize,
                baseCellSize: $baseCellSize,
                boardViewWidth: $boardViewWidth,
                boardViewHeight: $boardViewHeight,
                showPopover: $showPopover,
                newWidth: $newWidth,
                newHeight: $newHeight
            )
        }
    }
    
    return Preview()
}

