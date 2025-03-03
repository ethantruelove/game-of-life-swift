//
//  BoardSizePopoverView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/1/25.
//

import SwiftUI

struct BoardSizePopoverView: View {
    @Environment(GameManager.self) var gameManager
    @Environment(BoardViewModel.self) var boardViewModel
    
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
                        let pixels = width * height
                        if pixels >= 1 && pixels < 10000000 {
                            gameManager.resizeBoard(width: width, height: height)
                            boardViewModel.resizeBoard(width: width, height: height)
                        } else {
                            errorMessage = "Total pixels must be between 1 and 1,000,000, attempted \(pixels)"
                            showError = true
                        }
                    } else {
                        errorMessage = "Integer numbers only"
                        showError = true
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

#Preview {
    struct Preview: View {
        @Environment(GameManager.self) var gameManager
        @Environment(BoardViewModel.self) var boardViewModel
        @State var showPopover: Bool = false
        @State var newWidth: String = "10"
        @State var newHeight: String = "10"
        
        init() {
            gameManager.board.randomize()
        }
        
        var body: some View {
            BoardSizePopoverView(
                gameManager: _gameManager,
                boardViewModel: _boardViewModel,
                showPopover: $showPopover,
                newWidth: $newWidth,
                newHeight: $newHeight
            )
        }
    }
    
    return Preview()
}
