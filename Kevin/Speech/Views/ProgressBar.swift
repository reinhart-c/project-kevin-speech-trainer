//
//  ProgressBar.swift
//  Kevin
//
//  Created by Alifa Reppawali on 13/06/25.
//

import SwiftUI

struct ProgressBar: View {
    var body: some View {
        let progress: Double = 0.5 // temp
        let remainingTime: String = "10:00" // temp

        HStack {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 35, height: 35)
                Text("🏆")
                    .font(.system(size: 22))
            }
            Text("Progress")
                .fontWeight(.semibold)
                .font(.system(size: 15))
            Spacer()
                .frame(width: 15)
            
            HStack{
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.pinkBarEmpty)
                        .frame(height: 6)

                    Capsule()
                        .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellowBar, Color.pinkBar]),
                        startPoint: .leading,
                        endPoint: .trailing
                            )
                        )
                        .frame(width: 100 * progress, height: 6)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                    }

                // temporary
                Text(remainingTime)
                    .fontWeight(.semibold)
                    .font(.system(size: 15))
            }
            .frame(maxWidth: 300)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.yellowBar.opacity(0.2), Color.pinkBar.opacity(0.1)]), startPoint: .leading, endPoint: .trailing
            )
        )
        .clipShape(Capsule())
        .padding()
    }
}

#Preview {
    ProgressBar()
}
