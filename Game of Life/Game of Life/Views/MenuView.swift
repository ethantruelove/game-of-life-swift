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
    @Binding var board: Board
    @Binding var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    @Binding var tickTime: Double
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                offset = .zero
            }) {
                ZStack {
                    Image(systemName: "arrow.left.to.line")
                        .padding(.trailing)
                    Image(systemName: "arrow.right.to.line")
                        .padding(.leading)
                    Image(systemName: "arrow.up.to.line")
                        .padding(.bottom)
                    Image(systemName: "arrow.down.to.line")
                        .padding(.top)
                }
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
        @State private var board: Board = Board(width: 15, height: 25)
        @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher> = Timer.publish(every: 1000000, on: .main, in: .common).autoconnect()
        @State private var tickTime: Double = 0.1
        
        init() {
            board.randomize()
        }
        
        var body: some View {
            MenuView(
                offset: $offset,
                board: $board,
                timer: $timer,
                tickTime: $tickTime
            )
        }
    }
    
    return Preview()
}
