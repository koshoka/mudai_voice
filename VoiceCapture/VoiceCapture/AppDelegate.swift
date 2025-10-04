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
    private var modelDownloadWindow: NSWindow?

    // Services
    private var audioRecordingService: AudioRecordingServiceProtocol!
    private var fileStorageService: FileStorageServiceProtocol!
    private var notificationService: NotificationServiceProtocol!
    private var transcriptionService: TranscriptionServiceProtocol!
    private var modelDownloadManager: ModelDownloadManager!

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
        observeTranscriptionState()
        // TODO: KeyboardShortcuts SPM追加後にコメント解除
        setupKeyboardShortcuts()

        // モデルダウンロードチェック（非同期）
        Task {
            await checkAndDownloadModel()
        }
    }

    // MARK: - Setup

    private func checkPermissions() {
        PermissionsManager.shared.requestMicrophonePermission { [weak self] granted in
            if !granted {
                DispatchQueue.main.async {
                    self?.showMicrophonePermissionAlert()
                }
            }
        }
    }

    private func showMicrophonePermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "マイクへのアクセスが必要です"
        alert.informativeText = "nonvoiceは録音機能のためにマイクへのアクセスが必要です。システム設定でマイクへのアクセスを許可してください。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "システム設定を開く")
        alert.addButton(withTitle: "後で")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            // システム設定のプライバシー > マイクを開く
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone") {
                NSWorkspace.shared.open(url)
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
        alert.informativeText = "nonvoiceは録音完了や文字起こし完了を通知するために、通知の送信が必要です。システム環境設定で通知を許可してください。"
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
        modelDownloadManager = ModelDownloadManager()
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

    private func observeTranscriptionState() {
        transcriptionViewModel.$status
            .combineLatest(transcriptionViewModel.$progress)
            .sink { [weak self] status, progress in
                self?.updateTranscriptionProgress(status: status, progress: progress)
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

    // MARK: - Model Download

    private func checkAndDownloadModel() async {
        AppLogger.modelDownload.info("Checking if model is downloaded...")

        // モデルが既にダウンロード済みかチェック
        if await modelDownloadManager.isModelDownloaded() {
            AppLogger.modelDownload.info("Model already downloaded, skipping download")
            return
        }

        // ダウンロードが必要な場合、UIを表示
        AppLogger.modelDownload.info("Model not found, showing download window")
        showModelDownloadWindow()

        do {
            // モデルダウンロード実行
            try await modelDownloadManager.ensureModelDownloaded()

            // ダウンロード完了後、少し待ってからウィンドウを閉じる
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2秒待つ
            closeModelDownloadWindow()

        } catch {
            AppLogger.modelDownload.error("Model download failed: \(error.localizedDescription)")
            // エラーはModelDownloadViewで表示されるので、ここでは何もしない
        }
    }

    private func showModelDownloadWindow() {
        guard modelDownloadWindow == nil else {
            modelDownloadWindow?.makeKeyAndOrderFront(nil)
            return
        }

        let downloadView = ModelDownloadView(downloadManager: modelDownloadManager)
        let hostingController = NSHostingController(rootView: downloadView)

        let window = NSWindow(contentViewController: hostingController)
        window.title = "WhisperKitモデルのダウンロード"
        window.styleMask = [.titled, .closable]
        window.center()
        window.level = .floating

        modelDownloadWindow = window
        window.delegate = self

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        AppLogger.modelDownload.info("Model download window opened")
    }

    private func closeModelDownloadWindow() {
        modelDownloadWindow?.close()
        modelDownloadWindow = nil
        AppLogger.modelDownload.info("Model download window closed")
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else {
            fatalError("Failed to create status bar button")
        }

        // アイコン設定（水色で他のマイクアプリと区別）
        // テンプレートモードを無効化してカラーを適用
        if let baseImage = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "nonvoice") {
            baseImage.isTemplate = false
            let config = NSImage.SymbolConfiguration(hierarchicalColor: .cyan)
            button.image = baseImage.withSymbolConfiguration(config)
        }

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

        // nonvoiceについて
        let aboutItem = NSMenuItem(
            title: "nonvoiceについて",
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

        // テンプレートモードを無効化して水色を適用
        if let baseImage = NSImage(systemSymbolName: iconName, accessibilityDescription: "nonvoice") {
            baseImage.isTemplate = false
            let config = NSImage.SymbolConfiguration(hierarchicalColor: .cyan)
            button.image = baseImage.withSymbolConfiguration(config)
        }

        // アニメーションの追加・削除
        if isRecording {
            startPulseAnimation(on: button)
        } else {
            stopPulseAnimation(on: button)
        }
    }

    private func startPulseAnimation(on button: NSStatusBarButton) {
        // 既存のアニメーションがあれば削除
        button.layer?.removeAllAnimations()

        // レイヤーアニメーションを有効化
        button.wantsLayer = true

        // パルスアニメーション作成
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 1.0
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 0.4
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity

        // アニメーション適用
        button.layer?.add(pulseAnimation, forKey: "pulseAnimation")

        AppLogger.recording.debug("Pulse animation started")
    }

    private func stopPulseAnimation(on button: NSStatusBarButton) {
        // アニメーション削除
        button.layer?.removeAnimation(forKey: "pulseAnimation")

        // 不透明度を元に戻す
        button.layer?.opacity = 1.0

        AppLogger.recording.debug("Pulse animation stopped")
    }

    private func updateMenuItems(isRecording: Bool) {
        recordingMenuItem?.title = isRecording ? "録音停止" : "録音開始"
    }

    private func updateTranscriptionProgress(status: TranscriptionViewModel.TranscriptionStatus, progress: Float) {
        guard let button = statusItem?.button else { return }

        switch status {
        case .transcribing:
            let percentage = Int(progress * 100)
            button.toolTip = "文字起こし中... \(percentage)%"
        case .idle, .completed, .failed:
            button.toolTip = "nonvoice"
        }
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

            // 設定ウィンドウを最前面に表示
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

            settingsWindow = window
            window.delegate = self

            AppLogger.settings.info("Settings window opened")
        }

        // アプリをアクティブ化して設定ウィンドウを最前面に表示
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.orderFrontRegardless()
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "nonvoice"
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
        } else if notification.object as? NSWindow === modelDownloadWindow {
            modelDownloadWindow = nil
            AppLogger.modelDownload.info("Model download window closed by user")
        }
    }
}
