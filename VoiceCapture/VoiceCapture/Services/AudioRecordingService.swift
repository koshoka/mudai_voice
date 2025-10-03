//
//  AudioRecordingService.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import AVFoundation
import Combine

class AudioRecordingService: NSObject, AudioRecordingServiceProtocol {
    // MARK: - Properties

    private var audioRecorder: AVAudioRecorder?
    private var currentRecordingURL: URL?

    private let audioLevelSubject = PassthroughSubject<Float, Never>()
    var audioLevelPublisher: AnyPublisher<Float, Never> {
        audioLevelSubject.eraseToAnyPublisher()
    }

    private var levelTimer: Timer?

    // MARK: - AudioRecordingServiceProtocol

    func startRecording() async throws {
        // 録音設定
        let settings = buildRecordingSettings()

        // ファイルURL生成
        let fileName = generateFileName()
        let saveDirectory = SettingsManager.shared.saveDirectory

        // ディレクトリ作成
        try FileManager.default.createDirectory(at: saveDirectory, withIntermediateDirectories: true)

        let audioURL = saveDirectory.appendingPathComponent(fileName)
        currentRecordingURL = audioURL

        // AVAudioRecorder初期化
        audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true

        // 録音開始
        guard audioRecorder?.record() == true else {
            throw VoiceCaptureError.recordingFailed(underlying: NSError(domain: "VoiceCapture", code: -1))
        }

        // 音量レベルモニタリング開始
        startLevelMonitoring()

        AppLogger.recording.info("Recording started: \(fileName)")
    }

    func stopRecording() async throws -> URL {
        guard let recorder = audioRecorder, let url = currentRecordingURL else {
            throw VoiceCaptureError.recordingFailed(underlying: NSError(domain: "VoiceCapture", code: -2))
        }

        recorder.stop()
        stopLevelMonitoring()

        audioRecorder = nil
        currentRecordingURL = nil

        AppLogger.recording.info("Recording stopped: \(url.lastPathComponent)")

        return url
    }

    // MARK: - Private Methods

    private func buildRecordingSettings() -> [String: Any] {
        let settings = SettingsManager.shared.audioSettings

        return [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: settings.sampleRate,
            AVNumberOfChannelsKey: settings.channels,
            AVLinearPCMBitDepthKey: settings.bitDepth,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }

    private func generateFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return "\(formatter.string(from: Date())).wav"
    }

    private func startLevelMonitoring() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateAudioLevel()
        }
    }

    private func stopLevelMonitoring() {
        levelTimer?.invalidate()
        levelTimer = nil
        audioLevelSubject.send(0)
    }

    private func updateAudioLevel() {
        guard let recorder = audioRecorder else { return }

        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0)

        // デシベルを0-1の範囲に正規化
        // -160dB（無音）〜 0dB（最大）
        let normalized = pow(10, averagePower / 20)
        audioLevelSubject.send(normalized)
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecordingService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            AppLogger.recording.error("Recording finished unsuccessfully")
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            AppLogger.recording.error("Encoding error: \(error.localizedDescription)")
        }
    }
}
