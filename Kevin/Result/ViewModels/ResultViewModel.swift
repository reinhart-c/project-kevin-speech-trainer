//
//  ResultViewModel.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 12/06/25.
//

import Foundation
import Combine
import SwiftUI

internal class ResultViewModel: ObservableObject {
    @Published var result: Result?
    @Published var isCalculating: Bool = false

    func calculateScore(transcribedText: String, expectedText: String, emotionResults: [VoiceEmotionClassifierOutput]? = nil) {
        isCalculating = true

        // Simulate some processing time for better UX
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let result = Result(
                transcribedText: transcribedText,
                expectedText: expectedText,
                emotionResults: emotionResults
            )

            DispatchQueue.main.async {
                self?.result = result
                self?.isCalculating = false
            }
        }
    }

    func reset() {
        result = nil
        isCalculating = false
    }

    var scoreColor: Color {
        guard let score = result?.score else { return .gray }

        switch score {
        case 90...100: return .green
        case 70...89: return .blue
        case 50...69: return .orange
        default: return .red
        }
    }

    var scoreGrade: String {
        guard let score = result?.score else { return "N/A" }

        switch score {
        case 90...100: return "Excellent"
        case 80...89: return "Good"
        case 70...79: return "Fair"
        case 60...69: return "Needs Improvement"
        default: return "Poor"
        }
    }
}
