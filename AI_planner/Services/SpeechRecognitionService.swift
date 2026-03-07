//
//  SpeechRecognitionService.swift
//  AI_planner
//
//  Created by Judy459 on 3/3/26.
//

import Foundation
import Speech
import AVFoundation
import Combine

@MainActor
class SpeechRecognitionService: ObservableObject {
    
    // MARK: - Published State
    @Published var isRecording = false
    @Published var recognizedText = ""
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        guard speechStatus == .authorized else {
            errorMessage = "Speech recognition not authorized"
            return false
        }
        
        let micGranted = await AVAudioApplication.requestRecordPermission()
        guard micGranted else {
            errorMessage = "Microphone access not authorized"
            return false
        }
        
        return true
    }
    
    // MARK: - Start Recording
    
    func startRecording() async {
        guard await requestAuthorization() else { return }
        
        // Stop any existing session
        stopRecording()
        
        errorMessage = nil
        recognizedText = ""
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition unavailable"
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            self.recognitionRequest = request
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                request.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            isRecording = true
            
            recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in
                    guard let self = self else { return }
                    
                    if let result = result {
                        self.recognizedText = result.bestTranscription.formattedString
                    }
                    
                    if let error = error {
                        let nsError = error as NSError
                        // Ignore cancellation errors (user stopped recording)
                        if nsError.domain != "kAFAssistantErrorDomain" || nsError.code != 216 {
                            self.errorMessage = "Recognition error: \(error.localizedDescription)"
                        }
                        self.stopRecording()
                    }
                    
                    if result?.isFinal == true {
                        self.stopRecording()
                    }
                }
            }
            
        } catch {
            errorMessage = "Failed to start recording: \(error.localizedDescription)"
            isRecording = false
        }
    }
    
    // MARK: - Stop Recording
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
        
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    // MARK: - Toggle
    
    func toggleRecording() async {
        if isRecording {
            stopRecording()
        } else {
            await startRecording()
        }
    }
}
