//
//  AudioSettings.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation

struct AudioSettings: Codable {
    let sampleRate: Double
    let bitDepth: Int
    let channels: Int

    static let `default` = AudioSettings(
        sampleRate: 44100.0,
        bitDepth: 16,
        channels: 1
    )
}
