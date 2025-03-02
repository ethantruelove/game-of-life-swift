//
//  StarView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/2/25.
//

import SwiftUI

struct StarView: View {
    @State private var rating = 0
    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { num in
                Image(systemName: num <= rating ? "star.fill" : "star")
                    .foregroundColor(Color("rating"))
                    .onTapGesture {
                        rating = num
                    }
            }
        }
    }
}

#Preview {
    StarView()
}
