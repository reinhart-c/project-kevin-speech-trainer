//
//  Category.swift
//  Kevin
//
//  Created by Alifa Reppawali on 12/06/25.
//

import SwiftUI

struct Category: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let tag: String
    let backgroundColor: Color
    let icon: String
}

extension Category {
    var gradient: LinearGradient {
        switch tag {
        case "Product":
            return LinearGradient(colors: [.blueIcon, .lightBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Social Advocacy":
            return LinearGradient(colors: [.purpleIcon, .lightPurple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "Political":
            return LinearGradient(colors: [.pinkIcon, .lightPink], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.gray, .gray], startPoint: .top, endPoint: .bottom)
        }
    }
}
