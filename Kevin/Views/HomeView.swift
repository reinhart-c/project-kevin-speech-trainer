//
//  HomeView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 10/06/25.
//

import SwiftUI
struct HomeView: View {
    var body: some View {
        NavigationView {
            NavigationLink(destination: SpeechView()) {
                Text("Hello, Kevin!")
            }
        }
    }
}

#Preview {
    HomeView()
}
