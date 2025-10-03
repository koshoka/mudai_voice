//
//  VoiceCaptureApp.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import SwiftUI

@main
struct VoiceCaptureApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
