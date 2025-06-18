//
//  SpeechView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 10/06/25.
//

import SwiftUI
import AVFoundation
import AVKit

struct SpeechView: View {
    @ObservedObject var speechViewModel: SpeechViewModel
    @StateObject private var prompterViewModel = PrompterViewModel()
    @StateObject private var resultViewModel = ResultViewModel()

    @State private var showingVideoPlayer = false
    @State private var showingTranscriptionView = false
    @State private var selectedVideoForTranscription: URL?
    @State private var showingResult = false
    @State private var videoPlayer: AVPlayer?
    @State private var isVideoPlaying = false

    init(speechViewModel: SpeechViewModel = SpeechViewModel()) {
        self.speechViewModel = speechViewModel
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Speech Training")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            HStack(spacing: 20) {
                ZStack {
                    if showingVideoPlayer, let videoURL = speechViewModel.lastRecordedVideoURL {
                        VideoPlayer(player: videoPlayer ?? AVPlayer(url: videoURL))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .aspectRatio(16/9, contentMode: .fit)
                            .cornerRadius(15)
                            .onAppear {
                                if videoPlayer == nil {
                                    videoPlayer = AVPlayer(url: videoURL)
                                }
                            }
                    } else {
                        CameraPreview(session: speechViewModel.session)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .aspectRatio(16/9, contentMode: .fit)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }

                    if !speechViewModel.hasCameraPermissions {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Camera access required")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Please grant camera and microphone access in Settings.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(15)
                    } else if speechViewModel.isCountingDown {
                        Text("\(speechViewModel.countdownSeconds)")
                            .font(.system(size: 100, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(15)
                    }
                }

                if showingResult {
                    ResultView(viewModel: resultViewModel) {
                        showingResult = false
                        showingVideoPlayer = false
                        resultViewModel.reset()
                        prompterViewModel.resetHighlighting()
                        speechViewModel.transcriptionText = ""
                        speechViewModel.transcriptionError = nil
                        speechViewModel.emotionResults = []
                        videoPlayer = nil
                        isVideoPlaying = false
                    }
                } else {
                    PrompterView(viewModel: prompterViewModel)
                }
            }
            .padding(.horizontal)
            
            Text(speechViewModel.isCountingDown ? "Get ready..." :
                 speechViewModel.isRecording ? "Recording in progress..." :
                 showingVideoPlayer && speechViewModel.lastRecordedVideoURL != nil ?
                 (isVideoPlaying ? "Playing recorded video" : "Video paused") : "Ready to record")
                .font(.headline)
                .foregroundColor(speechViewModel.isCountingDown ? .blue :
                                 speechViewModel.isRecording ? .red :
                               (showingVideoPlayer && speechViewModel.lastRecordedVideoURL != nil) ?
                               (isVideoPlaying ? .blue : .orange) : .primary)

            HStack(spacing: 30) {
                if showingVideoPlayer {
                    Button(action: {
                        if isVideoPlaying {
                            videoPlayer?.pause()
                            isVideoPlaying = false
                        } else {
                            videoPlayer?.play()
                            isVideoPlaying = true
                        }
                    }) {
                        VStack {
                            Circle()
                                .fill(isVideoPlaying ? Color.orange : Color.blue)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: isVideoPlaying ? "pause.fill" : "play.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 32))
                                )
                            Text(isVideoPlaying ? "Pause" : "Play")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }

                    Button(action: {
                        showingVideoPlayer = false
                        showingResult = false
                        resultViewModel.reset()
                        prompterViewModel.resetHighlighting()
                        speechViewModel.transcriptionText = ""
                        speechViewModel.transcriptionError = nil
                        speechViewModel.emotionResults = []
                        videoPlayer?.pause()
                        videoPlayer = nil
                        isVideoPlaying = false
                    }) {
                        VStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "arrow.clockwise")
                                        .foregroundColor(.white)
                                        .font(.system(size: 32))
                                )
                            Text("Try Again")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                } else {
                    if speechViewModel.isRecording {
                        Button(action: {
                            speechViewModel.stopRecording()
                            prompterViewModel.stopHighlighting()
                        }) {
                            VStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "stop.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 32))
                                    )
                                Text("Stop")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .disabled(!speechViewModel.hasCameraPermissions)
                    } else {
                        Button(action: {
                            showingResult = false
                            resultViewModel.reset()
                            prompterViewModel.resetHighlighting()
                            speechViewModel.startRecording {
                                prompterViewModel.startHighlighting()
                            }
                            showingVideoPlayer = false
                            speechViewModel.transcriptionText = ""
                            speechViewModel.transcriptionError = nil
                            speechViewModel.emotionResults = []
                        }) {
                            VStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "record.circle")
                                            .foregroundColor(.white)
                                            .font(.system(size: 32))
                                    )
                                Text("Record")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                        }
                        .disabled(!speechViewModel.hasCameraPermissions)
                    }
                }
            }
            .padding()
            
            if !speechViewModel.recordedVideos.isEmpty && !speechViewModel.isRecording {
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
                                        // Display custom title instead of "Recording X"
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

            Spacer()
        }
        .onAppear {
            speechViewModel.setupCamera()
            speechViewModel.loadRecordings()
        }
        .onDisappear {
            speechViewModel.stopSession()
            prompterViewModel.stopHighlighting()
            videoPlayer?.pause()
        }
        .onChange(of: speechViewModel.isRecording) { oldValue, newValue in
            if !newValue && oldValue && speechViewModel.lastRecordedVideoURL != nil {
                if let url = speechViewModel.lastRecordedVideoURL {
                    videoPlayer = AVPlayer(url: url) 
                    isVideoPlaying = false 
                }
                showingResult = true
            }
        }
        .onChange(of: speechViewModel.lastRecordedVideoURL) { oldValue, newValue in
            if newValue != nil && !speechViewModel.isRecording {
                if !showingVideoPlayer { 
                    showingVideoPlayer = true
                    if let url = newValue {
                        videoPlayer = AVPlayer(url: url)
                        isVideoPlaying = false
                    }
                }
            } else if newValue == nil {
                showingVideoPlayer = false
                videoPlayer = nil
                isVideoPlaying = false
            }
        }
        .onChange(of: prompterViewModel.prompterHasFinished) { oldValue, newValue in
            print("📝 Prompter finished changed from \(oldValue) to \(newValue)")
            if newValue == true && speechViewModel.isRecording {
                print("📝 Prompter has finished. Stopping recording.")
                speechViewModel.stopRecording()
               }
        }
        .onChange(of: speechViewModel.isTranscribing) { oldValue, newValue in
            print("🔄 isTranscribing changed from \(oldValue) to \(newValue)")
            print("📊 current transcriptionText: '\(speechViewModel.transcriptionText)'")
            print("🎬 current isRecording: \(speechViewModel.isRecording)")
            if !newValue && !speechViewModel.isRecording && !speechViewModel.isAnalyzingEmotion {
                print("🎯 Both transcription and emotion analysis finished. Calculating score.")
                resultViewModel.calculateScore(
                    transcribedText: speechViewModel.transcriptionText,
                    expectedText: prompterViewModel.prompter.script,
                    emotionResults: speechViewModel.emotionResults
                )
                
                // Save the score for the current recording
                if let currentURL = speechViewModel.lastRecordedVideoURL {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let score = resultViewModel.result?.score {
                            speechViewModel.setRecordingScore(score, for: currentURL)
                        }
                    }
                }
                
                if !showingResult && speechViewModel.lastRecordedVideoURL != nil { 
                    showingResult = true
                }
            }
        }
        .onChange(of: speechViewModel.isAnalyzingEmotion) { oldValue, newValue in
            if !newValue && !speechViewModel.isTranscribing && !speechViewModel.isRecording {
                print("🎯 Both transcription and emotion analysis finished. Calculating score.")
                resultViewModel.calculateScore(
                    transcribedText: speechViewModel.transcriptionText,
                    expectedText: prompterViewModel.prompter.script,
                    emotionResults: speechViewModel.emotionResults
                )
                
                // Save the score for the current recording
                if let currentURL = speechViewModel.lastRecordedVideoURL {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let score = resultViewModel.result?.score {
                            speechViewModel.setRecordingScore(score, for: currentURL)
                        }
                    }
                }
                
                if !showingResult && speechViewModel.lastRecordedVideoURL != nil { 
                    showingResult = true
                }
            }
        }
        .sheet(isPresented: $showingTranscriptionView) {
            TranscriptionView(
                videoURL: selectedVideoForTranscription,
                viewModel: speechViewModel
            )
            .frame(minWidth: 800, minHeight: 600)
            .presentationDetents([.large])
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

// Transcription View
struct TranscriptionView: View {
    let videoURL: URL?
    @ObservedObject var viewModel: SpeechViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if let url = videoURL {
                    Button("Retry Transcription") {
                        viewModel.transcribeVideo(url: url)
                    }
                    .disabled(viewModel.isTranscribing)
                    .buttonStyle(.bordered)
                }

                Spacer()

                Text("Speech Transcription")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            VStack(spacing: 20) {
                if let url = videoURL {
                    Text("Recording: \(url.lastPathComponent)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top, 16)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if viewModel.isTranscribing {
                            HStack {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Transcribing audio...")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }

                        if !viewModel.transcriptionText.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Transcription:")
                                    .font(.headline)
                                    .fontWeight(.semibold)

                                ScrollView {
                                    Text(viewModel.transcriptionText)
                                        .font(.body)
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .textSelection(.enabled)
                                }
                                .frame(minHeight: 100, maxHeight: .infinity)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(10)
                            }
                        }

                        if let error = viewModel.transcriptionError {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Error:")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)

                                Text(error)
                                    .font(.body)
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }

                        if !viewModel.isTranscribing && viewModel.transcriptionText.isEmpty && viewModel.transcriptionError == nil {
                             VStack(spacing: 16) {
                                Image(systemName: "waveform.and.mic")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)

                                Text("Ready to transcribe")
                                    .font(.title2)
                                    .fontWeight(.medium)

                                if videoURL != nil {
                                     Text("Tap 'Retry Transcription' to convert the audio from your recording to text, or it will start automatically if triggered from the main view.")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                } else {
                                    Text("No video selected for transcription.")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(32)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            if let url = videoURL, !viewModel.isTranscribing, viewModel.transcriptionText.isEmpty {
                viewModel.transcribeVideo(url: url)
                viewModel.detectEmotion(url: url)
            }
        }
    }
}

struct CameraPreview: NSViewRepresentable {
    let session: AVCaptureSession

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer = previewLayer

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) -> Void {
        if let layer = nsView.layer as? AVCaptureVideoPreviewLayer {
            layer.session = session

            DispatchQueue.main.async {
                 if layer.frame != nsView.bounds {
                    layer.frame = nsView.bounds
                }
            }
        }
    }
}

#Preview {
    SpeechView()
}
