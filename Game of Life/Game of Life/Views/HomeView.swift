//
//  HomeView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 2/26/25.
//

import SwiftUI
import Combine

struct HomeView: View {
    @State private var board = Board(width: 40, height: 40)
    @State private var tickTime: Double = 0.1
    // start at high number to prevent wasted checking whenever autoplay is off
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher> = Timer.publish(every: 1000000, on: .main, in: .common).autoconnect()
    @State private var editMode: EditMode = .none
    @State private var baseCellSize: CGFloat = 25
    @State private var cellSize: CGFloat = 25
    @State private var initialOffset: CGSize = .zero
    @State private var offset: CGSize = .zero
    
    @State private var showSettings = false
    
    var body: some View {
        // attribution: https://stackoverflow.com/questions/60021403/how-to-get-height-and-width-of-view-or-screen-in-swiftui
        // attribution: https://developer.apple.com/documentation/swiftui/geometryreader
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                GameBoardView(
                    board: $board,
                    cellSize: $cellSize,
                    editMode: $editMode,
                    initialOffset: $initialOffset,
                    offset: $offset,
                    baseCellSize: baseCellSize)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .onAppear() {
                    let screenWidth = geometry.size.width
                    let screenHeight = geometry.size.height * 0.75
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
                
                VStack() {
                    HStack {
                        Spacer()
                        SettingsView(
                            showSettings: $showSettings,
                            editMode: $editMode
                        )
                        .padding(.trailing)
                    }
                    
                    Spacer()
                    MenuView(
                        offset: $offset,
                        board: $board,
                        timer: $timer,
                        tickTime: $tickTime
                    )
                    .background(Color("dead"))
                }
                //.frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    HomeView()
}
