//
//  SpeechViewModelStore.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 18/06/25.
//

import Foundation

class SpeechViewModelStore: ObservableObject {
    static let shared = SpeechViewModelStore()
    
    @Published var speechViewModel = SpeechViewModel()
    
    private init() {}
}
