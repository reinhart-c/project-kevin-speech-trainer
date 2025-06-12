//
//  PrompterViewModel.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 12/06/25.
//

import Foundation
import Combine

class PrompterViewModel: ObservableObject {
    @Published var prompter: Prompter

    init() {
        self.prompter = Prompter(script: """
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
        """)
    }
}