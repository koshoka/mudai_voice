//
//  AudioDevice.swift
//  VoiceCapture
//
//  Created on 2025-10-04.
//

import Foundation
import AVFoundation

/// オーディオ入力デバイス（マイク）を表す構造体
struct AudioDevice: Identifiable, Codable, Hashable {
    let id: String
    let name: String

    var displayName: String {
        name
    }

    /// デフォルトの入力デバイス
    static var `default`: AudioDevice {
        AudioDevice(id: "default", name: "システムデフォルト")
    }
}

// MARK: - Audio Device Discovery

extension AudioDevice {
    /// 利用可能なオーディオ入力デバイスを取得
    static func availableDevices() -> [AudioDevice] {
        var devices: [AudioDevice] = [.default]

        #if os(macOS)
        // macOSでAVCaptureDeviceを使用してマイクデバイスを列挙
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.microphone, .external],
            mediaType: .audio,
            position: .unspecified
        )

        for device in discoverySession.devices {
            devices.append(AudioDevice(
                id: device.uniqueID,
                name: device.localizedName
            ))
        }
        #endif

        return devices
    }
}
