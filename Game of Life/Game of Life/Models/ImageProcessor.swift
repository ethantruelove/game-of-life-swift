//
//  ImageProcessor.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/2/25.
//

import UIKit
import SwiftUI

struct ImageProcessor {
    static func convertImageToBoard(
        uiImage: UIImage,
        gameManager: GameManager,
        boardViewModel: BoardViewModel
    ) -> Bool {
        guard let cgImage = uiImage.cgImage else {
            return false
        }
        
        let reduction = min(1, 100000 / (uiImage.size.width * uiImage.size.height))
        let width = Int(uiImage.size.width * pow(reduction, 0.5))
        let height = Int(uiImage.size.height * pow(reduction, 0.5))
        
        gameManager.resizeBoard(width: width, height: height)
        boardViewModel.resetView()
        
        boardViewModel.baseCellSize = min(
            boardViewModel.boardViewWidth / CGFloat(width),
            boardViewModel.boardViewHeight / CGFloat(height)
        )
        boardViewModel.cellSize = boardViewModel.baseCellSize
        
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
        ) else { return false }
    
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // attribution: https://stackoverflow.com/questions/33214508/how-do-i-get-the-rgb-value-of-a-pixel-using-cgcontext
        guard let pixelData = context.data else { return false }
        let buffer = pixelData.bindMemory(to: UInt8.self, capacity: width * height)
        
        // attribution: https://developer.apple.com/documentation/foundation/data/2832722-advanced
        // attribution: https://developer.apple.com/documentation/swift/unsafemutablepointer/pointee/
        let sum = (0..<(height * width)).reduce(0) { acc, index in
            acc + Int(buffer.advanced(by: index).pointee)
        }
        let threshold = Double(sum) / Double(height * width)
        
        for y in (0..<height).reversed() {
            for x in (0..<width).reversed() {
                if buffer[y * width + x] < UInt8(threshold) {
                    gameManager.board.setCell(x: x, y: y, state: true)
                }
            }
        }
        
        return true
    }
}
