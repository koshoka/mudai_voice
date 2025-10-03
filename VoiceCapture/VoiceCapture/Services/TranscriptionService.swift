//
//  TranscriptionService.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation
import Combine
import WhisperKit

class TranscriptionService: TranscriptionServiceProtocol {
    // MARK: - Properties
    
    private var whisperKit: WhisperKit?
    private let settingsManager = SettingsManager.shared
    let transcriptionProgress = PassthroughSubject<Float, Never>()
    
    // MARK: - TranscriptionServiceProtocol
    
    func transcribe(audioURL: URL) async throws -> String {
        AppLogger.transcription.info("Starting transcription for: \(audioURL.lastPathComponent)")
        
        do {
            // WhisperKitの初期化（モデル選択）
            try await initializeWhisperKit()
            
            guard let whisperKit = whisperKit else {
                throw VoiceCaptureError.transcriptionFailed(reason: "WhisperKitの初期化に失敗しました")
            }
            
            // 進捗報告: 0% (開始)
            transcriptionProgress.send(0.0)
            
            // 音声ファイルをロード
            AppLogger.transcription.info("Loading audio file...")
            transcriptionProgress.send(0.2)
            
            // WhisperKitで文字起こし実行
            let transcriptionResult = try await whisperKit.transcribe(audioPath: audioURL.path)

            // 進捗報告: 90% (文字起こし完了)
            transcriptionProgress.send(0.9)

            // 結果を統合（v0.6.0以降は配列を返す）
            let transcribedText = transcriptionResult.first?.text ?? ""
            
            if transcribedText.isEmpty {
                throw VoiceCaptureError.transcriptionFailed(reason: "文字起こし結果が空です")
            }
            
            AppLogger.transcription.info("Transcription completed successfully")
            
            // 進捗報告: 100% (完了)
            transcriptionProgress.send(1.0)
            
            return transcribedText
            
        } catch let error as VoiceCaptureError {
            AppLogger.transcription.error("Transcription failed: \(error.localizedDescription)")
            throw error
        } catch {
            AppLogger.transcription.error("Transcription failed with unexpected error: \(error.localizedDescription)")
            throw VoiceCaptureError.transcriptionFailed(reason: error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    
    private func initializeWhisperKit() async throws {
        // 既に初期化済みの場合はスキップ
        if whisperKit != nil {
            AppLogger.transcription.info("WhisperKit already initialized")
            return
        }
        
        let modelName = getModelName()
        AppLogger.transcription.info("Initializing WhisperKit with model: \(modelName)")
        
        do {
            // WhisperKitを初期化
            whisperKit = try await WhisperKit(modelFolder: modelName)
            AppLogger.transcription.info("WhisperKit initialized successfully")
        } catch {
            AppLogger.transcription.error("Failed to initialize WhisperKit: \(error.localizedDescription)")
            throw VoiceCaptureError.transcriptionFailed(reason: "WhisperKitの初期化に失敗しました: \(error.localizedDescription)")
        }
    }
    
    private func getModelName() -> String {
        switch settingsManager.whisperModel {
        case .small:
            return "openai_whisper-small"
        case .medium:
            return "openai_whisper-medium"
        }
    }
}
