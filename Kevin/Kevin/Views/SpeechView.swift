//
//  SpeechView.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 10/06/25.
//

import SwiftUI
import AVFoundation

struct SpeechView: View {
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        VStack {
            // Camera preview
            CameraPreview(session: cameraManager.session)
                .frame(height: 300)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            HStack(spacing: 20) {
                // Record button
                Button(action: {
                    if cameraManager.isRecording {
                        cameraManager.stopRecording()
                    } else {
                        cameraManager.startRecording()
                    }
                }) {
                    Circle()
                        .fill(cameraManager.isRecording ? Color.red : Color.blue)
                        .frame(width: 70, height: 70)
                        .overlay(
                            Image(systemName: cameraManager.isRecording ? "stop.fill" : "video.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                        )
                }
                
                // Status text
                Text(cameraManager.isRecording ? "Recording..." : "Tap to Record")
                    .font(.headline)
                    .foregroundColor(cameraManager.isRecording ? .red : .primary)
            }
            .padding()
        }
        .padding()
        .onAppear {
            cameraManager.setupCamera()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
}

// Camera Preview UIViewRepresentable
struct CameraPreview: NSViewRepresentable {
    let session: AVCaptureSession
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer = previewLayer
        view.wantsLayer = true
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let layer = nsView.layer as? AVCaptureVideoPreviewLayer {
            layer.session = session
        }
    }
}

// Camera Manager
class CameraManager: NSObject, ObservableObject {
    @Published var isRecording = false
    let session = AVCaptureSession()
    private var movieFileOutput = AVCaptureMovieFileOutput()
    
    func setupCamera() {
        // Request camera and microphone permissions
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                AVCaptureDevice.requestAccess(for: .audio) { audioGranted in
                    if audioGranted {
                        DispatchQueue.main.async {
                            self.configureSession()
                        }
                    }
                }
            }
        }
    }
    
    private func configureSession() {
        session.beginConfiguration()
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else {
            session.commitConfiguration()
            return
        }
        session.addInput(videoInput)
        
        // Add audio input
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
              session.canAddInput(audioInput) else {
            session.commitConfiguration()
            return
        }
        session.addInput(audioInput)
        
        // Add movie file output
        if session.canAddOutput(movieFileOutput) {
            session.addOutput(movieFileOutput)
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
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
}

// AVCaptureFileOutputRecordingDelegate
extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Recording error: \(error.localizedDescription)")
        } else {
            print("Recording saved to: \(outputFileURL)")
        }
    }
}

#Preview {
    SpeechView()
}
