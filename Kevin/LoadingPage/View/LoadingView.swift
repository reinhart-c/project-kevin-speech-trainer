//
//  LoadingView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 14/06/25.
//

import Lottie
import SwiftUI

struct LoadingView: View {

    @State private var shimmerOffset: CGFloat = -1.0

    var body: some View {
        ZStack {
            LottieView(filename: "LoadingPaperPlaneAimation")
                .frame(width: 800, height: 800)

            VStack {

                let gradientText = Text("Processing Your Speech...")
                    .font(.system(size: 28))
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purpleTitle, .blueTitle],
                            startPoint: .leading,
                            endPoint: .trailing))

                // Shimmer overlay
                let shimmer = LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.5),
                        Color.white.opacity(0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                    .frame(width: 330, height: 50)
                    // .rotationEffect(.degrees(10))
                    .offset(x: shimmerOffset * 300)

                gradientText
                    .overlay(
                        shimmer
                            .mask(gradientText)
                    )
                    .onAppear {
                        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                            shimmerOffset = 1.5
                        }
                    }
                    .padding(.top, 300)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView()
}
