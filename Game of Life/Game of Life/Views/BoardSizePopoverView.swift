//
//  BoardSizePopoverView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/1/25.
//

import SwiftUI

/// A view for handling the popover that appears when a user wants to resize the board.
struct BoardSizePopoverView: View {
    /// The `GameManager` to use.
    @Environment(GameManager.self) var gameManager
    /// The global `BoardViewModel` to use.
    @Environment(BoardViewModel.self) var boardViewModel
    
    /// Indicates if the popover should be visible or not.
    @Binding var showPopover: Bool
    /// Indicates if the inputted values are out of range and error message should show.
    @State private var showError = false
    /// The error message to show, if applicable.
    @State private var errorMessage = ""
    /// The new width of the board by cell count represented as a string for user input.
    @State private var newWidth: String = ""
    /// The new height of the board by cell count represented as a string for user input.
    @State private var newHeight: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                // attribution: https://developer.apple.com/documentation/swiftui/textfield
                // it seems like there is a bug that makes this lag and log "Can't find or decode reasons" on the first tap until a gesture time out hits
                // https://developer.apple.com/forums/thread/769432
                // also seems to be a bug following the second refocus
                // https://stackoverflow.com/questions/77800488/rtiinputsystemclient-remotetextinputsessionwithidperforminputoperation-perf
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
                        if pixels >= 1 && pixels < 1000000 {
                            showPopover = false
                            gameManager.resizeBoard(width: width, height: height)
                            boardViewModel.resizeBoard(width: width, height: height, boardWidth: gameManager.board.width, boardHeight: gameManager.board.height)
                        } else {
                            errorMessage = "Total area must be between 1 and 1 million"
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
        .onAppear() {
            newWidth = "\(gameManager.board.width)"
            newHeight = "\(gameManager.board.height)"
        }
    }
}

#Preview {
    @Previewable @State var showPopover: Bool = false
    
    let gameManager = GameManager(width: 10, height: 10)
    let boardViewModel = BoardViewModel()
    
    BoardSizePopoverView(showPopover: $showPopover)
        .environment(gameManager)
        .environment(boardViewModel)
}
