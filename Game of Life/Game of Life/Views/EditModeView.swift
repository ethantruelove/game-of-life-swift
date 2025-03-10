//
//  SettingsView.swift
//  Game of Life
//
//  Created by Ethan Truelove on 2/26/25.
//

import SwiftUI

/// A view for the overall edit mode handling.
struct EditModeView: View {
    /// Indicates whether other edit modes besides the selected one should be shown.
    @Binding var showEditModes: Bool
    /// The currently selected edit mode.
    @Binding var editMode: EditMode
    /// The global `GameManager` to use.
    @Environment(GameManager.self) var gameManager
    
    var body: some View {
        ZStack {
            EditModePrimaryButtonView(
                showEditModes: $showEditModes,
                editMode: editMode
            )
            .onChange(of: editMode) {
                if editMode != .none {
                    gameManager.autoplay = false
                }
            }
            
            if showEditModes {
                VStack(spacing: 10) {
                    ForEach(EditMode.allCases, id: \.self) { mode in
                        if mode != editMode {
                            EditModeSubButtonView(icon: mode.iconName) {
                                editMode = mode
                            }
                        }
                    }
                }
                // hard code offset to match where above settings button occupies
                .offset(y: 108)
                .transition(.offset(y: -50).combined(with: .opacity))
            }
        }
        // need to put this here so it does not mess up when placed inside of HomeView and is inside of safe zones
        .frame(height: 80)
    }
}

#Preview {
    @Previewable @State var showEditModes: Bool = false
    @Previewable @State var editMode: EditMode = .none
    let gameManager = GameManager(width: 40, height: 80)
    
    EditModeView(
        showEditModes: $showEditModes,
        editMode: $editMode
    )
    .environment(gameManager)
}
