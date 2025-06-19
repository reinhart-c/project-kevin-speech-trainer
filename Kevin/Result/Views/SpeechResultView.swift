//
//  SpeechResultView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 17/06/25.
//

import SwiftUI

struct SpeechResultView: View {
    @Binding var path: NavigationPath
    @StateObject private var viewModel = ResultViewModel()
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("This is my first time to present product") // title
                            .foregroundStyle(Color.primary)
                            .font(.system(size: 30, weight: .semibold))
                            .padding(.top, 40)
                        
                        HStack {
                            Text("12 March 2024") // date
                                .foregroundStyle(Color.gray)
                                .font(.system(size: 20))
                            
                            Circle()
                                .foregroundStyle(Color.lightGrey)
                                .frame(width: 5, height: 5)
                            
                            // image icon category
                            
                            Text("Product") // tag category
                                .font(.system(size: 20))
                        }
                    }
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Text("Back to home")
                            .foregroundStyle(Color.black)
                            .font(.system(size: 20))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(30)
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 50)
                }
                HStack {
                    Rectangle()
                    SegmentedResult(
                        viewModel: viewModel,
                        onReset: {
                            viewModel.reset() // implement this function in your view model
                        }
                    )
                    
                }
                .padding([.leading, .trailing], 40)
                .background(Color.lightBlue)
                .cornerRadius(20)
                .frame(width: 400, height: 500)
                
            }
            HStack {
                Rectangle()
               // ResultView() // score and emotion
            }
            .padding([.leading, .trailing], 40)
            .background(Color.lightBlue)
            .cornerRadius(20)
            .frame(width: 400, height: 500)
                        
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var path = NavigationPath()

        var body: some View {
            SpeechResultView(path: $path)
        }
    }

    return PreviewWrapper()
}

