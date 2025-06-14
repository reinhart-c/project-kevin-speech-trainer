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
    
    init(transcribedText: String, expectedText: String) {
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
}

