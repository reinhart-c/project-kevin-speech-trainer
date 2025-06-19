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
                        .padding()
                    }
                }
            }
            .padding()
            .frame(maxWidth: 350)
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

            let vm = ResultViewModel()
            vm.result = mockResult
            vm.isCalculating = false
            _viewModel = StateObject(wrappedValue: vm)
        }

        var body: some View {
            SegmentedResult(viewModel: viewModel, onReset: {})
        }
    }

    return PreviewWrapper()
}

