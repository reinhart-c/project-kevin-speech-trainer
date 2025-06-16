//
//  EmotionRadarView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 16/06/25.
//

import SwiftUI

enum EmotionCase: String, CaseIterable {
    case angry = "Angry"
    case disgust = "Disgust"
    case fearful = "Fearful"
    case happy = "Happy"
    case neutral = "Neutral"
    case sad = "Sad"
}

struct EmotionDataPoint: Identifiable {
    var id = UUID()
    var entries: [EmotionEntry]
    var color: Color

    init(angry: Double, disgust: Double, fearful: Double,
         happy: Double, neutral: Double, sad: Double, color: Color) {
        self.entries = [
            EmotionEntry(emotionCase: .angry, value: angry),
            EmotionEntry(emotionCase: .disgust, value: disgust),
            EmotionEntry(emotionCase: .fearful, value: fearful),
            EmotionEntry(emotionCase: .happy, value: happy),
            EmotionEntry(emotionCase: .neutral, value: neutral),
            EmotionEntry(emotionCase: .sad, value: sad)
        ]
        self.color = color
    }

    init(emotionBreakdown: [String: Double], color: Color) {
        self.entries = EmotionCase.allCases.map { emotionCase in
            let value = emotionBreakdown.first(where: { key, _ in
                let keyLower = key.lowercased()
                let caseLower = emotionCase.rawValue.lowercased()

                if keyLower == caseLower {
                    return true
                }

                if (keyLower == "fear" && caseLower == "fearful") ||
                   (keyLower == "fearful" && caseLower == "fear") {
                    return true
                }

                return false
            })?.value ?? 0.0

            return EmotionEntry(emotionCase: emotionCase, value: value)
        }
        self.color = color
    }
}

struct EmotionDimension: Identifiable {
    var id = UUID()
    var name: String
    var maxVal: Double
    var emotionCase: EmotionCase

    init(maxVal: Double, emotionCase: EmotionCase) {
        self.emotionCase = emotionCase
        self.name = emotionCase.rawValue
        self.maxVal = maxVal
    }
}

struct EmotionEntry {
    var emotionCase: EmotionCase
    var value: Double
}

struct EmotionRadarView: View {
    var mainColor: Color
    var subtleColor: Color
    var center: CGPoint
    var labelWidth: CGFloat = 60
    var width: CGFloat
    var quantityIncrementalDividers: Int
    var dimensions: [EmotionDimension]
    var data: [EmotionDataPoint]

    init(width: CGFloat, mainColor: Color = .blue, subtleColor: Color = .gray,
         quantityIncrementalDividers: Int = 3, dimensions: [EmotionDimension],
         data: [EmotionDataPoint]) {
        self.width = width
        self.center = CGPoint(x: width/2, y: width/2)
        self.mainColor = mainColor
        self.subtleColor = subtleColor
        self.quantityIncrementalDividers = quantityIncrementalDividers
        self.dimensions = dimensions
        self.data = data
    }

    var body: some View {
        VStack(spacing: 16) {
            // Dominant Emotion Display
            VStack(spacing: 8) {
                Text("How was your tone of voice?")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                // Dominant Emotion Card
                HStack {
                    Text("Dominant Vibe")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(getDominantEmotion().emotion)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(emotionColor(for: getDominantEmotion().emotion))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 20)

            // Existing Radar Chart
            ZStack {
                // Background gradient circles for reference
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { scale in
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    subtleColor.opacity(0.3),
                                    subtleColor.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .frame(
                            width: ((width - (50 + labelWidth)) * CGFloat(scale)),
                            height: ((width - (50 + labelWidth)) * CGFloat(scale))
                        )
                }

                // Main Spokes with gradient
                ForEach(0..<dimensions.count, id: \.self) { i in
                    Path { path in
                        let angle = radAngle_fromFraction(numerator: i, denominator: dimensions.count)
                        let x = (width - (50 + labelWidth))/2 * cos(angle)
                        let y = (width - (50 + labelWidth))/2 * sin(angle)
                        path.move(to: center)
                        path.addLine(to: CGPoint(x: center.x + x, y: center.y + y))
                    }
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                emotionColor(for: dimensions[i].emotionCase.rawValue).opacity(0.6),
                                emotionColor(for: dimensions[i].emotionCase.rawValue).opacity(0.1)
                            ]),
                            startPoint: .center,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round)
                    )
                }

                // Labels
                ForEach(0..<dimensions.count, id: \.self) { i in
                    Text(dimensions[i].emotionCase.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(emotionColor(for: dimensions[i].emotionCase.rawValue))
                        .frame(width: labelWidth, height: 12)
                        .rotationEffect(.degrees(
                            (degAngle_fromFraction(numerator: i, denominator: dimensions.count) > 90 &&
                             degAngle_fromFraction(numerator: i, denominator: dimensions.count) < 270) ? 180 : 0
                        ))
                        .background(Color.clear)
                        .offset(x: (width - 40)/2)
                        .rotationEffect(.radians(
                            Double(radAngle_fromFraction(numerator: i, denominator: dimensions.count))
                        ))
                }

                // Outer Border with gradient
                Path { path in
                    for i in 0..<dimensions.count + 1 {
                        let angle = radAngle_fromFraction(numerator: i, denominator: dimensions.count)
                        let x = (width - (50 + labelWidth))/2 * cos(angle)
                        let y = (width - (50 + labelWidth))/2 * sin(angle)
                        if i == 0 {
                            path.move(to: CGPoint(x: center.x + x, y: center.y + y))
                        } else {
                            path.addLine(to: CGPoint(x: center.x + x, y: center.y + y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            mainColor.opacity(0.4),
                            mainColor.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )

                // Enhanced Data Polygons with multiple gradient layers
                ForEach(0..<data.count, id: \.self) { j in
                    let path = createDataPath(for: j)

                    ZStack {
                        // Outer glow effect
                        path
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        data[j].color.opacity(0.4),
                                        data[j].color.opacity(0.1),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 50
                                )
                            )
                            .blur(radius: 3)

                        // Main fill with enhanced gradient
                        path
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: data[j].color.opacity(0.6), location: 0.0),
                                        .init(color: data[j].color.opacity(0.3), location: 0.5),
                                        .init(color: data[j].color.opacity(0.1), location: 1.0)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        // Stroke with gradient
                        path
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        data[j].color.opacity(0.9),
                                        data[j].color.opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                            )
                    }
                }

                // Enhanced Data Points with glow effect
                ForEach(0..<data.count, id: \.self) { j in
                    ForEach(0..<dimensions.count, id: \.self) { i in
                        let thisDimension = dimensions[i]
                        let dataPointVal = getDataPointValue(for: thisDimension.emotionCase, in: data[j])
                        let angle = radAngle_fromFraction(numerator: i, denominator: dimensions.count)
                        let size = ((width - (50 + labelWidth))/2) * (CGFloat(dataPointVal)/CGFloat(thisDimension.maxVal))
                        let x = size * cos(angle)
                        let y = size * sin(angle)

                        ZStack {
                            // Glow effect
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            emotionColor(for: thisDimension.emotionCase.rawValue).opacity(0.6),
                                            emotionColor(for: thisDimension.emotionCase.rawValue).opacity(0.2),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 2,
                                        endRadius: 8
                                    )
                                )
                                .frame(width: 12, height: 12)
                                .blur(radius: 1)

                            // Main point
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            emotionColor(for: thisDimension.emotionCase.rawValue),
                                            emotionColor(for: thisDimension.emotionCase.rawValue).opacity(0.7)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 6, height: 6)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
                                        .frame(width: 6, height: 6)
                                )
                        }
                        .position(x: center.x + x, y: center.y + y)
                    }
                }
            }
            .frame(width: width, height: width)
        }
    }

    // Add helper function to get dominant emotion
    private func getDominantEmotion() -> (emotion: String, percentage: Double) {
        guard let dataPoint = data.first else {
            return ("Neutral", 0.0)
        }

        let sortedEntries = dataPoint.entries.sorted { $0.value > $1.value }
        guard let dominantEntry = sortedEntries.first else {
            return ("Neutral", 0.0)
        }

        return (dominantEntry.emotionCase.rawValue, dominantEntry.value)
    }

    private func createDataPath(for dataIndex: Int) -> Path {
        Path { path in
            for i in 0..<dimensions.count + 1 {
                let thisDimension = dimensions[i == dimensions.count ? 0 : i]
                let maxVal = thisDimension.maxVal
                let dataPointVal = getDataPointValue(for: thisDimension.emotionCase, in: data[dataIndex])
                let angle = radAngle_fromFraction(numerator: i == dimensions.count ? 0 : i, denominator: dimensions.count)
                let size = ((width - (50 + labelWidth))/2) * (CGFloat(dataPointVal)/CGFloat(maxVal))
                let x = size * cos(angle)
                let y = size * sin(angle)

                if i == 0 {
                    path.move(to: CGPoint(x: center.x + x, y: center.y + y))
                } else {
                    path.addLine(to: CGPoint(x: center.x + x, y: center.y + y))
                }
            }
        }
    }

    private func getDataPointValue(for emotionCase: EmotionCase, in dataPoint: EmotionDataPoint) -> Double {
        for entry in dataPoint.entries {
            if emotionCase == entry.emotionCase {
                return entry.value
            }
        }
        return 0
    }

    private func emotionColor(for emotion: String) -> Color {
        switch emotion.lowercased() {
        case "happy": return .yellow
        case "sad": return .blue
        case "angry": return .red
        case "fearful": return .purple
        case "disgust": return .green
        case "neutral": return .gray
        default: return .secondary
        }
    }
}

// Helper functions
func deg2rad(_ number: CGFloat) -> CGFloat {
    return number * .pi / 180
}

func radAngle_fromFraction(numerator: Int, denominator: Int) -> CGFloat {
    return deg2rad(360 * (CGFloat(numerator)/CGFloat(denominator)))
}

func degAngle_fromFraction(numerator: Int, denominator: Int) -> CGFloat {
    return 360 * (CGFloat(numerator)/CGFloat(denominator))
}

// Updated dimensions for 6 emotions only
let emotionDimensions = [
    EmotionDimension(maxVal: 100, emotionCase: .angry),
    EmotionDimension(maxVal: 100, emotionCase: .disgust),
    EmotionDimension(maxVal: 100, emotionCase: .fearful),
    EmotionDimension(maxVal: 100, emotionCase: .happy),
    EmotionDimension(maxVal: 100, emotionCase: .neutral),
    EmotionDimension(maxVal: 100, emotionCase: .sad)
]

#Preview {
    EmotionRadarView(
        width: 300,
        mainColor: .blue,
        subtleColor: .gray,
        quantityIncrementalDividers: 3,
        dimensions: emotionDimensions,
        data: [
            EmotionDataPoint(
                angry: 20, disgust: 5, fearful: 60,
                happy: 15, neutral: 25, sad: 30,
                color: .blue
            )
        ]
    )
}
