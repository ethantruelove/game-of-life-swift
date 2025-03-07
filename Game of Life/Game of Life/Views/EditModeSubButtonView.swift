//
//  SettingsButton.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/1/25.
//

import SwiftUI


/// A view to handle the buttons that are other options to select.
struct EditModeSubButtonView: View {
    /// The SF Symbol icon to render.
    let icon: String
    /// The action to perform on button tap.
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
    @Previewable @State var editMode: EditMode = .none
    
    EditModeSubButtonView(icon: editMode.iconName) {
        editMode = editMode == .none ? .fill : .none
    }
}
