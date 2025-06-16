//
//  RadarModel.swift
//  Kevin
//
//  Created by Alifa Reppawali on 13/06/25.
//

import SwiftUI

struct RadarModel: Identifiable {
    let id = UUID()
    let label: String
    let value: Double  // value from 0.0 to 1.0
}
