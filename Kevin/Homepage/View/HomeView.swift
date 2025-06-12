//
//  HomeView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 10/06/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = CategoryViewModel()
    var body: some View {
        VStack {
            HStack {
                Text("**“Say It”**")
                    .foregroundStyle(
                        LinearGradient(colors: [.purpleTitle, .blueTitle], startPoint: .leading, endPoint: .trailing))
                    .font(.system(size: 22))
                    
                
                + Text(" Better,\nMove Them Further!")
                        .foregroundColor(.primary)
                        .bold()
                        .font(.system(size: 22))
                
                Spacer()
                
                Streak()
                    .frame(maxWidth:500)
            }
            //.padding()
            HStack(spacing: 16) {
                if let first = viewModel.categories.first {
                    CategoryCardView(category: first)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                           }

                VStack(spacing: 16) {
                    ForEach(viewModel.categories.dropFirst(), id: \.id) { category in
                        CategoryCardView(category: category)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
            //.frame(height:250)
            
            HStack {
                Text("Your Progress")
                    .padding(.horizontal)
                Spacer()
                SearchBarView()
            }
            ProgressItem(title: "This is my first practice to present product", date: "12 March 2024, 20:00", categoryName: "Political", categoryColor: .blue, categoryIcon: "test", score: 30, tag: "test")
            ProgressItem(title: "This is my first practice to present product", date: "12 March 2024, 20:00", categoryName: "Political", categoryColor: .blue, categoryIcon: "test", score: 30, tag: "test")
            ProgressItem(title: "This is my first practice to present product", date: "12 March 2024, 20:00", categoryName: "Political", categoryColor: .blue, categoryIcon: "test", score: 30, tag: "test")
            ProgressItem(title: "This is my first practice to present product", date: "12 March 2024, 20:00", categoryName: "Political", categoryColor: .blue, categoryIcon: "test", score: 30, tag: "test")
        }
        
    }
}

#Preview {
    HomeView()
}

