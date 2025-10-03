//
//  AppDelegate.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties

    private var statusItem: NSStatusItem?

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
    }

    // MARK: - Setup

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else {
            fatalError("Failed to create status bar button")
        }

        // アイコン設定
        button.image = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "VoiceCapture")
        button.image?.isTemplate = true

        // メニュー構築
        setupMenu()
    }

    private func setupMenu() {
        let menu = NSMenu()

        // 録音開始/停止
        let recordingItem = NSMenuItem(
            title: "録音開始",
            action: #selector(toggleRecording),
            keyEquivalent: ""
        )
        recordingItem.target = self
        menu.addItem(recordingItem)

        menu.addItem(NSMenuItem.separator())

        // 最後の録音を開く
        let openLastRecordingItem = NSMenuItem(
            title: "最後の録音を開く",
            action: #selector(openLastRecording),
            keyEquivalent: ""
        )
        openLastRecordingItem.target = self
        menu.addItem(openLastRecordingItem)

        // 最後の文字起こしを開く
        let openLastTranscriptionItem = NSMenuItem(
            title: "最後の文字起こしを開く",
            action: #selector(openLastTranscription),
            keyEquivalent: ""
        )
        openLastTranscriptionItem.target = self
        menu.addItem(openLastTranscriptionItem)

        menu.addItem(NSMenuItem.separator())

        // 設定
        let settingsItem = NSMenuItem(
            title: "設定...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        // VoiceCaptureについて
        let aboutItem = NSMenuItem(
            title: "VoiceCaptureについて",
            action: #selector(showAbout),
            keyEquivalent: ""
        )
        aboutItem.target = self
        menu.addItem(aboutItem)

        menu.addItem(NSMenuItem.separator())

        // 終了
        let quitItem = NSMenuItem(
            title: "終了",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    // MARK: - Actions

    @objc private func toggleRecording() {
        // TODO: 録音機能の実装
        print("録音開始/停止がクリックされました")
    }

    @objc private func openLastRecording() {
        // TODO: 最後の録音を開く機能の実装
        print("最後の録音を開くがクリックされました")
    }

    @objc private func openLastTranscription() {
        // TODO: 最後の文字起こしを開く機能の実装
        print("最後の文字起こしを開くがクリックされました")
    }

    @objc private func openSettings() {
        // TODO: 設定画面の実装
        print("設定がクリックされました")
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "VoiceCapture"
        alert.informativeText = "Version 1.0.0\n\n録音の不安をゼロに、思考を音声で即座に記録し、自動で文字起こしして整理するmacOSアプリ。"
        alert.alertStyle = .informational
        alert.runModal()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
