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
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !showSplashScreen {
                    HomeView(launchCount: launchCount)
                } else {
                    SplashScreenView()
                        .onTapGesture {
                            withAnimation {
                                showSplashScreen = false
                            }
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation {
                                    showSplashScreen = false
                                }
                            }
                            
                            Settings.shared.loadDefaults()
                            
                            if !completedLaunch {
                                launchCount = Settings.shared.launchCount
                                Settings.shared.setLaunchCount(launchCount)
                                completedLaunch = true
                            }
                        }
                        .transition(.opacity)
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
