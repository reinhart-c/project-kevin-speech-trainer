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
    @StateObject private var viewModel = SpeechViewModel() // Use the new ViewModel
    @State private var showingVideoPlayer = false
    @State private var showingTranscriptionView = false
    @State private var selectedVideoForTranscription: URL?
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Speech Training")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            // Video preview area
            ZStack {
                if showingVideoPlayer, let videoURL = viewModel.lastRecordedVideoURL {
                    // Video player for recorded video
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(height: 400)
                        .cornerRadius(15)
                } else {
                    // Camera preview
                    CameraPreview(session: viewModel.session) // Use session from ViewModel
                        .frame(height: 400)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        )
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
            
            // Status text
            Text(viewModel.isRecording ? "Recording in progress..." :
                 showingVideoPlayer && viewModel.lastRecordedVideoURL != nil ? "Playing recorded video" : "Ready to record")
                .font(.headline)
                .foregroundColor(viewModel.isRecording ? .red :
                               (showingVideoPlayer && viewModel.lastRecordedVideoURL != nil) ? .blue : .primary)
            
            // Control buttons
            HStack(spacing: 30) {
                // Record/Stop button
                Button(action: {
                    if viewModel.isRecording {
                        viewModel.stopRecording()
                    } else {
                        showingVideoPlayer = false // Switch back to camera view if playing
                        viewModel.lastRecordedVideoURL = nil // Clear last played video to ensure camera shows
                        viewModel.startRecording()
                    }
                }) {
                    VStack {
                        Circle()
                            .fill(viewModel.isRecording ? Color.red : Color.blue)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: viewModel.isRecording ? "stop.fill" : "record.circle")
                                    .foregroundColor(.white)
                                    .font(.title)
                            )
                        Text(viewModel.isRecording ? "Stop" : "Record")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                .disabled(!viewModel.hasCameraPermissions)
                
                // Back to camera button (only show when playing video)
                if showingVideoPlayer && viewModel.lastRecordedVideoURL != nil {
                    Button(action: {
                        showingVideoPlayer = false
                        // viewModel.lastRecordedVideoURL = nil // Optional: clear to ensure camera preview
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
                
                // Play latest button (only show when not recording and has recordings)
                if !viewModel.isRecording && !viewModel.recordedVideos.isEmpty && !showingVideoPlayer {
                    Button(action: {
                        if let latestVideo = viewModel.recordedVideos.first { // Assuming sorted newest first
                            viewModel.lastRecordedVideoURL = latestVideo
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
            
            // Recording history
            if !viewModel.recordedVideos.isEmpty {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Previous Recordings")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Delete All") {
                            viewModel.deleteAllRecordings()
                            showingVideoPlayer = false
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack {
                            // Iterating directly over viewModel.recordedVideos as it's now sorted
                            ForEach(viewModel.recordedVideos, id: \.self) { url in
                                HStack {
                                    VStack(alignment: .leading) {
                                        // Find index for display name if needed, or use a more robust model
                                        let index = viewModel.recordedVideos.firstIndex(of: url) ?? -1
                                        Text("Recording \(viewModel.recordedVideos.count - index)")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(formatDate(from: url))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 10) {
                                        Button("Play") {
                                            viewModel.lastRecordedVideoURL = url
                                            showingVideoPlayer = true
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .controlSize(.small)
                                        
                                        Button("Transcribe") {
                                            selectedVideoForTranscription = url
                                            showingTranscriptionView = true
                                            // Transcription is now triggered from TranscriptionView's onAppear or a button there
                                            // viewModel.transcribeVideo(url: url) // Or trigger here if preferred
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                        .foregroundColor(.blue)
                                        .disabled(viewModel.isTranscribing)
                                        
                                        Button("Delete") {
                                            viewModel.deleteRecording(url: url)
                                            // If we're currently playing the deleted video, go back to camera or play next/previous
                                            if viewModel.lastRecordedVideoURL == url { // This condition might be tricky if url is already deleted
                                                showingVideoPlayer = false // Go back to camera view
                                                // viewModel.lastRecordedVideoURL = viewModel.recordedVideos.first // Play newest
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
            viewModel.setupCamera() // This now handles both camera and speech permissions
            viewModel.loadRecordings()
        }
        .onDisappear {
            viewModel.stopSession()
        }
        .onChange(of: viewModel.lastRecordedVideoURL) { oldValue, newValue in
            if newValue != nil && !viewModel.isRecording {
                showingVideoPlayer = true
            } else if newValue == nil {
                showingVideoPlayer = false
            }
        }
        .sheet(isPresented: $showingTranscriptionView) {
            TranscriptionView(
                videoURL: selectedVideoForTranscription,
                viewModel: viewModel // Pass the viewModel
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
        return url.lastPathComponent // Fallback to filename
    }
}

// Transcription View
struct TranscriptionView: View {
    let videoURL: URL?
    @ObservedObject var viewModel: SpeechViewModel // Use SpeechViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with controls
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
            .background(Color(NSColor.controlBackgroundColor)) // Adapts to light/dark mode
            
            Divider()
            
            // Content area
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
        .background(Color(NSColor.windowBackgroundColor)) // Adapts to light/dark mode
        .onAppear {
            // Automatically start transcription if a videoURL is provided and not already transcribing
            if let url = videoURL, !viewModel.isTranscribing, viewModel.transcriptionText.isEmpty {
                viewModel.transcribeVideo(url: url)
            }
        }
    }
}

// Camera Preview NSViewRepresentable (No changes needed, it takes AVCaptureSession)
struct CameraPreview: NSViewRepresentable {
    let session: AVCaptureSession
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill // Changed to fill for better preview
        previewLayer.frame = view.bounds // Set initial frame
        view.layer = previewLayer
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let layer = nsView.layer as? AVCaptureVideoPreviewLayer {
            layer.session = session // Ensure session is up to date
            
            // Update layer frame to match view bounds on resize
            DispatchQueue.main.async { // Ensure UI updates on main thread
                 if layer.frame != nsView.bounds {
                    layer.frame = nsView.bounds
                }
            }
        }
    }
}


// Removed CameraManager and SpeechRecognizer classes as their logic is now in SpeechViewModel

#Preview {
    SpeechView()
}
