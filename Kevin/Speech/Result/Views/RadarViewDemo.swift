//
//  RadarViewDemo.swift
//  Kevin
//
//  Created by Alifa Reppawali on 13/06/25.
//

import SwiftUI

struct RadarChartDemo: View {
    var data: [RadarModel] = [
        .init(label: "Happy", value: 0.2),
        .init(label: "Fear", value: 0.8),
        .init(label: "Sadness", value: 0.6),
        .init(label: "Angry", value: 0.3),
        .init(label: "Disgust", value: 0.1)
    ]

    var body: some View {
        RadarView(dataPoints: data)
            .padding()
    }
}

#Preview{
    RadarChartDemo()
}
