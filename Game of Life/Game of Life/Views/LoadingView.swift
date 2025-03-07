//
//  LoadingView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/5/25.
//

import SwiftUI

/// A view to show the users to indicate the the board is being randomized or set.
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            Text("Loading board...")
                .foregroundStyle(Color("dead"))
                .padding()
                .background(Rectangle().fill(Color.gray))
                .cornerRadius(10)
        }
    }
}

#Preview {
    LoadingView()
}
