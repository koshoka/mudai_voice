//
//  AudioSettings.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation

struct AudioSettings: Codable, Equatable {
    var sampleRate: SampleRate
    var bitDepth: BitDepth
    var channels: ChannelCount
    var whisperModel: WhisperModel

    static let `default` = AudioSettings(
        sampleRate: .rate44_1kHz,
        bitDepth: .bit16,
        channels: .mono,
        whisperModel: .distilLargeV3
    )

    // AVFoundation用の変換プロパティ
    var sampleRateValue: Double { sampleRate.rawValue }
    var bitDepthValue: Int { bitDepth.rawValue }
    var channelCountValue: Int { channels.rawValue }

    // MARK: - Nested Types

    enum SampleRate: Double, CaseIterable, Codable {
        case rate44_1kHz = 44100.0
        case rate48kHz = 48000.0

        var displayName: String {
            switch self {
            case .rate44_1kHz: return "44.1 kHz"
            case .rate48kHz: return "48 kHz"
            }
        }
    }

    enum BitDepth: Int, CaseIterable, Codable {
        case bit16 = 16
        case bit24 = 24

        var displayName: String {
            switch self {
            case .bit16: return "16-bit"
            case .bit24: return "24-bit"
            }
        }
    }

    enum ChannelCount: Int, CaseIterable, Codable {
        case mono = 1
        case stereo = 2

        var displayName: String {
            switch self {
            case .mono: return "モノラル"
            case .stereo: return "ステレオ"
            }
        }
    }

    enum WhisperModel: String, Codable, CaseIterable {
        // WhisperKitの推奨する短い形式のモデル名を使用
        // これにより、HuggingFaceリポジトリでの曖昧性エラーを回避
        case small = "small"
        case medium = "medium"
        case distilLargeV3 = "distil-large-v3"
        case largeV3 = "large-v3"

        var displayName: String {
            switch self {
            case .small: return "Small (216MB・軽量)"
            case .medium: return "Medium (500MB・標準)"
            case .distilLargeV3: return "Distil Large-v3 (594MB・高精度・推奨)"
            case .largeV3: return "Large-v3 (947MB・最高精度)"
            }
        }

        /// ユーザー表示用の簡潔な名前
        var shortName: String {
            switch self {
            case .small: return "small"
            case .medium: return "medium"
            case .distilLargeV3: return "distil-large-v3"
            case .largeV3: return "large-v3"
            }
        }
    }
}
