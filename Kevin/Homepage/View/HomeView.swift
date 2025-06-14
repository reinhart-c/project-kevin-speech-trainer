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
        ScrollView {
            VStack {
                HStack {
                    (
                        Text("**“Say It”**")
                            .foregroundStyle(
                                LinearGradient(colors: [.purpleTitle, .blueTitle], startPoint: .leading, endPoint: .trailing))
                        
                        + Text(" Better,\nMove Them Further!")
                            .foregroundColor(.primary)
                       
                    )
                    .bold()
                    .font(.system(size: 48))
                    .padding(.top, 20)
                    .padding(.leading, 40)
                    
                    Spacer()
                    
                    Streak()
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                }
                .padding()
                
                CategoryCardListView()
                    .padding(.top, -30)
                
                HStack {
                    Text("Your Progress")
                        .padding(.horizontal)
                        .padding(.leading, 40)
                        .bold()
                        .font(.system(size: 28))
                    
                    Spacer()
                    SearchBarView()
                        .padding(.trailing, 40)
                }
                ProgressItem(title: "This is my first practice to present product", date: "12 March 2024, 20:00", categoryName: "Political", categoryColor: .blue, categoryIcon: "test", score: 30, tag: "test")
                ProgressItem(title: "This is my first practice to present product", date: "12 March 2024, 20:00", categoryName: "Political", categoryColor: .blue, categoryIcon: "test", score: 30, tag: "test")
                ProgressItem(title: "This is my first practice to present product", date: "12 March 2024, 20:00", categoryName: "Political", categoryColor: .blue, categoryIcon: "test", score: 30, tag: "test")
                ProgressItem(title: "This is my first practice to present product", date: "12 March 2024, 20:00", categoryName: "Political", categoryColor: .blue, categoryIcon: "test", score: 30, tag: "test")
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
}

