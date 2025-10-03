//
//  TranscriptionViewModel.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation

@MainActor
class TranscriptionViewModel: ObservableObject {
    init(transcriptionService: TranscriptionServiceProtocol,
         fileStorageService: FileStorageServiceProtocol,
         notificationService: NotificationServiceProtocol) {
        // TODO: Phase 3で実装
    }

    func startTranscription(audioURL: URL) async {
        // TODO: Phase 3で実装
        print("Transcription will be implemented in Phase 3")
    }
}

protocol TranscriptionServiceProtocol {
    // TODO: Phase 3で実装
}

class TranscriptionService: TranscriptionServiceProtocol {
    // TODO: Phase 3で実装
}
