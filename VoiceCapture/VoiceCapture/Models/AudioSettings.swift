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
        whisperModel: .medium
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
        case small
        case medium

        var displayName: String {
            switch self {
            case .small: return "Small (軽量・高速)"
            case .medium: return "Medium (高精度)"
            }
        }
    }
}
