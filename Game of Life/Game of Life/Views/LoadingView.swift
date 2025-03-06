//
//  LoadingView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/5/25.
//

import SwiftUI

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
