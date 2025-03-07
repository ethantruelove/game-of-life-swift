//
//  SpeedView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/2/25.
//

import SwiftUI

/// A view to show the slider and visualize the tick time.
struct SpeedView: View {
    /// The number of generations per second to target represented as a negative log base 10 value.
    /// - Note: For example, `tickTime = 3` indicates that there should be 1,000 generations per second.
    @Binding var tickTime: Double
    /// The function to call whenever the `tickTime` changes.
    var onTickChange: () -> Void
    
    var body: some View {
        // attribution: https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-a-slider-and-read-values-from-it
        // attribution: https://codewithchris.com/swiftui-slider-tutorial-2023/
        VStack {
            Slider(
                value: $tickTime, in: -1...3,
                onEditingChanged: { editing in
                    if !editing {
                        onTickChange()
                        Settings.shared.setTickTime(tickTime)
                    }
            })
            // convert from logarithmic to generations per second
            Text("\(String(format: "%g", pow(10, tickTime))) (gen/s)")
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    @Previewable @State var tickTime: Double = 1
    
    SpeedView(tickTime: $tickTime, onTickChange: {})
}
