//
//  ConfirmationModalView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 16/06/25.
//


import SwiftUI

struct ConfirmationModalView: View {
    enum ActionType {
        case endSession, retry
    }

    var actionType: ActionType
    var onConfirm: () -> Void
    var onCancel: () -> Void

    @Binding var dontAskAgain: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.yellow)

            Text(actionType == .endSession ? "Are you sure?" : "Do you want to restart?")
                .font(.title2.bold())
                .foregroundColor(.black)

            Text("The progress you’ve made will not be saved")
                .foregroundColor(.gray)

            HStack {
                Button(action: onCancel) {
                    Text(actionType == .endSession ? "Cancel" : "No")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(Color.gray)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.gray.opacity(0.3)))
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: onConfirm) {
                    Text(actionType == .endSession ? "End Session" : "Yes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(actionType == .endSession ? Color.redButton : Color.blueButton)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 250, height: 50)

            Toggle(isOn: $dontAskAgain) {
                Text("Don’t ask again")
                    .foregroundColor(.gray)
            }
            .toggleStyle(CheckboxToggleStyle())
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .padding()
    }
}

extension ConfirmationModalView.ActionType: Identifiable {
    var id: String {
        switch self {
        case .endSession: return "endSession"
        case .retry: return "retry"
        }
    }
}

#Preview {
    ConfirmationModalView(
        actionType: .endSession,
        onConfirm: {},
        onCancel: {},
        dontAskAgain: .constant(false)
    )
}

