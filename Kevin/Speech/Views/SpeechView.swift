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
    @StateObject private var speechViewModel = SpeechViewModel()
    @StateObject private var prompterViewModel = PrompterViewModel()
    @StateObject private var resultViewModel = ResultViewModel() // Add ResultViewModel

    @State private var showingVideoPlayer = false
    @State private var showingTranscriptionView = false
    @State private var selectedVideoForTranscription: URL?
    @State private var showingResult = false // Add state for showing result
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Speech Training")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            HStack(spacing: 20) {
                ZStack {
                    if showingVideoPlayer, let videoURL = speechViewModel.lastRecordedVideoURL {
                        VideoPlayer(player: AVPlayer(url: videoURL))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .aspectRatio(16/9, contentMode: .fit)
                            .cornerRadius(15)
                    } else {
                        CameraPreview(session: speechViewModel.session)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .aspectRatio(16/9, contentMode: .fit)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
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
                    }
                }
                
                // Overlay message when no camera access
                if !viewModel.hasCameraPermissions {
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Camera access required")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Please grant camera and microphone access in Settings.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .frame(height: 400)

                // Show ResultView instead of PrompterView when recording is finished and we have results
                if showingResult {
                    ResultView(viewModel: resultViewModel) {
                        // Reset action
                        showingResult = false
                        resultViewModel.reset()
                        prompterViewModel.resetHighlighting()
                        speechViewModel.transcriptionText = ""
                        speechViewModel.transcriptionError = nil
                    }
                } else {
                    PrompterView(viewModel: prompterViewModel)
                }
            }
            .padding(.horizontal)
            
            Text(speechViewModel.isRecording ? "Recording in progress..." :
                 showingVideoPlayer && speechViewModel.lastRecordedVideoURL != nil ? "Playing recorded video" : "Ready to record")
                .font(.headline)
                .foregroundColor(speechViewModel.isRecording ? .red :
                               (showingVideoPlayer && speechViewModel.lastRecordedVideoURL != nil) ? .blue : .primary)
            
            HStack(spacing: 30) {
                Button(action: {
                    if speechViewModel.isRecording {
                        speechViewModel.stopRecording()
                        prompterViewModel.stopHighlighting()
                    } else {
                        showingResult = false // Hide result when starting new recording
                        resultViewModel.reset()
                        prompterViewModel.resetHighlighting()
                        prompterViewModel.startHighlighting()
                        speechViewModel.startRecording()
                        showingVideoPlayer = false
                    }
                }) {
                    VStack {
                        Circle()
                            .fill(speechViewModel.isRecording ? Color.red : Color.blue)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: speechViewModel.isRecording ? "stop.fill" : "record.circle")
                                    .foregroundColor(.white)
                                    .font(.title)
                            )
                        Text(speechViewModel.isRecording ? "Stop" : "Record")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                .disabled(!speechViewModel.hasCameraPermissions)
                
                if showingVideoPlayer && speechViewModel.lastRecordedVideoURL != nil {
                    Button(action: {
                        showingVideoPlayer = false
                    }) {
                        VStack {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.white)
                                        .font(.title)
                                )
                            Text("Camera")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
               
                if !speechViewModel.isRecording && !speechViewModel.recordedVideos.isEmpty && !showingVideoPlayer {
                    Button(action: {
                        if let latestVideo = speechViewModel.recordedVideos.first {
                            speechViewModel.lastRecordedVideoURL = latestVideo
                            showingVideoPlayer = true
                        }
                    }) {
                        VStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "play.fill")
                                        .foregroundColor(.white)
                                        .font(.title)
                                )
                            Text("Play Latest")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .padding()
            
            if !speechViewModel.recordedVideos.isEmpty {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Previous Recordings")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Delete All") {
                            speechViewModel.deleteAllRecordings()
                            showingVideoPlayer = false
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
                                        let index = speechViewModel.recordedVideos.firstIndex(of: url) ?? -1
                                        Text("Recording \(speechViewModel.recordedVideos.count - index)")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(formatDate(from: url))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 10) {
                                        Button("Play") {
                                            speechViewModel.lastRecordedVideoURL = url
                                            showingVideoPlayer = true
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .controlSize(.small)
                                        
                                        Button("Transcribe") {
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
        }
        .onChange(of: speechViewModel.lastRecordedVideoURL) { oldValue, newValue in
            if newValue != nil && !speechViewModel.isRecording {
                showingVideoPlayer = true
            } else if newValue == nil {
                showingVideoPlayer = false
            }
        }
        .onChange(of: prompterViewModel.prompterHasFinished) { oldValue, newValue in
            print("📝 Prompter finished changed from \(oldValue) to \(newValue)")
            if newValue == true && speechViewModel.isRecording {
                print("📝 Prompter has finished. Stopping recording.")
                speechViewModel.stopRecording()
               }
        }
        // REMOVE the previous .onChange(of: speechViewModel.transcriptionText) that sets showingResult

        // REVISED: Rely primarily on isTranscribing finishing AFTER recording has stopped
        .onChange(of: speechViewModel.isTranscribing) { oldValue, newValue in
            // newValue is the new state of isTranscribing
            print("🔄 isTranscribing changed from \(oldValue) to \(newValue)")
            print("📊 current transcriptionText: '\(speechViewModel.transcriptionText)'")
            print("🎬 current isRecording: \(speechViewModel.isRecording)")
            
            // When transcription stops (newValue is false) AND recording has already stopped
            if !newValue && !speechViewModel.isRecording {
                print("🎯 Transcription finished and recording is stopped. Calculating score and showing result.")
                resultViewModel.calculateScore(
                    transcribedText: speechViewModel.transcriptionText, // This can be empty
                    expectedText: prompterViewModel.prompter.script
                )
                showingResult = true
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
                                .frame(minHeight: 100, maxHeight: .infinity) // Allow it to grow
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
//                test mlmodel
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
    
    func updateNSView(_ nsView: NSView, context: Context) {
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
