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
                        let value = min(max(dataPoints[i].value, 0), 1)  // clamp to [0, 1]
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
                .fill(Color.blue.opacity(0.3))

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

                // Labels
                ForEach(0..<count, id: \.self) { i in
                    let angle = angleStep * Double(i) - .pi / 2
                    let label = dataPoints[i].label
                    let labelX = center.x + (maxRadius + 20) * cos(angle)
                    let labelY = center.y + (maxRadius + 20) * sin(angle)

                    Text(label)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .position(x: labelX, y: labelY)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(width: 250, height: 250)
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
