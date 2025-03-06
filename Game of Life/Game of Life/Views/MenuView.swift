//
//  MenuView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/1/25.
//

import SwiftUI
import Combine
import PhotosUI

struct MenuView: View {
    @Environment(GameManager.self) var gameManager
    @Environment(BoardViewModel.self) var boardViewModel
    
    @State private var showBoardSizePopover = false
    @State private var newWidth = ""
    @State private var newHeight = ""
    
    @State private var showSpeedView = false
    
    @State private var selectedItem: PhotosPickerItem?
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
                }) {
                    Image(systemName: gameManager.autoplay ? "pause.fill" : "play.fill")
                }
                Spacer()
            }
        }
        .padding(.vertical)
    }
    
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
