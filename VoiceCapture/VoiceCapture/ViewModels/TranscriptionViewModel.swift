//
//  TranscriptionViewModel.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation
import Combine

@MainActor
class TranscriptionViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var progress: Float = 0.0
    @Published var status: TranscriptionStatus = .idle
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let transcriptionService: TranscriptionServiceProtocol
    private let fileStorageService: FileStorageServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Nested Types
    
    enum TranscriptionStatus {
        case idle
        case transcribing
        case completed
        case failed
    }
    
    // MARK: - Initialization
    
    init(transcriptionService: TranscriptionServiceProtocol,
         fileStorageService: FileStorageServiceProtocol,
         notificationService: NotificationServiceProtocol) {
        self.transcriptionService = transcriptionService
        self.fileStorageService = fileStorageService
        self.notificationService = notificationService
        
        setupProgressObserver()
    }
    
    // MARK: - Public Methods
    
    func startTranscription(audioURL: URL) async {
        guard status != .transcribing else {
            AppLogger.transcription.warning("Transcription already in progress")
            return
        }
        
        status = .transcribing
        progress = 0.0
        errorMessage = nil
        
        AppLogger.transcription.info("Starting transcription for: \(audioURL.lastPathComponent)")
        
        do {
            // 文字起こし実行
            let transcribedText = try await transcriptionService.transcribe(audioURL: audioURL)
            
            // Markdownファイルとして保存
            let markdownURL = try await fileStorageService.saveMarkdown(text: transcribedText, audioURL: audioURL)
            
            status = .completed
            progress = 1.0
            
            AppLogger.transcription.info("Transcription completed and saved: \(markdownURL.lastPathComponent)")
            
            // 完了通知を送信
            await notificationService.sendTranscriptionComplete(fileName: markdownURL.lastPathComponent)
            
        } catch let error as VoiceCaptureError {
            handleError(error)
        } catch {
            handleError(VoiceCaptureError.transcriptionFailed(reason: error.localizedDescription))
        }
    }
    
    func cancelTranscription() {
        // TODO: キャンセル機能の実装（必要に応じて）
        status = .idle
        progress = 0.0
        AppLogger.transcription.info("Transcription cancelled")
    }
    
    // MARK: - Private Methods
    
    private func setupProgressObserver() {
        transcriptionService.transcriptionProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.progress = progress
            }
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: VoiceCaptureError) {
        status = .failed
        errorMessage = error.localizedDescription
        progress = 0.0
        
        AppLogger.transcription.error("Transcription error: \(error.localizedDescription)")
        
        Task {
            await notificationService.sendError(message: "文字起こし失敗: \(error.localizedDescription)")
        }
    }
}
