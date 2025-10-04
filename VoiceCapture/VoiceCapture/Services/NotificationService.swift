//
//  NotificationService.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation
import UserNotifications
import AppKit
import AVFoundation

class NotificationService: NSObject, NotificationServiceProtocol {
    // MARK: - Initialization

    override init() {
        super.init()
        requestAuthorization()
        setupNotificationCategories()
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - Authorization

    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                AppLogger.recording.error("Notification authorization error: \(error.localizedDescription)")
            }

            AppLogger.recording.info("Notification authorization: \(granted)")
        }
    }

    // MARK: - Notification Categories Setup

    private func setupNotificationCategories() {
        let recordingCategory = createRecordingCompleteCategory()
        let transcriptionCategory = createTranscriptionCompleteCategory()

        UNUserNotificationCenter.current().setNotificationCategories([
            recordingCategory,
            transcriptionCategory
        ])
    }

    private func createRecordingCompleteCategory() -> UNNotificationCategory {
        let openInFinderAction = UNNotificationAction(
            identifier: "OPEN_IN_FINDER",
            title: "Finderで開く",
            options: .foreground
        )

        let deleteAction = UNNotificationAction(
            identifier: "DELETE_RECORDING",
            title: "削除",
            options: [.destructive]
        )

        return UNNotificationCategory(
            identifier: "RECORDING_COMPLETE",
            actions: [openInFinderAction, deleteAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
    }

    private func createTranscriptionCompleteCategory() -> UNNotificationCategory {
        let openFileAction = UNNotificationAction(
            identifier: "OPEN_TRANSCRIPTION",
            title: "ファイルを開く",
            options: .foreground
        )

        let openInFinderAction = UNNotificationAction(
            identifier: "OPEN_IN_FINDER",
            title: "Finderで表示",
            options: .foreground
        )

        let deleteAction = UNNotificationAction(
            identifier: "DELETE_TRANSCRIPTION",
            title: "削除",
            options: [.destructive]
        )

        return UNNotificationCategory(
            identifier: "TRANSCRIPTION_COMPLETE",
            actions: [openFileAction, openInFinderAction, deleteAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
    }

    // MARK: - NotificationServiceProtocol

    func sendRecordingComplete(fileName: String) async {
        let fileURL = SettingsManager.shared.saveDirectory.appendingPathComponent(fileName)
        let fileInfo = await getFileInfo(at: fileURL)

        let content = UNMutableNotificationContent()
        content.title = "録音完了"
        content.body = formatRecordingNotificationBody(fileName: fileName, fileInfo: fileInfo)
        content.sound = .default
        content.userInfo = [
            "type": "recording",
            "fileName": fileName,
            "filePath": fileURL.path
        ]
        content.categoryIdentifier = "RECORDING_COMPLETE"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            AppLogger.recording.info("Recording complete notification sent: \(fileName)")
        } catch {
            AppLogger.recording.error("Failed to send notification: \(error.localizedDescription)")
        }
    }

    func sendTranscriptionComplete(fileName: String) async {
        let fileURL = SettingsManager.shared.saveDirectory.appendingPathComponent(fileName)
        let fileInfo = await getFileInfo(at: fileURL)

        let content = UNMutableNotificationContent()
        content.title = "文字起こし完了"
        content.body = formatTranscriptionNotificationBody(fileName: fileName, fileInfo: fileInfo)
        content.sound = .default
        content.userInfo = [
            "type": "transcription",
            "fileName": fileName,
            "filePath": fileURL.path
        ]
        content.categoryIdentifier = "TRANSCRIPTION_COMPLETE"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            AppLogger.transcription.info("Transcription complete notification sent: \(fileName)")
        } catch {
            AppLogger.transcription.error("Failed to send notification: \(error.localizedDescription)")
        }
    }

    func sendTranscriptionProgress(fileName: String, progress: Float) async {
        let percentage = Int(progress * 100)

        // 進捗バーの視覚化（20個のブロック）
        let totalBars = 20
        let filledBars = Int(Float(totalBars) * progress)
        let progressBar = String(repeating: "▓", count: filledBars) +
                          String(repeating: "░", count: totalBars - filledBars)

        let content = UNMutableNotificationContent()
        content.title = "文字起こし中"
        content.body = """
        \(fileName)
        \(progressBar) \(percentage)%
        """
        content.interruptionLevel = .active
        // 音は設定しない（進捗通知は無音）

        // 固定IDを使用して通知を更新（複数の通知が表示されないようにする）
        let request = UNNotificationRequest(
            identifier: "transcription-progress",
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            AppLogger.transcription.debug("Transcription progress notification updated: \(percentage)%")
        } catch {
            AppLogger.transcription.error("Failed to send progress notification: \(error.localizedDescription)")
        }
    }

    func sendError(message: String) async {
        let content = UNMutableNotificationContent()
        content.title = "エラー"
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            AppLogger.recording.error("Failed to send error notification: \(error.localizedDescription)")
        }
    }

    // MARK: - Helper Methods

    private func getFileInfo(at url: URL) async -> FileInfo {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return FileInfo(size: nil, duration: nil, creationDate: nil)
        }

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let size = attributes[.size] as? Int64
            let creationDate = attributes[.creationDate] as? Date

            // 音声ファイルの場合、時間情報を取得
            var duration: TimeInterval?
            if url.pathExtension == "m4a" || url.pathExtension == "wav" || url.pathExtension == "mp3" {
                duration = await getAudioDuration(at: url)
            }

            return FileInfo(size: size, duration: duration, creationDate: creationDate)
        } catch {
            AppLogger.recording.error("Failed to get file info: \(error.localizedDescription)")
            return FileInfo(size: nil, duration: nil, creationDate: nil)
        }
    }

    private func getAudioDuration(at url: URL) async -> TimeInterval? {
        // AVFoundationを使用して音声ファイルの長さを取得
        let asset = AVURLAsset(url: url)

        do {
            // macOS 13.0+の推奨APIを使用（非同期）
            let duration = try await asset.load(.duration)
            guard duration.isValid && !duration.isIndefinite else {
                return nil
            }
            return CMTimeGetSeconds(duration)
        } catch {
            AppLogger.recording.error("Failed to get audio duration: \(error.localizedDescription)")
            return nil
        }
    }

    private func formatRecordingNotificationBody(fileName: String, fileInfo: FileInfo) -> String {
        var parts: [String] = []

        if let duration = fileInfo.duration {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            parts.append("録音時間: \(String(format: "%d:%02d", minutes, seconds))")
        }

        if let size = fileInfo.size {
            parts.append("サイズ: \(formatFileSize(size))")
        }

        if parts.isEmpty {
            return "ファイル: \(fileName)"
        } else {
            return parts.joined(separator: " | ")
        }
    }

    private func formatTranscriptionNotificationBody(fileName: String, fileInfo: FileInfo) -> String {
        var parts: [String] = []

        if let size = fileInfo.size {
            // テキストファイルの場合、文字数を推定
            let estimatedCharacters = size / 3 // 1文字あたり約3バイトと仮定
            parts.append("約\(estimatedCharacters)文字")
        }

        parts.append("ファイル: \(fileName)")

        return parts.joined(separator: " | ")
    }

    private func formatFileSize(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    // MARK: - Nested Types

    private struct FileInfo {
        let size: Int64?
        let duration: TimeInterval?
        let creationDate: Date?
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        switch response.actionIdentifier {
        case "OPEN_IN_FINDER":
            if let filePath = userInfo["filePath"] as? String {
                let fileURL = URL(fileURLWithPath: filePath)
                NSWorkspace.shared.selectFile(
                    fileURL.path,
                    inFileViewerRootedAtPath: fileURL.deletingLastPathComponent().path
                )
            }

        case "OPEN_TRANSCRIPTION":
            if let filePath = userInfo["filePath"] as? String {
                let fileURL = URL(fileURLWithPath: filePath)
                NSWorkspace.shared.open(fileURL)
            }

        case "DELETE_RECORDING", "DELETE_TRANSCRIPTION":
            if let filePath = userInfo["filePath"] as? String {
                deleteFile(at: filePath)
            }

        case UNNotificationDefaultActionIdentifier:
            // 通知をクリックした場合のデフォルト動作
            if let filePath = userInfo["filePath"] as? String,
               let type = userInfo["type"] as? String {
                let fileURL = URL(fileURLWithPath: filePath)

                if type == "transcription" {
                    NSWorkspace.shared.open(fileURL)
                } else {
                    NSWorkspace.shared.selectFile(
                        fileURL.path,
                        inFileViewerRootedAtPath: fileURL.deletingLastPathComponent().path
                    )
                }
            }

        default:
            break
        }

        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    private func deleteFile(at path: String) {
        let fileURL = URL(fileURLWithPath: path)

        // 削除確認アラート
        let alert = NSAlert()
        alert.messageText = "ファイルを削除しますか？"
        alert.informativeText = "「\(fileURL.lastPathComponent)」を削除します。この操作は取り消せません。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "削除")
        alert.addButton(withTitle: "キャンセル")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            do {
                try FileManager.default.removeItem(at: fileURL)
                AppLogger.recording.info("File deleted: \(fileURL.lastPathComponent)")

                // 削除成功の通知
                Task {
                    await sendDeletionConfirmation(fileName: fileURL.lastPathComponent)
                }
            } catch {
                AppLogger.recording.error("Failed to delete file: \(error.localizedDescription)")

                // 削除失敗のアラート
                let errorAlert = NSAlert()
                errorAlert.messageText = "削除に失敗しました"
                errorAlert.informativeText = error.localizedDescription
                errorAlert.alertStyle = .critical
                errorAlert.runModal()
            }
        }
    }

    private func sendDeletionConfirmation(fileName: String) async {
        let content = UNMutableNotificationContent()
        content.title = "ファイル削除完了"
        content.body = "「\(fileName)」を削除しました"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            AppLogger.recording.error("Failed to send deletion confirmation: \(error.localizedDescription)")
        }
    }
}
