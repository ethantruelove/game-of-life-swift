//
//  Game_of_LifeApp.swift
//  Game of Life
//
//  Created by Ethan Truelove on 2/26/25.
//

import SwiftUI

@main
struct Game_of_LifeApp: App {
    /// Indicates whether or not the splash screen should be shown.
    @State private var showSplashScreen: Bool = true
    /// The number of times the application has been launched (zero indexed).
    @State private var launchCount: Int = 0
    /// The scene phase to keep track of.
    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    /// Indicates whether or not the launch has completed by loading settings and initializing global states.
    @State private var completedLaunch: Bool = false
    
    /// The creation of the `GameManager` to track in the environment later.
    @State private var gameManager: GameManager? = nil
    /// The creation of the `BoardViewModel` to track in the environment later.
    @State private var boardViewModel: BoardViewModel? = nil
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // show the home screen view once splash screen is gone and global models loaded
                if !showSplashScreen {
                    if let gameManager, let boardViewModel {
                        // attribution: https://stackoverflow.com/questions/76958093/how-to-bind-environment-variable-ios17
                        HomeView(launchCount: launchCount)
                            .environment(gameManager)
                            .environment(boardViewModel)
                    }
                } else {
                    SplashScreenView()
                        // allow for early dismissal of the splash screen
                        .onTapGesture {
                            showSplashScreen = false
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                showSplashScreen = false
                            }
                            
                            // load in relevant settings and instantiate global model objects
                            Settings.shared.loadDefaults()
                            let sWidth = Settings.shared.boardWidth
                            let sHeight = Settings.shared.boardHeight
                            let sTickTime = Settings.shared.tickTime
                            self.gameManager = GameManager(width: sWidth, height: sHeight, tickTime: sTickTime)
                            self.boardViewModel = BoardViewModel()
                            
                            // increment the launch count on a successful launch
                            if !completedLaunch {
                                launchCount = Settings.shared.launchCount
                                Settings.shared.setLaunchCount(launchCount + 1)
                                completedLaunch = true
                            }
                        }
                }
            }
            // attribution: https://www.jessesquires.com/blog/2024/06/29/swiftui-scene-phase/
            .onChange(of: scenePhase) { old, new in
                // make sure splash screen does not come back when focusing back in
                if new == .active && old == .background {
                    showSplashScreen = false
                }
            }
        }
    }
}
