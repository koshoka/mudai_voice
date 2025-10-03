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

    // MARK: - Initialization

    init(audioService: AudioRecordingServiceProtocol,
         fileStorageService: FileStorageServiceProtocol,
         notificationService: NotificationServiceProtocol,
         transcriptionViewModel: TranscriptionViewModel) {
        self.audioService = audioService
        self.fileStorageService = fileStorageService
        self.notificationService = notificationService
        self.transcriptionViewModel = transcriptionViewModel
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
            errorMessage = "録音ファイルが見つかりません"
            return
        }

        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
    }

    func openLastTranscription() async {
        guard let url = lastTranscriptionURL else {
            errorMessage = "文字起こしファイルが見つかりません"
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

        if let vcError = error as? VoiceCaptureError {
            errorMessage = vcError.localizedDescription
        } else {
            errorMessage = "録音エラーが発生しました"
        }

        isRecording = false
        stopTimer()
        stopAudioLevelMonitoring()
    }
}
