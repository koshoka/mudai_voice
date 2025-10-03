//
//  SettingsManager.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    // MARK: - Published Properties

    @Published var saveDirectory: URL {
        didSet {
            UserDefaults.standard.set(saveDirectory, forKey: Keys.saveDirectory)
        }
    }

    @Published var autoTranscribe: Bool {
        didSet {
            UserDefaults.standard.set(autoTranscribe, forKey: Keys.autoTranscribe)
        }
    }

    @Published var audioSettings: AudioSettings {
        didSet {
            if let encoded = try? JSONEncoder().encode(audioSettings) {
                UserDefaults.standard.set(encoded, forKey: Keys.audioSettings)
            }
        }
    }

    // MARK: - Private Keys

    private enum Keys {
        static let saveDirectory = "saveDirectory"
        static let autoTranscribe = "autoTranscribe"
        static let audioSettings = "audioSettings"
    }

    // MARK: - Initialization

    private init() {
        // デフォルト保存先
        let defaultDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("VoiceCapture")

        // UserDefaultsから読み込み
        self.saveDirectory = UserDefaults.standard.url(forKey: Keys.saveDirectory) ?? defaultDirectory

        // autoTranscribeのデフォルト値の処理
        if UserDefaults.standard.object(forKey: Keys.autoTranscribe) != nil {
            self.autoTranscribe = UserDefaults.standard.bool(forKey: Keys.autoTranscribe)
        } else {
            self.autoTranscribe = true // 初回はデフォルトtrue
            UserDefaults.standard.set(true, forKey: Keys.autoTranscribe)
        }

        if let data = UserDefaults.standard.data(forKey: Keys.audioSettings),
           let settings = try? JSONDecoder().decode(AudioSettings.self, from: data) {
            self.audioSettings = settings
        } else {
            self.audioSettings = AudioSettings.default
        }
    }

    // MARK: - Methods

    func resetToDefaults() {
        let defaultDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("VoiceCapture")

        saveDirectory = defaultDirectory
        autoTranscribe = true
        audioSettings = AudioSettings.default
    }
}
