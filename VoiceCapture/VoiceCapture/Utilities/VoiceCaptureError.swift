//
//  VoiceCaptureError.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation

enum VoiceCaptureError: LocalizedError {
    case recordingFailed(underlying: Error)
    case permissionDenied
    case fileOperationFailed(underlying: Error)
    case transcriptionFailed(reason: String)

    var errorDescription: String? {
        switch self {
        case .recordingFailed:
            return "録音に失敗しました"
        case .permissionDenied:
            return "マイクへのアクセスが許可されていません"
        case .fileOperationFailed:
            return "ファイル操作に失敗しました"
        case .transcriptionFailed(let reason):
            return "文字起こしに失敗しました: \(reason)"
        }
    }
}
