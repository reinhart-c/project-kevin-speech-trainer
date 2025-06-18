//
//  OnboardingPageView.swift
//  Kevin
//
//  Created by Vincent Wisnata on 18/06/25.
//

import SwiftUI

struct OnboardingPageView: View {
    let item: Onboarding
    
    var body: some View {
        VStack(spacing: 30) {
            // Image placeholder - replace with your actual images
            Image(systemName: getSystemIcon(for: item.image))
                .font(.system(size: 120))
                .foregroundColor(.black.opacity(0.7))
                .frame(height: 200)
            
            VStack(spacing: 15) {
                Text(item.title)
                    .font(.title.bold())
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text(item.subtitle)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding()
    }
    
    // Helper function to map your image names to system icons
    private func getSystemIcon(for imageName: String) -> String {
        switch imageName {
        case "onboarding1":
            return "location.circle"
        case "onboarding2":
            return "headphones.circle"
        case "onboarding3":
            return "video.circle"
        case "onboarding4":
            return "chart.bar.doc.horizontal"
        default:
            return "circle"
        }
    }
}
