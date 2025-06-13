//
//  VoiceToneCard.swift
//  Kevin
//
//  Created by Alifa Reppawali on 13/06/25.
//

import SwiftUI

struct VoiceToneCard: View {
    var body: some View {
        VStack {
            
            Text("How was your tone of voice?")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            //Spacer()
            
            HStack {
                Text("Dominant Vibe")
                    .foregroundStyle(.gray)
                    .font(.system(size: 17))
                
                Spacer()
                
                Text("Fear") //temp -> emotion
                    .font(.system(size: 20, weight: .medium))
            }
            .padding()
            .frame(width: 370)
            .background(Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(.lightGrey), lineWidth: 1)
            )
            
            //Spacer()
            
            RadarView(dataPoints: [
                RadarModel(label: "Happy", value: 0.2),
                RadarModel(label: "Fear", value: 0.8),
                RadarModel(label: "Sadness", value: 0.6),
                RadarModel(label: "Angry", value: 0.3),
                RadarModel(label: "Disgust", value: 0.1),
                RadarModel(label: "Neutral", value: 0.1)
            ])
            .padding([.top, .bottom], 20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .frame(width: 400, height: 500)
    }
}

#Preview {
    VoiceToneCard()
}
