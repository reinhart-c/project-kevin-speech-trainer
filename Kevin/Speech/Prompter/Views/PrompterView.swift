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
    
    let onStartRecording: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                // Main content with corner radius
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        ScrollView {
                            // Check if we're recording by looking at currentWordIndex
                            if viewModel.currentWordIndex == -1 {
                                
                                Text("Get Ready to Speak!\n\n")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 20, weight: .semibold))
                                
                                Text("\n\n\nMake sure your body language is visible. Take a breath, and show your best self")
                                    .padding()
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 15))
                                    .multilineTextAlignment(.center)
                                
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
                                .padding(.top, 200)
                                .buttonStyle(PlainButtonStyle())
                                
                            } else {
                                viewModel.words.enumerated().reduce(Text("")) { (accumulatedText, pair) in
                                    let (index, word) = pair
                                    return accumulatedText +
                                    Text(word + " ")
                                        .font(.system(size: 19, weight: .medium))
                                        .foregroundColor(index == viewModel.currentWordIndex ? Color.accentColor : Color.primary) // Highlight current word
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                            .frame(height: 380)
                        // Apply corner radius to scroll content too
                            .clipShape(RoundedRectangle(cornerRadius: 10))
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
                    .frame(height: 380)
            }
        }
        .frame(width: 300)
        .frame(maxHeight: .infinity)
    }
}

struct PrompterView_Previews: PreviewProvider {
    static var previews: some View {
        PrompterView(viewModel: PrompterViewModel(script: "Preview script with a few words to see highlighting.")) {
        }
    }
}
