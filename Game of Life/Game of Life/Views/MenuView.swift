//
//  MenuView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/1/25.
//

import SwiftUI
import Combine

struct MenuView: View {
    @Binding var offset: CGSize
    @Binding var lastOffset: CGSize
    @Binding var scale: CGFloat
    @Binding var lastScale: CGFloat
    @Binding var cellSize: CGFloat
    @Binding var baseCellSize: CGFloat
    @Binding var board: Board
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    @Binding var tickTime: Double
    
    @Binding var boardViewWidth: CGFloat
    @Binding var boardViewHeight: CGFloat
    
    @State private var showBoardSizePopover = false
    @State private var newWidth = ""
    @State private var newHeight = ""
    
    var body: some View {
        HStack {
            Spacer()
            
            // attribution: https://www.swiftyplace.com/blog/swiftui-popovers-and-popups
            Button(action: {
                newWidth = "\(board.width)"
                newHeight = "\(board.height)"
                showBoardSizePopover = true
            }) {
                Image(systemName: "squareshape.split.3x3")
            }
            .popover(isPresented: $showBoardSizePopover) {
                BoardSizePopoverView(
                    board: $board,
                    offset: $offset,
                    lastOffset: $lastOffset,
                    scale: $scale,
                    lastScale: $lastScale,
                    cellSize: $cellSize,
                    baseCellSize: $baseCellSize,
                    boardViewWidth: $boardViewWidth,
                    boardViewHeight: $boardViewHeight,
                    showPopover: $showBoardSizePopover,
                    newWidth: $newWidth,
                    newHeight: $newHeight
                )
                .presentationCompactAdaptation(.popover)
            }
            
            Spacer()
            Button(action: {
                offset = .zero
                lastOffset = .zero
                scale = 1
                lastScale = 1
                cellSize = baseCellSize
            }) {
                Image(systemName: "dot.scope")
            }
            Spacer()
            Button(action: {
                board.randomize()
            }) {
                Image(systemName: "dice.fill")
            }
            Spacer()
            Button(action: {
                board.tick()
            }) {
                Image(systemName: "arrow.forward")
            }
            Spacer()
            Button(action: {
                board.autoplay.toggle()
                
                // stop no matter what in case user hits too quickly
                stopAutoplay()
                if board.autoplay {
                    startAutoplay()
                }
            }) {
                Image(systemName: board.autoplay ? "pause.fill" : "play.fill")
            }
            Spacer()
        }
        .padding(.vertical)
        .background(
            Rectangle().fill(Color("dead"))
                .shadow(color: Color("alive"), radius: 2, y: -1)
        )
    }
    
    // attribution: https://www.hackingwithswift.com/books/ios-swiftui/triggering-events-repeatedly-using-a-timer
    func startAutoplay() {
        timer = Timer.publish(every: tickTime, on: .main, in: .common).autoconnect()
    }
    
    func stopAutoplay() {
        timer.upstream.connect().cancel()
    }
}

#Preview {
    struct Preview: View {
        @State private var offset: CGSize = .zero
        @State private var lastOffset: CGSize = .zero
        @State private var scale: CGFloat = 1
        @State private var lastScale: CGFloat = 1
        @State private var cellSize: CGFloat = 5
        @State private var baseCellSize: CGFloat = 5
        @State private var board: Board = Board(width: 15, height: 25)
        @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher> = Timer.publish(every: 1000000, on: .main, in: .common).autoconnect()
        @State private var tickTime: Double = 0.1
        
        @State private var boardViewWidth: CGFloat = 400
        @State private var boardViewHeight: CGFloat = 600
        
        init() {
            board.randomize()
        }
        
        var body: some View {
            MenuView(
                offset: $offset,
                lastOffset: $lastOffset,
                scale: $scale,
                lastScale: $lastScale,
                cellSize: $cellSize,
                baseCellSize: $baseCellSize,
                board: $board,
                timer: $timer,
                tickTime: $tickTime,
                boardViewWidth: $boardViewWidth,
                boardViewHeight: $boardViewHeight
            )
        }
    }
    
    return Preview()
}
