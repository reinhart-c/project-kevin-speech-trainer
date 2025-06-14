//
//  ProgressItem.swift
//  KevinUI
//
//  Created by Alifa Reppawali on 11/06/25.
//

import SwiftUI

struct ProgressItem: View {
    let title: String
    let date: String
    let categoryName: String
    let categoryColor: Color
    let categoryIcon: String
    let score: Int
    let tag: String
    
    var categoryDetails: (color: Color, icon: String) {
        switch categoryName {
        case "Product":
            return (.blue, "lightbulb")
        case "Social Advocacy":
            return (.purple, "person.3")
        case "Political":
            return (.pink, "flame")
        default:
            return (.gray, "questionmark.circle")
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Title & Date
            HStack(spacing: 4) {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .font(.system(size: 18))
                
                Spacer()
                
                Text(date)
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                    
            }
            Spacer()
                .frame(width: 100)
            
            // Category Badge (temp, use if else)
            HStack(spacing: 4) {
                Image(systemName: categoryDetails.icon)
                Text(categoryName)
            }
            .foregroundColor(categoryDetails.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .font(.system(size: 16))
            
            Spacer()
                .frame(width: 150)

            // Score Badge
            Text("\(score)")
                .font(.system(size: 17))
                .foregroundColor(.white)
                .padding(11)
                .background(Color.black)
                .clipShape(Circle())
            
            Spacer()
                .frame(width: 100)
            
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.darkGray)
                .font(.system(size: 30))
        }
        .padding()
        .background(Color.lightGrey)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .frame(height:75)
        .padding(.horizontal)
        .padding([.leading, .trailing], 40)
    }
}

#Preview {
    ProgressItem(title: "This is my first practice to present product", date: "12 March 2024, 20:00", categoryName: "Political", categoryColor: .blue, categoryIcon: "test", score: 30, tag: "test")
    ProgressItem(title: "This is my first practice to present product", date: "12 March 2024, 20:00", categoryName: "Political", categoryColor: .blue, categoryIcon: "test", score: 30, tag: "test")
}
