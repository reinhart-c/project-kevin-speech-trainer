//
//  OnboardingView.swift
//  Kevin
//
//  Created by Vincent Wisnata on 18/06/25.

import SwiftUI

import SwiftUI

import SwiftUI

struct OnboardingView: View {
    var onReady: () -> Void
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Progress indicator
                HStack {
                    ForEach(0..<viewModel.onboardingItems.count, id: \.self) { index in
                        Circle()
                            .fill(index <= viewModel.currentPage ? Color.black : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 20)
                
                // Main content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(Array(viewModel.onboardingItems.enumerated()), id: \.element.id) { index, item in
                        OnboardingPageView(item: item)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentPage)
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if viewModel.currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                viewModel.previousPage()
                            }
                        }
                        .foregroundColor(.gray)
                        .frame(width: 80)
                    } else {
                        Spacer()
                            .frame(width: 80)
                    }
                    
                    Spacer()
                    
                    Button(viewModel.isLastPage ? "Get Started" : "Next") {
                        if viewModel.isLastPage {
                            onReady()
                        } else {
                            withAnimation {
                                viewModel.nextPage()
                            }
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.black)
                    .cornerRadius(25)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}
