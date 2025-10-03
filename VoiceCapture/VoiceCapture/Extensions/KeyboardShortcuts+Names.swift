//
//  KeyboardShortcuts+Names.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

// TODO: KeyboardShortcuts SPM追加後にコメント解除

import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleRecording = Self(
        "toggleRecording",
        default: .init(.p, modifiers: [.option])
    )
}

