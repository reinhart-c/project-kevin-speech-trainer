//
//  PrompterView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 12/06/25.
//

import SwiftUI

struct PrompterView: View {
    @ObservedObject var viewModel: PrompterViewModel
    
    @State private var showingResult = false
    @State private var showingVideoPlayer = false
    @State private var scrollOffset: CGFloat = 0
    
    let onStartRecording: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                // Main content with corner radius
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        ScrollViewReader { proxy in
                            ScrollView(.vertical) {
                                // Check if we're recording by looking at currentWordIndex
                                if viewModel.currentWordIndex == -1 {
                                    VStack(spacing: 20) {
                                        Spacer()
                                        
                                        Text("Get Ready to Speak!")
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 20, weight: .semibold))
                                            .multilineTextAlignment(.center)
                                        
                                        Text("Make sure your body language is visible. Take a breath, and show your best self")
                                            .foregroundStyle(.gray)
                                            .font(.system(size: 15))
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 20)
                                        
                                        Spacer()
                                        
                                        Button {
                                            showingResult = false
                                            viewModel.resetHighlighting()
                                            showingVideoPlayer = false
                                            onStartRecording()
                                        } label: {
                                            Text("Start Now")
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 30)
                                                .padding(.vertical, 12)
                                                .background(Color.black)
                                                .clipShape(Capsule())
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        Spacer()
                                    }
                                    .frame(height: 340) // Ensure content fits within scroll area
                                    
                                } else {
                                    LazyVStack(alignment: .leading, spacing: 8) {
                                        // Group words into lines for better text flow
                                        let wordsPerLine = 6 // Adjust this for better line breaks
                                        let lineGroups = stride(from: 0, to: viewModel.words.count, by: wordsPerLine).map { startIndex in
                                            let endIndex = min(startIndex + wordsPerLine, viewModel.words.count)
                                            return Array(startIndex..<endIndex)
                                        }
                                        
                                        ForEach(Array(lineGroups.enumerated()), id: \.offset) { lineIndex, wordIndices in
                                            // Create flowing text for this line
                                            wordIndices.reduce(Text("")) { accumulatedText, wordIndex in
                                                accumulatedText +
                                                Text(viewModel.words[wordIndex] + " ")
                                                    .font(.system(size: 19, weight: .medium))
                                                    .foregroundColor(wordIndex == viewModel.currentWordIndex ? Color.accentColor : Color.primary)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .id("line-\(lineIndex)") // ID for each line
                                        }
                                    }
                                    .padding()
                                }
                            }
                            .frame(height: 380)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .onChange(of: viewModel.currentWordIndex) { newIndex in
                                // Auto-scroll to the line containing the current word
                                if newIndex >= 0 && newIndex < viewModel.words.count {
                                    let wordsPerLine = 6
                                    let lineIndex = newIndex / wordsPerLine
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        proxy.scrollTo("line-\(lineIndex)", anchor: .center)
                                    }
                                }
                            }
                        }
                    )
                    .mask(
                        VStack(spacing: 0) {
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 30)
                            
                            Rectangle().fill(Color.black)
                            
                            LinearGradient(
                                gradient: Gradient(colors: [.black, .clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 30)
                        }
                    )
                    .frame(height: 580)
            }
        }
        .frame(width: 400, height: 580)
        .padding(.trailing, 40)
    }
}

struct PrompterView_Previews: PreviewProvider {
    static var previews: some View {
        PrompterView(viewModel: PrompterViewModel(script: "Preview script with a few words to see highlighting.")) {
        }
    }
}
