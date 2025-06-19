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
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("How was your tone of voice?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        // .padding()
                    Spacer()
                    
                    // Existing Radar Chart -> change to donut chart
                    if let dataPoint = data.first {
                        EmotionRingView(dataPoint: dataPoint)
                    }
            
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Explanation")
                        .font(.system(size: 13, weight: .medium))
                    
                    let dominant = getDominantEmotion().emotion

                    Group {
                        if dominant == "Fearful" {
                            Text("😨 Fear: High pitch, cautious rhythm")
                        } else if dominant == "Sad" {
                            Text("😢 Sadness: Low energy, downward intonation")
                        } else if dominant == "Angry" {
                            Text("😠 Angry: Strong, tense enunciation")
                        } else if dominant == "Neutral" {
                            Text("😐 Neutral: Balanced tone but limited")
                        } else if dominant == "Happy" {
                            Text("😊 Happy: Slight smiles, more energy")
                        } else if dominant == "Disgust" {
                            Text("🤢 Disgust: Flat tone, strained delivery")
                        } else {
                            Text("🤔 No explanation available.")
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(10)
            }
            .frame(width: 300)
            // .padding()
//            .background(Color.lightBlue)
//            .cornerRadius(10)
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
            for idx in 0..<dimensions.count + 1 {
                let thisDimension = dimensions[idx == dimensions.count ? 0 : idx]
                let maxVal = thisDimension.maxVal
                let dataPointVal = getDataPointValue(for: thisDimension.emotionCase, in: data[dataIndex])
                let angle = radAngle_fromFraction(numerator: idx == dimensions.count ? 0 : idx, denominator: dimensions.count)
                let size = ((width - (50 + labelWidth))/2) * (CGFloat(dataPointVal)/CGFloat(maxVal))
                let xCoor = size * cos(angle)
                let yCoor = size * sin(angle)
                if idx == 0 {
                    path.move(to: CGPoint(x: center.x + xCoor, y: center.y + yCoor))
                } else {
                    path.addLine(to: CGPoint(x: center.x + xCoor, y: center.y + yCoor))
                }
            }
        }
    }

    private func getDataPointValue(for emotionCase: EmotionCase, in dataPoint: EmotionDataPoint) -> Double {
        for entry in dataPoint.entries where emotionCase == entry.emotionCase {
                return entry.value
        }
        return 0
    }

    private func emotionColor(for emotion: String) -> Color {
        switch emotion.lowercased() {
        case "happy": return .blueTitle
        case "sad": return .sadness
        case "angry": return .angry
        case "fearful": return .pinkText
        case "disgust": return .disgust
        case "neutral": return .purpleText
        default: return .secondary
        }
    }
}

struct EmotionDonutChart: View {
    var entries: [EmotionEntry]

    private var total: Double {
        entries.map { $0.value }.reduce(0, +)
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let lineWidth = size * 0.2
//            let radius = size / 2

            ZStack {
                ForEach(entries.indices, id: \.self) { index in
                    let startAngle = angle(at: index)
                    let endAngle = angle(at: index + 1)
                    let emotion = entries[index]

                    CircleArc(startAngle: startAngle,
                              endAngle: endAngle)
                        .stroke(emotionColor(for: emotion.emotionCase),
                                style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt))
                }
            }
            .frame(width: size, height: size)
        }
    }

    private func angle(at index: Int) -> Angle {
        let fraction = entries.prefix(index).map { $0.value }.reduce(0, +) / total
        return .degrees(fraction * 360 - 90) // Start at top
    }

    private func emotionColor(for emotion: EmotionCase) -> Color {
        switch emotion {
        case .happy: return Color.blueTitle
        case .sad: return Color.sadness
        case .angry: return Color.angry
        case .fearful: return Color.pinkText
        case .disgust: return Color.disgust
        case .neutral: return Color.purpleText
        }
    }
}

struct EmotionLegend: View {
    var entries: [EmotionEntry]

    private func emotionColor(for emotion: EmotionCase) -> Color {
        switch emotion {
        case .happy: return Color.blueTitle
        case .sad: return Color.sadness
        case .angry: return Color.angry
        case .fearful: return Color.pinkText
        case .disgust: return Color.disgust
        case .neutral: return Color.purpleText
        }
    }

    var body: some View {
        let visibleEntries = entries.filter { $0.value > 0 }
        let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

        HStack {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(visibleEntries, id: \.emotionCase) { entry in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(emotionColor(for: entry.emotionCase))
                            .frame(width: 10, height: 10)
                        Text("\(entry.emotionCase.rawValue.replacingOccurrences(of: "ful", with: "")) (\(Int(entry.value))%)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}

struct CircleArc: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        return path
    }
}

struct EmotionRingView: View {
    var dataPoint: EmotionDataPoint

    private var total: Double {
        dataPoint.entries.map { $0.value }.reduce(0, +)
    }

    private var dominantEmotion: (label: String, percent: Double) {
        let top = dataPoint.entries.max(by: { $0.value < $1.value }) ?? EmotionEntry(emotionCase: .neutral, value: 0)
        return (top.emotionCase.rawValue.replacingOccurrences(of: "ful", with: ""), top.value)
    }

    var body: some View {
        VStack(spacing: 16) {

            ZStack {
                // Donut chart
                EmotionDonutChart(entries: dataPoint.entries)

                // Center label
                VStack(spacing: 4) {
                    Text("Dominant Vibe")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text(dominantEmotion.label)
                        .font(.system(size: 35, weight: .bold))
                        .bold()
                }
            }
            .frame(width: 220, height: 220)
            .padding()

            // Legend
            EmotionLegend(entries: dataPoint.entries)
                .frame(maxWidth: 330)
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
