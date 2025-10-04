//
//  NotificationServiceProtocol.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation

protocol NotificationServiceProtocol {
    func sendRecordingComplete(fileName: String) async
    func sendTranscriptionComplete(fileName: String) async
    func sendTranscriptionProgress(fileName: String, progress: Float) async
    func sendError(message: String) async
}
