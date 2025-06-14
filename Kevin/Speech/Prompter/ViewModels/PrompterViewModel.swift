//
//  PrompterViewModel.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 12/06/25.
//

import Foundation
import Combine
import SwiftUI // For Timer and Color, though Timer is Foundation

class PrompterViewModel: ObservableObject {
    @Published var prompter: Prompter
    @Published var words: [String] = []
    @Published var currentWordIndex: Int = -1
    @Published var prompterHasFinished: Bool = false // New: To signal when prompter is done

    private var scriptTimer: Timer?
    private let highlightingSpeed: TimeInterval = 0.5 // Seconds per word

    // Allow script injection for flexibility, with a default
    init(script: String = """
        Hello and welcome to this presentation.
        Today, we will be discussing the future of technology.
        Our first point will cover artificial intelligence.
        Then, we'll move on to blockchain and its applications.
        Finally, we will explore the impact of quantum computing.
        Remember to speak clearly and maintain eye contact.
        Pause at appropriate moments to let your points sink in.
        This is a hardcoded script for now.
        We can make this dynamic later.
        Good luck with your speech!
        """) {
        self.prompter = Prompter(script: script)
        self.words = tokenizeScript(script)
        // Highlighting will be started externally now
    }

    private func tokenizeScript(_ script: String) -> [String] {
        return script.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
    }

    func startHighlighting() {
        if words.isEmpty {
            prompterHasFinished = true // If no words, it's immediately finished
            return
        }
        stopHighlighting() // Ensure any existing timer is stopped
        currentWordIndex = -1
        prompterHasFinished = false // Reset finished flag

        scriptTimer = Timer.scheduledTimer(withTimeInterval: highlightingSpeed, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.currentWordIndex < self.words.count - 1 {
                self.currentWordIndex += 1
            } else {
                self.prompterHasFinished = true // Signal prompter finished
                self.stopHighlighting() // Stop when end of script is reached
            }
        }
    }

    func stopHighlighting() {
        scriptTimer?.invalidate()
        scriptTimer = nil
    }

    func resetHighlighting() {
        stopHighlighting()
        currentWordIndex = -1
        prompterHasFinished = false
    }

    func updateScript(_ newScript: String) {
        prompter.script = newScript
        words = tokenizeScript(newScript)
        resetHighlighting() // Reset state if script changes
    }

    deinit {
        stopHighlighting()
    }
}
