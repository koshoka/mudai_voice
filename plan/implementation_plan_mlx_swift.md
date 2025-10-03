# VoiceCapture - MLX Swift実装計画書

**プロジェクト名**: VoiceCapture (mudai_voice)
**技術スタック**: Swift 5.9+ / SwiftUI / MLX Swift / macOS 12.0+
**作成日**: 2025-10-03
**バージョン**: 1.0.0

---

## 目次

1. [プロジェクト概要](#1-プロジェクト概要)
2. [技術選定の詳細根拠](#2-技術選定の詳細根拠)
3. [アーキテクチャ設計](#3-アーキテクチャ設計)
4. [プロジェクト構造](#4-プロジェクト構造)
5. [Phase 1: 基本録音機能](#5-phase-1-基本録音機能)
6. [Phase 2: ホットキーと設定](#6-phase-2-ホットキーと設定)
7. [Phase 3: MLX Swift統合](#7-phase-3-mlx-swift統合)
8. [Phase 4: UX改善](#8-phase-4-ux改善)
9. [テスト戦略](#9-テスト戦略)
10. [セキュリティとプライバシー](#10-セキュリティとプライバシー)
11. [リスク分析と対策](#11-リスク分析と対策)
12. [詳細タイムライン](#12-詳細タイムライン)
13. [チェックリスト](#13-チェックリスト)

---

## 1. プロジェクト概要

### 1.1 ビジョン

**「録音の不安をゼロに」**

VoiceCaptureは、思考を音声で即座に記録し、自動で文字起こしして整理するmacOSメニューバーアプリケーションである。ユーザーが録音中に感じる「ちゃんと録音できているか」という不安を解消し、録音したコンテンツを確実に活用できる環境を提供する。

### 1.2 コアバリュー

1. **信頼性**: 録音が確実に動作していることをリアルタイムで視覚的に確認できる
2. **自動化**: 録音停止後、自動的に文字起こしが実行され、Markdown形式で保存される
3. **シンプルさ**: ホットキー一つで録音開始/停止、複雑な操作は不要
4. **効率性**: Apple Silicon専用のMLX最適化により、高速な文字起こしを実現

### 1.3 ターゲットユーザー

- **コンテンツクリエイター**: ポッドキャスト、YouTube動画の台本作成
- **研究者・学生**: インタビュー、講義の文字起こし
- **ビジネスパーソン**: 会議メモ、アイデアの音声記録
- **ライター**: 音声による下書き作成

### 1.4 主要機能（MVP）

#### 録音機能
- グローバルホットキー（デフォルト: `Cmd + Shift + R`）
- リアルタイム音量レベルメーター
- 録音時間表示（mm:ss形式）
- メニューバーアイコンの動的変更（録音中は赤色）

#### 自動保存
- ファイル名規則: `YYYYMMDD_HHMMSS.wav`
- ユーザー指定フォルダへの自動保存
- macOS通知センターによる完了通知

#### 文字起こし
- MLX Whisper（medium）による高速処理
- 日本語対応
- Markdown形式での出力
- 録音停止後の自動実行（設定で変更可能）

#### 設定管理
- ホットキーカスタマイズ
- 保存先フォルダ選択
- 録音品質設定（サンプルレート、ビット深度）
- 文字起こし自動実行のON/OFF

---

## 2. 技術選定の詳細根拠

### 2.1 選択肢の比較

プロジェクト開始時、3つの技術アプローチを検討した：

| 項目 | MLX Swift（採用） | Python Bridge | whisper.cpp |
|------|-------------------|---------------|-------------|
| **パフォーマンス** | ⭐️⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️ |
| **開発効率** | ⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️⭐️ | ⭐️⭐️ |
| **保守性** | ⭐️⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️ | ⭐️⭐️⭐️ |
| **配布容易性** | ⭐️⭐️⭐️⭐️⭐️ | ⭐️⭐️ | ⭐️⭐️⭐️⭐️ |
| **Apple Silicon最適化** | ⭐️⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️⭐️⭐️ | ⭐️⭐️⭐️ |

### 2.2 MLX Swift採用の決定理由

#### 優位性

1. **ネイティブSwiftアプリケーション**
   - 外部依存なし（Pythonランタイム不要）
   - App Store配布が容易
   - macOSとの完全な統合

2. **Apple Silicon専用最適化**
   - Metal Performance Shaders（MPS）の直接活用
   - 従来のWhisperより2-4倍高速
   - メモリ効率が優秀

3. **開発体験**
   - 完全な型安全性
   - Swiftの最新機能活用（async/await、Actor）
   - Xcodeの強力なデバッグツール

4. **長期的メリット**
   - Apple公式のMLXフレームワーク
   - 継続的なアップデートとサポート
   - Swift Packageによる依存管理

#### 考慮したデメリット

1. **学習コスト**: MLX Swiftは比較的新しいフレームワーク
   - **対策**: 公式ドキュメントとサンプルコードの徹底的な調査
   - **対策**: 既存のMLX Whisperプロジェクト（Python版）からの知見活用

2. **ドキュメント不足の可能性**
   - **対策**: コミュニティフォーラム（Discord、GitHub Issues）の活用
   - **対策**: ソースコードレベルでの理解

3. **未検証のパフォーマンス**
   - **対策**: Phase 3の初期段階でベンチマーク実施
   - **対策**: Python Bridge実装をフォールバックプランとして準備

### 2.3 技術スタック詳細

#### コアテクノロジー

```
┌─────────────────────────────────────────┐
│         VoiceCapture Application         │
├─────────────────────────────────────────┤
│  UI Layer: SwiftUI + AppKit              │
│  - MenuBarView, SettingsView             │
│  - AudioLevelMeter, RecordingTimer       │
├─────────────────────────────────────────┤
│  Business Logic: ViewModels              │
│  - RecordingViewModel                    │
│  - SettingsViewModel                     │
│  - TranscriptionViewModel                │
├─────────────────────────────────────────┤
│  Services Layer                          │
│  - AudioRecordingService (AVFoundation)  │
│  - TranscriptionService (MLX Swift)      │
│  - FileStorageService                    │
│  - HotKeyService (Carbon API)            │
│  - NotificationService                   │
├─────────────────────────────────────────┤
│  Frameworks & Libraries                  │
│  - MLX Swift (Whisper)                   │
│  - AVFoundation (Audio)                  │
│  - UserNotifications (Notifications)     │
│  - Combine (Reactive Programming)        │
└─────────────────────────────────────────┘
```

#### 依存関係（Swift Package Manager）

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/ml-explore/mlx-swift.git", from: "0.1.0"),
    // 将来的な拡張用
    // .package(url: "https://github.com/sparkle-project/Sparkle.git", from: "2.0.0")
]
```

---

## 3. アーキテクチャ設計

### 3.1 アーキテクチャパターン

**MVVM + Services + Coordinator**

このプロジェクトでは、以下の設計パターンを採用する：

1. **MVVM (Model-View-ViewModel)**
   - UI（View）とビジネスロジック（ViewModel）の分離
   - テスタビリティの向上
   - SwiftUIとの親和性

2. **Services Layer**
   - 再利用可能なビジネスロジックの集約
   - 単一責任の原則（SRP）の遵守
   - 依存性注入（DI）によるテスト容易性

3. **Coordinator (軽量)**
   - アプリケーションのライフサイクル管理
   - メニューバーアプリのため、複雑な画面遷移はなし

### 3.2 データフロー

#### 録音フロー

```
User Action (Hotkey)
    ↓
HotKeyService.onHotKeyPressed()
    ↓
RecordingViewModel.toggleRecording()
    ↓
[分岐] isRecording?
    ↓ (NO)
AudioRecordingService.startRecording()
    ↓
@Published var isRecording = true
    ↓
View更新 (メニューバーアイコン変更)
    ↓
タイマー開始 (recordingTime更新)
    ↓
音量レベルモニタリング開始
    ↓
... 録音中 ...
    ↓
User Action (Hotkey again)
    ↓
AudioRecordingService.stopRecording()
    ↓
FileStorageService.saveWAV(url)
    ↓
NotificationService.sendRecordingComplete()
    ↓
[自動] TranscriptionViewModel.startTranscription(url)
```

#### 文字起こしフロー

```
TranscriptionViewModel.startTranscription(audioURL)
    ↓
@Published var isTranscribing = true
    ↓
TranscriptionService.transcribe(audioURL) [async]
    ↓
MLX Whisper実行 (バックグラウンドスレッド)
    ↓
@Published var progress更新 (0.0 → 1.0)
    ↓
Result<String, Error>
    ↓
[成功]
    ↓
FileStorageService.saveMarkdown(text, audioURL)
    ↓
NotificationService.sendTranscriptionComplete()
    ↓
@Published var isTranscribing = false
```

### 3.3 レイヤー構成

#### 1. Presentation Layer (UI)

**責務**: ユーザーインタラクションと状態表示

```swift
// Views/MenuBar/MenuBarView.swift
struct MenuBarView: View {
    @ObservedObject var viewModel: RecordingViewModel

    var body: some View {
        HStack {
            Image(systemName: viewModel.isRecording ? "mic.fill" : "mic")
                .foregroundColor(viewModel.isRecording ? .red : .gray)

            if viewModel.isRecording {
                Text(viewModel.formattedTime)
                    .font(.caption)
            }
        }
    }
}
```

#### 2. ViewModel Layer

**責務**: ビジネスロジックとプレゼンテーションロジック

```swift
// ViewModels/RecordingViewModel.swift
@MainActor
class RecordingViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var audioLevel: Float = 0

    private let audioService: AudioRecordingServiceProtocol
    private let transcriptionViewModel: TranscriptionViewModel

    init(audioService: AudioRecordingServiceProtocol,
         transcriptionViewModel: TranscriptionViewModel) {
        self.audioService = audioService
        self.transcriptionViewModel = transcriptionViewModel
    }

    func toggleRecording() async {
        if isRecording {
            await stopRecording()
        } else {
            await startRecording()
        }
    }

    private func startRecording() async {
        do {
            try await audioService.startRecording()
            isRecording = true
            startTimer()
            startAudioLevelMonitoring()
        } catch {
            handleError(error)
        }
    }

    private func stopRecording() async {
        do {
            let audioURL = try await audioService.stopRecording()
            isRecording = false
            stopTimer()

            if SettingsManager.shared.autoTranscribe {
                await transcriptionViewModel.startTranscription(audioURL: audioURL)
            }
        } catch {
            handleError(error)
        }
    }
}
```

#### 3. Services Layer

**責務**: コアビジネスロジックと外部システムとの統合

**AudioRecordingService**: 録音処理
**TranscriptionService**: 文字起こし処理
**FileStorageService**: ファイルI/O
**HotKeyService**: グローバルホットキー管理
**NotificationService**: システム通知

#### 4. Models Layer

**責務**: データモデルとビジネスルール

```swift
// Models/Recording.swift
struct Recording: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let createdAt: Date
    let duration: TimeInterval
    let fileURL: URL
    var transcriptionURL: URL?
    var transcriptionStatus: TranscriptionStatus
}

enum TranscriptionStatus: String, Codable {
    case pending
    case inProgress
    case completed
    case failed
}
```

### 3.4 依存性注入（DI）

**Protocol-Oriented Programming**による疎結合設計

```swift
// Services/Protocols/AudioRecordingServiceProtocol.swift
protocol AudioRecordingServiceProtocol {
    func startRecording() async throws
    func stopRecording() async throws -> URL
    var audioLevelPublisher: AnyPublisher<Float, Never> { get }
}

// テスト時のモック実装
class MockAudioRecordingService: AudioRecordingServiceProtocol {
    var startRecordingCalled = false
    var stopRecordingCalled = false

    func startRecording() async throws {
        startRecordingCalled = true
    }

    func stopRecording() async throws -> URL {
        stopRecordingCalled = true
        return URL(fileURLWithPath: "/tmp/test.wav")
    }

    var audioLevelPublisher: AnyPublisher<Float, Never> {
        Just(0.5).eraseToAnyPublisher()
    }
}
```

---

## 4. プロジェクト構造

### 4.1 完全なディレクトリ階層

```
VoiceCapture/
├── VoiceCapture.xcodeproj
├── VoiceCapture/
│   ├── App/
│   │   ├── VoiceCaptureApp.swift           # アプリエントリーポイント
│   │   ├── AppDelegate.swift               # メニューバー管理
│   │   └── Info.plist                      # アプリ設定
│   │
│   ├── Coordinators/
│   │   └── AppCoordinator.swift            # アプリライフサイクル
│   │
│   ├── Models/
│   │   ├── Recording.swift                 # 録音データモデル
│   │   ├── Transcription.swift             # 文字起こしデータモデル
│   │   ├── Settings.swift                  # 設定データモデル
│   │   └── AudioSettings.swift             # 音声設定モデル
│   │
│   ├── ViewModels/
│   │   ├── RecordingViewModel.swift        # 録音ビジネスロジック
│   │   ├── SettingsViewModel.swift         # 設定ビジネスロジック
│   │   └── TranscriptionViewModel.swift    # 文字起こしビジネスロジック
│   │
│   ├── Views/
│   │   ├── MenuBar/
│   │   │   ├── MenuBarView.swift           # メニューバーUI
│   │   │   └── MenuBarController.swift     # メニュー管理
│   │   │
│   │   ├── Settings/
│   │   │   ├── SettingsView.swift          # 設定画面メイン
│   │   │   ├── GeneralSettingsView.swift   # 一般設定タブ
│   │   │   ├── RecordingSettingsView.swift # 録音設定タブ
│   │   │   └── HotKeyRecorderView.swift    # ホットキー設定UI
│   │   │
│   │   └── Components/
│   │       ├── AudioLevelMeter.swift       # 音量レベルメーター
│   │       ├── RecordingTimer.swift        # 録音タイマー表示
│   │       └── NotificationBanner.swift    # アプリ内通知
│   │
│   ├── Services/
│   │   ├── Protocols/
│   │   │   ├── AudioRecordingServiceProtocol.swift
│   │   │   ├── TranscriptionServiceProtocol.swift
│   │   │   ├── FileStorageServiceProtocol.swift
│   │   │   ├── HotKeyServiceProtocol.swift
│   │   │   └── NotificationServiceProtocol.swift
│   │   │
│   │   ├── Implementation/
│   │   │   ├── AudioRecordingService.swift
│   │   │   ├── TranscriptionService.swift
│   │   │   ├── FileStorageService.swift
│   │   │   ├── HotKeyService.swift
│   │   │   └── NotificationService.swift
│   │   │
│   │   └── Managers/
│   │       ├── SettingsManager.swift       # UserDefaults管理
│   │       └── PermissionsManager.swift    # 権限管理
│   │
│   ├── Utilities/
│   │   ├── Extensions/
│   │   │   ├── URL+Extensions.swift
│   │   │   ├── Date+Extensions.swift
│   │   │   └── FileManager+Extensions.swift
│   │   │
│   │   ├── Logger/
│   │   │   └── AppLogger.swift             # 構造化ログ
│   │   │
│   │   ├── Constants/
│   │   │   ├── AppConstants.swift
│   │   │   └── ErrorMessages.swift
│   │   │
│   │   └── Errors/
│   │       └── VoiceCaptureError.swift     # カスタムエラー定義
│   │
│   ├── Resources/
│   │   ├── Assets.xcassets/
│   │   │   ├── AppIcon.appiconset/
│   │   │   ├── MenuBarIcon.imageset/
│   │   │   └── Colors/
│   │   │
│   │   └── Localizable.strings             # 多言語対応（将来）
│   │
│   └── MLX/
│       ├── WhisperModel/
│       │   └── ggml-medium.bin             # Whisperモデル（大容量）
│       │
│       └── Wrappers/
│           └── MLXWhisperWrapper.swift     # MLX Swift Whisperラッパー
│
├── VoiceCaptureTests/
│   ├── ViewModelTests/
│   │   ├── RecordingViewModelTests.swift
│   │   └── SettingsViewModelTests.swift
│   │
│   ├── ServiceTests/
│   │   ├── AudioRecordingServiceTests.swift
│   │   ├── TranscriptionServiceTests.swift
│   │   └── FileStorageServiceTests.swift
│   │
│   └── Mocks/
│       ├── MockAudioRecordingService.swift
│       ├── MockTranscriptionService.swift
│       └── MockFileStorageService.swift
│
├── VoiceCaptureUITests/
│   ├── MenuBarUITests.swift
│   └── SettingsUITests.swift
│
├── Package.swift                            # Swift Package依存管理
└── README.md                                # プロジェクト説明
```

### 4.2 ファイル数と規模

| カテゴリ | ファイル数 | 推定行数 |
|----------|-----------|---------|
| App | 3 | 150 |
| Models | 4 | 200 |
| ViewModels | 3 | 450 |
| Views | 9 | 700 |
| Services | 11 | 1200 |
| Utilities | 8 | 400 |
| Tests | 8 | 800 |
| **合計** | **46** | **~3900** |

---

## 5. Phase 1: 基本録音機能

**期間**: 3-4日
**目標**: 録音開始/停止、WAV保存、視覚的フィードバック

### 5.1 タスクリスト

- [ ] **1.1** Xcodeプロジェクト作成
- [ ] **1.2** AppDelegate.swiftとメニューバー基本構造
- [ ] **1.3** RecordingViewModel実装
- [ ] **1.4** AudioRecordingService実装
- [ ] **1.5** FileStorageService実装
- [ ] **1.6** 音量レベルメーター実装
- [ ] **1.7** 録音タイマー表示実装
- [ ] **1.8** メニューバーアイコン動的変更
- [ ] **1.9** ユニットテスト作成
- [ ] **1.10** 統合テスト（録音→保存フロー）

### 5.2 詳細実装

#### 5.2.1 Xcodeプロジェクト作成

**手順**:

1. Xcodeを起動
2. "Create a new Xcode project"
3. テンプレート選択: macOS → App
4. プロジェクト設定:
   - Product Name: `VoiceCapture`
   - Team: （あなたのApple Developer Team）
   - Organization Identifier: `com.yourdomain`
   - Bundle Identifier: `com.yourdomain.VoiceCapture`
   - Interface: SwiftUI
   - Language: Swift
   - Include Tests: ✅
5. 保存先: `/Users/kk/development/mudai_voice/VoiceCapture/`

**Info.plist設定**:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>VoiceCaptureはあなたの音声を録音して文字起こしするために、マイクへのアクセスが必要です。</string>

<key>NSAppleEventsUsageDescription</key>
<string>グローバルホットキーを登録するために、システムイベントへのアクセスが必要です。</string>

<key>LSUIElement</key>
<true/>  <!-- メニューバーのみ表示（Dockアイコンなし） -->

<key>LSMinimumSystemVersion</key>
<string>12.0</string>
```

#### 5.2.2 AppDelegate.swift実装

```swift
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties

    private var statusItem: NSStatusItem?
    private var recordingViewModel: RecordingViewModel!
    private var settingsWindow: NSWindow?

    // MARK: - Application Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupServices()
        setupMenuBar()
        setupViewModels()
        checkPermissions()
    }

    // MARK: - Setup

    private func setupServices() {
        // DIコンテナの初期化（将来的には専用DIコンテナを作成）
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

    private func setupViewModels() {
        // サービスのインスタンス化
        let audioService = AudioRecordingService()
        let transcriptionService = TranscriptionService()
        let fileStorageService = FileStorageService()
        let notificationService = NotificationService()

        // ViewModelの初期化
        let transcriptionViewModel = TranscriptionViewModel(
            transcriptionService: transcriptionService,
            fileStorageService: fileStorageService,
            notificationService: notificationService
        )

        recordingViewModel = RecordingViewModel(
            audioService: audioService,
            fileStorageService: fileStorageService,
            notificationService: notificationService,
            transcriptionViewModel: transcriptionViewModel
        )

        // 録音状態の監視
        observeRecordingState()
    }

    private func observeRecordingState() {
        recordingViewModel.$isRecording
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRecording in
                self?.updateMenuBarIcon(isRecording: isRecording)
                self?.updateMenuItems(isRecording: isRecording)
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    private func updateMenuBarIcon(isRecording: Bool) {
        if isRecording {
            statusItem?.button?.image = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "Recording")
            statusItem?.button?.contentTintColor = .red
        } else {
            statusItem?.button?.image = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "VoiceCapture")
            statusItem?.button?.contentTintColor = nil
        }
    }

    private func updateMenuItems(isRecording: Bool) {
        guard let menu = statusItem?.menu else { return }

        if let recordingItem = menu.item(at: 0) {
            recordingItem.title = isRecording ? "録音停止" : "録音開始"
        }
    }

    // MARK: - Permissions

    private func checkPermissions() {
        PermissionsManager.shared.requestMicrophonePermission { granted in
            if !granted {
                DispatchQueue.main.async {
                    self.showPermissionAlert()
                }
            }
        }
    }

    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "マイクへのアクセスが必要です"
        alert.informativeText = "VoiceCaptureを使用するには、システム環境設定でマイクへのアクセスを許可してください。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "システム環境設定を開く")
        alert.addButton(withTitle: "キャンセル")

        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone")!)
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
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)

            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "設定"
            settingsWindow?.styleMask = [.titled, .closable]
            settingsWindow?.setContentSize(NSSize(width: 500, height: 400))
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
```

#### 5.2.3 RecordingViewModel実装

```swift
import Foundation
import Combine

@MainActor
class RecordingViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var audioLevel: Float = 0
    @Published var errorMessage: String?
    @Published var lastRecordingURL: URL?
    @Published var lastTranscriptionURL: URL?

    // MARK: - Computed Properties

    var formattedTime: String {
        let minutes = Int(recordingTime) / 60
        let seconds = Int(recordingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Private Properties

    private let audioService: AudioRecordingServiceProtocol
    private let fileStorageService: FileStorageServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let transcriptionViewModel: TranscriptionViewModel

    private var timer: Timer?
    private var audioLevelCancellable: AnyCancellable?

    // MARK: - Initialization

    init(audioService: AudioRecordingServiceProtocol,
         fileStorageService: FileStorageServiceProtocol,
         notificationService: NotificationServiceProtocol,
         transcriptionViewModel: TranscriptionViewModel) {
        self.audioService = audioService
        self.fileStorageService = fileStorageService
        self.notificationService = notificationService
        self.transcriptionViewModel = transcriptionViewModel
    }

    // MARK: - Public Methods

    func toggleRecording() async {
        if isRecording {
            await stopRecording()
        } else {
            await startRecording()
        }
    }

    func openLastRecording() async {
        guard let url = lastRecordingURL else {
            errorMessage = "録音ファイルが見つかりません"
            return
        }

        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
    }

    func openLastTranscription() async {
        guard let url = lastTranscriptionURL else {
            errorMessage = "文字起こしファイルが見つかりません"
            return
        }

        NSWorkspace.shared.open(url)
    }

    // MARK: - Private Methods

    private func startRecording() async {
        do {
            try await audioService.startRecording()
            isRecording = true
            recordingTime = 0
            errorMessage = nil

            startTimer()
            startAudioLevelMonitoring()

            AppLogger.recording.info("Recording started")
        } catch {
            handleError(error)
        }
    }

    private func stopRecording() async {
        do {
            let audioURL = try await audioService.stopRecording()
            isRecording = false
            stopTimer()
            stopAudioLevelMonitoring()

            lastRecordingURL = audioURL

            // 通知送信
            await notificationService.sendRecordingComplete(fileName: audioURL.lastPathComponent)

            AppLogger.recording.info("Recording stopped: \(audioURL.lastPathComponent)")

            // 自動文字起こし
            if SettingsManager.shared.autoTranscribe {
                await transcriptionViewModel.startTranscription(audioURL: audioURL)
            }
        } catch {
            handleError(error)
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordingTime += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        recordingTime = 0
    }

    private func startAudioLevelMonitoring() {
        audioLevelCancellable = audioService.audioLevelPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$audioLevel)
    }

    private func stopAudioLevelMonitoring() {
        audioLevelCancellable?.cancel()
        audioLevel = 0
    }

    private func handleError(_ error: Error) {
        AppLogger.recording.error("Recording error: \(error.localizedDescription)")

        if let vcError = error as? VoiceCaptureError {
            errorMessage = vcError.localizedDescription
        } else {
            errorMessage = "録音エラーが発生しました"
        }

        isRecording = false
        stopTimer()
        stopAudioLevelMonitoring()
    }
}
```

#### 5.2.4 AudioRecordingService実装

```swift
import AVFoundation
import Combine

class AudioRecordingService: NSObject, AudioRecordingServiceProtocol {
    // MARK: - Properties

    private var audioRecorder: AVAudioRecorder?
    private var audioSession: AVAudioSession = .sharedInstance()
    private var currentRecordingURL: URL?

    private let audioLevelSubject = PassthroughSubject<Float, Never>()
    var audioLevelPublisher: AnyPublisher<Float, Never> {
        audioLevelSubject.eraseToAnyPublisher()
    }

    private var levelTimer: Timer?

    // MARK: - AudioRecordingServiceProtocol

    func startRecording() async throws {
        // 録音設定
        let settings = buildRecordingSettings()

        // ファイルURL生成
        let fileName = generateFileName()
        let saveDirectory = SettingsManager.shared.saveDirectory

        // ディレクトリ作成
        try FileManager.default.createDirectory(at: saveDirectory, withIntermediateDirectories: true)

        let audioURL = saveDirectory.appendingPathComponent(fileName)
        currentRecordingURL = audioURL

        // AVAudioRecorder初期化
        audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true

        // 録音開始
        guard audioRecorder?.record() == true else {
            throw VoiceCaptureError.recordingFailed(underlying: NSError(domain: "VoiceCapture", code: -1))
        }

        // 音量レベルモニタリング開始
        startLevelMonitoring()

        AppLogger.recording.info("Recording started: \(fileName)")
    }

    func stopRecording() async throws -> URL {
        guard let recorder = audioRecorder, let url = currentRecordingURL else {
            throw VoiceCaptureError.recordingFailed(underlying: NSError(domain: "VoiceCapture", code: -2))
        }

        recorder.stop()
        stopLevelMonitoring()

        audioRecorder = nil
        currentRecordingURL = nil

        AppLogger.recording.info("Recording stopped: \(url.lastPathComponent)")

        return url
    }

    // MARK: - Private Methods

    private func buildRecordingSettings() -> [String: Any] {
        let settings = SettingsManager.shared.audioSettings

        return [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: settings.sampleRate,
            AVNumberOfChannelsKey: settings.channels,
            AVLinearPCMBitDepthKey: settings.bitDepth,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }

    private func generateFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return "\(formatter.string(from: Date())).wav"
    }

    private func startLevelMonitoring() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateAudioLevel()
        }
    }

    private func stopLevelMonitoring() {
        levelTimer?.invalidate()
        levelTimer = nil
        audioLevelSubject.send(0)
    }

    private func updateAudioLevel() {
        guard let recorder = audioRecorder else { return }

        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0)

        // デシベルを0-1の範囲に正規化
        // -160dB（無音）〜 0dB（最大）
        let normalized = pow(10, averagePower / 20)
        audioLevelSubject.send(normalized)
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecordingService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            AppLogger.recording.error("Recording finished unsuccessfully")
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            AppLogger.recording.error("Encoding error: \(error.localizedDescription)")
        }
    }
}
```

#### 5.2.5 FileStorageService実装

```swift
import Foundation

class FileStorageService: FileStorageServiceProtocol {
    // MARK: - FileStorageServiceProtocol

    func saveMarkdown(text: String, audioURL: URL) async throws -> URL {
        let markdownContent = generateMarkdown(text: text, audioURL: audioURL)
        let markdownURL = audioURL.deletingPathExtension().appendingPathExtension("md")

        try markdownContent.write(to: markdownURL, atomically: true, encoding: .utf8)

        AppLogger.fileSystem.info("Markdown saved: \(markdownURL.lastPathComponent)")

        return markdownURL
    }

    func getRecentRecordings(limit: Int = 10) async throws -> [Recording] {
        let saveDirectory = SettingsManager.shared.saveDirectory

        guard FileManager.default.fileExists(atPath: saveDirectory.path) else {
            return []
        }

        let contents = try FileManager.default.contentsOfDirectory(
            at: saveDirectory,
            includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        )

        let wavFiles = contents.filter { $0.pathExtension == "wav" }

        let recordings: [Recording] = try wavFiles.compactMap { url in
            let attributes = try url.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])

            guard let createdAt = attributes.creationDate else { return nil }

            let transcriptionURL = url.deletingPathExtension().appendingPathExtension("md")
            let hasTranscription = FileManager.default.fileExists(atPath: transcriptionURL.path)

            return Recording(
                id: UUID(),
                fileName: url.lastPathComponent,
                createdAt: createdAt,
                duration: 0, // AVAssetから取得する場合は別途実装
                fileURL: url,
                transcriptionURL: hasTranscription ? transcriptionURL : nil,
                transcriptionStatus: hasTranscription ? .completed : .pending
            )
        }

        return recordings
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(limit)
            .map { $0 }
    }

    func deleteRecording(_ recording: Recording) async throws {
        try FileManager.default.removeItem(at: recording.fileURL)

        if let transcriptionURL = recording.transcriptionURL {
            try? FileManager.default.removeItem(at: transcriptionURL)
        }

        AppLogger.fileSystem.info("Recording deleted: \(recording.fileName)")
    }

    // MARK: - Private Methods

    private func generateMarkdown(text: String, audioURL: URL) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        let dateString = formatter.string(from: Date())

        let fileName = audioURL.lastPathComponent

        return """
        # 録音 \(dateString)

        **録音日時**: \(dateString)
        **ファイル名**: \(fileName)

        ---

        \(text)
        """
    }
}
```

#### 5.2.6 音量レベルメーター実装

```swift
import SwiftUI

struct AudioLevelMeter: View {
    let level: Float

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))

                // レベルバー
                RoundedRectangle(cornerRadius: 4)
                    .fill(levelColor)
                    .frame(width: geometry.size.width * CGFloat(level))
                    .animation(.easeOut(duration: 0.1), value: level)
            }
        }
        .frame(height: 8)
    }

    private var levelColor: Color {
        switch level {
        case 0..<0.3:
            return .green
        case 0.3..<0.7:
            return .yellow
        default:
            return .red
        }
    }
}

struct AudioLevelMeter_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AudioLevelMeter(level: 0.2)
            AudioLevelMeter(level: 0.5)
            AudioLevelMeter(level: 0.9)
        }
        .padding()
        .frame(width: 200)
    }
}
```

### 5.3 Phase 1の完了基準

- [ ] 録音開始/停止が正常に動作する
- [ ] WAVファイルが指定ディレクトリに保存される
- [ ] ファイル名が`YYYYMMDD_HHMMSS.wav`形式である
- [ ] メニューバーアイコンが録音状態に応じて変化する
- [ ] 録音時間が正確に表示される
- [ ] 音量レベルメーターがリアルタイムで更新される
- [ ] ユニットテストが全てパスする
- [ ] 統合テストが全てパスする

---

## 6. Phase 2: ホットキーと設定

**期間**: 1-2日
**目標**: グローバルホットキー、設定画面、UserDefaults永続化

### 6.1 タスクリスト

- [ ] **2.1** HotKeyService実装（Carbon API）
- [ ] **2.2** SettingsManager実装
- [ ] **2.3** SettingsViewModel実装
- [ ] **2.4** SettingsView実装（SwiftUI）
- [ ] **2.5** HotKeyRecorderView実装
- [ ] **2.6** UserDefaults永続化
- [ ] **2.7** ホットキー設定のバリデーション
- [ ] **2.8** ユニットテスト作成
- [ ] **2.9** 統合テスト（設定変更→反映確認）

### 6.2 詳細実装

#### 6.2.1 HotKeyService実装

```swift
import Carbon
import AppKit

class HotKeyService: HotKeyServiceProtocol {
    // MARK: - Properties

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private var hotKeyCallback: (() -> Void)?

    private let hotKeySignature: FourCharCode = UTGetOSTypeFromString("vcap" as CFString)
    private let hotKeyID: UInt32 = 1

    // MARK: - HotKeyServiceProtocol

    func register(keyCode: UInt32, modifiers: UInt32, callback: @escaping () -> Void) throws {
        // 既存のホットキーを解除
        unregister()

        hotKeyCallback = callback

        // イベントハンドラの登録
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, event, userData) -> OSStatus in
                guard let service = Unmanaged<HotKeyService>.fromOpaque(userData!).takeUnretainedValue() as HotKeyService? else {
                    return OSStatus(eventNotHandledErr)
                }

                service.hotKeyCallback?()
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )

        guard status == noErr else {
            throw VoiceCaptureError.hotKeyRegistrationFailed
        }

        // ホットキーの登録
        let hotKeyID = EventHotKeyID(signature: hotKeySignature, id: self.hotKeyID)
        var hotKeyRef: EventHotKeyRef?

        let registerStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        guard registerStatus == noErr, hotKeyRef != nil else {
            throw VoiceCaptureError.hotKeyRegistrationFailed
        }

        self.hotKeyRef = hotKeyRef

        AppLogger.recording.info("HotKey registered: keyCode=\(keyCode), modifiers=\(modifiers)")
    }

    func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }

        hotKeyCallback = nil
    }

    deinit {
        unregister()
    }
}

// MARK: - Key Code Utilities

extension HotKeyService {
    static let defaultKeyCode: UInt32 = 15 // R key
    static let defaultModifiers: UInt32 = UInt32(cmdKey | shiftKey)

    static func modifiersToString(_ modifiers: UInt32) -> String {
        var result = ""

        if modifiers & UInt32(cmdKey) != 0 {
            result += "⌘"
        }
        if modifiers & UInt32(shiftKey) != 0 {
            result += "⇧"
        }
        if modifiers & UInt32(optionKey) != 0 {
            result += "⌥"
        }
        if modifiers & UInt32(controlKey) != 0 {
            result += "⌃"
        }

        return result
    }

    static func keyCodeToString(_ keyCode: UInt32) -> String {
        // キーコードから文字列への変換
        // 簡易版（実際にはより詳細なマッピングが必要）
        switch keyCode {
        case 15: return "R"
        case 0: return "A"
        case 11: return "B"
        // ... 他のキーコード
        default: return "Unknown"
        }
    }
}
```

#### 6.2.2 SettingsManager実装

```swift
import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    // MARK: - Published Properties

    @Published var saveDirectory: URL {
        didSet {
            UserDefaults.standard.set(saveDirectory, forKey: Keys.saveDirectory)
        }
    }

    @Published var autoTranscribe: Bool {
        didSet {
            UserDefaults.standard.set(autoTranscribe, forKey: Keys.autoTranscribe)
        }
    }

    @Published var hotKeyCode: UInt32 {
        didSet {
            UserDefaults.standard.set(Int(hotKeyCode), forKey: Keys.hotKeyCode)
        }
    }

    @Published var hotKeyModifiers: UInt32 {
        didSet {
            UserDefaults.standard.set(Int(hotKeyModifiers), forKey: Keys.hotKeyModifiers)
        }
    }

    @Published var audioSettings: AudioSettings {
        didSet {
            if let encoded = try? JSONEncoder().encode(audioSettings) {
                UserDefaults.standard.set(encoded, forKey: Keys.audioSettings)
            }
        }
    }

    // MARK: - Private Keys

    private enum Keys {
        static let saveDirectory = "saveDirectory"
        static let autoTranscribe = "autoTranscribe"
        static let hotKeyCode = "hotKeyCode"
        static let hotKeyModifiers = "hotKeyModifiers"
        static let audioSettings = "audioSettings"
    }

    // MARK: - Initialization

    private init() {
        // デフォルト保存先
        let defaultDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("VoiceCapture")

        // UserDefaultsから読み込み
        self.saveDirectory = UserDefaults.standard.url(forKey: Keys.saveDirectory) ?? defaultDirectory
        self.autoTranscribe = UserDefaults.standard.bool(forKey: Keys.autoTranscribe)
            ? UserDefaults.standard.bool(forKey: Keys.autoTranscribe)
            : true // デフォルトtrue

        self.hotKeyCode = UInt32(UserDefaults.standard.integer(forKey: Keys.hotKeyCode))
        if self.hotKeyCode == 0 {
            self.hotKeyCode = HotKeyService.defaultKeyCode
        }

        self.hotKeyModifiers = UInt32(UserDefaults.standard.integer(forKey: Keys.hotKeyModifiers))
        if self.hotKeyModifiers == 0 {
            self.hotKeyModifiers = HotKeyService.defaultModifiers
        }

        if let data = UserDefaults.standard.data(forKey: Keys.audioSettings),
           let settings = try? JSONDecoder().decode(AudioSettings.self, from: data) {
            self.audioSettings = settings
        } else {
            self.audioSettings = AudioSettings.default
        }
    }

    // MARK: - Methods

    func resetToDefaults() {
        let defaultDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("VoiceCapture")

        saveDirectory = defaultDirectory
        autoTranscribe = true
        hotKeyCode = HotKeyService.defaultKeyCode
        hotKeyModifiers = HotKeyService.defaultModifiers
        audioSettings = AudioSettings.default
    }
}

// MARK: - AudioSettings Model

struct AudioSettings: Codable {
    var sampleRate: Double
    var bitDepth: Int
    var channels: Int

    static let `default` = AudioSettings(
        sampleRate: 44100.0,
        bitDepth: 16,
        channels: 1
    )
}
```

#### 6.2.3 SettingsView実装

```swift
import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        TabView {
            GeneralSettingsView(viewModel: viewModel)
                .tabItem {
                    Label("一般", systemImage: "gearshape")
                }

            RecordingSettingsView(viewModel: viewModel)
                .tabItem {
                    Label("録音", systemImage: "mic.fill")
                }
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - GeneralSettingsView

struct GeneralSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section(header: Text("保存先")) {
                HStack {
                    Text(viewModel.saveDirectory.path)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    Button("選択...") {
                        viewModel.selectSaveDirectory()
                    }
                }
            }

            Section(header: Text("文字起こし")) {
                Toggle("録音停止後に自動実行", isOn: $viewModel.autoTranscribe)
            }

            Section(header: Text("ホットキー")) {
                HotKeyRecorderView(
                    keyCode: $viewModel.hotKeyCode,
                    modifiers: $viewModel.hotKeyModifiers
                )
            }
        }
        .padding()
    }
}

// MARK: - RecordingSettingsView

struct RecordingSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            Section(header: Text("録音品質")) {
                Picker("サンプルレート", selection: $viewModel.sampleRate) {
                    Text("16kHz").tag(16000.0)
                    Text("22.05kHz").tag(22050.0)
                    Text("44.1kHz").tag(44100.0)
                    Text("48kHz").tag(48000.0)
                }

                Picker("ビット深度", selection: $viewModel.bitDepth) {
                    Text("16bit").tag(16)
                    Text("24bit").tag(24)
                }

                Picker("チャンネル", selection: $viewModel.channels) {
                    Text("モノラル").tag(1)
                    Text("ステレオ").tag(2)
                }
            }

            Section {
                HStack {
                    Spacer()
                    Button("デフォルトに戻す") {
                        viewModel.resetToDefaults()
                    }
                    Spacer()
                }
            }
        }
        .padding()
    }
}

// MARK: - HotKeyRecorderView

struct HotKeyRecorderView: View {
    @Binding var keyCode: UInt32
    @Binding var modifiers: UInt32

    @State private var isRecording = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("現在のホットキー:")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                Text(currentHotKeyString)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)

                Spacer()

                Button(isRecording ? "キーを押してください..." : "変更") {
                    isRecording.toggle()
                }
            }
        }
        .onAppear {
            // キーボードイベントのモニタリング設定
            setupKeyMonitoring()
        }
    }

    private var currentHotKeyString: String {
        let modifiersString = HotKeyService.modifiersToString(modifiers)
        let keyString = HotKeyService.keyCodeToString(keyCode)
        return "\(modifiersString)\(keyString)"
    }

    private func setupKeyMonitoring() {
        // NSEventの監視実装
        // 実際の実装では、ローカルイベントモニターを使用
    }
}
```

### 6.3 Phase 2の完了基準

- [ ] グローバルホットキーが正常に動作する
- [ ] 設定画面が表示される
- [ ] 設定変更が即座に反映される
- [ ] UserDefaultsに設定が永続化される
- [ ] ホットキーが他のアプリと競合しない
- [ ] 設定のバリデーションが動作する
- [ ] ユニットテストが全てパスする

---

## 7. Phase 3: MLX Swift統合

**期間**: 3-4日
**目標**: MLX Swift Whisperによる文字起こし、Markdown出力

### 7.1 タスクリスト

- [ ] **3.1** MLX Swift調査とリポジトリ確認
- [ ] **3.2** Package.swiftにMLX依存追加
- [ ] **3.3** Whisper mediumモデルダウンロード
- [ ] **3.4** MLXWhisperWrapper実装
- [ ] **3.5** TranscriptionService実装
- [ ] **3.6** TranscriptionViewModel実装
- [ ] **3.7** 非同期処理とエラーハンドリング
- [ ] **3.8** 進捗報告UI実装
- [ ] **3.9** Markdown生成とファイル保存
- [ ] **3.10** パフォーマンスベンチマーク
- [ ] **3.11** ユニットテスト作成
- [ ] **3.12** 統合テスト（録音→文字起こし→保存）

### 7.2 MLX Swift調査

#### 7.2.1 リポジトリ確認

**公式リポジトリ**: https://github.com/ml-explore/mlx-swift

**ドキュメント確認項目**:
- [ ] Whisperモデルのサポート状況
- [ ] サンプルコードの存在確認
- [ ] API仕様の理解
- [ ] モデルフォーマット（GGML/SafeTensors）
- [ ] パフォーマンス特性

**調査コマンド**:
```bash
# リポジトリのクローン
git clone https://github.com/ml-explore/mlx-swift.git
cd mlx-swift

# Whisper関連の検索
grep -r "whisper" .
grep -r "transcribe" .

# サンプルコードの確認
find . -name "*whisper*" -o -name "*speech*"
```

#### 7.2.2 Whisperモデルのダウンロード

```bash
# Whisper mediumモデルのダウンロード
cd /Users/kk/development/mudai_voice/VoiceCapture/VoiceCapture/MLX/WhisperModel

# オプション1: Hugging Faceから直接ダウンロード
# モデル形式によって異なるため、MLX Swiftのドキュメントを参照

# オプション2: whisper.cppのモデル変換ツール使用
# git clone https://github.com/ggerganov/whisper.cpp
# cd whisper.cpp
# bash ./models/download-ggml-model.sh medium
```

### 7.3 詳細実装

#### 7.3.1 Package.swift設定

```swift
// Package.swift
// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "VoiceCapture",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "VoiceCapture", targets: ["VoiceCapture"])
    ],
    dependencies: [
        .package(url: "https://github.com/ml-explore/mlx-swift.git", from: "0.1.0"),
        // 将来的な拡張
        // .package(url: "https://github.com/sparkle-project/Sparkle.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "VoiceCapture",
            dependencies: [
                .product(name: "MLX", package: "mlx-swift"),
                .product(name: "MLXRandom", package: "mlx-swift"),
                // Whisper関連のプロダクトを追加（実際のプロダクト名はドキュメント参照）
            ]
        ),
        .testTarget(
            name: "VoiceCaptureTests",
            dependencies: ["VoiceCapture"]
        )
    ]
)
```

#### 7.3.2 MLXWhisperWrapper実装

```swift
import Foundation
import MLX
// import MLXWhisper (実際のモジュール名はMLX Swiftのドキュメントに従う)

class MLXWhisperWrapper {
    // MARK: - Properties

    private let modelPath: String
    private var whisperModel: Any? // 実際の型はMLX Swiftのドキュメントに従う

    // MARK: - Initialization

    init(modelPath: String) throws {
        self.modelPath = modelPath

        // モデルのロード
        // 実際の実装はMLX Swiftのドキュメントに従う
        // 例:
        // self.whisperModel = try WhisperModel.load(path: modelPath)

        AppLogger.transcription.info("MLX Whisper model loaded from: \(modelPath)")
    }

    // MARK: - Transcription

    func transcribe(audioPath: String, language: String = "ja") async throws -> String {
        // 音声ファイルの読み込みと前処理
        let audioData = try loadAudioData(audioPath: audioPath)

        // Whisperモデルでの文字起こし
        // 実際の実装はMLX Swiftのドキュメントに従う
        // 例:
        // let result = try await whisperModel?.transcribe(
        //     audio: audioData,
        //     language: language,
        //     task: .transcribe
        // )

        // 仮の実装（実際にはMLX Swiftの正しいAPIを使用）
        let result = try await performTranscription(audioData: audioData, language: language)

        return result
    }

    func transcribeWithProgress(
        audioPath: String,
        language: String = "ja",
        progressCallback: @escaping (Float) -> Void
    ) async throws -> String {
        // 進捗報告付きの文字起こし
        // MLX Swiftが進捗コールバックをサポートしている場合

        let audioData = try loadAudioData(audioPath: audioPath)

        // 仮の実装
        var progress: Float = 0.0

        while progress < 1.0 {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
            progress += 0.1
            progressCallback(progress)
        }

        let result = try await performTranscription(audioData: audioData, language: language)

        return result
    }

    // MARK: - Private Methods

    private func loadAudioData(audioPath: String) throws -> Data {
        // WAVファイルの読み込み
        let url = URL(fileURLWithPath: audioPath)
        return try Data(contentsOf: url)
    }

    private func performTranscription(audioData: Data, language: String) async throws -> String {
        // 実際のMLX Whisper APIを使用した文字起こし
        // この部分はMLX Swiftの公式ドキュメントに従って実装

        // 仮の実装（実際にはMLX APIを使用）
        return "これはテスト用の文字起こし結果です。実際にはMLX Whisperで処理されます。"
    }
}
```

#### 7.3.3 TranscriptionService実装

```swift
import Foundation

actor TranscriptionService: TranscriptionServiceProtocol {
    // MARK: - Properties

    private let whisperWrapper: MLXWhisperWrapper
    private let modelPath: String

    // MARK: - Initialization

    init() throws {
        // モデルパスの設定
        let bundle = Bundle.main
        guard let modelURL = bundle.url(forResource: "ggml-medium", withExtension: "bin") else {
            throw VoiceCaptureError.transcriptionFailed(
                underlying: NSError(domain: "VoiceCapture", code: -3, userInfo: [
                    NSLocalizedDescriptionKey: "Whisperモデルが見つかりません"
                ])
            )
        }

        self.modelPath = modelURL.path
        self.whisperWrapper = try MLXWhisperWrapper(modelPath: modelPath)
    }

    // MARK: - TranscriptionServiceProtocol

    func transcribe(audioURL: URL) async throws -> String {
        AppLogger.transcription.info("Transcription started: \(audioURL.lastPathComponent)")

        do {
            let result = try await whisperWrapper.transcribe(
                audioPath: audioURL.path,
                language: "ja"
            )

            AppLogger.transcription.info("Transcription completed: \(result.count) characters")

            return result
        } catch {
            AppLogger.transcription.error("Transcription failed: \(error.localizedDescription)")
            throw VoiceCaptureError.transcriptionFailed(underlying: error)
        }
    }

    func transcribeWithProgress(
        audioURL: URL,
        progressCallback: @escaping (Float) -> Void
    ) async throws -> String {
        AppLogger.transcription.info("Transcription with progress started: \(audioURL.lastPathComponent)")

        do {
            let result = try await whisperWrapper.transcribeWithProgress(
                audioPath: audioURL.path,
                language: "ja",
                progressCallback: progressCallback
            )

            AppLogger.transcription.info("Transcription completed: \(result.count) characters")

            return result
        } catch {
            AppLogger.transcription.error("Transcription failed: \(error.localizedDescription)")
            throw VoiceCaptureError.transcriptionFailed(underlying: error)
        }
    }
}
```

#### 7.3.4 TranscriptionViewModel実装

```swift
import Foundation
import Combine

@MainActor
class TranscriptionViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var isTranscribing = false
    @Published var progress: Float = 0.0
    @Published var lastTranscription: String?
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let transcriptionService: TranscriptionServiceProtocol
    private let fileStorageService: FileStorageServiceProtocol
    private let notificationService: NotificationServiceProtocol

    // MARK: - Initialization

    init(transcriptionService: TranscriptionServiceProtocol,
         fileStorageService: FileStorageServiceProtocol,
         notificationService: NotificationServiceProtocol) {
        self.transcriptionService = transcriptionService
        self.fileStorageService = fileStorageService
        self.notificationService = notificationService
    }

    // MARK: - Public Methods

    func startTranscription(audioURL: URL) async {
        isTranscribing = true
        progress = 0.0
        errorMessage = nil

        do {
            // 進捗コールバック
            let progressCallback: (Float) -> Void = { [weak self] newProgress in
                Task { @MainActor in
                    self?.progress = newProgress
                }
            }

            // 文字起こし実行
            let text = try await transcriptionService.transcribeWithProgress(
                audioURL: audioURL,
                progressCallback: progressCallback
            )

            lastTranscription = text

            // Markdown保存
            let markdownURL = try await fileStorageService.saveMarkdown(text: text, audioURL: audioURL)

            // 通知送信
            await notificationService.sendTranscriptionComplete(fileName: markdownURL.lastPathComponent)

            AppLogger.transcription.info("Transcription workflow completed")
        } catch {
            handleError(error)
        }

        isTranscribing = false
        progress = 0.0
    }

    // MARK: - Private Methods

    private func handleError(_ error: Error) {
        AppLogger.transcription.error("Transcription error: \(error.localizedDescription)")

        if let vcError = error as? VoiceCaptureError {
            errorMessage = vcError.localizedDescription
        } else {
            errorMessage = "文字起こしエラーが発生しました"
        }
    }
}
```

### 7.4 Phase 3の完了基準

- [ ] MLX Swiftが正常にビルドされる
- [ ] Whisperモデルがロードされる
- [ ] 文字起こしが正常に実行される
- [ ] 日本語の認識精度が許容範囲（主観評価）
- [ ] Markdown形式で保存される
- [ ] 進捗が正確に報告される
- [ ] パフォーマンスが許容範囲（1分の音声を30秒以内で処理）
- [ ] ユニットテストが全てパスする
- [ ] 統合テストが全てパスする

---

## 8. Phase 4: UX改善

**期間**: 1-2日
**目標**: 音量メーター強化、通知機能、エラーハンドリング

### 8.1 タスクリスト

- [ ] **4.1** 音量レベルメーターの視覚的改善
- [ ] **4.2** 通知アクション実装
- [ ] **4.3** メニューバー機能拡張
- [ ] **4.4** エラーリカバリー機能
- [ ] **4.5** パフォーマンス最適化
- [ ] **4.6** ログ機能強化
- [ ] **4.7** ユーザビリティテスト
- [ ] **4.8** 最終統合テスト

### 8.2 詳細実装

#### 8.2.1 NotificationService強化

```swift
import Foundation
import UserNotifications

class NotificationService: NSObject, NotificationServiceProtocol {
    // MARK: - Initialization

    override init() {
        super.init()
        requestAuthorization()
    }

    // MARK: - Authorization

    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                AppLogger.recording.error("Notification authorization error: \(error.localizedDescription)")
            }

            AppLogger.recording.info("Notification authorization: \(granted)")
        }
    }

    // MARK: - NotificationServiceProtocol

    func sendRecordingComplete(fileName: String) async {
        let content = UNMutableNotificationContent()
        content.title = "録音完了"
        content.body = "ファイル: \(fileName)"
        content.sound = .default
        content.userInfo = ["type": "recording", "fileName": fileName]

        // アクション追加
        let openAction = UNNotificationAction(
            identifier: "OPEN_FILE",
            title: "Finderで開く",
            options: .foreground
        )

        let category = UNNotificationCategory(
            identifier: "RECORDING_COMPLETE",
            actions: [openAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "RECORDING_COMPLETE"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            AppLogger.recording.error("Failed to send notification: \(error.localizedDescription)")
        }
    }

    func sendTranscriptionComplete(fileName: String) async {
        let content = UNMutableNotificationContent()
        content.title = "文字起こし完了"
        content.body = "ファイル: \(fileName)"
        content.sound = .default
        content.userInfo = ["type": "transcription", "fileName": fileName]

        let openAction = UNNotificationAction(
            identifier: "OPEN_FILE",
            title: "ファイルを開く",
            options: .foreground
        )

        let category = UNNotificationCategory(
            identifier: "TRANSCRIPTION_COMPLETE",
            actions: [openAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "TRANSCRIPTION_COMPLETE"

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            AppLogger.transcription.error("Failed to send notification: \(error.localizedDescription)")
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        switch response.actionIdentifier {
        case "OPEN_FILE":
            if let fileName = userInfo["fileName"] as? String {
                openFile(fileName: fileName, type: userInfo["type"] as? String ?? "")
            }
        default:
            break
        }

        completionHandler()
    }

    private func openFile(fileName: String, type: String) {
        let saveDirectory = SettingsManager.shared.saveDirectory
        let fileURL = saveDirectory.appendingPathComponent(fileName)

        if type == "transcription" {
            NSWorkspace.shared.open(fileURL)
        } else {
            NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: saveDirectory.path)
        }
    }
}
```

#### 8.2.2 エラーハンドリング強化

```swift
// Utilities/Errors/VoiceCaptureError.swift

enum VoiceCaptureError: LocalizedError {
    case microphonePermissionDenied
    case recordingFailed(underlying: Error)
    case transcriptionFailed(underlying: Error)
    case fileSystemError(underlying: Error)
    case hotKeyRegistrationFailed
    case modelNotFound
    case insufficientStorage

    var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "マイクへのアクセスが許可されていません"
        case .recordingFailed(let error):
            return "録音エラー: \(error.localizedDescription)"
        case .transcriptionFailed(let error):
            return "文字起こしエラー: \(error.localizedDescription)"
        case .fileSystemError(let error):
            return "ファイルシステムエラー: \(error.localizedDescription)"
        case .hotKeyRegistrationFailed:
            return "ホットキーの登録に失敗しました"
        case .modelNotFound:
            return "Whisperモデルが見つかりません"
        case .insufficientStorage:
            return "ストレージ容量が不足しています"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .microphonePermissionDenied:
            return "システム環境設定 > セキュリティとプライバシー > マイク でVoiceCaptureを許可してください"
        case .recordingFailed:
            return "録音デバイスが正しく接続されているか確認してください"
        case .transcriptionFailed:
            return "音声ファイルが破損していないか確認してください"
        case .fileSystemError:
            return "保存先フォルダの権限を確認してください"
        case .hotKeyRegistrationFailed:
            return "他のアプリケーションと競合している可能性があります。別のホットキーを設定してください"
        case .modelNotFound:
            return "アプリケーションを再インストールしてください"
        case .insufficientStorage:
            return "ディスクの空き容量を確保してください"
        }
    }
}
```

### 8.3 Phase 4の完了基準

- [ ] 通知が正常に動作する
- [ ] 通知アクションが機能する
- [ ] エラーメッセージが分かりやすい
- [ ] エラーから適切にリカバリーできる
- [ ] パフォーマンスが最適化されている
- [ ] 全ての機能が統合されている
- [ ] ユーザビリティテストをパスする
- [ ] 全てのテストがパスする

---

## 9. テスト戦略

### 9.1 ユニットテスト

#### 9.1.1 ViewModelテスト

```swift
import XCTest
@testable import VoiceCapture

@MainActor
class RecordingViewModelTests: XCTestCase {
    var sut: RecordingViewModel!
    var mockAudioService: MockAudioRecordingService!
    var mockFileStorageService: MockFileStorageService!
    var mockNotificationService: MockNotificationService!
    var mockTranscriptionViewModel: TranscriptionViewModel!

    override func setUp() async throws {
        try await super.setUp()

        mockAudioService = MockAudioRecordingService()
        mockFileStorageService = MockFileStorageService()
        mockNotificationService = MockNotificationService()
        mockTranscriptionViewModel = TranscriptionViewModel(
            transcriptionService: MockTranscriptionService(),
            fileStorageService: mockFileStorageService,
            notificationService: mockNotificationService
        )

        sut = RecordingViewModel(
            audioService: mockAudioService,
            fileStorageService: mockFileStorageService,
            notificationService: mockNotificationService,
            transcriptionViewModel: mockTranscriptionViewModel
        )
    }

    override func tearDown() async throws {
        sut = nil
        mockAudioService = nil
        mockFileStorageService = nil
        mockNotificationService = nil
        mockTranscriptionViewModel = nil

        try await super.tearDown()
    }

    func testToggleRecording_startsRecording() async {
        // Given
        XCTAssertFalse(sut.isRecording)

        // When
        await sut.toggleRecording()

        // Then
        XCTAssertTrue(sut.isRecording)
        XCTAssertEqual(mockAudioService.startRecordingCallCount, 1)
    }

    func testToggleRecording_stopsRecording() async {
        // Given
        await sut.toggleRecording() // Start
        XCTAssertTrue(sut.isRecording)

        // When
        await sut.toggleRecording() // Stop

        // Then
        XCTAssertFalse(sut.isRecording)
        XCTAssertEqual(mockAudioService.stopRecordingCallCount, 1)
    }

    func testStopRecording_sendsNotification() async {
        // Given
        await sut.toggleRecording() // Start

        // When
        await sut.toggleRecording() // Stop

        // Then
        XCTAssertEqual(mockNotificationService.sendRecordingCompleteCallCount, 1)
    }
}
```

### 9.2 統合テスト

```swift
import XCTest
@testable import VoiceCapture

class TranscriptionIntegrationTests: XCTestCase {
    var audioRecordingService: AudioRecordingService!
    var fileStorageService: FileStorageService!

    override func setUp() async throws {
        try await super.setUp()

        audioRecordingService = AudioRecordingService()
        fileStorageService = FileStorageService()
    }

    func testEndToEndFlow_recordingToTranscription() async throws {
        // 1. テスト用音声ファイル作成
        let testAudioURL = createTestAudioFile()

        // 2. 文字起こし実行
        let transcriptionService = try TranscriptionService()
        let result = try await transcriptionService.transcribe(audioURL: testAudioURL)

        // 3. 結果検証
        XCTAssertFalse(result.isEmpty)
        XCTAssertGreaterThan(result.count, 10)

        // 4. Markdown保存
        let markdownURL = try await fileStorageService.saveMarkdown(text: result, audioURL: testAudioURL)

        // 5. ファイル存在確認
        XCTAssertTrue(FileManager.default.fileExists(atPath: markdownURL.path))

        // クリーンアップ
        try? FileManager.default.removeItem(at: testAudioURL)
        try? FileManager.default.removeItem(at: markdownURL)
    }

    private func createTestAudioFile() -> URL {
        // テスト用のWAVファイルを生成
        let tempDirectory = FileManager.default.temporaryDirectory
        let testAudioURL = tempDirectory.appendingPathComponent("test_audio.wav")

        // 簡単なWAVファイルデータを作成（実際には適切な音声データが必要）
        let testData = Data() // 仮のデータ
        try? testData.write(to: testAudioURL)

        return testAudioURL
    }
}
```

### 9.3 UIテスト

```swift
import XCTest

class MenuBarUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testMenuBarIcon_appearsOnLaunch() {
        // メニューバーアイコンの存在確認
        let menuBarIcon = app.statusItems["VoiceCapture"]
        XCTAssertTrue(menuBarIcon.exists)
    }

    func testRecordingMenu_togglesRecording() {
        // メニュークリック
        let menuBarIcon = app.statusItems["VoiceCapture"]
        menuBarIcon.click()

        // 録音開始メニューアイテムをクリック
        app.menuItems["録音開始"].click()

        // 録音中の状態確認
        menuBarIcon.click()
        let stopMenuItem = app.menuItems["録音停止"]
        XCTAssertTrue(stopMenuItem.exists)
    }
}
```

### 9.4 テストカバレッジ目標

| カテゴリ | カバレッジ目標 |
|---------|--------------|
| ViewModels | 90%以上 |
| Services | 85%以上 |
| Utilities | 80%以上 |
| **全体** | **85%以上** |

---

## 10. セキュリティとプライバシー

### 10.1 権限管理

**必要な権限**:
1. マイクへのアクセス (`NSMicrophoneUsageDescription`)
2. システムイベント (`NSAppleEventsUsageDescription`)

**実装**:

```swift
class PermissionsManager {
    static let shared = PermissionsManager()

    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            completion(granted)
        }
    }

    func checkMicrophonePermission() -> Bool {
        AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }
}
```

### 10.2 データ保護

**ファイル保護レベル**:

```swift
extension FileStorageService {
    func saveSecurely(data: Data, to url: URL) throws {
        try data.write(to: url, options: [.completeFileProtection, .atomic])
    }
}
```

### 10.3 サンドボックス

**Entitlements設定**:

```xml
<!-- VoiceCapture.entitlements -->
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.device.audio-input</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

---

## 11. リスク分析と対策

### 11.1 主要リスク

| リスク | 影響度 | 確率 | 対策 | 代替案 |
|--------|--------|------|------|--------|
| MLX SwiftのWhisperサポート不完全 | 高 | 中 | Phase 3初期段階で徹底検証 | Python Bridge実装（選択肢B） |
| Whisperモデルサイズ大（数GB） | 中 | 高 | 初回起動時のダウンロード方式 | Smallモデル使用 |
| ホットキー互換性問題 | 低 | 低 | 複数のホットキーオプション提供 | メニュー操作のみフォールバック |
| 文字起こし速度が遅い | 中 | 低 | MLX最適化活用、非同期処理 | モデルサイズの調整 |
| メモリ使用量過多 | 中 | 中 | ストリーミング録音、定期的な解放 | 録音時間制限の導入 |

### 11.2 フォールバックプラン

#### MLX Swift統合失敗時

**状況**: Phase 3でMLX SwiftのWhisperサポートが不十分と判明

**対策**:
1. **即座に選択肢B（Python Bridge）に切り替え**
2. 既存の`mojiokoshi_project`のPythonコードを活用
3. Swiftから`subprocess`でPythonスクリプトを呼び出し
4. 配布時はPython環境を同梱（pyinstaller使用）

**実装例**:

```swift
class PythonBridgeTranscriptionService: TranscriptionServiceProtocol {
    func transcribe(audioURL: URL) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: pythonPath)
        process.arguments = [transcribeScriptPath, audioURL.path]

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8) ?? ""
    }
}
```

---

## 12. 詳細タイムライン

### 12.1 週次スケジュール

#### Week 1: Phase 1 + Phase 2前半

| 日 | タスク | 成果物 |
|----|--------|--------|
| Day 1 | Xcodeプロジェクト作成、AppDelegate実装 | 基本構造 |
| Day 2 | RecordingViewModel、AudioRecordingService | 録音機能 |
| Day 3 | FileStorageService、音量メーター | 保存機能、UI |
| Day 4 | HotKeyService実装 | ホットキー機能 |
| Day 5 | SettingsManager、SettingsView | 設定画面 |

#### Week 2: Phase 2後半 + Phase 3

| 日 | タスク | 成果物 |
|----|--------|--------|
| Day 6 | MLX Swift調査、Package.swift設定 | MLX統合準備 |
| Day 7 | Whisperモデルダウンロード、MLXWhisperWrapper | モデル統合 |
| Day 8 | TranscriptionService実装 | 文字起こし機能 |
| Day 9 | TranscriptionViewModel、進捗UI | UI統合 |
| Day 10 | Markdown生成、パフォーマンステスト | Phase 3完了 |

#### Week 3: Phase 4 + テスト

| 日 | タスク | 成果物 |
|----|--------|--------|
| Day 11 | NotificationService強化、エラーハンドリング | UX改善 |
| Day 12 | ユニットテスト作成 | テストカバレッジ |
| Day 13 | 統合テスト、UIテスト | テスト完了 |
| Day 14 | バグ修正、最終調整 | MVP完成 |
| Day 15 | ドキュメント作成、配布準備 | リリース準備 |

### 12.2 マイルストーン

| マイルストーン | 日付目標 | 完了基準 |
|---------------|---------|---------|
| M1: Phase 1完了 | Day 3 | 録音→保存が動作 |
| M2: Phase 2完了 | Day 5 | ホットキー、設定が動作 |
| M3: Phase 3完了 | Day 10 | 文字起こしが動作 |
| M4: Phase 4完了 | Day 11 | 全機能統合完了 |
| M5: テスト完了 | Day 13 | カバレッジ85%達成 |
| M6: MVP完成 | Day 15 | リリース可能状態 |

---

## 13. チェックリスト

### 13.1 Phase 1チェックリスト

#### 基本録音機能
- [ ] Xcodeプロジェクトが作成されている
- [ ] AppDelegate.swiftが実装されている
- [ ] メニューバーアイコンが表示される
- [ ] 録音開始/停止メニューが動作する
- [ ] RecordingViewModelが実装されている
- [ ] AudioRecordingServiceが実装されている
- [ ] 録音開始時にWAVファイルが生成される
- [ ] ファイル名が`YYYYMMDD_HHMMSS.wav`形式である
- [ ] 指定ディレクトリに保存される
- [ ] 録音中にメニューバーアイコンが赤色になる
- [ ] 録音時間が正確に表示される
- [ ] 音量レベルメーターが動作する
- [ ] FileStorageServiceが実装されている
- [ ] ユニットテストが作成されている
- [ ] 統合テストが作成されている
- [ ] 全てのテストがパスする

### 13.2 Phase 2チェックリスト

#### ホットキーと設定
- [ ] HotKeyServiceが実装されている
- [ ] グローバルホットキーが登録される
- [ ] ホットキーで録音開始/停止ができる
- [ ] SettingsManagerが実装されている
- [ ] SettingsViewModelが実装されている
- [ ] SettingsViewが実装されている
- [ ] 設定画面が表示される
- [ ] 保存先フォルダを選択できる
- [ ] ホットキーを変更できる
- [ ] 録音品質設定が変更できる
- [ ] 自動文字起こしのON/OFFが切り替えられる
- [ ] 設定がUserDefaultsに保存される
- [ ] アプリ再起動時に設定が復元される
- [ ] ユニットテストが作成されている
- [ ] 全てのテストがパスする

### 13.3 Phase 3チェックリスト

#### MLX Swift統合
- [ ] MLX Swiftリポジトリを調査済み
- [ ] Package.swiftにMLX依存が追加されている
- [ ] プロジェクトがビルドできる
- [ ] Whisper mediumモデルをダウンロード済み
- [ ] モデルがプロジェクトに含まれている
- [ ] MLXWhisperWrapperが実装されている
- [ ] モデルのロードが成功する
- [ ] TranscriptionServiceが実装されている
- [ ] TranscriptionViewModelが実装されている
- [ ] 文字起こしが実行される
- [ ] 日本語が正しく認識される
- [ ] 進捗が報告される
- [ ] Markdown形式で保存される
- [ ] Markdownのフォーマットが正しい
- [ ] パフォーマンスベンチマーク実施済み
- [ ] 1分の音声を30秒以内で処理できる
- [ ] ユニットテストが作成されている
- [ ] 統合テストが作成されている
- [ ] 全てのテストがパスする

### 13.4 Phase 4チェックリスト

#### UX改善
- [ ] 音量レベルメーターが視覚的に改善されている
- [ ] NotificationServiceが強化されている
- [ ] 録音完了通知が表示される
- [ ] 文字起こし完了通知が表示される
- [ ] 通知アクションが動作する
- [ ] 通知からファイルを開ける
- [ ] エラーメッセージが分かりやすい
- [ ] エラーから適切にリカバリーできる
- [ ] ログが適切に記録される
- [ ] パフォーマンスが最適化されている
- [ ] メモリリークがない
- [ ] ユーザビリティテスト実施済み
- [ ] 全ての機能が統合されている
- [ ] 全てのテストがパスする

### 13.5 リリース前チェックリスト

#### 品質保証
- [ ] テストカバレッジが85%以上
- [ ] 全てのユニットテストがパスする
- [ ] 全ての統合テストがパスする
- [ ] 全てのUIテストがパスする
- [ ] メモリリークがない
- [ ] クラッシュが発生しない
- [ ] パフォーマンスが許容範囲
- [ ] エラーハンドリングが適切

#### セキュリティ
- [ ] Info.plistに権限説明が記載されている
- [ ] 権限リクエストが動作する
- [ ] ファイル保護が有効
- [ ] サンドボックスが有効

#### ドキュメント
- [ ] README.mdが作成されている
- [ ] ユーザーガイドが作成されている
- [ ] ライセンスが明記されている
- [ ] コードコメントが適切

#### 配布準備
- [ ] アプリアイコンが設定されている
- [ ] バージョン番号が設定されている
- [ ] 署名証明書が設定されている
- [ ] Notarization準備完了（将来）
- [ ] DMG作成準備完了（将来）

---

## 14. 参考資料

### 14.1 技術ドキュメント

- [Swift公式ドキュメント](https://www.swift.org/documentation/)
- [SwiftUI公式チュートリアル](https://developer.apple.com/tutorials/swiftui)
- [AVFoundation Programming Guide](https://developer.apple.com/documentation/avfoundation)
- [MLX Swift GitHub](https://github.com/ml-explore/mlx-swift)
- [Whisper論文](https://arxiv.org/abs/2212.04356)
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)

### 14.2 コミュニティリソース

- [Swift Forums](https://forums.swift.org/)
- [Stack Overflow - Swift](https://stackoverflow.com/questions/tagged/swift)
- [Reddit - r/swift](https://www.reddit.com/r/swift/)
- [MLX Discord](https://discord.gg/mlx) （仮のURL、実際のリンクを確認）

### 14.3 サンプルプロジェクト

- [既存のmojiokoshi_project](/Users/kk/windsurf-ai/mojiokoshi_project) - MLX Whisper（Python版）の実装参考
- MLX Swift Examples（公式リポジトリのexamplesディレクトリ）

---

## 15. まとめ

この実装計画書は、VoiceCapture（mudai_voice）プロジェクトをMLX Swiftで実装するための完全なロードマップである。

**主要な決定事項**:
- **技術スタック**: Swift + MLX Swift
- **アーキテクチャ**: MVVM + Services Layer
- **開発期間**: 3-4週間（15日間）
- **テストカバレッジ**: 85%以上

**成功の鍵**:
1. Phase 3の早期検証（MLX Swiftの実現可能性）
2. 徹底したテスト駆動開発
3. ユーザビリティを最優先
4. フォールバックプランの準備

**次のステップ**:
1. この計画書をレビュー
2. Phase 1の実装開始
3. マイルストーンごとの進捗確認

---

**最終更新日**: 2025-10-03
**作成者**: VoiceCapture Development Team
**バージョン**: 1.0.0
