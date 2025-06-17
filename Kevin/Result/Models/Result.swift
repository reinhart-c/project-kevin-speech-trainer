//
//  Result.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 12/06/25.
//

import Foundation

struct Result {
    let score: Int
    let transcribedText: String
    let expectedText: String
    let matchedWords: [String]
    let extraWords: [String]
    let missedWords: [String]

    // Add emotion properties
    let dominantEmotion: String?
    let dominantEmotionPercentage: Double?
    let emotionBreakdown: [String: Double]? // For detailed breakdown

    init(transcribedText: String, expectedText: String, emotionResults: [VoiceEmotionClassifierOutput]? = nil) {
        self.transcribedText = transcribedText
        self.expectedText = expectedText

        // Normalize and tokenize both texts
        let transcribedWords = Self.normalizeAndTokenize(transcribedText)
        let expectedWords = Self.normalizeAndTokenize(expectedText)

        // Calculate matches and differences
        let expectedSet = Set(expectedWords)
        let transcribedSet = Set(transcribedWords)

        self.matchedWords = Array(expectedSet.intersection(transcribedSet))
        self.extraWords = Array(transcribedSet.subtracting(expectedSet))
        self.missedWords = Array(expectedSet.subtracting(transcribedSet))

        // Calculate score
        self.score = Self.calculateScore(
            expectedWords: expectedWords,
            transcribedWords: transcribedWords,
            matchedWords: matchedWords,
            extraWords: extraWords
        )

        // Process emotion results
        if let emotionResults = emotionResults, !emotionResults.isEmpty {
            let (dominant, percentage, breakdown) = Self.processEmotionResults(emotionResults)
            self.dominantEmotion = dominant
            self.dominantEmotionPercentage = percentage
            self.emotionBreakdown = breakdown
        } else {
            self.dominantEmotion = nil
            self.dominantEmotionPercentage = nil
            self.emotionBreakdown = nil
        }
    }

    private static func normalizeAndTokenize(_ text: String) -> [String] {
        return text.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty }
    }

    private static func calculateScore(
        expectedWords: [String],
        transcribedWords: [String],
        matchedWords: [String],
        extraWords: [String]
    ) -> Int {
        guard !expectedWords.isEmpty else { return 0 }

        // Base score from matched words
        let matchPercentage = Double(matchedWords.count) / Double(expectedWords.count)
        var score = matchPercentage * 100

        // Penalty for extra words (filler words, mistakes)
        let extraWordPenalty = Double(extraWords.count) * 2.0 // 2% penalty per extra word
        score = max(0, score - extraWordPenalty)

        return min(100, max(0, Int(score.rounded())))
    }

    private static func processEmotionResults(_ results: [VoiceEmotionClassifierOutput]) -> (String?, Double?, [String: Double]?) {
        guard !results.isEmpty else { return (nil, nil, nil) }

        // Aggregate probabilities across all predictions
        var emotionTotals: [String: Double] = [:]
        var emotionCounts: [String: Int] = [:]

        for result in results {
            for (emotion, probability) in result.targetProbability {
                emotionTotals[emotion, default: 0.0] += probability
                emotionCounts[emotion, default: 0] += 1
            }
        }

        // Calculate averages
        var emotionAverages: [String: Double] = [:]
        for (emotion, total) in emotionTotals {
            let count = emotionCounts[emotion] ?? 1
            emotionAverages[emotion] = total / Double(count)
        }

        // Find dominant emotion
        let sortedEmotions = emotionAverages.sorted { $0.value > $1.value }
        guard let dominantEmotion = sortedEmotions.first else {
            return (nil, nil, nil)
        }

        return (
            dominantEmotion.key,
            dominantEmotion.value * 100, // Convert to percentage
            emotionAverages.mapValues { $0 * 100 } // Convert all to percentages
        )
    }
}
