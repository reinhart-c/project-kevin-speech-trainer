//
//  Streak.swift
//  Kevin
//
//  Created by Alifa Reppawali on 12/06/25.
//


import SwiftUI

struct Streak: View {
    var body: some View {
        HStack {
            ZStack{
                Circle()
                    .fill(Color.white)
                    .frame(width:20, height:20)
                Text("🔥")
                    .font(.system(size: 10))
            }
            Text("Practice Streak Today!")
                .fontWeight(.semibold)
                .font(.system(size: 10))
            
            //Streak Bars
            HStack{
                ForEach(0..<3){index in
                    Capsule()
                        .fill(index == 0 ?
                              AnyShapeStyle(
                                LinearGradient(
                                    gradient: Gradient(colors:  [Color.yellowBar, Color.pinkBar]), startPoint: .leading, endPoint: .trailing
                                    )
                                ): AnyShapeStyle(Color.pinkBarEmpty)
                              )
                        .frame(width:30, height:5)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                gradient: Gradient(colors:  [Color.yellowBar.opacity(0.2), Color.pinkBar.opacity(0.1)]), startPoint: .leading, endPoint: .trailing
            )
        )
        .clipShape(Capsule())
        .padding()
    }
}

#Preview {
    Streak()
}
