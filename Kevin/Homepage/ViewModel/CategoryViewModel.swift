//
//  CategoryViewModel.swift
//  Kevin
//
//  Created by Alifa Reppawali on 12/06/25.
//

import SwiftUI

internal class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = [
        Category(
            title: "Product deserves the spotlight",
            subtitle: "Deliver product pitches that build trust and interest",
            tag: "Product",
            backgroundColor: Color.lightBlue,
            icon: "lightbulb.max"
        ),
        Category(
            title: "Lead with purpose, speak with power",
            subtitle: "Deliver powerful messages that move people",
            tag: "Political",
            backgroundColor: Color.lightPink,
            icon: "flame"
        ),
        Category(
            title: "From cause to community",
            subtitle: "Deliver talks that drive social action",
            tag: "Social Advocacy",
            backgroundColor: Color.lightPurple,
            icon: "person.3"
        )
    ]
}
