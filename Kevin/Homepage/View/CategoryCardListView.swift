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
    @State private var presentedCategory: Category? = nil
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            CategoryCardView(category: viewModel.categories[0], path: $path)
                .frame(width: 445, height: 500)
                .onTapGesture {
                    presentedCategory = viewModel.categories[0]
                }
            CategoryCardView(category: viewModel.categories[1], path: $path)
                .frame(width: 445, height: 500)
                .onTapGesture {
                    presentedCategory = viewModel.categories[1]
                }
            CategoryCardView(category: viewModel.categories[2], path: $path)
                .frame(width: 445, height: 500)
                .onTapGesture {
                    presentedCategory = viewModel.categories[2]
                }
        }
        .padding()
        .sheet(item: $presentedCategory) { category in
            CategoryModalView(category: category) {
                path.append("SpeechView")
            }
        }
    }
}
#Preview {
//    CategoryCardListView()
}
