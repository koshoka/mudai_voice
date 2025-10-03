//
//  Recording.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation

struct Recording: Identifiable {
    let id: UUID
    let fileName: String
    let createdAt: Date
    let duration: TimeInterval
    let fileURL: URL
    let transcriptionURL: URL?
    let transcriptionStatus: TranscriptionStatus
}

enum TranscriptionStatus {
    case pending
    case inProgress
    case completed
    case failed
}
