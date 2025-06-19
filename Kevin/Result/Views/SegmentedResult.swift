//
//  SegmentedResult.swift
//  Kevin
//
//  Created by Alifa Reppawali on 18/06/25.
//

import SwiftUI

enum ResultTab: String, CaseIterable, Identifiable {
    case fluency = "Fluency"
    case tone = "Tone of Voice"
    
    var id: String { self.rawValue }
}

struct SegmentedResult: View {
    @ObservedObject var viewModel: ResultViewModel
    let onReset: () -> Void
    
    @State private var selectedTab: ResultTab = .fluency
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Card Background
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: - Segmented Control
                Picker("", selection: $selectedTab) {
                    ForEach(ResultTab.allCases) { tab in
                        Text(tab.rawValue)
                            .tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(maxWidth: 300)
                .padding(.horizontal)
                
                // MARK: - Switch Views Based on Selected Tab
                Group {
                    switch selectedTab {
                    case .fluency:
                        ResultView(viewModel: viewModel, onReset: onReset)
                    case .tone:
                        if let result = viewModel.result,
                           let emotionBreakdown = result.emotionBreakdown {
                            EmotionRadarView(
                                width: 300,
                                mainColor: .blue,
                                subtleColor: .gray,
                                quantityIncrementalDividers: 3,
                                dimensions: emotionDimensions,
                                data: [
                                    EmotionDataPoint(
                                        emotionBreakdown: emotionBreakdown,
                                        color: .blue
                                    )
                                ]
                            )
                            .padding()
                        } else {
                            VStack(spacing: 16) {
                                Text("No emotion data available")
                                    .font(.title2)
                                    .foregroundColor(.secondary)
                                Text("Try recording again to get emotion analysis")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 200)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: 350, maxHeight: 600)
            .background(Color.blueSegmented)
            .cornerRadius(24)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @StateObject private var viewModel = ResultViewModel()

        init() {
            let mockResult = Result(
                transcribedText: "This is my speech",
                expectedText: "This is my expected text"
            )

            let rvm = ResultViewModel()
            rvm.result = mockResult
            rvm.isCalculating = false
            _viewModel = StateObject(wrappedValue: rvm)
        }

        var body: some View {
            SegmentedResult(viewModel: viewModel, onReset: {})
        }
    }

    return PreviewWrapper()
}
