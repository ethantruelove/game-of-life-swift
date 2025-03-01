//
//  HomeView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 2/26/25.
//

import SwiftUI

struct HomeView: View {
    @State private var board = Board(width: 15, height: 30)
    @State private var tickTime: Double = 0.1
    // start at high number to prevent wasted checking whenever autoplay is off
    @State private var timer = Timer.publish(every: 1000000, on: .main, in: .common).autoconnect()
    @State private var editMode: EditMode = .none
    @State private var baseCellSize: CGFloat = 25
    @State private var cellSize: CGFloat = 25
    @State private var initialOffset: CGSize = .zero
    @State private var offset: CGSize = .zero
    
    @State private var showSettings = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                GameBoardView(
                    board: $board,
                    cellSize: $cellSize,
                    editMode: $editMode,
                    initialOffset: $initialOffset,
                    offset: $offset,
                    baseCellSize: baseCellSize)
                .frame(maxWidth: .infinity, maxHeight:. infinity)
                //.clipped()
                .onAppear() {
                    let screenWidth = UIScreen.main.bounds.width
                    let screenHeight = UIScreen.main.bounds.height * 0.75
                    let gridWidth = CGFloat(board.width) * cellSize
                    let gridheight = CGFloat(board.height) * cellSize
                    
                    initialOffset = CGSize(width: max(0, (screenWidth - gridWidth) / 2), height: max(0, (screenHeight - gridheight) / 2))
                    print("Setting initial offset to: \(initialOffset)")
                }
                .onReceive(timer) { _ in
                    if board.autoplay {
                        board.tick()
                    }
                }
                
                SettingsView(
                    showSettings: $showSettings,
                    editMode: $editMode
                )
                    .padding(.trailing)
            }
            
            Spacer()
            
            ZStack {
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
            }
            .zIndex(1)
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
