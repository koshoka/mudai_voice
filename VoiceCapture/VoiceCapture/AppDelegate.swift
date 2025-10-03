//
//  AppDelegate.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Cocoa
import SwiftUI
import Combine
import UserNotifications
// TODO: KeyboardShortcuts SPM追加後にコメント解除
import KeyboardShortcuts

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties

    private var statusItem: NSStatusItem?
    private var recordingMenuItem: NSMenuItem?
    private var settingsWindow: NSWindow?

    // Services
    private var audioRecordingService: AudioRecordingServiceProtocol!
    private var fileStorageService: FileStorageServiceProtocol!
    private var notificationService: NotificationServiceProtocol!
    private var transcriptionService: TranscriptionServiceProtocol!

    // ViewModels
    private var recordingViewModel: RecordingViewModel!
    private var transcriptionViewModel: TranscriptionViewModel!

    // Combine
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        checkPermissions()
        checkNotificationPermission()
        setupServices()
        setupViewModels()
        setupMenuBar()
        observeRecordingState()
        // TODO: KeyboardShortcuts SPM追加後にコメント解除
        setupKeyboardShortcuts()
    }

    // MARK: - Setup

    private func checkPermissions() {
        PermissionsManager.shared.requestMicrophonePermission { granted in
            if !granted {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "マイクへのアクセスが必要です"
                    alert.informativeText = "VoiceCaptureは録音機能のためにマイクへのアクセスが必要です。システム環境設定でマイクへのアクセスを許可してください。"
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            }
        }
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    // 権限未決定の場合、リクエスト
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                        if let error = error {
                            AppLogger.recording.error("Notification authorization error: \(error.localizedDescription)")
                        }

                        if !granted {
                            DispatchQueue.main.async {
                                self.showNotificationPermissionAlert()
                            }
                        }
                    }
                } else if settings.authorizationStatus == .denied {
                    // 拒否されている場合、システム環境設定を開くよう促す
                    self.showNotificationPermissionAlert()
                }
            }
        }
    }

    private func showNotificationPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "通知へのアクセスが必要です"
        alert.informativeText = "VoiceCaptureは録音完了や文字起こし完了を通知するために、通知の送信が必要です。システム環境設定で通知を許可してください。"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "システム環境設定を開く")
        alert.addButton(withTitle: "後で")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            // システム環境設定の通知セクションを開く
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    private func setupServices() {
        audioRecordingService = AudioRecordingService()
        fileStorageService = FileStorageService()
        notificationService = NotificationService()
        transcriptionService = TranscriptionService()
    }

    private func setupViewModels() {
        transcriptionViewModel = TranscriptionViewModel(
            transcriptionService: transcriptionService,
            fileStorageService: fileStorageService,
            notificationService: notificationService
        )

        recordingViewModel = RecordingViewModel(
            audioService: audioRecordingService,
            fileStorageService: fileStorageService,
            notificationService: notificationService,
            transcriptionViewModel: transcriptionViewModel
        )
    }

    private func observeRecordingState() {
        recordingViewModel.$isRecording
            .sink { [weak self] isRecording in
                self?.updateMenuBarIcon(isRecording: isRecording)
                self?.updateMenuItems(isRecording: isRecording)
            }
            .store(in: &cancellables)
    }

    // TODO: KeyboardShortcuts SPM追加後にコメント解除
    
    private func setupKeyboardShortcuts() {
        KeyboardShortcuts.onKeyUp(for: .toggleRecording) { [weak self] in
            Task { @MainActor in
                await self?.recordingViewModel.toggleRecording()
            }
        }
    }
    

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
        recordingMenuItem = NSMenuItem(
            title: "録音開始",
            action: #selector(toggleRecording),
            keyEquivalent: ""
        )
        recordingMenuItem?.target = self
        menu.addItem(recordingMenuItem!)

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

    private func updateMenuBarIcon(isRecording: Bool) {
        guard let button = statusItem?.button else { return }

        let iconName = isRecording ? "mic.circle.fill" : "mic.fill"
        button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "VoiceCapture")
        button.image?.isTemplate = true
    }

    private func updateMenuItems(isRecording: Bool) {
        recordingMenuItem?.title = isRecording ? "録音停止" : "録音開始"
    }

    // MARK: - Actions

    @objc private func toggleRecording() {
        Task { @MainActor in
            await recordingViewModel.toggleRecording()
        }
    }

    @objc private func openLastRecording() {
        Task { @MainActor in
            await recordingViewModel.openLastRecording()
        }
    }

    @objc private func openLastTranscription() {
        Task { @MainActor in
            await recordingViewModel.openLastTranscription()
        }
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView(viewModel: SettingsViewModel())
            let hostingController = NSHostingController(rootView: settingsView)

            let window = NSWindow(contentViewController: hostingController)
            window.title = "設定"
            window.styleMask = [.titled, .closable]
            window.setContentSize(NSSize(width: 500, height: 400))
            window.center()

            settingsWindow = window
            window.delegate = self

            AppLogger.settings.info("Settings window opened")
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
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

// MARK: - NSWindowDelegate

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if notification.object as? NSWindow === settingsWindow {
            settingsWindow = nil
            AppLogger.settings.info("Settings window closed")
        }
    }
}
