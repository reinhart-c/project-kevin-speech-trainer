//
//  SpeechView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 10/06/25.
//

import SwiftUI
import AVFoundation
import AVKit
import Speech

struct SpeechView: View {
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var speechRecognizer = SpeechRecognizer()
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
                if showingVideoPlayer, let videoURL = cameraManager.lastRecordedVideoURL {
                    // Video player for recorded video
                    VideoPlayer(player: AVPlayer(url: videoURL))
                        .frame(height: 400)
                        .cornerRadius(15)
                } else {
                    // Camera preview
                    CameraPreview(session: cameraManager.session)
                        .frame(height: 400)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        )
                }
                
                // Overlay message when no camera access
                if !cameraManager.hasPermissions {
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Camera access required")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(15)
                }
            }
            
            // Status text
            Text(cameraManager.isRecording ? "Recording in progress..." : 
                 showingVideoPlayer ? "Playing recorded video" : "Ready to record")
                .font(.headline)
                .foregroundColor(cameraManager.isRecording ? .red : 
                               showingVideoPlayer ? .blue : .primary)
            
            // Control buttons
            HStack(spacing: 30) {
                // Record/Stop button
                Button(action: {
                    if cameraManager.isRecording {
                        cameraManager.stopRecording()
                    } else {
                        showingVideoPlayer = false
                        cameraManager.startRecording()
                    }
                }) {
                    VStack {
                        Circle()
                            .fill(cameraManager.isRecording ? Color.red : Color.blue)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: cameraManager.isRecording ? "stop.fill" : "record.circle")
                                    .foregroundColor(.white)
                                    .font(.title)
                            )
                        Text(cameraManager.isRecording ? "Stop" : "Record")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                .disabled(!cameraManager.hasPermissions)
                
                // Back to camera button (only show when playing video)
                if showingVideoPlayer {
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
                
                // Play latest button (only show when not recording and has recordings)
                if !cameraManager.isRecording && !cameraManager.recordedVideos.isEmpty && !showingVideoPlayer {
                    Button(action: {
                        if let latestVideo = cameraManager.recordedVideos.last {
                            cameraManager.lastRecordedVideoURL = latestVideo
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
            if !cameraManager.recordedVideos.isEmpty {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Previous Recordings")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Delete All") {
                            cameraManager.deleteAllRecordings()
                            showingVideoPlayer = false
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(Array(cameraManager.recordedVideos.enumerated().reversed()), id: \.offset) { index, url in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Recording \(cameraManager.recordedVideos.count - index)")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(formatDate(from: url))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 10) {
                                        Button("Play") {
                                            cameraManager.lastRecordedVideoURL = url
                                            showingVideoPlayer = true
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .controlSize(.small)
                                        
                                        Button("Transcribe") {
                                            selectedVideoForTranscription = url
                                            showingTranscriptionView = true
                                            speechRecognizer.transcribeVideo(url: url)
                                        }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                        .foregroundColor(.blue)
                                        .disabled(speechRecognizer.isTranscribing)
                                        
                                        Button("Delete") {
                                            cameraManager.deleteRecording(url: url)
                                            // If we're currently playing the deleted video, go back to camera
                                            if cameraManager.lastRecordedVideoURL == url {
                                                showingVideoPlayer = false
                                                cameraManager.lastRecordedVideoURL = nil
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
            cameraManager.setupCamera()
            speechRecognizer.requestPermissions()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .onChange(of: cameraManager.lastRecordedVideoURL) { _ in
            if cameraManager.lastRecordedVideoURL != nil && !cameraManager.isRecording {
                showingVideoPlayer = true
            }
        }
        .sheet(isPresented: $showingTranscriptionView) {
            TranscriptionView(
                videoURL: selectedVideoForTranscription,
                speechRecognizer: speechRecognizer
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
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return "Unknown date"
    }
}

// Transcription View
struct TranscriptionView: View {
    let videoURL: URL?
    @ObservedObject var speechRecognizer: SpeechRecognizer
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with controls
            HStack {
                if let url = videoURL {
                    Button("Retry") {
                        speechRecognizer.transcribeVideo(url: url)
                    }
                    .disabled(speechRecognizer.isTranscribing)
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
                        if speechRecognizer.isTranscribing {
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
                        
                        if !speechRecognizer.transcriptionText.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Transcription:")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                ScrollView {
                                    Text(speechRecognizer.transcriptionText)
                                        .font(.body)
                                        .padding(16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(10)
                                        .textSelection(.enabled)
                                }
                                .frame(minHeight: 200, maxHeight: 400)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(10)
                            }
                        }
                        
                        if let error = speechRecognizer.transcriptionError {
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
                        
                        if !speechRecognizer.isTranscribing && speechRecognizer.transcriptionText.isEmpty && speechRecognizer.transcriptionError == nil {
                            VStack(spacing: 16) {
                                Image(systemName: "waveform.and.mic")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                
                                Text("Ready to transcribe")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                
                                Text("Tap 'Transcribe' to convert the audio from your recording to text.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
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
    }
}

// Speech Recognizer Class
class SpeechRecognizer: ObservableObject {
    @Published var transcriptionText = ""
    @Published var isTranscribing = false
    @Published var transcriptionError: String?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition not authorized")
                @unknown default:
                    print("Unknown speech recognition status")
                }
            }
        }
    }
    
    func transcribeVideo(url: URL) {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            transcriptionError = "Speech recognition not available"
            return
        }
        
        isTranscribing = true
        transcriptionText = ""
        transcriptionError = nil
        
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        
        speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.transcriptionError = error.localizedDescription
                    self?.isTranscribing = false
                    return
                }
                
                if let result = result {
                    self?.transcriptionText = result.bestTranscription.formattedString
                    
                    if result.isFinal {
                        self?.isTranscribing = false
                    }
                }
            }
        }
    }
}

// Camera Preview NSViewRepresentable
struct CameraPreview: NSViewRepresentable {
    let session: AVCaptureSession
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer = previewLayer
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let layer = nsView.layer as? AVCaptureVideoPreviewLayer {
            layer.session = session
            
            // Update layer frame to match view bounds
            DispatchQueue.main.async {
                layer.frame = nsView.bounds
            }
        }
    }
}

// Camera Manager
class CameraManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var lastRecordedVideoURL: URL?
    @Published var recordedVideos: [URL] = []
    @Published var hasPermissions = false
    
    let session = AVCaptureSession()
    private var movieFileOutput = AVCaptureMovieFileOutput()
    
    func setupCamera() {
        checkPermissions()
    }
    
    private func checkPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] videoGranted in
            if videoGranted {
                AVCaptureDevice.requestAccess(for: .audio) { [weak self] audioGranted in
                    DispatchQueue.main.async {
                        self?.hasPermissions = videoGranted && audioGranted
                        if self?.hasPermissions == true {
                            self?.configureSession()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.hasPermissions = false
                }
            }
        }
    }
    
    private func configureSession() {
        session.beginConfiguration()
        
        // Set session preset for better quality
        if session.canSetSessionPreset(.high) {
            session.sessionPreset = .high
        }
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        
        // Add audio input
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {
            session.commitConfiguration()
            return
        }
        
        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
        
        // Add movie file output
        if session.canAddOutput(movieFileOutput) {
            session.addOutput(movieFileOutput)
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func startRecording() {
        guard !isRecording && hasPermissions else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).mov")
        
        movieFileOutput.startRecording(to: outputURL, recordingDelegate: self)
        isRecording = true
    }
    
    func stopRecording() {
        guard isRecording else { return }
        movieFileOutput.stopRecording()
        isRecording = false
    }
    
    func stopSession() {
        session.stopRunning()
    }
    
    func deleteRecording(url: URL) {
        // Remove from file system
        do {
            try FileManager.default.removeItem(at: url)
            print("Successfully deleted recording: \(url)")
        } catch {
            print("Error deleting recording: \(error.localizedDescription)")
        }
        
        // Remove from array
        recordedVideos.removeAll { $0 == url }
        
        // Update lastRecordedVideoURL if it was the deleted one
        if lastRecordedVideoURL == url {
            lastRecordedVideoURL = recordedVideos.last
        }
    }
    
    func deleteAllRecordings() {
        for url in recordedVideos {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("Error deleting recording \(url): \(error.localizedDescription)")
            }
        }
        recordedVideos.removeAll()
        lastRecordedVideoURL = nil
    }
}

// AVCaptureFileOutputRecordingDelegate
extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("Recording error: \(error.localizedDescription)")
            } else {
                print("Recording saved to: \(outputFileURL)")
                self.lastRecordedVideoURL = outputFileURL
                self.recordedVideos.append(outputFileURL)
            }
        }
    }
}

#Preview {
    SpeechView()
}
