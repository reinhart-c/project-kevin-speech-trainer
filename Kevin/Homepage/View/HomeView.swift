//
//  HomeView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 10/06/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @StateObject private var speechViewModelStore = SpeechViewModelStore.shared
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
                                ProgressItem(title: recordingTitle, date: formatDate(from: url), categoryName: "Test", categoryColor: .blue, categoryIcon: "test", score: score, tag: "test")
                            }
                        }
                    }
                    .padding()
                }.onAppear {
                    speechViewModel.loadRecordings()
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
