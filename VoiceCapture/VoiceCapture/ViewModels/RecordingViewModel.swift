//
//  RecordingViewModel.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation
import Combine
import AppKit

@MainActor
class RecordingViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var audioLevel: Float = 0
    @Published var errorMessage: String?
    @Published var lastRecordingURL: URL?
    @Published var lastTranscriptionURL: URL?

    // MARK: - Computed Properties

    var formattedTime: String {
        let minutes = Int(recordingTime) / 60
        let seconds = Int(recordingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Private Properties

    private let audioService: AudioRecordingServiceProtocol
    private let fileStorageService: FileStorageServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let transcriptionViewModel: TranscriptionViewModel

    private var timer: Timer?
    private var audioLevelCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(audioService: AudioRecordingServiceProtocol,
         fileStorageService: FileStorageServiceProtocol,
         notificationService: NotificationServiceProtocol,
         transcriptionViewModel: TranscriptionViewModel) {
        self.audioService = audioService
        self.fileStorageService = fileStorageService
        self.notificationService = notificationService
        self.transcriptionViewModel = transcriptionViewModel

        observeTranscriptionState()
    }

    // MARK: - Public Methods

    func toggleRecording() async {
        if isRecording {
            await stopRecording()
        } else {
            await startRecording()
        }
    }

    func openLastRecording() async {
        guard let url = lastRecordingURL else {
            showErrorAlert(
                title: "録音ファイルが見つかりません",
                message: "まだ録音を行っていないか、ファイルが削除されています。",
                suggestion: "新しい録音を開始してください。"
            )
            return
        }

        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
    }

    func openLastTranscription() async {
        guard let url = lastTranscriptionURL else {
            showErrorAlert(
                title: "文字起こしファイルが見つかりません",
                message: "まだ文字起こしを行っていないか、ファイルが削除されています。",
                suggestion: "録音を行い、自動文字起こしを有効にするか、手動で文字起こしを実行してください。"
            )
            return
        }

        NSWorkspace.shared.open(url)
    }

    // MARK: - Private Methods

    private func startRecording() async {
        do {
            try await audioService.startRecording()
            isRecording = true
            recordingTime = 0
            errorMessage = nil

            startTimer()
            startAudioLevelMonitoring()

            AppLogger.recording.info("Recording started")
        } catch {
            handleError(error)
        }
    }

    private func stopRecording() async {
        do {
            let audioURL = try await audioService.stopRecording()
            isRecording = false
            stopTimer()
            stopAudioLevelMonitoring()

            lastRecordingURL = audioURL

            // 通知送信
            await notificationService.sendRecordingComplete(fileName: audioURL.lastPathComponent)

            AppLogger.recording.info("Recording stopped: \(audioURL.lastPathComponent)")

            // 自動文字起こし
            if SettingsManager.shared.autoTranscribe {
                await transcriptionViewModel.startTranscription(audioURL: audioURL)
            }
        } catch {
            handleError(error)
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordingTime += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        recordingTime = 0
    }

    private func startAudioLevelMonitoring() {
        audioLevelCancellable = audioService.audioLevelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] level in
                self?.audioLevel = level
            }
    }

    private func stopAudioLevelMonitoring() {
        audioLevelCancellable?.cancel()
        audioLevel = 0
    }

    private func handleError(_ error: Error) {
        AppLogger.recording.error("Recording error: \(error.localizedDescription)")

        isRecording = false
        stopTimer()
        stopAudioLevelMonitoring()

        if let vcError = error as? VoiceCaptureError {
            errorMessage = vcError.localizedDescription
            showDetailedErrorAlert(for: vcError)
        } else {
            errorMessage = "録音エラーが発生しました"
            showErrorAlert(
                title: "録音エラー",
                message: error.localizedDescription,
                suggestion: "問題が解決しない場合は、アプリを再起動してください。"
            )
        }
    }

    private func showDetailedErrorAlert(for error: VoiceCaptureError) {
        let alert = NSAlert()
        alert.messageText = error.errorDescription ?? "エラーが発生しました"
        alert.informativeText = [error.failureReason, error.recoverySuggestion]
            .compactMap { $0 }
            .joined(separator: "\n\n")
        alert.alertStyle = .warning

        // パーミッションエラーの場合はシステム設定を開くボタンを追加
        if case .permissionDenied = error {
            alert.addButton(withTitle: "システム設定を開く")
            alert.addButton(withTitle: "キャンセル")

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                    NSWorkspace.shared.open(url)
                }
            }
        } else {
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }

    private func showErrorAlert(title: String, message: String, suggestion: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = "\(message)\n\n\(suggestion)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func observeTranscriptionState() {
        transcriptionViewModel.$lastTranscriptionURL
            .sink { [weak self] url in
                self?.lastTranscriptionURL = url
            }
            .store(in: &cancellables)
    }
}
