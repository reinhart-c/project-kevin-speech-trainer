//
//  OnboardingViewModel.swift
//  Kevin
//
//  Created by Vincent Wisnata on 18/06/25.
//

import SwiftUI

internal class OnboardingViewModel: ObservableObject {
    @Published var onboardingItems: [Onboarding] = [
        Onboarding(
            title: "Find A Quiet Place",
            subtitle: "Minimize background noise for better accuracy",
            image: "onboarding1"
        ),
        Onboarding(
            title: "Recommend To Use Earphone",
            subtitle: "External mic helps us hear and analyze your speech better",
            image: "onboarding2"
        ),
        Onboarding(
            title: "Keep Your Camera On",
            subtitle: "It helps you see your performance",
            image: "onboarding3"
        ),
        Onboarding(
            title: "Get Helpful Feedback",
            subtitle: "At the end, we'll show how you did based on your speech recording result",
            image: "onboarding4"
        )
    ]
    
    @Published var currentPage = 0
    @Published var practiceTitle = ""
    
    var isLastPage: Bool {
        currentPage == onboardingItems.count - 1
    }
    
    func nextPage() {
        if currentPage < onboardingItems.count - 1 {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
    func skipOnboarding() {
        // handled in view
        // currentPage = onboardingItems.count - 1
    }
}
