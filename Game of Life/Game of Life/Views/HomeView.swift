//
//  HomeView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 2/26/25.
//

import SwiftUI
import Combine

struct HomeView: View {
    private let launchCount: Int
    @State private var showRateView: Bool
    
    @State private var board: Board
    @State private var tickTime: Double = 0
    // start at high number to prevent wasted checking whenever autoplay is off
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher> = Timer.publish(every: 1000000, on: .main, in: .common).autoconnect()
    @State private var editMode: EditMode = .none
    @State private var cellSize: CGFloat = 5
    @State private var initialOffset: CGSize = .zero
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    @State private var showSettings = false
    
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    
    @State private var baseCellSize: CGFloat = 5
    @State private var boardViewWidth: CGFloat = 0
    @State private var boardViewHeight: CGFloat = 0
    
    @Environment(\.scenePhase) private var scenePhase: ScenePhase
    
    init(launchCount: Int) {
        self.launchCount = launchCount
        
        if launchCount == 2 {
            self.showRateView = true
        }
        else {
            self.showRateView = false
        }
        
        let sWidth = Settings.shared.boardWidth
        let sHeight = Settings.shared.boardHeight
        let sTickTime = Settings.shared.tickTime
        
        let board = Board(width: sWidth, height: sHeight)
        board.randomize()
        _board = State(initialValue: board)
        _tickTime = State(initialValue: sTickTime)
    }
    
    var body: some View {
        ZStack {
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
                        lastOffset: $lastOffset,
                        scale: $scale,
                        lastScale: $lastScale,
                        baseCellSize: baseCellSize)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .onAppear() {
                        // TODO: see if this is still needed after switching to Canvas
                        let screenWidth = geometry.size.width
                        let screenHeight = geometry.size.height * 0.75
                        let gridWidth = CGFloat(board.width) * cellSize
                        let gridheight = CGFloat(board.height) * cellSize
                        
                        initialOffset = CGSize(width: max(0, (screenWidth - gridWidth) / 2), height: max(0, (screenHeight - gridheight) / 2))
                        print("Setting initial offset to: \(initialOffset)")
                        
                        let minWidth = geometry.size.width / CGFloat(board.width)
                        let minHeight = geometry.size.height / CGFloat(board.height)
                        baseCellSize = min(minWidth, minHeight)
                        cellSize = baseCellSize
                        
                        boardViewWidth = geometry.size.width
                        boardViewHeight = geometry.size.height
                        print("Initial cellSize \(cellSize)")
                    }
                    .onReceive(timer) { _ in
                        if board.autoplay {
                            board.tick()
                        }
                    }
                    
                    VStack() {
                        HStack {
                            Spacer()
                            EditModeView(
                                showEditModes: $showSettings,
                                editMode: $editMode
                            )
                            .padding(.trailing)
                        }
                        
                        Spacer()
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
                        .background(Color("dead"))
                        .padding(.bottom)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        
            if showRateView {
                ZStack {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showRateView = false
                        }
                    RateView(showRateView: $showRateView)
                        .transition(.opacity)
                        .animation(.easeInOut, value: showRateView)
                }
            }
        }
        .onChange(of: scenePhase) { old, new in
            if old == .active {
                if board.autoplay {
                    timer.upstream.connect().cancel()
                }
            }
            
            if new == .active {
                if board.autoplay {
                    timer = Timer.publish(every: pow(10, -tickTime), on: .main, in: .common).autoconnect()
                }
            }
        }
    }
    
    private func checkSettingsChange() {
        let sWidth = Settings.shared.boardWidth
        let sHeight = Settings.shared.boardHeight
        let sTickTime = Settings.shared.tickTime
        
        if board.width != sWidth || board.height != sHeight {
            board = Board(width: sWidth, height: sHeight)
            board.randomize()
            
            offset = .zero
            lastOffset = .zero
            scale = 1
            lastScale = 1
            
            baseCellSize = min(boardViewWidth / CGFloat(board.width), boardViewHeight / CGFloat(board.height))
            cellSize = baseCellSize
        }
        
        if tickTime != sTickTime {
            tickTime = sTickTime
            
            if board.autoplay {
                timer.upstream.connect().cancel()
                timer = Timer.publish(every: pow(10, -tickTime), on: .main, in: .common).autoconnect()
            }
        }
    }
}

#Preview("Normal") {
    HomeView(launchCount: 1)
}

#Preview("Rate View") {
    HomeView(launchCount: 2)
}
