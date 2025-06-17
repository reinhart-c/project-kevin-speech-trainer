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
    @State private var showModal = false
    @State private var selectedCategory: Category? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            CategoryCardView(category: viewModel.categories[0], path: $path)
                .frame(width: 445, height: 500)
                .onTapGesture {
                    selectedCategory = viewModel.categories[0]
                    showModal = true // Show modal on tap
                }
            CategoryCardView(category: viewModel.categories[1], path: $path)
                .frame(width: 445, height: 500)
                .onTapGesture {
                    selectedCategory = viewModel.categories[1]
                    showModal = true
                }
            CategoryCardView(category: viewModel.categories[2], path: $path)
                .frame(width: 445, height: 500)
                .onTapGesture {
                    selectedCategory = viewModel.categories[2]
                    showModal = true
                }
        }
        .padding()
        .sheet(isPresented: $showModal) {
            if let category = selectedCategory {
                CategoryModalView(category: category) {
                    path.append("SpeechView")
                }
            }
        }
    }
}

#Preview {
//    CategoryCardListView()
}
