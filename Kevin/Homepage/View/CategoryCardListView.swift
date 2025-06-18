//
//  CategoryCardListView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 12/06/25.
//
import SwiftUI

struct SpeechDestination: Hashable {
    let practiceTitle: String
}

struct CategoryCardListView: View {
    @State private var showOnboarding = true
    @State private var onboardingCompleted = false
    
    @StateObject private var viewModel = CategoryViewModel()
    @Binding var path: NavigationPath
    @State private var presentedCategory: Category?
    @State private var selectedCategory: Category?
    @State private var practiceTitle: String = ""
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            CategoryCardView(category: viewModel.categories[0], path: $path)
                .frame(width: 445, height: 500)
                .onTapGesture {
                    handleCategoryTap(viewModel.categories[0])
                }
            CategoryCardView(category: viewModel.categories[1], path: $path)
                .frame(width: 445, height: 500)
                .onTapGesture {
                    handleCategoryTap(viewModel.categories[1])
                }
            CategoryCardView(category: viewModel.categories[2], path: $path)
                .frame(width: 445, height: 500)
                .onTapGesture {
                    handleCategoryTap(viewModel.categories[2])
                }
        }
        .padding()
        .sheet(isPresented: $showOnboarding) {
            OnboardingView {
                onboardingCompleted = true
                showOnboarding = false
            }
        }
        .sheet(item: $presentedCategory) { category in
            CategoryModalView(category: category) { title in
                practiceTitle = title
                path.append(SpeechDestination(practiceTitle: title))
            }
        }
        .navigationDestination(for: SpeechDestination.self) { destination in
            SpeechView(practiceTitle: destination.practiceTitle, speechViewModel: SpeechViewModelStore.shared.speechViewModel, path: $path)
        }
    }
    
    private func handleCategoryTap(_ category: Category) {
        selectedCategory = category
        
        if onboardingCompleted {
            presentedCategory = category
        } else {
            showOnboarding = true
        }
    }
}

#Preview {
//    CategoryCardListView()
}
