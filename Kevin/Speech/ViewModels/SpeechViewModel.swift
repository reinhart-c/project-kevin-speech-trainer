//
//  SpeechViewModel.swift
//  Kevin
//
//  Created by Teuku Fazariz Basya on 10/06/25.
//

import SwiftUI
import AVFoundation
import Speech
import Combine

class SpeechViewModel: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    // MARK: - Published Properties from CameraManager
    @Published var isRecording = false
    @Published var lastRecordedVideoURL: URL?
    @Published var recordedVideos: [URL] = []
    @Published var hasCameraPermissions = false
    
    // MARK: - Published Properties from SpeechRecognizer
    @Published var transcriptionText = ""
    @Published var isTranscribing = false
    @Published var transcriptionError: String?
    @Published var hasSpeechRecognitionPermissions = false

    // MARK: - AVFoundation Properties
    let session = AVCaptureSession()
    private var movieFileOutput = AVCaptureMovieFileOutput()
    
    // MARK: - Speech Recognition Properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechURLRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    override init() {
        super.init()
        loadRecordings() // Load existing recordings on init
    }

    // MARK: - Camera Setup and Permissions
    func setupCamera() {
        checkCameraPermissions()
        checkSpeechRecognitionPermissions()
    }

    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.checkAudioPermissions() // Proceed to check audio if video is authorized
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] videoGranted in
                if videoGranted {
                    self?.checkAudioPermissions()
                } else {
                    DispatchQueue.main.async {
                        self?.hasCameraPermissions = false
                    }
                }
            }
        default:
            DispatchQueue.main.async {
                self.hasCameraPermissions = false
            }
        }
    }

    private func checkAudioPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            DispatchQueue.main.async {
                self.hasCameraPermissions = true
                self.configureSession()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] audioGranted in
                DispatchQueue.main.async {
                    if audioGranted {
                        self?.hasCameraPermissions = true
                        self?.configureSession()
                    } else {
                        self?.hasCameraPermissions = false
                    }
                }
            }
        default:
            DispatchQueue.main.async {
                self.hasCameraPermissions = false
            }
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        
        if session.canSetSessionPreset(.high) {
            session.sessionPreset = .high
        }

        // Video Input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else {
            print("Failed to set up video input.")
            session.commitConfiguration()
            return
        }
        session.addInput(videoInput)

        // Audio Input
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
              session.canAddInput(audioInput) else {
            print("Failed to set up audio input.")
            session.commitConfiguration()
            return
        }
        session.addInput(audioInput)

        // Movie File Output
        if session.canAddOutput(movieFileOutput) {
            session.addOutput(movieFileOutput)
        } else {
            print("Failed to add movie file output.")
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }

    // MARK: - Recording
    func startRecording() {
        guard !isRecording && hasCameraPermissions else { return }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).mov")
        
        movieFileOutput.startRecording(to: outputURL, recordingDelegate: self)
        DispatchQueue.main.async {
            self.isRecording = true
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        movieFileOutput.stopRecording() // Delegate will set isRecording to false
    }

    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.isRecording = false
            if let error = error {
                print("Recording error: \(error.localizedDescription)")
            } else {
                print("Recording saved to: \(outputFileURL)")
                self.lastRecordedVideoURL = outputFileURL
                self.recordedVideos.append(outputFileURL)
                self.sortRecordings()
                self.transcribeVideo(url: outputFileURL) 
            }
        }
    }

    // MARK: - File Management
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func loadRecordings() {
        let fileManager = FileManager.default
        let documentsURL = getDocumentsDirectory()
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            self.recordedVideos = fileURLs.filter { $0.pathExtension == "mov" && $0.lastPathComponent.starts(with: "recording_") }
            self.sortRecordings()
            if let last = self.recordedVideos.first { // Assuming sorted descending
                 self.lastRecordedVideoURL = last
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
    private func sortRecordings() {
        recordedVideos.sort { url1, url2 in
            guard let time1 = Double(url1.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "recording_", with: "")),
                  let time2 = Double(url2.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "recording_", with: "")) else {
                return false
            }
            return time1 > time2 // Sort descending, newest first
        }
    }

    func deleteRecording(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            recordedVideos.removeAll { $0 == url }
            if lastRecordedVideoURL == url {
                lastRecordedVideoURL = recordedVideos.first // newest if sorted
            }
            print("Successfully deleted recording: \(url)")
        } catch {
            print("Error deleting recording \(url): \(error.localizedDescription)")
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

    // MARK: - Speech Recognition
    func checkSpeechRecognitionPermissions() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.hasSpeechRecognitionPermissions = true
                    print("Speech recognition authorized")
                case .denied, .restricted, .notDetermined:
                    self?.hasSpeechRecognitionPermissions = false
                    print("Speech recognition not authorized")
                @unknown default:
                    self?.hasSpeechRecognitionPermissions = false
                    print("Unknown speech recognition status")
                }
            }
        }
    }
    
    func transcribeVideo(url: URL) {
        guard hasSpeechRecognitionPermissions else {
            transcriptionError = "Speech recognition permission not granted."
            isTranscribing = false
            return
        }
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            transcriptionError = "Speech recognition not available on this device or for the selected locale."
            isTranscribing = false
            return
        }
        
        if isTranscribing { // Cancel previous task if any
            recognitionTask?.cancel()
            recognitionTask = nil
            recognitionRequest = nil
        }

        isTranscribing = true
        transcriptionText = ""
        transcriptionError = nil
        
        recognitionRequest = SFSpeechURLRecognitionRequest(url: url)
        guard let recognitionRequest = recognitionRequest else {
            transcriptionError = "Unable to create recognition request."
            isTranscribing = false
            return
        }
        
        recognitionRequest.shouldReportPartialResults = false // Set to true if you want live updates

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                self.transcriptionText = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                DispatchQueue.main.async {
                    self.isTranscribing = false
                    if let error = error {
                        self.transcriptionError = error.localizedDescription
                        print("Transcription error: \(error.localizedDescription)")
                    }
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                }
            }
        }
    }
}