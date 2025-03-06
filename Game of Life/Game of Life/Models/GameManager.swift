//
//  GameManager.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/2/25.
//

import SwiftUI
import Observation
import Combine

/// The model object to handle game managemenet overall beyond simple board state.
@Observable
class GameManager {
    /// The underlying board model to manage.
    var board: Board
    /// The number of generations per second to target represented as a negative log base 10 value.
    /// - Note: For example, `tickTime = 3` indicates that there should be 1,000 generations per second.
    var tickTime: Double
    /// The timer to fire the next generation for if `autoplay` is `True`.
    var timer: Timer?
    /// Whether or not the user wants ticks to occur automatically.
    var autoplay: Bool
    /// Indicates whether or not a generation is currently being calculated.
    var isProcessingTick: Bool = false
    /// Tracks the task for the current tick being processed.
    var currentTick: Task<Void, Never>? = nil
    /// Indicates if autoplaying was turned on previously.
    /// - Note: This is used to disable autoplay on scene switch to background and resume upon return.
    var wasAutoplaying: Bool = false
    /// Indicates whether or not the underlying board model is in a process (e.g. randomizing, setting, etc.).
    var isLoading: Bool = false
    
    /// The initializer for the game manager.
    /// - Parameters:
    ///   - width: The width of the board by cell count.
    ///   - height: The height of the board by cell count.
    ///   - tickTime: The number of generations per second to target represented as a negative log base 10 value.
    init(width: Int = Settings.shared.boardWidth,
         height: Int = Settings.shared.boardHeight,
         tickTime: Double = Settings.shared.tickTime) {
        self.board = Board(width: width, height: height)
        self.tickTime = tickTime
        self.autoplay = false
    }
    
    /// Upon starting autoplay, set the `timer` to fire at the scheduled `tickTime` from now.
    func startAutoplay() {
        timer = setTimer()
    }
    
    /// Stop the timer and cancel the current calculation's task if it is ongoing.
    func stopAutoplay() {
        // attribution: https://www.hackingwithswift.com/quick-start/concurrency/how-to-cancel-a-task
        // attribution: https://www.avanderlee.com/concurrency/detached-tasks/
        self.currentTick?.cancel()
        timer?.invalidate()
    }
    
    /// Wrapper to stop and start autoplay again to ensure flushing of previous calculation.
    func restartAutoplay() {
        stopAutoplay()
        startAutoplay()
    }
    
    /// Set the timer to fire at the proper time
    /// - Returns: The timer object that was set
    func setTimer() -> Timer {
        // set up timer for next tick only to accomodate if processing time > tick freq and not stack calls
        return Timer.scheduledTimer(withTimeInterval: pow(10, -tickTime), repeats: false) { _ in
            self.currentTick = self.tick()
       }
    }
    
    /// Triggers and returns the task with the next generation's calculation.
    /// - Returns: The Task object of the next generation's calculation.
    func tick() -> Task<Void, Never>? {
        // do not schedule the next generation if one is currently being calculated
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
    
    /// Schedule the next generation's calculation, invalidate the current timer and set a new one to refresh the timing.
    /// - Note: This is mainly helpful for when calculation time takes longer than the target `tickTime`.
    private func scheduleTick() {
        timer?.invalidate()
        timer = setTimer()
    }
    
    /// Flip autoplay's state.
    func toggleAutoplay() {
        autoplay.toggle()
        
        // stop no matter what in case user hits too quickly
        stopAutoplay()
        if autoplay {
            startAutoplay()
            self.currentTick = tick()
        }
    }
    
    /// Randomize the underlying board model.
    func randomizeBoard() {
        // allow a small delay for the UI to put on the loading screen if needed due to large board size
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
    
    /// Resize the board with the new provided `width` and `height`.
    /// - Parameters:
    ///   - width: The width of the new board by cell count.
    ///   - height: The height of the new board by cell count.
    func resizeBoard(width: Int, height: Int) {
        board = Board(width: width, height: height)
        randomizeBoard()
        
        Settings.shared.setBoardWidth(width)
        Settings.shared.setBoardHeight(height)
    }
    
    /// Update the `tickTime` value with the provided one.
    /// - Parameter newTickTime: The number of generations per second to target represented as a negative log base 10 value.
    func updateTickTime(_ newTickTime: Double) {
        tickTime = newTickTime
        Settings.shared.setTickTime(tickTime)
        
        // restart autoplay with the new tick time if it was ongoing
        if autoplay {
            restartAutoplay()
        }
    }
    
    /// Handle various parameters based on scene change.
    /// - Parameters:
    ///   - old: The old scene phase.
    ///   - new: The new scene phase.
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
