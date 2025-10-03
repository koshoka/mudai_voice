//
//  SettingsViewModel.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation
import Combine
import AppKit

@MainActor
class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var saveDirectory: URL
    @Published var autoTranscribe: Bool
    @Published var sampleRate: AudioSettings.SampleRate
    @Published var bitDepth: AudioSettings.BitDepth
    @Published var channels: AudioSettings.ChannelCount
    @Published var whisperModel: AudioSettings.WhisperModel
    @Published var selectedAudioDevice: AudioDevice

    // MARK: - Computed Properties

    var availableAudioDevices: [AudioDevice] {
        settingsManager.availableAudioDevices
    }

    // MARK: - Private Properties

    private let settingsManager = SettingsManager.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        // SettingsManagerから初期値読み込み
        self.saveDirectory = settingsManager.saveDirectory
        self.autoTranscribe = settingsManager.autoTranscribe
        self.sampleRate = settingsManager.audioSettings.sampleRate
        self.bitDepth = settingsManager.audioSettings.bitDepth
        self.channels = settingsManager.audioSettings.channels
        self.whisperModel = settingsManager.whisperModel
        self.selectedAudioDevice = settingsManager.selectedAudioDevice

        // 双方向バインディング
        setupBindings()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // 保存先ディレクトリの変更を監視
        $saveDirectory
            .sink { [weak self] newValue in
                self?.settingsManager.saveDirectory = newValue
            }
            .store(in: &cancellables)

        // 自動文字起こしの変更を監視
        $autoTranscribe
            .sink { [weak self] newValue in
                self?.settingsManager.autoTranscribe = newValue
            }
            .store(in: &cancellables)

        // 音声設定の変更を監視
        Publishers.CombineLatest3($sampleRate, $bitDepth, $channels)
            .sink { [weak self] rate, depth, channelCount in
                guard let self = self else { return }
                let newSettings = AudioSettings(
                    sampleRate: rate,
                    bitDepth: depth,
                    channels: channelCount,
                    whisperModel: self.whisperModel
                )
                self.settingsManager.audioSettings = newSettings
            }
            .store(in: &cancellables)

        // Whisperモデルの変更を監視
        $whisperModel
            .sink { [weak self] newValue in
                self?.settingsManager.whisperModel = newValue
            }
            .store(in: &cancellables)

        // オーディオデバイスの変更を監視
        $selectedAudioDevice
            .sink { [weak self] newValue in
                self?.settingsManager.selectedAudioDevice = newValue
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    /// 保存先ディレクトリを選択
    func selectSaveDirectory() {
        // LSUIElement=trueのメニューバーアプリでは、モーダルダイアログを表示する前に
        // アプリをアクティベートする必要がある
        NSApp.activate(ignoringOtherApps: true)

        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = "選択"
        panel.message = "録音ファイルの保存先を選択してください"
        panel.directoryURL = saveDirectory

        // メニューバーアプリでも正しく表示されるようレベルを設定
        panel.level = .modalPanel

        if panel.runModal() == .OK {
            if let url = panel.url {
                saveDirectory = url
                AppLogger.settings.info("Save directory changed to: \(url.path)")
            }
        }
    }

    /// 設定をデフォルトにリセット
    func resetToDefaults() {
        settingsManager.resetToDefaults()

        // UIを更新
        saveDirectory = settingsManager.saveDirectory
        autoTranscribe = settingsManager.autoTranscribe
        sampleRate = settingsManager.audioSettings.sampleRate
        bitDepth = settingsManager.audioSettings.bitDepth
        channels = settingsManager.audioSettings.channels
        whisperModel = settingsManager.whisperModel
        selectedAudioDevice = settingsManager.selectedAudioDevice

        AppLogger.settings.info("Settings reset to defaults")
    }
}
