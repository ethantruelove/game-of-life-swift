//
//  Settings.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/2/25.
//

import Foundation

// attribution: https://techmusings.optisolbusiness.com/ios-setting-bundle-integration-c4d12e95d130
// attribution: https://medium.com/@allan_alves/making-an-environment-manager-using-settings-bundle-on-ios-cbbecb6fd290
class Settings {
    static let shared = Settings()
    
    private init() {}
    
    var initialLaunch: Date? {
        return UserDefaults.standard.object(forKey: Keys.initialLaunch) as? Date
    }
    
    var boardWidth: Int {
        return UserDefaults.standard.integer(forKey: Keys.boardWidth)
    }
    
    var boardHeight: Int {
        return UserDefaults.standard.integer(forKey: Keys.boardHeight)
    }
    
    var tickTime: Double {
        return UserDefaults.standard.double(forKey: Keys.tickTime)
    }
    
    func setBoardWidth(_ width: Int) {
        UserDefaults.standard.set(width, forKey: Keys.boardWidth)
    }
    
    func setBoardHeight(_ height: Int) {
        UserDefaults.standard.set(height, forKey: Keys.boardHeight)
    }
    
    func setTickTime(_ tickTime: Double) {
        UserDefaults.standard.set(tickTime, forKey: Keys.tickTime)
    }
    
    func loadDefaults() {
        let defaults: [String: Any] = [
            Keys.boardWidth: 50,
            Keys.boardHeight: 100,
            Keys.tickTime: 1.0,
            Keys.developerName: "Ethan Truelove",
        ]
        
        UserDefaults.standard.register(defaults: defaults)
        
        if UserDefaults.standard.object(forKey: Keys.initialLaunch) == nil {
            UserDefaults.standard.set(Date(), forKey: Keys.initialLaunch)
        }
    }
}
