//
//  FluencyScore.swift
//  Kevin
//
//  Created by Alifa Reppawali on 13/06/25.
//

import SwiftUI

struct FluencyScore: View {
    var body: some View {
        VStack {
            
            
            RadarView(dataPoints: [
                RadarModel(label: "Happy", value: 0.2),
                RadarModel(label: "Fear", value: 0.8),
                RadarModel(label: "Sadness", value: 0.6),
                RadarModel(label: "Angry", value: 0.3),
                RadarModel(label: "Disgust", value: 0.1),
                RadarModel(label: "Neutral", value: 0.1)
            ])
        }
        .padding()
    }
}

#Preview {
    FluencyScore()
}

