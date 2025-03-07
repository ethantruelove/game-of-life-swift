//
//  HomeView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 2/26/25.
//

import SwiftUI
import Combine

/// A view to handle the main screen the user will see and interact with.
struct HomeView: View {
    /// The number of times the application has been launched.
    /// - Note: This is used to indicate whether or not the rating alert should be shown.
    private let launchCount: Int
    /// Indicate whether or not the alert to ask for a review should be shown.
    @State private var askForReview: Bool
    /// Indicate whether or not the screen for soliciting a rating should be shown.
    @State private var showRateView: Bool = false
    /// Indicate whether or not the screen with interaction information should be shown.
    @State private var showInfoView: Bool = false
    
    /// The global `GameManager` to use.
    @Environment(GameManager.self) private var gameManager
    /// The global `BoardViewModel` to use.
    @Environment(BoardViewModel.self) private var boardViewModel
    
    // - TODO: rename this to showEditModes
    /// Indicate whether or not the additional edit modes should be shown.
    @State private var showSettings = false
    /// The scene phase to allow tracking of scene changes.
    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    
    
    /// The initializer for the view.
    /// - Parameter launchCount: The launch count to use.
    /// - Note: This comes from loading from settings and is passed in from the main entry point.
    init(launchCount: Int) {
        self.launchCount = launchCount
        
        // As `launchCount` is 0 indexed, this is shown on the 5th launch
        if launchCount == 4 {
            self.askForReview = true
        } else {
            self.askForReview = false
        }
    }
    
    var body: some View {
        ZStack {
            // attribution: https://stackoverflow.com/questions/60021403/how-to-get-height-and-width-of-view-or-screen-in-swiftui
            // attribution: https://developer.apple.com/documentation/swiftui/geometryreader
            GeometryReader { geometry in
                GameBoardView(
                    gameManager: _gameManager,
                    boardViewModel: _boardViewModel
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .onAppear() {
                        gameManager.randomizeBoard()
                    }
                
                if !boardViewModel.isInteracting {
                    VStack() {
                        HStack {
                            Button(action: {
                                showInfoView = true
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 25))
                                    .foregroundStyle(.gray)
                                    .padding()
                            }
                            .padding(.leading)
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
                        .background(Color("dead").shadow(color: Color("alive"), radius: 2, y: -1))
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
            
            if showInfoView {
                ZStack {
                    Color.black.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showInfoView = false
                        }
                    InfoView()
                }
                
            }
            
            if gameManager.isLoading {
                LoadingView()
            }
        }
        .onChange(of: scenePhase) { old, new in
            gameManager.handleScenePhaseChange(old: old, new: new)
        }
        .alert("Enjoying the Game of Life?\nLeave a Rating!", isPresented: $askForReview) {
            Button("Dismiss") {}
            Button("Rate") {
                showRateView = true
            }
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
    
    HomeView(launchCount: 4)
        .environment(gameManager)
        .environment(boardViewModel)
}

#Preview("Loading") {
    struct Preview: View {
        let gameManager = GameManager(width: 40, height: 80)
        let boardViewModel = BoardViewModel()
        
        init() {
            gameManager.isLoading = true
        }
        
        var body: some View {
            HomeView(launchCount: 1)
                .environment(gameManager)
                .environment(boardViewModel)
        }
    }
    
    return Preview()
}
