//
//  Game_of_LifeApp.swift
//  Game of Life
//
//  Created by Ethan Truelove on 2/26/25.
//

import SwiftUI

@main
struct Game_of_LifeApp: App {
    init() {
        Settings.shared.loadDefaults()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
