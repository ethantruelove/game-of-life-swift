//
//  HomeView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 2/26/25.
//

import SwiftUI
import Combine

struct HomeView: View {
    private let launchCount: Int
    @State private var showRateView: Bool

    @Environment(GameManager.self) private var gameManager
    @Environment(BoardViewModel.self) private var boardViewModel
    
    @State private var showSettings = false
    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    
    init(launchCount: Int) {
        self.launchCount = launchCount
        
        if launchCount == 2 {
            self.showRateView = true
        } else {
            self.showRateView = false
        }
        
        let sWidth = Settings.shared.boardWidth
        let sHeight = Settings.shared.boardHeight
        let sTickTime = Settings.shared.tickTime
        
        let gameManager = GameManager(width: sWidth, height: sHeight, tickTime: sTickTime)
        gameManager.board.randomize()
    }
    
    var body: some View {
        ZStack {
            // attribution: https://stackoverflow.com/questions/60021403/how-to-get-height-and-width-of-view-or-screen-in-swiftui
            // attribution: https://developer.apple.com/documentation/swiftui/geometryreader
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    GameBoardView(
                        gameManager: _gameManager,
                        boardViewModel: _boardViewModel
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .onAppear() {                        
                        let minWidth = geometry.size.width / CGFloat(gameManager.board.width)
                        let minHeight = geometry.size.height / CGFloat(gameManager.board.height)
                        boardViewModel.baseCellSize = min(minWidth, minHeight)
                        boardViewModel.cellSize = boardViewModel.baseCellSize
                        
                        boardViewModel.boardViewWidth = geometry.size.width
                        boardViewModel.boardViewHeight = geometry.size.height
                    }
                    .onReceive(gameManager.timer) { _ in
                        if gameManager.board.autoplay {
                            gameManager.tick()
                        }
                    }
                    
                    VStack() {
                        HStack {
                            Spacer()
                            EditModeView(
                                showEditModes: $showSettings,
                                editMode: Binding(
                                    get: { boardViewModel.editMode },
                                    set: { boardViewModel.editMode = $0 }
                                )
                            )
                            .padding(.trailing)
                        }
                        
                        Spacer()
                        MenuView(
                            gameManager: _gameManager,
                            boardViewModel: _boardViewModel
                        )
                        .background(Color("dead"))
                        .padding(.bottom)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        
            if showRateView {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showRateView = false
                        }
                    RateView(showRateView: $showRateView)
                        .transition(.opacity)
                        .animation(.easeInOut, value: showRateView)
                }
            }
        }
        .onChange(of: scenePhase) { old, new in
            gameManager.handleScenePhaseChange(old: old, new: new)
        }
    }
}

#Preview("Normal") {
    let gameManager = GameManager(width: 80, height: 80)
    let boardViewModel = BoardViewModel()
    
    HomeView(launchCount: 1)
        .environment(gameManager)
        .environment(boardViewModel)
}

#Preview("Rate View") {
    let gameManager = GameManager(width: 40, height: 80)
    let boardViewModel = BoardViewModel()
    
    HomeView(launchCount: 2)
        .environment(gameManager)
        .environment(boardViewModel)
}
