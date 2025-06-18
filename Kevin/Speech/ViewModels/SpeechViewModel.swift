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
import CoreML

internal class SpeechViewModel: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    // MARK: - Published Properties from CameraManager
    @Published var isRecording = false
    @Published var lastRecordedVideoURL: URL?
    @Published var recordedVideos: [URL] = []
    @Published var hasCameraPermissions = false
    @Published var isCountingDown: Bool = false
    @Published var countdownSeconds: Int = 3
    private var countdownTimer: Timer?
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
    
    // Add emotion detection properties
    @Published var emotionResults: [VoiceEmotionClassifierOutput] = []
    @Published var isAnalyzingEmotion = false
    
    // Add these properties for recording titles and scores
    @Published var recordingTitles: [URL: String] = [:]
    @Published var recordingScores: [URL: Int] = [:]
    
    var currentPracticeTitle: String = "Untitled Practice"
    
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
    func startRecording(onCountdownFinished: @escaping () -> Void) {
        guard !isRecording && !isCountingDown && hasCameraPermissions else { return }
        
        DispatchQueue.main.async {
            self.isCountingDown = true
            self.countdownSeconds = 3
        }
        
        countdownTimer?.invalidate()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            DispatchQueue.main.async {
                if self.countdownSeconds > 1 {
                    self.countdownSeconds -= 1
                } else {
                    timer.invalidate()
                    self.countdownTimer = nil
                    self.isCountingDown = false
                    self.beginActualRecording(onCountdownFinished: onCountdownFinished)
                }
            }
        }
    }
    
    private func beginActualRecording(onCountdownFinished: @escaping () -> Void) {
        guard !isRecording && hasCameraPermissions else { return }
        
        onCountdownFinished()
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let outputURL = documentsPath.appendingPathComponent("recording_\(Date().timeIntervalSince1970).mov")
        
        movieFileOutput.startRecording(to: outputURL, recordingDelegate: self)
        DispatchQueue.main.async {
            self.isRecording = true
        }
    }
    
    func stopRecording() {
        if isCountingDown {
            countdownTimer?.invalidate()
            countdownTimer = nil
            DispatchQueue.main.async {
                self.isCountingDown = false
                self.countdownSeconds = 3
            }
            return
        }
        
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
                
                // Set the recording title when the recording is finished
                self.setRecordingTitle(self.currentPracticeTitle, for: outputFileURL)
                
                self.sortRecordings()
                
                // Start both transcription and emotion detection
                self.transcribeVideo(url: outputFileURL)
                self.detectEmotion(url: outputFileURL)
            }
        }
    }
    
    // Add method to start recording with title
    func startRecordingWithTitle(_ title: String, onCountdownFinished: @escaping () -> Void) {
        currentPracticeTitle = title
        startRecording(onCountdownFinished: onCountdownFinished)
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
            
            // Load persisted titles and scores
            loadRecordingTitles()
            loadRecordingScores()
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
            recordingTitles.removeValue(forKey: url)
            recordingScores.removeValue(forKey: url)
            saveRecordingTitles()
            saveRecordingScores()
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
        recordingTitles.removeAll()
        recordingScores.removeAll()
        lastRecordedVideoURL = nil
        saveRecordingTitles()
        saveRecordingScores()
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
    
    func loadAudioSamplesAndPredict(videoURL: URL) async throws -> [VoiceEmotionClassifierOutput] {
        // Load the AVAsset and get audio track
        let asset = AVAsset(url: videoURL)
        guard let audioTrack = try await asset.loadTracks(withMediaType: .audio).first else {
            throw NSError(domain: "AudioError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No audio track found"])
        }
        
        // Read raw PCM audio at 48kHz
        let reader = try AVAssetReader(asset: asset)
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 48000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMBitDepthKey: 32
        ]
        let output = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: outputSettings)
        reader.add(output)
        reader.startReading()
        
        var audioData = [Float]()
        while reader.status == .reading,
              let sampleBuffer = output.copyNextSampleBuffer(),
              let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {
            
            let length = CMBlockBufferGetDataLength(blockBuffer)
            var buffer = [Float](repeating: 0, count: length / MemoryLayout<Float>.size)
            buffer.withUnsafeMutableBytes {
                guard let baseAddress = $0.baseAddress else {
                    return
                }
                CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: baseAddress)
            }
            audioData.append(contentsOf: buffer)
        }
        
        guard reader.status == .completed else {
            throw NSError(domain: "AudioError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to read audio samples"])
        }
        
        // Set up AVAudioConverter to resample to 16kHz mono
        guard
            let inputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000.0, channels: 1, interleaved: false),
            let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000.0, channels: 1, interleaved: false)
        else {
            throw NSError(domain: "AudioError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAudioFormat"])
        }
        let inputFrameCount = AVAudioFrameCount(audioData.count)
        guard let inputBuffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: inputFrameCount) else {
            throw NSError(domain: "AudioError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAudioPCMBuffer"])
        }
        inputBuffer.frameLength = inputFrameCount
        audioData.withUnsafeBufferPointer {
            guard
                let floatChannelData = inputBuffer.floatChannelData,
                let baseAddress = $0.baseAddress
            else {
                return
            }
            
            floatChannelData.pointee.update(from: baseAddress, count: Int(inputFrameCount))
        }
        
        guard let converter = AVAudioConverter(from: inputFormat, to: outputFormat) else {
            throw NSError(domain: "AudioError", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAudioConverter"])
        }
        let ratio = outputFormat.sampleRate / inputFormat.sampleRate
        let outputFrameCapacity = AVAudioFrameCount(Double(inputFrameCount) * ratio)
        guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: outputFrameCapacity) else {
            throw NSError(domain: "AudioError", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAudioPCMBuffer"])
        }
        var error: NSError?
        converter.convert(to: outputBuffer, error: &error) { _, outStatus in
            outStatus.pointee = .haveData
            return inputBuffer
        }
        
        if let error = error {
            throw error
        }
        
        // Get the resampled data as [Float]
        guard let floatChannelData = outputBuffer.floatChannelData else {
            throw NSError(domain: "AudioError", code: 7, userInfo: [NSLocalizedDescriptionKey: "Failed to get floatChannelData"])
        }
        let resampledData = Array(UnsafeBufferPointer(start: floatChannelData[0],
                                                      count: Int(outputBuffer.frameLength)))
        
        // Prepare sliding windows
        let windowSize = 15600
        let hopSize = 7800 // 50% overlap
        let model = try VoiceEmotionClassifier(configuration: .init())
        var predictions: [VoiceEmotionClassifierOutput] = []
        
        for start in stride(from: 0, to: resampledData.count - windowSize + 1, by: hopSize) {
            let window = Array(resampledData[start..<start + windowSize])
            let mlArray = try MLMultiArray(shape: [NSNumber(value: windowSize)], dataType: .float32)
            for (idx, sample) in window.enumerated() {
                mlArray[idx] = NSNumber(value: sample)
            }
            let result = try model.prediction(audioSamples: mlArray)
            predictions.append(result)
        }
        
        return predictions
    }
    
    func detectEmotion(url: URL) {
        isAnalyzingEmotion = true
        
        Task(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            do {
                let results = try await self.loadAudioSamplesAndPredict(videoURL: url)
                
                await MainActor.run {
                    self.emotionResults = results
                    self.isAnalyzingEmotion = false
                    
                    // Log results for debugging
                    for (idx, result) in results.enumerated() {
                        print("Prediction \(idx + 1): \(result.target)")
                        for (label, prob) in result.targetProbability.sorted(by: { $0.value > $1.value }) {
                            print("  - \(label): \(String(format: "%.2f", prob * 100))%")
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.isAnalyzingEmotion = false
                    print("Error during emotion detection: \(error)")
                }
            }
        }
        
    }
    
    // Add this method to get recording title
    func getRecordingTitle(for url: URL) -> String {
        return recordingTitles[url] ?? "Untitled Recording"
    }
    
    // Add this method to set recording score
    func setRecordingScore(_ score: Int, for url: URL) {
        recordingScores[url] = score
    }
    
    // Add this method to get recording score
    func getRecordingScore(for url: URL) -> Int? {
        return recordingScores[url]
    }
    
    // Add this method to set recording title
    func setRecordingTitle(_ title: String, for url: URL) {
        recordingTitles[url] = title
        saveRecordingTitles()
    }
    
    // MARK: - Persistence
    private func saveRecordingTitles() {
        let data = recordingTitles.compactMapValues { $0 }.mapKeys { $0.lastPathComponent }
        UserDefaults.standard.set(data, forKey: "recordingTitles")
    }

    private func loadRecordingTitles() {
        if let data = UserDefaults.standard.dictionary(forKey: "recordingTitles") as? [String: String] {
            let documentsURL = getDocumentsDirectory()
            recordingTitles = Dictionary(uniqueKeysWithValues: data.compactMap { filename, title in
                let url = documentsURL.appendingPathComponent(filename)
                return FileManager.default.fileExists(atPath: url.path) ? (url, title) : nil
            })
        }
    }

    private func saveRecordingScores() {
        let data = recordingScores.mapKeys { $0.lastPathComponent }
        UserDefaults.standard.set(data, forKey: "recordingScores")
    }

    private func loadRecordingScores() {
        if let data = UserDefaults.standard.dictionary(forKey: "recordingScores") as? [String: Int] {
            let documentsURL = getDocumentsDirectory()
            recordingScores = Dictionary(uniqueKeysWithValues: data.compactMap { filename, score in
                let url = documentsURL.appendingPathComponent(filename)
                return FileManager.default.fileExists(atPath: url.path) ? (url, score) : nil
            })
        }
    }
}

extension Dictionary {
    func mapKeys<NewKey: Hashable>(_ transform: (Key) -> NewKey) -> [NewKey: Value] {
        return Dictionary<NewKey, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }
}
