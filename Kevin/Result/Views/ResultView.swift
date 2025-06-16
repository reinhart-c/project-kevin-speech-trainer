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
            HStack {
                Text("Speech Analysis")
                    .font(.headline)
                
                Spacer()
                
                Button("Try Again") {
                    onReset()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
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
                        VStack(spacing: 10) {
                            Text("\(result.score)")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundColor(viewModel.scoreColor) // Removed Color() wrapper
                            
                            Text(viewModel.scoreGrade)
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(viewModel.scoreColor) // Removed Color() wrapper
                            
                            Text("out of 100")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(viewModel.scoreColor.opacity(0.1)) // Use .opacity directly on the Color
                        .cornerRadius(15)
                        
                        // Statistics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Analysis")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            StatRow(
                                title: "Words Matched",
                                value: "\(result.matchedWords.count)",
                                color: .green
                            )
                            
                            if !result.extraWords.isEmpty {
                                StatRow(
                                    title: "Extra Words",
                                    value: "\(result.extraWords.count)",
                                    color: .orange
                                )
                            }
                            
                            if !result.missedWords.isEmpty {
                                StatRow(
                                    title: "Missed Words",
                                    value: "\(result.missedWords.count)",
                                    color: .red
                                )
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                        
                        // Detailed Breakdown (Optional)
                        if !result.extraWords.isEmpty || !result.missedWords.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Details")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                if !result.extraWords.isEmpty {
                                    DetailSection(
                                        title: "Extra Words:",
                                        words: result.extraWords,
                                        color: .orange
                                    )
                                }
                                
                                if !result.missedWords.isEmpty {
                                    DetailSection(
                                        title: "Missed Words:",
                                        words: result.missedWords,
                                        color: .red
                                    )
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(10)
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
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct DetailSection: View {
    let title: String
    let words: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
            
            Text(words.joined(separator: ", "))
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(color.opacity(0.1))
                .cornerRadius(6)
        }
    }
}

#Preview {
    ResultView(viewModel: {
        let vm = ResultViewModel()
        vm.result = Result(
            transcribedText: "Hello world this is a test with some extra words",
            expectedText: "Hello world this is a test"
        )
        return vm
    }()) {
        print("Reset tapped")
    }
}

