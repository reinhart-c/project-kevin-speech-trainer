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
                    .foregroundColor(.primary)
                    .font(.system(size: 11))
                
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .font(.system(size: 9))
                    
            }
            Spacer()
            
            // Category Badge (temp, use if else)
            HStack(spacing: 4) {
                Image(systemName: categoryDetails.icon)
                Text(categoryName)
            }
            .font(.caption)
            .foregroundColor(categoryDetails.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)

            // Score Badge
            Text("\(score)")
                .font(.caption)
                .foregroundColor(.white)
                .padding(8)
                .background(Color.black)
                .clipShape(Circle())

            // Tag Capsule
            HStack(spacing: 4) {
                Image(systemName: "wave.3.right")
                Text("“\(tag)”")
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(.lightGrey))
            .clipShape(Capsule())
        }
        .padding()
        .background(Color(.black).opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .frame(height:45)
    }
}

#Preview {
    ProgressItem(title: "This is my first practice to present product", date: "12 March 2024, 20:00", categoryName: "Political", categoryColor: .blue, categoryIcon: "test", score: 30, tag: "test")
}
