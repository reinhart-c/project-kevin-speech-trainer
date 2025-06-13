//
//  FluencyScore.swift
//  Kevin
//
//  Created by Alifa Reppawali on 13/06/25.
//

import SwiftUI

struct FluencyScore: View {
    var body: some View {
        ScrollView{
            VStack {
                FluencyScoreView(viewModel: .mock)
                
                VoiceToneCard()
            }
            .padding()
        }
    }
}

#Preview {
    FluencyScore()
}

