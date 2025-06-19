//
//  HalfRingFluencyGauge.swift
//  Kevin
//
//  Created by Alifa Reppawali on 18/06/25.
//

import SwiftUI

struct HalfRingFluencyGauge: View {
    let score: Int
    
    private var percentage: Double {
        min(max(Double(score) / 100, 0), 1)
    }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let lineWidth: CGFloat = 18
            let dotSize: CGFloat = 16
            let radius = min(size.width, size.height) * 0.6
            let center = CGPoint(x: size.width / 2, y: size.height * 0.8)

//            let startAngle = Angle(degrees: 160)
            let endAngle = Angle(degrees: 160 + (220 * percentage))

            ZStack {
                // Background arc
                Path { path in
                    path.addArc(center: center,
                                radius: radius,
                                startAngle: .degrees(160),
                                endAngle: .degrees(20),
                                clockwise: false)
                }
                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

                // Progress arc
                Path { path in
                    path.addArc(center: center,
                                radius: radius,
                                startAngle: .degrees(160),
                                endAngle: endAngle,
                                clockwise: false)
                }
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purpleTitle, Color.blueTitle]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

                // Dot
                let angle = endAngle.radians
                let dotX = center.x + cos(angle) * radius
                let dotY = center.y + sin(angle) * radius

                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purpleTitle, Color.blueTitle]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: dotSize, height: dotSize)
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .position(x: dotX, y: dotY)

                let textOffsetY = radius * 0.3  // Adjust this multiplier to center it nicely

                VStack(spacing: 4) {
                    Text("\(score)")
                        .font(.system(size: 40, weight: .bold))
                        .padding(.top, textOffsetY)
                    
                    Text("Fluency Score")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("0")
                            .font(.system(size: 25))
                            .foregroundStyle(LinearGradient(
                                gradient: Gradient(colors: [Color.purpleTitle, Color.blueTitle]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        
                        Spacer()
                        
                        Text("100")
                            .font(.system(size: 25))
                            .foregroundStyle(LinearGradient(
                                gradient: Gradient(colors: [Color.purpleTitle, Color.blueTitle]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    }
                    .frame(maxWidth: 130)
                }
                .position(x: center.x, y: center.y - textOffsetY)
            }
        }
        .frame(width: 220, height: 150)
        .padding(.top, 20)
    }
}

#Preview {
    VStack(spacing: 10) {
        HalfRingFluencyGauge(score: 0)
        HalfRingFluencyGauge(score: 100)
        HalfRingFluencyGauge(score: 3)
    }
}
