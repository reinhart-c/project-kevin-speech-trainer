//
//  OnboardingView.swift
//  Kevin
//
//  Created by Vincent Wisnata on 18/06/25.
import SwiftUI

struct OnboardingView: View {
    var onReady: () -> Void
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack(spacing: 0) {
                HStack{
                    Spacer()
                    Button(action: {
                        onReady()
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 18, height: 18)
                    }
                    .buttonStyle(.plain)
                }.padding(.top, 32)
                // Main content
                ZStack {
                    ForEach(Array(viewModel.onboardingItems.enumerated()), id: \.element.id) { index, item in
                        OnboardingPageView(item: item)
                            .opacity(index == viewModel.currentPage ? 1 : 0)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
                    }
                }
                
                // Navigation buttons with absolutely centered progress
                ZStack {
                    HStack {
                        // Left side - Skip button
                        Button {
                            onReady()
                            //viewModel.skipOnboarding()
                        } label: {
                            Text("Skip").foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        // Right side - Navigation buttons
                        HStack {
                            // Back Button
                            if viewModel.currentPage > 0 {
                                Button(action: {
                                    withAnimation {
                                        viewModel.previousPage()
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.gray)
                                        .padding()
                                        .background(
                                            Circle()
                                                .fill(Color.white.opacity(0.0001))
                                                .overlay(
                                                    Circle().stroke(Color.gray, lineWidth: 1)
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                                .frame(width: 52, height: 52)
                                .contentShape(Circle())
                            }
                            
                            Spacer()
                            
                            // Next Button
                            Button(action: {
                                if viewModel.isLastPage {
                                    onReady()
                                } else {
                                    withAnimation {
                                        viewModel.nextPage()
                                    }
                                }
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .padding()
                                    .background(Circle().fill(Color.black))
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(width: 112, height: 52)
                    }
                    
                    // Progress indicator
                    HStack(spacing: 8) {
                        ForEach(0..<viewModel.onboardingItems.count, id: \.self) { index in
                            Capsule()
                                .fill(index <= viewModel.currentPage ? Color.black : Color.gray.opacity(0.3))
                                .frame(width: 40, height: 8)
                        }
                    }
                }
               
            }.frame(width: 500)
            .padding(.bottom, 40)
                .padding(.horizontal, 40)
        }
    }
}

#Preview {
    OnboardingView {
        print("Onboarding completed!")
    }
}
