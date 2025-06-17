//
//  CategoryCardView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 12/06/25.
//


import SwiftUI

struct CategoryCardView: View {
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
                    .offset(x: -90, y: 70)
                    .rotationEffect(.degrees(15))
            }
            else if category.tag == "Political"{
                Image(systemName: category.icon)
                    .resizable()
                    .foregroundStyle(category.gradient)
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .offset(x: -120, y: 100)
                    .rotationEffect(.degrees(10))
            }
            else { //Social Advocacy
                Image(systemName: category.icon)
                    .resizable()
                    .foregroundStyle(category.gradient)
                    .scaledToFit()
                    .frame(width: 370, height: 370)
                    .offset(x: -80, y: 100)
                    .rotationEffect(.degrees(5))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                
                //title & subtitle
                Text(category.title)
                    .font(.system(size: 24, weight: .medium))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                    .frame(minHeight: 50, alignment: .topLeading)
                    .padding(.bottom, -20)
                
                Text(category.subtitle)
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .frame(minHeight: 50, alignment: .topLeading)
                    .padding(.bottom, 30)
                
            }
            .padding()

            HStack(spacing: 4) {
                if category.tag == "Product" {
                    Text("Product")
                        .font(.system(size: 20))
                }
                else if category.tag == "Political" {
                    Text("Political")
                        .font(.system(size: 20))
                }
                else{
                    Text("Social Advocacy")
                        .font(.system(size: 20))
                }
            }
            .foregroundColor(.gray)
            .padding(.horizontal, 19)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.8))
            .clipShape(Capsule())
            .padding([.top, .trailing], 28)
//            .onTapGesture {
//                path.append("SpeechView")
//            }
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
