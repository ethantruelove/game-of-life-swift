//
//  SettingsPrimaryButtonView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/1/25.
//

import SwiftUI

struct EditModePrimaryButtonView: View {
    @Binding var showEditModes: Bool
    var editMode: EditMode
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                showEditModes.toggle()
            }
        }) {
            Image(systemName: editMode.iconName)
                .font(.system(size: 25))
                .foregroundColor(showEditModes ? .blue : .gray)
                .shadow(color: Color("dead"), radius: 3)
                .rotationEffect(Angle(degrees: showEditModes ? 360 : 0))
                .frame(width: 20, height: 20)
                .scaledToFit()
                .padding()
                .background(Circle().fill(showEditModes ? Color.gray : Color.gray.opacity(0.5)))
        }
    }
}

#Preview {
    @Previewable @State var showEditModes: Bool = false
    
    ZStack {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color("background"))
                .frame(width: 35, height: 70)
            Rectangle().fill(Color("alive"))
                .frame(width: 35, height: 70)
        }
        
        EditModePrimaryButtonView(
            showEditModes: $showEditModes,
            editMode: .none
        )
    }
}
