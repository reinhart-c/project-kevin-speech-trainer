//
//  CategoryCardView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 12/06/25.
//


import SwiftUI

struct CategoryCardView: View {
   //@StateObject private var viewModel = CategoryViewModel()
    let category: Category

    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            //background icon
            Image(systemName: category.icon)
                .resizable()
                .foregroundStyle(category.gradient)
                .scaledToFit()
                .frame(width: 140, height: 140)
                .offset(x: -170, y: 47)
                .rotationEffect(.degrees(15))
            
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                Text(category.title)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(category.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()

            HStack(spacing: 4) {
                Text("Start Pitch")
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.8))
            .clipShape(Capsule())
            .padding()
        }
        //.frame(height: 150)
        .background(category.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    CategoryCardView(category: Category(
        title: "Product deserves the spotlight",
        subtitle: "Deliver product pitches that build trust and interest",
        tag: "Product",
        backgroundColor: Color.lightBlue,
        icon: "lightbulb.max"
    ))
    .padding()
    //.previewLayout(.sizeThatFits)
}
