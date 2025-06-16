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
    @Binding var path: NavigationPath

    var body: some View {
        ZStack(alignment: .topTrailing) {
            
            //background icon
            if category.tag == "Product" {
                Image(systemName: category.icon)
                    .resizable()
                    .foregroundStyle(category.gradient)
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                    .offset(x: -350, y: 130)
                    .rotationEffect(.degrees(15))
            }
            else if category.tag == "Political"{
                Image(systemName: category.icon)
                    .resizable()
                    .foregroundStyle(category.gradient)
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .offset(x: -460, y: 100)
                    .rotationEffect(.degrees(10))
            }
            else { //Social Advocacy
                Image(systemName: category.icon)
                    .resizable()
                    .foregroundStyle(category.gradient)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .offset(x: -440, y: 43)
                    .rotationEffect(.degrees(5))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                
                //title
                if category.tag == "Product" {
                    Text(category.title)
                        .font(.system(size: 33, weight: .medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.black)
                    
                    Text(category.subtitle)
                        .font(.system(size: 25))
                        .foregroundColor(.gray)
                    
                } else {
                    Text(category.title)
                        .font(.system(size: 25, weight: .medium))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.black)
                    
                    Text(category.subtitle)
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .padding(.bottom, 20)

            HStack(spacing: 4) {
                Text("Start Pitch")
                    .font(.system(size: 20))
            }
            .foregroundColor(.gray)
            .padding(.horizontal, 19)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.8))
            .clipShape(Capsule())
            .padding([.top, .trailing], 28)
            .onTapGesture {
                path.append("SpeechView")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(category.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        //.padding()
    }
}

#Preview {
//    CategoryCardView(category: Category(
//        title: "Lead with purpose, speak with power",
//        subtitle: "Deliver powerful messages that move people",
//        tag: "Political",
//        backgroundColor: Color.lightPink,
//        icon: "flame"
//    ))
//    .padding()
    //.previewLayout(.sizeThatFits)
}
