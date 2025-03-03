//
//  GameManager.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/2/25.
//

import SwiftUI
import Observation
import Combine

@Observable
class GameManager {
    var board: Board
    var tickTime: Double
    var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    init(width: Int = Settings.shared.boardWidth,
         height: Int = Settings.shared.boardHeight,
         tickTime: Double = Settings.shared.tickTime) {
        self.board = Board(width: width, height: height)
        self.tickTime = tickTime
        self.timer = Timer.publish(every: 1000000, on: .main, in: .common).autoconnect()
        self.board.randomize()
    }
    
    // attribution: https://www.hackingwithswift.com/books/ios-swiftui/triggering-events-repeatedly-using-a-timer
    func startAutoplay() {
        timer = Timer.publish(every: pow(10, -tickTime), on: .main, in: .common).autoconnect()
    }
    
    func stopAutoplay() {
        timer.upstream.connect().cancel()
    }
    
    func restartAutoplay() {
        stopAutoplay()
        startAutoplay()
    }
    
    func tick() {
        board.tick()
    }
    
    func toggleAutoplay() {
        board.autoplay.toggle()
        
        // Stop no matter what in case user hits too quickly
        stopAutoplay()
        if board.autoplay {
            startAutoplay()
        }
    }
    
    func randomizeBoard() {
        board.randomize()
    }
    
    func resizeBoard(width: Int, height: Int) {
        board = Board(width: width, height: height)
        board.randomize()
        
        Settings.shared.setBoardWidth(width)
        Settings.shared.setBoardHeight(height)
    }
    
    func updateTickTime(_ newTickTime: Double) {
        tickTime = newTickTime
        Settings.shared.setTickTime(tickTime)
        
        if board.autoplay {
            restartAutoplay()
        }
    }
    
    func handleScenePhaseChange(old: ScenePhase, new: ScenePhase) {
        if old == .active {
            if board.autoplay {
                stopAutoplay()
            }
        }
        
        if new == .active {
            if board.autoplay {
                startAutoplay()
            }
        }
    }
}
