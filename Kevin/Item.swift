//
//  Item.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 10/06/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
