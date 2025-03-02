//
//  SpeedView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/2/25.
//

import SwiftUI

struct SpeedView: View {
    @Binding var tickTime: Double
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
            Text("\(String(format: "%g", pow(10, tickTime))) (gen/s)")
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    struct Preview: View {
        @State private var tickTime: Double = 1
        
        var body: some View {
            SpeedView(
                tickTime: $tickTime,
                onTickChange: {}
            )
        }
    }
    
    return Preview()
}
