//
//  Game_of_LifeApp.swift
//  Game of Life
//
//  Created by Ethan Truelove on 2/26/25.
//

import SwiftUI

@main
struct Game_of_LifeApp: App {
    @State private var showSplashScreen: Bool = true
    @State private var launchCount: Int = 0
    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    @State private var completedLaunch: Bool = false
    
    @State private var gameManager: GameManager? = nil
    @State private var boardViewModel: BoardViewModel? = nil
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !showSplashScreen {
                    if let gameManager, let boardViewModel {
                        // attribution: https://stackoverflow.com/questions/76958093/how-to-bind-environment-variable-ios17
                        HomeView(launchCount: launchCount)
                            .environment(gameManager)
                            .environment(boardViewModel)
                    }
                } else {
                    SplashScreenView()
                        .onTapGesture {
                            showSplashScreen = false
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                showSplashScreen = false
                            }
                            
                            Settings.shared.loadDefaults()
                            let sWidth = Settings.shared.boardWidth
                            let sHeight = Settings.shared.boardHeight
                            let sTickTime = Settings.shared.tickTime
                            self.gameManager = GameManager(width: sWidth, height: sHeight, tickTime: sTickTime)
                            self.boardViewModel = BoardViewModel()
                            
                            if !completedLaunch {
                                launchCount = Settings.shared.launchCount
                                Settings.shared.setLaunchCount(launchCount)
                                completedLaunch = true
                            }
                        }
                }
            }
            // attribution: https://www.jessesquires.com/blog/2024/06/29/swiftui-scene-phase/
            .onChange(of: scenePhase) { old, new in
                if new == .active && old == .background {
                    showSplashScreen = false
                }
            }
        }
    }
}
