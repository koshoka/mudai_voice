//
//  AppLogger.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import OSLog

struct AppLogger {
    static let recording = Logger(subsystem: "com.yourdomain.VoiceCapture", category: "Recording")
    static let fileSystem = Logger(subsystem: "com.yourdomain.VoiceCapture", category: "FileSystem")
    static let transcription = Logger(subsystem: "com.yourdomain.VoiceCapture", category: "Transcription")
    static let settings = Logger(subsystem: "com.yourdomain.VoiceCapture", category: "Settings")
    static let modelDownload = Logger(subsystem: "com.yourdomain.VoiceCapture", category: "ModelDownload")
}
