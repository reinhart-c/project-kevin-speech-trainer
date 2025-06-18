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
    @State private var searchText = ""
    
    // Computed property to filter recordings based on search text
    private var filteredRecordings: [URL] {
        if searchText.isEmpty {
            return speechViewModel.recordedVideos
        } else {
            return speechViewModel.recordedVideos.filter { url in
                let recordingTitle = speechViewModel.getRecordingTitle(for: url)
                let formattedDate = formatDate(from: url)
                
                // Search in both title and date
                return recordingTitle.localizedCaseInsensitiveContains(searchText) ||
                       formattedDate.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack {
                    HStack {
                        (
                            Text("\"Say It\"")
                                .fontWeight(.bold)
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
                        SearchBarView(searchText: $searchText)
                            .padding(.trailing, 40)
                    }
                    
                    // Show search results info if searching
                    if !searchText.isEmpty {
                        HStack {
                            Text("Found \(filteredRecordings.count) recording\(filteredRecordings.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.leading, 40)
                            Spacer()
                        }
                        .padding(.top, 5)
                    }
                    
                    ScrollView {
                        LazyVStack {
                            if filteredRecordings.isEmpty && !searchText.isEmpty {
                                // Show "no results" message when searching but no matches found
                                VStack(spacing: 16) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray)
                                    
                                    Text("No recordings found")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text("Try searching with different keywords")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(40)
                                .frame(maxWidth: .infinity)
                            } else if filteredRecordings.isEmpty && searchText.isEmpty && speechViewModel.recordedVideos.isEmpty {
                                // Show "no recordings" message when no recordings exist
                                VStack(spacing: 16) {
                                    Image(systemName: "mic.slash")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray)
                                    
                                    Text("No recordings yet")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text("Start by creating your first speech recording")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(40)
                                .frame(maxWidth: .infinity)
                            } else {
                                ForEach(filteredRecordings, id: \.self) { url in
                                    let recordingTitle = speechViewModel.getRecordingTitle(for: url)
                                    let recordingScore = speechViewModel.getRecordingScore(for: url)
                                    ProgressItem(title: recordingTitle, date: formatDate(from: url), categoryName: "Test", categoryColor: .blue, categoryIcon: "test", score: recordingScore, tag: "test")
                                }
                            }
                        }
                    }
                }
                .padding()
            }.onAppear {
                speechViewModel.loadRecordings()
            }
            .navigationDestination(for: String.self) { recordingTitle in
                SpeechView(speechViewModel: speechViewModel)
                    .onAppear {
                        speechViewModel.setRecordingTitle(recordingTitle)
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
