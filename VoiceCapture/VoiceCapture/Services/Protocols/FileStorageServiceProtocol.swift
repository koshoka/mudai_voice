//
//  FileStorageServiceProtocol.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation

protocol FileStorageServiceProtocol {
    func saveMarkdown(text: String, audioURL: URL) async throws -> URL
    func getRecentRecordings(limit: Int) async throws -> [Recording]
    func deleteRecording(_ recording: Recording) async throws
}
