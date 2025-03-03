//
//  RateView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/2/25.
//

import SwiftUI

struct RateView: View {
    @Binding var showRateView: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("background"))
                .border(.red, width: 5)
                .cornerRadius(10)
            VStack {
                Spacer()
                Text("Thanks for playing!\nLeave a review?")
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                StarView()
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showRateView = false
                    }) {
                        Text("Dismiss")
                    }
                    Spacer()
                    Button(action: {
                        showRateView = false
                    }) {
                        Text("Submit")
                    }
                    Spacer()
                }
                Spacer()
            }
        }
        .frame(width: 250, height: 200)
            
    }
}

#Preview {
    @Previewable @State var showRateView: Bool = true
    
    RateView(showRateView: $showRateView)
}
