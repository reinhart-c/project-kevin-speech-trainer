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
    @Published var prompterHasFinished: Bool = false 
    
    private var scriptTimer: Timer?
    private let highlightingSpeed: TimeInterval = 0.5
    
    init(script: String = """
        Every once in a while, a revolutionary product comes along that changes everything and
        Apple has been... well, first of all, one’s very fortunate if you get to work on just one of these
        in your career. Apple has been very fortunate. It’s been able to introduce a few of these into
        the world.
        1984 - we introduced the Macintosh. It didn’t just change Apple. It changed the whole
        computer industry.
        In 2001, we introduced the first iPod. And it didn’t just change the way we all listen to
        music, it changed the entire music industry.
        Well, today we’re introducing three revolutionary products of this class. The first one is a
        widescreen iPod with touch controls. The second is a revolutionary mobile phone.
        And the third is a breakthrough Internet communications device.
        """) {
        self.prompter = Prompter(script: script)
        self.words = tokenizeScript(script)
    }

    private func tokenizeScript(_ script: String) -> [String] {
        return script.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
    }

    func startHighlighting() {
        if words.isEmpty {
            prompterHasFinished = true
            return
        }
        currentWordIndex = -1
        prompterHasFinished = false
        scriptTimer = Timer.scheduledTimer(withTimeInterval: highlightingSpeed, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.currentWordIndex < self.words.count - 1 {
                self.currentWordIndex += 1
            } else {
                self.prompterHasFinished = true
                self.stopHighlighting() 
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
