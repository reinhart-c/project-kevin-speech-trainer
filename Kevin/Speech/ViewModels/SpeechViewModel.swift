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
    
    func loadAudioSamplesAndPredict(videoURL: URL) throws -> [VoiceEmotionClassifierOutput] {
        // Load the AVAsset and get audio track
        let asset = AVAsset(url: videoURL)
        guard let audioTrack = asset.tracks(withMediaType: .audio).first else {
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
                CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: $0.baseAddress!)
            }
            audioData.append(contentsOf: buffer)
        }

        guard reader.status == .completed else {
            throw NSError(domain: "AudioError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to read audio samples"])
        }

        // Set up AVAudioConverter to resample to 16kHz mono
        let inputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000.0, channels: 1, interleaved: false)!
        let outputFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000.0, channels: 1, interleaved: false)!
        let inputFrameCount = AVAudioFrameCount(audioData.count)
        let inputBuffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: inputFrameCount)!
        inputBuffer.frameLength = inputFrameCount
        audioData.withUnsafeBufferPointer {
            inputBuffer.floatChannelData!.pointee.assign(from: $0.baseAddress!, count: Int(inputFrameCount))
        }

        let converter = AVAudioConverter(from: inputFormat, to: outputFormat)!
        let ratio = outputFormat.sampleRate / inputFormat.sampleRate
        let outputFrameCapacity = AVAudioFrameCount(Double(inputFrameCount) * ratio)
        let outputBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: outputFrameCapacity)!
        var error: NSError?
        converter.convert(to: outputBuffer, error: &error) { _, outStatus in
            outStatus.pointee = .haveData
            return inputBuffer
        }

        if let error = error {
            throw error
        }

        // Get the resampled data as [Float]
        let resampledData = Array(UnsafeBufferPointer(start: outputBuffer.floatChannelData![0],
                                                      count: Int(outputBuffer.frameLength)))

        // Prepare sliding windows
        let windowSize = 15600
        let hopSize = 7800 // 50% overlap
        let model = try VoiceEmotionClassifier()
        var predictions: [VoiceEmotionClassifierOutput] = []

        for start in stride(from: 0, to: resampledData.count - windowSize + 1, by: hopSize) {
            let window = Array(resampledData[start..<start + windowSize])
            let mlArray = try MLMultiArray(shape: [NSNumber(value: windowSize)], dataType: .float32)
            for (i, sample) in window.enumerated() {
                mlArray[i] = NSNumber(value: sample)
            }
            let result = try model.prediction(audioSamples: mlArray)
            predictions.append(result)
        }

        return predictions
    }

    
    func detectEmotion(url: URL){
        do {
            let results = try loadAudioSamplesAndPredict(videoURL: url)
            for (i, result) in results.enumerated() {
                print("Prediction \(i + 1): \(result.target)")
                for (label, prob) in result.targetProbability.sorted(by: { $0.value > $1.value }) {
                    print("  - \(label): \(String(format: "%.2f", prob * 100))%")
                }
            }
        } catch {
            print("Error during prediction: \(error)")
        }
    }
}
