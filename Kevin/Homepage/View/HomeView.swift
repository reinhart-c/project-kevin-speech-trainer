//
//  HomeView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 10/06/25.
//

import SwiftUI

// Add navigation destination for recordings
struct RecordingDestination: Hashable {
    let recordingURL: URL
    let practiceTitle: String
}

struct HomeView: View {
    @ObservedObject private var speechViewModelStore = SpeechViewModelStore.shared
    @State private var path = NavigationPath()
    
    private var speechViewModel: SpeechViewModel {
        speechViewModelStore.speechViewModel
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            NavigationStack(path: $path) {
                ScrollView {
                    VStack {
                        HStack {
                            (
                                Text("\"Say It\"")
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
                        LazyVStack {
                            ForEach(speechViewModel.recordedVideos, id: \.self) { url in
                                let recordingTitle = speechViewModel.getRecordingTitle(for: url)
                                let score = speechViewModel.getRecordingScore(for: url) ?? 0
                                Button(action: {
                                    let destination = RecordingDestination(
                                        recordingURL: url,
                                        practiceTitle: recordingTitle
                                    )
                                    path.append(destination)
                                }) {
                                    ProgressItem(
                                        title: recordingTitle,
                                        date: formatDate(from: url),
                                        categoryName: "Test",
                                        categoryColor: .blue,
                                        categoryIcon: "test",
                                        score: score,
                                        tag: "test"
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                }
                .onAppear {
                    speechViewModel.loadRecordings()
                }
                .refreshable {
                    speechViewModel.loadRecordings()
                }
                .onChange(of: speechViewModel.recordedVideos) { _, _ in
                }
                .navigationDestination(for: RecordingDestination.self) { destination in
                    SpeechView(
                        practiceTitle: destination.practiceTitle,
                        speechViewModel: speechViewModelStore.speechViewModel,
                        path: $path,
                        preselectedVideoURL: destination.recordingURL
                    )
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
