//
//  Game_of_LifeApp.swift
//  Game of Life
//
//  Created by Ethan Truelove on 2/26/25.
//

import SwiftUI

@main
struct Game_of_LifeApp: App {
    let launchCount: Int = Settings.shared.launchCount
    
    init() {
        Settings.shared.loadDefaults()
        Settings.shared.setLaunchCount(launchCount + 1)
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView(launchCount: launchCount)
        }
    }
}
