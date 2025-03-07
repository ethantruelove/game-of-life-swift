//
//  MenuView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/1/25.
//

import SwiftUI
import Combine
import PhotosUI

/// A view to house the buttons on the main menu bar for the app.
struct MenuView: View {
    /// The global `GameManager` to use.
    @Environment(GameManager.self) var gameManager
    /// The global `BoardViewModel` to use.
    @Environment(BoardViewModel.self) var boardViewModel
    
    /// Indicates whether or not the board popover should be shown to allow users to change the board size.
    @State private var showBoardSizePopover = false
    /// The value to show in the text field for the new width.
    @State private var newWidth = ""
    /// The value to show in the text field for the new height.
    @State private var newHeight = ""
    
    /// Indicates whether or not the slider to change the `tickTime` should be shown.
    @State private var showSpeedView = false
    
    /// Holds the reference to the photo picked by the user to set a board state with.
    @State private var selectedItem: PhotosPickerItem?
    /// Holds the reference to the data of the image picked by the user to set a board state with.
    @State private var selectedImageData: Data?
    
    var body: some View {
        VStack {
            if showSpeedView {
                SpeedView(
                    tickTime: Binding(
                        get: { gameManager.tickTime },
                        set: { gameManager.updateTickTime($0) }
                    ),
                    onTickChange: {}
                )
            }
            
            HStack {
                Spacer()
                
                // attribution: https://developer.apple.com/documentation/photokit/bringing-photos-picker-to-your-swiftui-app
                // attribution: https://www.hackingwithswift.com/quick-start/swiftui/how-to-let-users-select-pictures-using-photospicker
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "photo.on.rectangle")
                }
                // when the user picks a photo, get the raw data
                .onChange(of: selectedItem) { _, newValue in
                    if let newValue {
                        Task {
                            if let data = try? await newValue.loadTransferable(type: Data.self) {
                                await MainActor.run {
                                    selectedImageData = data
                                }
                            }
                        }
                    }
                }
                // once the data has been loaded, convert it to a valid board state
                .onChange(of: selectedImageData) {
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        if ImageProcessor.convertImageToBoard(
                            uiImage: uiImage,
                            gameManager: gameManager,
                            boardViewModel: boardViewModel
                        ) {
                            clearSelectedImage()
                        }
                    }
                }

                Spacer()
                
                // attribution: https://www.swiftyplace.com/blog/swiftui-popovers-and-popups
                Button(action: {
                    newWidth = "\(gameManager.board.width)"
                    newHeight = "\(gameManager.board.height)"
                    showBoardSizePopover.toggle()
                }) {
                    Image(systemName: "squareshape.split.3x3")
                }
                .popover(isPresented: $showBoardSizePopover) {
                    BoardSizePopoverView(
                        gameManager: _gameManager,
                        boardViewModel: _boardViewModel,
                        showPopover: $showBoardSizePopover
                    )
                    .presentationCompactAdaptation(.popover)
                }
                Spacer()
                
                Button(action: {
                    showSpeedView.toggle()
                }) {
                    Image(systemName: "hare.fill")
                }
                
                Spacer()
                Button(action: {
                    boardViewModel.resetView()
                }) {
                    Image(systemName: "dot.scope")
                }
                Spacer()
                Button(action: {
                    gameManager.randomizeBoard()
                }) {
                    Image(systemName: "dice.fill")
                }
                Spacer()
                Button(action: {
                    gameManager.currentTick = gameManager.tick()
                }) {
                    Image(systemName: "arrow.forward")
                }
                Spacer()
                Button(action: {
                    gameManager.toggleAutoplay()
                    boardViewModel.editMode = .none
                }) {
                    Image(systemName: gameManager.autoplay ? "pause.fill" : "play.fill")
                }
                Spacer()
            }
        }
        .padding(.vertical)
    }
    
    /// Clean up helper to reset the relevant data objects after a user has selected an image.
    private func clearSelectedImage() {
        selectedItem = nil
        selectedImageData = nil
    }
}

#Preview {
    let gameManager = GameManager()
    let boardViewModel = BoardViewModel()
    
    MenuView()
        .environment(gameManager)
        .environment(boardViewModel)
}
