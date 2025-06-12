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
