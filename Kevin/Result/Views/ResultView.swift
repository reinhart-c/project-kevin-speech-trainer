//
//  ResultView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 12/06/25.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var viewModel: ResultViewModel
    let onReset: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            if viewModel.isCalculating {
                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.large)
                    Text("Analyzing your speech...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let result = viewModel.result {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Score Display
                        VStack {
                            HalfRingFluencyGauge(score: result.score)
                                .padding(.bottom, 28)
                                .padding(.top, -17)
                            
                            // Statistics
                            if !result.missedWords.isEmpty {
                                StatRow(
                                    title: "Missed Words",
                                    value: "\(result.missedWords.count) times",
                                    color: .pinkText
                                )

                            }
                            
                            if !result.extraWords.isEmpty {
                                StatRow(
                                    title: "Extra Words",
                                    value: "\(result.extraWords.count) times",
                                    color: .purpleText
                                )
                            }
                            
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(15)
                        
                        // Removed the Dominant Emotion StatRow since it's shown in the dedicated emotion analysis section
                        
                       // Detailed Breakdown (Optional)
                        if !result.extraWords.isEmpty || !result.missedWords.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                
                                if !result.extraWords.isEmpty {
                                    DetailSection(
                                        title: "Extra Words:",
                                        words: result.extraWords,
                                        color: .black
                                    )
                                }
                                
                                if !result.missedWords.isEmpty {
                                    DetailSection(
                                        title: "Missed Words:",
                                        words: result.missedWords,
                                        color: .black
                                    )
                                }
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No results yet")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(width: 300)
        .padding()
//        .background(Color.lightBlue)
//        .cornerRadius(10)
    }
    
    private func createRadarDataPoints(from emotionBreakdown: [String: Double]) -> [RadarModel] {
        // Updated to match the 6 emotions from the ML model
        let emotionOrder = ["happy", "sad", "angry", "fearful", "disgust", "neutral"]
        
        return emotionOrder.compactMap { emotion in
            // Find matching emotion (case insensitive)
            if let percentage = emotionBreakdown.first(where: { $0.key.lowercased() == emotion })?.value {
                return RadarModel(
                    label: emotion.capitalized,
                    value: percentage / 100.0 // Convert percentage to 0-1 range
                )
            }
            return nil
        }
    }
    
    private func emotionColor(for emotion: String) -> Color {
        switch emotion.lowercased() {
        case "happy", "joy": return .yellow
        case "sad", "sadness": return .blue
        case "angry", "anger": return .red
        case "fearful", "fear": return .purple  // Updated to match "fearful"
        case "disgust": return .green
        case "neutral": return .gray
        default: return .secondary
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .light))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
        
    }
}

struct DetailSection: View {
    let title: String
    let words: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(words.joined(separator: ", "))
                .font(.system(size: 13))
                .foregroundColor(.black)
                // .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                // .background(color.opacity(0.1))
                .cornerRadius(6)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

// Add new EmotionBar component
struct EmotionBar: View {
    let emotion: String
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(emotion.capitalized)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(String(format: "%.1f", percentage))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * (percentage / 100), height: 4)
                }
            }
            .frame(height: 4)
        }
    }
}

#Preview {
    ResultView(viewModel: {
        let rvm = ResultViewModel()
        rvm.result = Result(
            transcribedText: "Hello this is a test with some extra words",
            expectedText: "Hello world this is a test"
        )
        return rvm
    }()) {
        print("Reset tapped")
    }
}
