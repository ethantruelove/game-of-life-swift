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
        var imageWidth = uiImage.size.width
        var imageHeight = uiImage.size.height
        
        // need to make sure photo is "up"
        // attribution: https://stackoverflow.com/questions/61149127/ensuring-image-data-is-correctly-oriented-on-ios-app-in-swift-5
        // attribution: https://developer.apple.com/documentation/swiftui/image/orientation
        // attribution: https://stackoverflow.com/questions/62266178/swift-function-that-swaps-two-values
        switch uiImage.imageOrientation {
        case .left, .right, .leftMirrored, .rightMirrored:
            swap(&imageWidth, &imageHeight)
        default:
            break
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
        
        // attribution: https://stackoverflow.com/questions/41991903/swift-images-rotated-from-portrait-to-landscape-when-loaded-from-firebase
        // attribution: https://stackoverflow.com/questions/27092354/rotating-uiimage-in-swift
        // attribution: https://stackoverflow.com/questions/21785254/uigraphicsgetcurrentcontext-vs-uigraphicsbeginimagecontext-uigraphicsendimagecon
        // attribution: https://www.hackingwithswift.com/guide/ios-classic/10/2/key-points
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 1.0)
        guard let _ = UIGraphicsGetCurrentContext() else { return false }
        uiImage.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let normalizedImage = UIGraphicsGetImageFromCurrentImageContext(),
              let normalizedCGImage = normalizedImage.cgImage else {
            return false
        }
        
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
        
        context.draw(normalizedCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
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
        
        boardViewModel.resizeBoard(width: width, height: height, boardWidth: width, boardHeight: height)
        boardViewModel.initialOffset = boardViewModel.calculateOffsetForContainingView(boardWidth: width, boardHeight: height)
        boardViewModel.offset = boardViewModel.initialOffset
        boardViewModel.lastOffset = boardViewModel.initialOffset
        
        UIGraphicsEndImageContext()
        
        return true
    }
}
