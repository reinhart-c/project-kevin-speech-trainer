//
//  MainView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 13/06/25.
//

import SwiftUI

struct MainView: View {

    @StateObject var speechViewModel = SpeechViewModel()
    @State private var showConfirmationModal = false
    @State private var confirmationAction: ConfirmationModalView.ActionType?
    @State private var dontAskAgain = false

    var body: some View {
        VStack {
            HStack {
                Text("Product deserves the spotlight") // category.title
                    .font(.system(size: 30, weight: .semibold))
                    .padding(.leading, 40)

                Spacer()

                // retry
                Button {
                    // retry session
                    if dontAskAgain {
                        speechViewModel.stopRecording()
                        speechViewModel.stopSession()
                        speechViewModel.startRecording{}
                    } else {
                        confirmationAction = .retry
                        showConfirmationModal = true
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding()
                    
                    //end
                    Button{
                        //endSession
                        if dontAskAgain {
                            speechViewModel.stopRecording()
                            speechViewModel.stopSession()
                        } else {
                            confirmationAction = .endSession
                            showConfirmationModal = true
                        }
                        
                    } label:{
                        Text("End Session")
                            .foregroundStyle(.white)
                            .font(.system(size: 20))
                    }
                    .padding()
                    .background(Color.redButton)
                    .cornerRadius(30)
                    .buttonStyle(PlainButtonStyle())
                    
                    ProgressBar()
                        .padding(.trailing, 40)
                }
                .padding(.top, 20)
                
                HStack {
                    SpeechView()

                }
            }
            .padding()
            
            .sheet(item: $confirmationAction) { action in
                ConfirmationModalView(
                    actionType: action,
                    onConfirm: {
                        if action == .endSession {
                            speechViewModel.stopRecording()
                            speechViewModel.stopSession()
                        } else if action == .retry {
                            speechViewModel.stopRecording()
                            speechViewModel.stopSession()
                            speechViewModel.startRecording()
                        }
                        confirmationAction = nil
                    },
                    onCancel: {
                        confirmationAction = nil
                    },
                    dontAskAgain: $dontAskAgain
                )
            }
        }
        .padding()

        .sheet(item: $confirmationAction) { action in
            ConfirmationModalView(
                actionType: action,
                onConfirm: {
                    if action == .endSession {
                        speechViewModel.stopRecording()
                        speechViewModel.stopSession()
                    } else if action == .retry {
                        speechViewModel.stopRecording()
                        speechViewModel.stopSession()
                        speechViewModel.startRecording{}
                    }
                    confirmationAction = nil
                },
                onCancel: {
                    confirmationAction = nil
                },
                dontAskAgain: $dontAskAgain
            )
        }
    }
}

#Preview {
    MainView()
}
