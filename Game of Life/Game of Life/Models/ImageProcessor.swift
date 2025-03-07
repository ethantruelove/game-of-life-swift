//
//  ImageProcessor.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/2/25.
//

import UIKit
import SwiftUI

/// The image processing class to handle converting the provided `UIImage` from `PhotosPicker` into a board view model.
struct ImageProcessor {
    
    /// Convert a provided UIImage to a proper board model by updating the BoardViewModel.
    /// - Parameters:
    ///   - uiImage: The `UIImage` to convert.
    ///   - gameManager: The `GameManager` object to update relevant properties.
    ///   - boardViewModel: The `BoardViewModel` object to update with the image data.
    /// - Returns: Indicates whether or not the conversion was successul.
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
        // this is because images like those taken in portrait mode have their widths and heights flipped
        // and rely on the orientation to properly handle rendering
        switch uiImage.imageOrientation {
        case .left, .right, .leftMirrored, .rightMirrored:
            swap(&imageWidth, &imageHeight)
        default:
            break
        }
        
        // reduce the size of the image to something more appropriate for a board size
        // that will still allow for detailed view of the image
        let reduction = min(1, 100000 / (uiImage.size.width * uiImage.size.height))
        let width = Int(uiImage.size.width * pow(reduction, 0.5))
        let height = Int(uiImage.size.height * pow(reduction, 0.5))
        
        gameManager.isLoading = true
        
        // allow a buffer to place the loading view on for the upcoming computation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
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
            // begin a context to draw the UIImage into so that it can be reoriented
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 1.0)
            guard let _ = UIGraphicsGetCurrentContext() else { return }
            uiImage.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            
            // get the underlying cgImage now that it has been properly oriented
            guard let normalizedImage = UIGraphicsGetImageFromCurrentImageContext(),
                  let normalizedCGImage = normalizedImage.cgImage else {
                return
            }
            
            // attribution: https://stackoverflow.com/questions/40178846/convert-uiimage-to-grayscale-keeping-image-quality
            // attribution: https://stackoverflow.com/questions/31966885/resize-uiimage-to-200x200pt-px
            // create a new context to map the image into gray scale to extract brightness values
            guard let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width,
                space: CGColorSpaceCreateDeviceGray(),
                bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue).rawValue
            ) else { return }
            
            context.draw(normalizedCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            
            // attribution: https://stackoverflow.com/questions/33214508/how-do-i-get-the-rgb-value-of-a-pixel-using-cgcontext
            // pull out the raw buffer data from the image context
            guard let pixelData = context.data else { return }
            let buffer = pixelData.bindMemory(to: UInt8.self, capacity: width * height)
            
            // attribution: https://developer.apple.com/documentation/foundation/data/2832722-advanced
            // attribution: https://developer.apple.com/documentation/swift/unsafemutablepointer/pointee/
            // run a reduction across the image buffer to find total brightness
            let sum = (0..<(height * width)).reduce(0) { acc, index in
                acc + Int(buffer.advanced(by: index).pointee)
            }
            // get the average brightness
            let threshold = Double(sum) / Double(height * width)
            
            // flip to represent in coordinate space where (0,0) is top left of view
            // set cells above average brightness as dead and those below as alive
            // future improvement could allow inversion toggle or using median instead of mean
            for y in (0..<height).reversed() {
                for x in (0..<width).reversed() {
                    if buffer[y * width + x] < UInt8(threshold) {
                        gameManager.board.setCell(x: x, y: y, state: true)
                    }
                }
            }
            
            // perform recalculations for the view model based on our new board model
            boardViewModel.resizeBoard(width: width, height: height)
            boardViewModel.initialOffset = boardViewModel.calculateOffsetForContainingView(boardWidth: width, boardHeight: height)
            boardViewModel.offset = boardViewModel.initialOffset
            boardViewModel.lastOffset = boardViewModel.initialOffset
            
            UIGraphicsEndImageContext()
            gameManager.isLoading = false
        }
        return true
    }
}
