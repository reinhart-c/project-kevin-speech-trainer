//
//  FluencyScoreView.swift
//  Kevin
//
//  Created by Alifa Reppawali on 13/06/25.
//


import SwiftUI

struct FluencyScoreView: View {
    @ObservedObject var viewModel: FluencyScoreViewModel

    var body: some View {
        VStack(spacing: 1) {
            // Custom Circular Gauge
            ZStack {
                Gauge(value: Double(viewModel.model.score), in: 0...100) {
                    EmptyView()
                } currentValueLabel: {
                    EmptyView() // Hiding the default label
                } minimumValueLabel: {
                    Text("0")
                        .foregroundStyle(
                            LinearGradient(colors: [.purpleTitle, .blueTitle], startPoint: .leading, endPoint: .trailing))
                        .font(.system(size: 10))
                } maximumValueLabel: {
                    Text("100")
                        .foregroundStyle(
                            LinearGradient(colors: [.purpleTitle, .blueTitle], startPoint: .leading, endPoint: .trailing))
                        .font(.system(size: 10))
                }
                .gaugeStyle(.accessoryCircular)
                .scaleEffect(3)
                .tint(
                    AngularGradient(
                        gradient: Gradient(colors: [.purpleTitle, .blueTitle]),
                        center: .center
                    )
                )
                .frame(width: 180, height: 180)

                VStack(spacing: 5) {
                    Text(viewModel.scoreText)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color.black)
                    Text("Fluency Score")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 17)
            }

            // Stat Boxes
            HStack(spacing: 16) {
                StatBox(label: "Filler", value: viewModel.fillerText)
                StatBox(label: "Pause", value: viewModel.pauseText)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Filler Words")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(viewModel.fillerTimesText)
                        .foregroundColor(.blueRadar)
                        .bold()
                }
                HStack {
                    Text("Average Pause Frequency")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(viewModel.averagePauseText)
                        .foregroundColor(.pinkResult)
                        .bold()
                }
            }
            .font(.system(size: 14))
            .padding()
            .padding([.leading, .trailing], 25)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .frame(width: 400, height: 400)
    }
}

struct StatBox: View {
    var label: String
    var value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Spacer()
            
            Text(value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
        }
        .padding()
        .frame(width: 140)
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(.lightGrey), lineWidth: 1)
        )
    }
}


#Preview {
    let testModel = FluencyScoreModel(score: 85, filler: 75, pause: 90, fillerTimes: 5, averagePause: 5)
    let viewModel = FluencyScoreViewModel(model: testModel)
    FluencyScoreView(viewModel: viewModel)
}
