//
//  Settings.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/2/25.
//

import Foundation

// attribution: https://techmusings.optisolbusiness.com/ios-setting-bundle-integration-c4d12e95d130
// attribution: https://medium.com/@allan_alves/making-an-environment-manager-using-settings-bundle-on-ios-cbbecb6fd290

/// A class for settings loading and setting.
class Settings {
    /// The singleton to reference throughout the application.
    static let shared = Settings()
    
    /// Initializer to nothing.
    private init() {}
    
    /// The `initialLaunch` date
    /// - Note: Can be `nil` as this is not defined in Root.plist
    var initialLaunch: Date? {
        return UserDefaults.standard.object(forKey: Keys.initialLaunch) as? Date
    }
    
    /// The number of times the application has been launched.
    var launchCount: Int {
        return UserDefaults.standard.integer(forKey: Keys.launchCount)
    }
    
    /// Set the number of times the application has been launched.
    /// - Parameter launchCount: The number of times the application has been launched.
    func setLaunchCount(_ launchCount: Int) {
        UserDefaults.standard.set(launchCount, forKey: Keys.launchCount)
    }
    
    /// The width of the board by cell count.
    var boardWidth: Int {
        return UserDefaults.standard.integer(forKey: Keys.boardWidth)
    }
    
    /// The height of the board by cell count.
    var boardHeight: Int {
        return UserDefaults.standard.integer(forKey: Keys.boardHeight)
    }
    
    /// The number of generations per second to target represented as a negative log base 10 value.
    /// - Note: For example, `tickTime = 3` indicates that there should be 1,000 generations per second.
    var tickTime: Double {
        return UserDefaults.standard.double(forKey: Keys.tickTime)
    }
    
    /// Commit the board width cell count to settings.
    /// - Parameter width: The width of the board by cell count.
    func setBoardWidth(_ width: Int) {
        UserDefaults.standard.set(width, forKey: Keys.boardWidth)
    }
    
    /// Commit the board height cell count to settings.
    /// - Parameter height: The height of the board by cell count.
    func setBoardHeight(_ height: Int) {
        UserDefaults.standard.set(height, forKey: Keys.boardHeight)
    }
    
    /// Commit the tick time tio settings.
    /// - Parameter tickTime: The tick time.
    func setTickTime(_ tickTime: Double) {
        UserDefaults.standard.set(tickTime, forKey: Keys.tickTime)
    }
    
    /// Default values to load in from settings if they are missing
    /// - Note: This should also be defined in the Root.plist file but is here for redundancy.
    func loadDefaults() {
        let defaults: [String: Any] = [
            Keys.boardWidth: 50,
            Keys.boardHeight: 100,
            Keys.tickTime: 1.0,
            Keys.developerName: "Ethan Truelove",
        ]
        
        UserDefaults.standard.register(defaults: defaults)
        
        // if there is no `initialLaunch` item, set it to the current date
        if UserDefaults.standard.object(forKey: Keys.initialLaunch) == nil {
            UserDefaults.standard.set(Date(), forKey: Keys.initialLaunch)
        }
    }
}
