//
//  FileStorageService.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation

class FileStorageService: FileStorageServiceProtocol {
    // MARK: - FileStorageServiceProtocol

    func saveMarkdown(text: String, audioURL: URL) async throws -> URL {
        let markdownContent = generateMarkdown(text: text, audioURL: audioURL)
        let markdownURL = audioURL.deletingPathExtension().appendingPathExtension("md")

        try markdownContent.write(to: markdownURL, atomically: true, encoding: .utf8)

        AppLogger.fileSystem.info("Markdown saved: \(markdownURL.lastPathComponent)")

        return markdownURL
    }

    func getRecentRecordings(limit: Int = 10) async throws -> [Recording] {
        let saveDirectory = SettingsManager.shared.saveDirectory

        guard FileManager.default.fileExists(atPath: saveDirectory.path) else {
            return []
        }

        let contents = try FileManager.default.contentsOfDirectory(
            at: saveDirectory,
            includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        )

        let wavFiles = contents.filter { $0.pathExtension == "wav" }

        let recordings: [Recording] = try wavFiles.compactMap { url in
            let attributes = try url.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])

            guard let createdAt = attributes.creationDate else { return nil }

            let transcriptionURL = url.deletingPathExtension().appendingPathExtension("md")
            let hasTranscription = FileManager.default.fileExists(atPath: transcriptionURL.path)

            return Recording(
                id: UUID(),
                fileName: url.lastPathComponent,
                createdAt: createdAt,
                duration: 0, // AVAssetから取得する場合は別途実装
                fileURL: url,
                transcriptionURL: hasTranscription ? transcriptionURL : nil,
                transcriptionStatus: hasTranscription ? .completed : .pending
            )
        }

        return recordings
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(limit)
            .map { $0 }
    }

    func deleteRecording(_ recording: Recording) async throws {
        try FileManager.default.removeItem(at: recording.fileURL)

        if let transcriptionURL = recording.transcriptionURL {
            try? FileManager.default.removeItem(at: transcriptionURL)
        }

        AppLogger.fileSystem.info("Recording deleted: \(recording.fileName)")
    }

    // MARK: - Private Methods

    private func generateMarkdown(text: String, audioURL: URL) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        let dateString = formatter.string(from: Date())

        let fileName = audioURL.lastPathComponent

        return """
        # 録音 \(dateString)

        **録音日時**: \(dateString)
        **ファイル名**: \(fileName)

        ---

        \(text)
        """
    }
}
