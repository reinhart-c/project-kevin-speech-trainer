//
//  CategoryCardListView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 12/06/25.
//
import SwiftUI

struct CategoryCardListView: View {
    @StateObject var viewModel = CategoryViewModel()
    @State var selectedCategory: Category? = nil
    @State var isShowingSheet = false
    @State private var titleToPass = ""
    @State private var navigateToMain = false

    var body: some View {
        NavigationStack {
            HStack(alignment: .top, spacing: 16) {
                // First card
                CategoryCardView(category: viewModel.categories[0])
                    .frame(width: 700, height: 477)
                    .onTapGesture {
                        selectedCategory = viewModel.categories[0]
                        isShowingSheet = true
                    }
                
                // Stacked cards
                VStack(spacing: 16) {
                    CategoryCardView(category: viewModel.categories[1])
                        .frame(width: 650, height: 230)
                        .onTapGesture {
                            selectedCategory = viewModel.categories[1]
                            isShowingSheet = true
                        }
                    
                    CategoryCardView(category: viewModel.categories[2])
                        .frame(width: 650, height: 230)
                        .onTapGesture {
                            selectedCategory = viewModel.categories[2]
                            isShowingSheet = true
                        }
                }
            }
            .padding(50)
        }

        
        .sheet(isPresented: $isShowingSheet) {
            if let selected = selectedCategory {
                CategoryModalView(category: selected) {
                    // Navigation to MainView can happen here
                }
            }
        }
    }
}

#Preview {
    CategoryCardListView()
}
