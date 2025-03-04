//
//  InfoView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/4/25.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Change edit modes")
                    .padding()
                    .background(Rectangle().fill(Color.gray))
                    .cornerRadius(10)
                    .padding(.trailing)
                    .padding(.top, 75)
            }
            Spacer()
            Text("Manipulate the board")
                .padding()
                .background(Rectangle().fill(Color.gray))
                .cornerRadius(10)
                .padding(.bottom, 40)
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.4)
            .edgesIgnoringSafeArea(.all)
        InfoView()
    }
}
