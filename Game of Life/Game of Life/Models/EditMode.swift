//
//  EditMode.swift
//  Game of Life
//
//  Created by Ethan Truelove on 3/1/25.
//

// attribution: https://developer.apple.com/documentation/swift/caseiterable
// attribution: https://medium.com/@raphaelcarletti/tips-and-tricks-swift-enum-functions-and-computed-property-c0bd4c7d7618
enum EditMode: String, CaseIterable {
    case none = "None"
    case fill = "Fill"
    case erase = "Erase"
    case toggle = "Toggle"
    
    var iconName: String {
        switch self {
        case .fill:
            return "paintbrush.pointed.fill"
        case .erase:
            return "eraser.line.dashed.fill"
        case .toggle:
            return "repeat"
        case .none:
            return "cursorarrow"
        }
    }
}
