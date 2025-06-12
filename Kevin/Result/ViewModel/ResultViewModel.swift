//
//  HomeView.swift
//  Kevin
//
//  Created by Vincent Wisnata on 10/06/25.
//

import SwiftUI

struct ResultViewModel: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: SpeechView()) {
                Text("Hello, this is a Result View!")
            }
        }
    }
}

#Preview {
    HomeView()
}
