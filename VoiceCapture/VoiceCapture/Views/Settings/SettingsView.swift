//
//  SettingsView.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import SwiftUI
// TODO: KeyboardShortcuts SPM追加後にコメント解除
import KeyboardShortcuts

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            // 保存先設定
            Section("保存先") {
                HStack {
                    Text(viewModel.saveDirectory.path)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("変更...") {
                        viewModel.selectSaveDirectory()
                    }
                }
            }

            // 録音デバイス設定
            Section("録音デバイス") {
                Picker("マイク", selection: $viewModel.selectedAudioDevice) {
                    ForEach(viewModel.availableAudioDevices) { device in
                        Text(device.displayName).tag(device)
                    }
                }
                .help("録音に使用するマイクを選択します")
            }

            // ホットキー設定
            // TODO: KeyboardShortcuts SPM追加後にコメント解除

            Section("ホットキー") {
                KeyboardShortcuts.Recorder(
                    "録音開始/停止:",
                    name: .toggleRecording
                )
            }


            // 音声品質設定
            Section("音声品質") {
                Picker("サンプルレート", selection: $viewModel.sampleRate) {
                    ForEach(AudioSettings.SampleRate.allCases, id: \.self) { rate in
                        Text(rate.displayName).tag(rate)
                    }
                }

                Picker("ビット深度", selection: $viewModel.bitDepth) {
                    ForEach(AudioSettings.BitDepth.allCases, id: \.self) { depth in
                        Text(depth.displayName).tag(depth)
                    }
                }

                Picker("チャンネル", selection: $viewModel.channels) {
                    ForEach(AudioSettings.ChannelCount.allCases, id: \.self) { channel in
                        Text(channel.displayName).tag(channel)
                    }
                }
            }

            // 文字起こし設定
            Section("文字起こし") {
                Toggle("自動文字起こし", isOn: $viewModel.autoTranscribe)
                    .help("録音停止後、自動的に文字起こしを開始します")

                Picker("Whisperモデル", selection: $viewModel.whisperModel) {
                    ForEach(AudioSettings.WhisperModel.allCases, id: \.self) { model in
                        Text(model.displayName).tag(model)
                    }
                }
                .help("文字起こしの精度と速度のバランスを選択します")
            }

            // リセットボタン
            Section {
                HStack {
                    Spacer()
                    Button("デフォルトに戻す") {
                        viewModel.resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .padding()
    }
}

// MARK: - Preview

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}
