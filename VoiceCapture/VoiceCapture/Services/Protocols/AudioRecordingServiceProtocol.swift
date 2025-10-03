//
//  AudioRecordingServiceProtocol.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation
import Combine

protocol AudioRecordingServiceProtocol {
    var audioLevelPublisher: AnyPublisher<Float, Never> { get }
    func startRecording() async throws
    func stopRecording() async throws -> URL
}
