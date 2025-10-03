//
//  PermissionsManager.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import AVFoundation

class PermissionsManager {
    static let shared = PermissionsManager()

    private init() {}

    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        // macOS 12.0以降で動作するようにAVCaptureDeviceを使用
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            completion(granted)
        }
    }

    func checkMicrophonePermission() -> Bool {
        // macOS 12.0以降で動作するようにAVCaptureDeviceを使用
        return AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }
}
