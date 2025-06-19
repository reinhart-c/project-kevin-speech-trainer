//
//  SpeechViewModelStore.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 18/06/25.
//

import Foundation
import Combine

internal class SpeechViewModelStore: ObservableObject {
    static let shared = SpeechViewModelStore()
    
    @Published var speechViewModel = SpeechViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        speechViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
}
