//
//  HomeView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 2/26/25.
//

import SwiftUI

struct HomeView: View {
    @State private var board = Board(width: 20, height: 30)
    @State private var tickTime: Double = 0.1
    // start at high number to prevent wasted checking whenever autoplay is off
    @State private var timer = Timer.publish(every: 1000000, on: .main, in: .common).autoconnect()
    @State private var editMode = false
    @State private var baseCellSize: CGFloat = 25
    @State private var cellSize: CGFloat = 25
    @State private var offset = CGSize.zero
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Button(editMode ? "Done" : "Edit") {
                        editMode.toggle()
                    }
                    .padding(.leading)
                    Spacer()
                }
                Text("Game of Life")
                    .font(.system(size: 30))
                    .padding()
                HStack {
                    Spacer()
                    Button(action: {
                        print("Button tapped!")
                    }) {
                        Image(systemName: "gear")
                            .font(.system(size: 25))
                            .foregroundColor(.gray)
                            .padding()
                            //.background(Circle().fill(Color.gray.opacity(0.2)))
                    }
                    .padding(.trailing)

                }
            }
            
            GameBoardView(
                board: $board,
                cellSize: $cellSize,
                editMode: $editMode,
                offset: $offset,
                lastScale: $lastScale,
                baseCellSize: baseCellSize)
            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.75)
            .clipped()
            .onReceive(timer) { _ in
                if board.autoplay {
                    board.tick()
                }
            }
            
            Spacer()
            
            ZStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.1)
                HStack {
                    Spacer()
                    Button("Randomize") {
                        board.randomize()
                    }
                    Spacer()
                    Button("Step forward") {
                        board.tick()
                    }
                    Spacer()
                    Button(board.autoplay ? "Pause" : "Start") {
                        board.autoplay.toggle()
                        
                        // stop no matter what in case user hits too quickly
                        stopAutoplay()
                        if board.autoplay {
                            startAutoplay()
                        }
                    }
                    Spacer()
                }
            }
        }
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
    HomeView()
}
