//
//  SettingsButton.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/1/25.
//

import SwiftUI

struct SettingsSubButtonView: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(Circle().fill(.gray))
        }
    }
}


#Preview {
    struct Preview: View {
        @State var editMode: EditMode = .none
        var body: some View {
            SettingsSubButtonView(icon: editMode.iconName) {
                editMode = .fill
            }
        }
    }
    
    return Preview()
}
