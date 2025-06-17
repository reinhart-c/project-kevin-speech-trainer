//
//  HomeView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 10/06/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @StateObject private var speechViewModel = SpeechViewModel()
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack {
                    HStack {
                        (
                            Text("**“Say It”**")
                                .foregroundStyle(
                                    LinearGradient(colors: [.purpleTitle, .blueTitle], startPoint: .leading, endPoint: .trailing))

                            + Text(" Better,\nMove Them Further!")
                                .foregroundColor(.primary)

                        )
                        .bold()
                        .font(.system(size: 48))
                        .padding(.top, 20)
                        .padding([.bottom, .leading], 40)
                        Spacer()

                        Streak()
                            .padding(.top, 20)
                            .padding(.trailing, 40)
                            .padding(.bottom, 40)
                    }
                    .padding()

                    CategoryCardListView(path: $path)
                        .padding(.top, -30)

                    HStack {
                        Text("Your Progress")
                            .padding(.horizontal)
                            .padding(.leading, 40)
                            .bold()
                            .font(.system(size: 28))

                        Spacer()
                        SearchBarView()
                            .padding(.trailing, 40)
                    }
                    ScrollView {
                        LazyVStack {
                            ForEach(speechViewModel.recordedVideos, id: \.self) { url in
                                let index = speechViewModel.recordedVideos.firstIndex(of: url) ?? -1
                                let recordingTitle = "Recording \(speechViewModel.recordedVideos.count - index)"
                                ProgressItem(title: recordingTitle, date: formatDate(from: url), categoryName: "Test", categoryColor: .blue, categoryIcon: "test", score: 30, tag: "test")
                            }
                        }
                    }
                }
                .padding()
            }.onAppear {
                speechViewModel.loadRecordings()
            }
            .navigationDestination(for: String.self) { val in
                if val == "SpeechView" {
                    SpeechView()
                }
            }
        }
    }

    private func formatDate(from url: URL) -> String {
        let filename = url.lastPathComponent
        if let timeInterval = Double(filename.replacingOccurrences(of: "recording_", with: "").replacingOccurrences(of: ".mov", with: "")) {
            let date = Date(timeIntervalSince1970: timeInterval)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return url.lastPathComponent
    }
}

#Preview {
    HomeView()
}
