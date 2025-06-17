//
//  CategoryCardListView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 12/06/25.
//
import SwiftUI

struct CategoryCardListView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @Binding var path: NavigationPath

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            CategoryCardView(category: viewModel.categories[0], path: $path)
                .frame(width: 440, height: 500)
            CategoryCardView(category: viewModel.categories[1], path: $path)
                .frame(width: 440, height: 500)
            CategoryCardView(category: viewModel.categories[2], path: $path)
                .frame(width: 440, height: 500)
        }
        .padding()
    }
}

#Preview {
//    CategoryCardListView()
}
