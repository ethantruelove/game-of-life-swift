//
//  MenuView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/1/25.
//

import SwiftUI
import Combine
import PhotosUI

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
    
    @State private var showSpeedView = false
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack {
            if showSpeedView {
                SpeedView(
                    tickTime: $tickTime,
                    onTickChange: {
                        if board.autoplay {
                            restartAutoplay()
                        }
                    }
                )
            }
            
            HStack {
                Spacer()
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "photo.on.rectangle")
                }
                // attribution: https://developer.apple.com/documentation/photokit/bringing-photos-picker-to-your-swiftui-app
                // attribution: https://www.hackingwithswift.com/quick-start/swiftui/how-to-let-users-select-pictures-using-photospicker
                .onChange(of: selectedItem) { _, newValue in
                    if let newValue {
                        Task {
                            if let data = try? await newValue.loadTransferable(type: Data.self) {
                                await MainActor.run {
                                    selectedImageData = data
                                }
                            }
                        }
                    }
                }
                .onChange(of: selectedImageData) {
                    if let selectedImageData, let uiImage = UIImage(data: selectedImageData) {
                        convertImageToBoard(uiImage: uiImage)
                    }
                }

                Spacer()
                
                // attribution: https://www.swiftyplace.com/blog/swiftui-popovers-and-popups
                Button(action: {
                    newWidth = "\(board.width)"
                    newHeight = "\(board.height)"
                    showBoardSizePopover.toggle()
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
                    showSpeedView.toggle()
                }) {
                    Image(systemName: "hare.fill")
                }
                
                Spacer()
                Button(action: {
                    centerBoard()
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
        }
        .padding(.vertical)
        .background(
            Rectangle().fill(Color("dead"))
                .shadow(color: Color("alive"), radius: 2, y: -1)
        )
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
    
    private func centerBoard() {
        offset = .zero
        lastOffset = .zero
        scale = 1
        lastScale = 1
        cellSize = baseCellSize
    }
    
    private func clearSelectedImage() {
        selectedItem = nil
        selectedImage = nil
        selectedImageData = nil
    }
    
    private func convertImageToBoard(uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage else {
            return
        }
        
        let reduction = min(1, 100000 / (uiImage.size.width * uiImage.size.height))
        let width = Int(uiImage.size.width * pow(reduction, 0.5))
        let height = Int(uiImage.size.height * pow(reduction, 0.5))
        
        board = Board(width: width, height: height)
        offset = .zero
        lastOffset = .zero

        baseCellSize = min(boardViewWidth / CGFloat(board.width), boardViewHeight / CGFloat(board.height))
        cellSize = baseCellSize
        
        scale = 1
        lastScale = 1
        
        Settings.shared.setBoardWidth(width)
        Settings.shared.setBoardHeight(height)
        
        // attribution: https://stackoverflow.com/questions/40178846/convert-uiimage-to-grayscale-keeping-image-quality
        // attribution: https://stackoverflow.com/questions/31966885/resize-uiimage-to-200x200pt-px
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).rawValue
        ) else { return }
    
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // attribution: https://stackoverflow.com/questions/33214508/how-do-i-get-the-rgb-value-of-a-pixel-using-cgcontext
        guard let pixelData = context.data else { return }
        let buffer = pixelData.bindMemory(to: UInt8.self, capacity: width * height)
        
        // attribution: https://developer.apple.com/documentation/foundation/data/2832722-advanced
        // attribution: https://developer.apple.com/documentation/swift/unsafemutablepointer/pointee/
        let sum = (0..<(height * width)).reduce(0) { acc, index in
            acc + Int(buffer.advanced(by: index).pointee)
        }
        let threshold = Double(sum) / Double(height * width)
        
        board.cells.removeAll()
        for y in (0..<height).reversed() {
            for x in (0..<width).reversed() {
                if buffer[y * width + x] < UInt8(threshold) {
                    board.setCell(x: x, y: y, state: true)
                }
            }
        }
        
        centerBoard()
        clearSelectedImage()
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
