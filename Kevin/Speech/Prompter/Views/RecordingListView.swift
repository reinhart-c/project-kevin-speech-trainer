//
//  RecordingListView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 18/06/25.
//

import SwiftUI
import AVFoundation

struct RecordingListView: View {
    @ObservedObject var speechViewModel: SpeechViewModel
    @Binding var showingVideoPlayer: Bool
    @Binding var showingResult: Bool
    @Binding var videoPlayer: AVPlayer?
    @Binding var isVideoPlaying: Bool
    @Binding var selectedVideoForTranscription: URL?
    @Binding var showingTranscriptionView: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Previous Recordings")
                    .font(.headline)

                Spacer()

                Button("Delete All") {
                    speechViewModel.deleteAllRecordings()
                    showingVideoPlayer = false
                    showingResult = false
                    videoPlayer = nil
                    isVideoPlaying = false
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .foregroundColor(.red)
            }
            .padding(.horizontal)

            ScrollView {
                LazyVStack {
                    ForEach(speechViewModel.recordedVideos, id: \.self) { url in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(speechViewModel.getRecordingTitle(for: url))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(formatDate(from: url))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            HStack(spacing: 10) {
                                Button("View") {
                                    speechViewModel.lastRecordedVideoURL = url
                                    showingVideoPlayer = true
                                    showingResult = false
                                    videoPlayer = AVPlayer(url: url)
                                    isVideoPlaying = false
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.small)

                                Button("Analyze") {
                                    selectedVideoForTranscription = url
                                    showingTranscriptionView = true
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .foregroundColor(.blue)
                                .disabled(speechViewModel.isTranscribing)

                                Button("Delete") {
                                    speechViewModel.deleteRecording(url: url)
                                    if speechViewModel.lastRecordedVideoURL == url {
                                        showingVideoPlayer = false
                                        showingResult = false
                                        videoPlayer = nil
                                        isVideoPlaying = false
                                    }
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
            }
            .frame(maxHeight: 200)
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
