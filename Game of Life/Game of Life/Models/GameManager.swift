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
    var timer: Timer?
    var autoplay: Bool
    var isProcessingTick: Bool = false
    var currentTick: Task<Void, Never>? = nil
    var wasAutoplaying: Bool = false
    var isLoading: Bool = false
    
    init(width: Int = Settings.shared.boardWidth,
         height: Int = Settings.shared.boardHeight,
         tickTime: Double = Settings.shared.tickTime) {
        self.board = Board(width: width, height: height)
        self.tickTime = tickTime
        self.autoplay = false
    }

    func startAutoplay() {
        timer = setTimer()
    }
    
    func stopAutoplay() {
        // attribution: https://www.hackingwithswift.com/quick-start/concurrency/how-to-cancel-a-task
        // attribution: https://www.avanderlee.com/concurrency/detached-tasks/
        self.currentTick?.cancel()
        timer?.invalidate()
    }
    
    func restartAutoplay() {
        stopAutoplay()
        startAutoplay()
    }
    
    func setTimer() -> Timer {
        // set up timer for next tick only to accomodate if processing time > tick freq and not stack calls
        return Timer.scheduledTimer(withTimeInterval: pow(10, -tickTime), repeats: false) { _ in
            self.currentTick = self.tick()
       }
    }
    
    func tick() -> Task<Void, Never>? {
        guard !isProcessingTick else { return nil }
        return Task {
            await MainActor.run { isProcessingTick = true }
            await board.tickAsync()
            await MainActor.run {
                isProcessingTick = false
                if self.autoplay {
                    scheduleTick()
                }
            }
        }
    }
    
    private func scheduleTick() {
        timer?.invalidate()
        timer = setTimer()
    }
    
    func toggleAutoplay() {
        autoplay.toggle()
        
        // stop no matter what in case user hits too quickly
        stopAutoplay()
        if autoplay {
            startAutoplay()
            self.currentTick = tick()
        }
    }
    
    func randomizeBoard() {
        if board.width * board.height > 100000 {
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.board.randomize()
                self.isLoading = false
            }
        }
        else {
            self.board.randomize()
        }
    }
    
    func resizeBoard(width: Int, height: Int) {
        board = Board(width: width, height: height)
        randomizeBoard()
        
        Settings.shared.setBoardWidth(width)
        Settings.shared.setBoardHeight(height)
    }
    
    func updateTickTime(_ newTickTime: Double) {
        tickTime = newTickTime
        Settings.shared.setTickTime(tickTime)
        
        if autoplay {
            restartAutoplay()
        }
    }
    
    func handleScenePhaseChange(old: ScenePhase, new: ScenePhase) {
        if old == .active {
            if autoplay {
                wasAutoplaying = true
                autoplay = false
                stopAutoplay()
            }
        }
        
        if new == .active {
            if wasAutoplaying {
                wasAutoplaying = false
                autoplay = true
                startAutoplay()
            }
        }
    }
}
