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
        VStack(spacing: 0) {
            Spacer()
            Image(item.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .font(.system(size: 60))
                .foregroundColor(.black.opacity(0.7))
                .frame( width: 150)
            
            VStack(spacing: 15) {
                Text(item.title)
                    .font(.title.bold())
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text(item.subtitle)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }.padding(.bottom, 30)
        }
    }
}
