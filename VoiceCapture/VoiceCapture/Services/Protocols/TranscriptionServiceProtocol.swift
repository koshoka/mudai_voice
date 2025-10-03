//
//  TranscriptionServiceProtocol.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation
import Combine

protocol TranscriptionServiceProtocol {
    /// 音声ファイルを文字起こしする
    func transcribe(audioURL: URL) async throws -> String
    
    /// 文字起こしの進捗を通知するPublisher
    var transcriptionProgress: PassthroughSubject<Float, Never> { get }
}
