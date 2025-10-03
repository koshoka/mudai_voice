//
//  NotificationService.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation
import UserNotifications
import AppKit

class NotificationService: NSObject, NotificationServiceProtocol {
    // MARK: - Initialization

    override init() {
        super.init()
        requestAuthorization()
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

    // MARK: - NotificationServiceProtocol

    func sendRecordingComplete(fileName: String) async {
        let content = UNMutableNotificationContent()
        content.title = "録音完了"
        content.body = "ファイル: \(fileName)"
        content.sound = .default
        content.userInfo = ["type": "recording", "fileName": fileName]

        // アクション追加
        let openAction = UNNotificationAction(
            identifier: "OPEN_FILE",
            title: "Finderで開く",
            options: .foreground
        )

        let category = UNNotificationCategory(
            identifier: "RECORDING_COMPLETE",
            actions: [openAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "RECORDING_COMPLETE"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            AppLogger.recording.error("Failed to send notification: \(error.localizedDescription)")
        }
    }

    func sendTranscriptionComplete(fileName: String) async {
        let content = UNMutableNotificationContent()
        content.title = "文字起こし完了"
        content.body = "ファイル: \(fileName)"
        content.sound = .default
        content.userInfo = ["type": "transcription", "fileName": fileName]

        let openAction = UNNotificationAction(
            identifier: "OPEN_FILE",
            title: "ファイルを開く",
            options: .foreground
        )

        let category = UNNotificationCategory(
            identifier: "TRANSCRIPTION_COMPLETE",
            actions: [openAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "TRANSCRIPTION_COMPLETE"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            AppLogger.transcription.error("Failed to send notification: \(error.localizedDescription)")
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
        case "OPEN_FILE":
            if let fileName = userInfo["fileName"] as? String {
                openFile(fileName: fileName, type: userInfo["type"] as? String ?? "")
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

    private func openFile(fileName: String, type: String) {
        let saveDirectory = SettingsManager.shared.saveDirectory
        let fileURL = saveDirectory.appendingPathComponent(fileName)

        if type == "transcription" {
            NSWorkspace.shared.open(fileURL)
        } else {
            NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: saveDirectory.path)
        }
    }
}
