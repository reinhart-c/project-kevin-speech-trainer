//
//  RadarView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 13/06/25.
//

import SwiftUI

struct RadarView: View {
    let dataPoints: [RadarModel]
    let maxRadius: CGFloat = 100

    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let count = dataPoints.count
            let angleStep = 2 * .pi / Double(count)

            ZStack {
                // Background circles for reference
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { scale in
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                        .frame(width: maxRadius * 2 * CGFloat(scale), height: maxRadius * 2 * CGFloat(scale))
                }
                
                // Axes
                ForEach(0..<count, id: \.self) { i in
                    Path { path in
                        let angle = angleStep * Double(i) - .pi / 2
                        let endX = center.x + maxRadius * cos(angle)
                        let endY = center.y + maxRadius * sin(angle)
                        path.move(to: center)
                        path.addLine(to: CGPoint(x: endX, y: endY))
                    }
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }

                // Radar Polygon Fill
                Path { path in
                    for i in 0..<count {
                        let angle = angleStep * Double(i) - .pi / 2
                        let value = min(max(dataPoints[i].value, 0), 1)
                        let x = center.x + maxRadius * CGFloat(value) * cos(angle)
                        let y = center.y + maxRadius * CGFloat(value) * sin(angle)
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)]),
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )

                // Radar Polygon Stroke
                Path { path in
                    for i in 0..<count {
                        let angle = angleStep * Double(i) - .pi / 2
                        let value = min(max(dataPoints[i].value, 0), 1)
                        let x = center.x + maxRadius * CGFloat(value) * cos(angle)
                        let y = center.y + maxRadius * CGFloat(value) * sin(angle)
                        if i == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    path.closeSubpath()
                }
                .stroke(Color.blue, lineWidth: 2)
                
                // Data points
                ForEach(0..<count, id: \.self) { i in
                    let angle = angleStep * Double(i) - .pi / 2
                    let value = min(max(dataPoints[i].value, 0), 1)
                    let x = center.x + maxRadius * CGFloat(value) * cos(angle)
                    let y = center.y + maxRadius * CGFloat(value) * sin(angle)
                    
                    Circle()
                        .fill(emotionColor(for: dataPoints[i].label))
                        .frame(width: 6, height: 6)
                        .position(x: x, y: y)
                }

                // Labels
                ForEach(0..<count, id: \.self) { i in
                    let angle = angleStep * Double(i) - .pi / 2
                    let label = dataPoints[i].label
                    let labelX = center.x + (maxRadius + 20) * cos(angle)
                    let labelY = center.y + (maxRadius + 20) * sin(angle)

                    Text(label)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(emotionColor(for: label))
                        .position(x: labelX, y: labelY)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(width: 250, height: 250)
    }
    
    private func emotionColor(for emotion: String) -> Color {
        switch emotion.lowercased() {
        case "happy", "joy": return .yellow
        case "sad", "sadness": return .blue
        case "angry", "anger": return .red
        case "fearful", "fear": return .purple  
        case "disgust": return .green
        case "neutral": return .gray
        default: return .secondary
        }
    }
}

#Preview {
    RadarView(dataPoints: [
        RadarModel(label: "Happy", value: 0.2),
        RadarModel(label: "Fear", value: 0.8),
        RadarModel(label: "Sadness", value: 0.6),
        RadarModel(label: "Angry", value: 0.3),
        RadarModel(label: "Disgust", value: 0.1),
        RadarModel(label: "Neutral", value: 0.1)
    ])
}
