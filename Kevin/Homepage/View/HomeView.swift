//
//  HomeView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 10/06/25.
//

import SwiftUI

struct HomeView: View {
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
                
                Streak()
                    .frame(maxWidth:500)
            }
            //.padding()
            HStack {
                Rectangle().fill(Color.blue)
                VStack {
                    Rectangle().fill(Color.blue)
                    Rectangle().fill(Color.blue)
                }
            }
            HStack {
                Text("Your Progress")
                Rectangle().fill(Color.blue)
            }
            ProgressItem(title: "This is my first practice to present product", date: "12 March 2024, 20:00", categoryName: "Political", categoryColor: .blue, categoryIcon: "test", score: 30, tag: "test")
        }
    }
}

#Preview {
    HomeView()
}

