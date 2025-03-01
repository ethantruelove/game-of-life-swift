//
//  SettingsPrimaryButtonView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/1/25.
//

import SwiftUI

struct SettingsPrimaryButtonView: View {
    @Binding var showSettings: Bool
    var editMode: EditMode
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                showSettings.toggle()
            }
        }) {
            Image(systemName: editMode.iconName)
                .font(.system(size: 25))
                .foregroundColor(showSettings ? .blue : .gray)
                .rotationEffect(Angle(degrees: showSettings ? 360 : 0))
                .frame(width: 20, height: 20)
                .scaledToFit()
                .padding()
                .background(Circle().fill(Color.gray.opacity(0.2)))
        }
    }
}


#Preview {
    struct Preview: View {
        @State private var showSettings: Bool = true
        let editMode: EditMode = .none
        
        var body: some View {
            SettingsPrimaryButtonView(showSettings: $showSettings, editMode: editMode)
        }
    }
    
    return Preview()
}
