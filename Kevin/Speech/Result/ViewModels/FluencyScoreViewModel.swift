//
//  FluencyScoreViewModel.swift
//  Kevin
//
//  Created by Alifa Reppawali on 13/06/25.
//

import Foundation
import SwiftUI

class FluencyScoreViewModel: ObservableObject {
    @Published var model: FluencyScoreModel

    init(model: FluencyScoreModel) {
        self.model = model
    }

    var scoreText: String {
        "\(model.score)"
    }

    var fillerText: String {
        "\(model.filler)"
    }

    var pauseText: String {
        "\(model.pause)"
    }

    var fillerTimesText: String {
        "\(model.fillerTimes) Times"
    }

    var averagePauseText: String {
        "\(model.averagePause) seconds"
    }

    var scoreProgress: CGFloat {
        min(CGFloat(model.score) / 100.0, 1.0)
    }
    
}

extension FluencyScoreViewModel {
    static let mock: FluencyScoreViewModel = FluencyScoreViewModel(
        model: FluencyScoreModel(score: 85, filler: 75, pause: 90, fillerTimes: 5, averagePause: 5)
    )
}
