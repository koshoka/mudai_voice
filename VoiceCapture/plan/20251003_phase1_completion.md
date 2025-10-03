# Phase 1 完了記録

作成日: 2025-10-03
コミット: 4cdd830

## プロジェクト概要

- **名前**: VoiceCapture
- **目的**: macOS録音アプリ（メニューバー常駐型）
- **技術**: Swift 5.9+, SwiftUI, AVFoundation, Combine
- **対象OS**: macOS 12.0+
- **リポジトリ**: https://github.com/koshoka/mudai_voice

## Phase 1 Day 1 完了内容

### 実装項目
- Xcodeプロジェクト作成
- メニューバーアプリ構造
- 基本UI（AppDelegate, VoiceCaptureApp）
- Info.plist設定（NSMicrophoneUsageDescription）
- アプリアイコン設定

### ファイル
- `VoiceCaptureApp.swift`: メインエントリーポイント
- `AppDelegate.swift`: メニューバー管理
- `Info.plist`: マイク権限要求
- `VoiceCapture.entitlements`: サンドボックス設定

## Phase 1 Day 2 完了内容

### アーキテクチャ実装

**MVVM + Services パターン**
- Protocol-Oriented Design
- 依存性注入
- テスト可能な設計

### ディレクトリ構造

```
VoiceCapture/VoiceCapture/
├── VoiceCaptureApp.swift
├── AppDelegate.swift
├── Models/
│   ├── Recording.swift
│   └── AudioSettings.swift
├── Services/
│   ├── Protocols/
│   │   ├── AudioRecordingServiceProtocol.swift
│   │   ├── FileStorageServiceProtocol.swift
│   │   └── NotificationServiceProtocol.swift
│   ├── AudioRecordingService.swift
│   ├── FileStorageService.swift
│   └── NotificationService.swift
├── Utilities/
│   ├── PermissionsManager.swift
│   ├── VoiceCaptureError.swift
│   ├── AppLogger.swift
│   └── SettingsManager.swift
└── ViewModels/
    ├── RecordingViewModel.swift
    └── TranscriptionViewModel.swift
```

### 実装詳細

#### 1. Protocols (3ファイル)

**AudioRecordingServiceProtocol**
- `startRecording()`: 録音開始
- `stopRecording()`: 録音停止してURL返却
- `audioLevelPublisher`: 音声レベルのCombine Publisher

**FileStorageServiceProtocol**
- `saveTranscription()`: 文字起こし保存
- `getRecentRecordings()`: 最近の録音取得
- `deleteRecording()`: 録音削除

**NotificationServiceProtocol**
- `sendRecordingComplete()`: 録音完了通知
- `sendTranscriptionComplete()`: 文字起こし完了通知

#### 2. Models (2ファイル)

**Recording**
```swift
struct Recording: Identifiable {
    let id: UUID
    let date: Date
    let audioURL: URL
    var transcriptionStatus: TranscriptionStatus
    var transcriptionURL: URL?
}
```

**AudioSettings**
```swift
struct AudioSettings: Codable {
    let sampleRate: Double      // デフォルト: 44100
    let bitDepth: Int            // デフォルト: 16
    let channels: Int            // デフォルト: 1（モノラル）
}
```

#### 3. Services (3ファイル)

**AudioRecordingService**
- AVAudioRecorderを使用
- WAV形式で録音
- リアルタイム音声レベル監視（Combine）
- ファイル名: `recording_YYYYMMDD_HHMMSS.wav`

**FileStorageService**
- Markdown形式で文字起こし保存
- ファイル管理（取得、削除）
- デフォルト保存先: `~/Documents/VoiceCapture/`

**NotificationService**
- macOS UserNotificationsフレームワーク使用
- 録音完了時に通知
- 文字起こし完了時に通知

#### 4. Utilities (4ファイル)

**PermissionsManager**
- **重要**: `AVCaptureDevice`使用（macOS 12.0互換）
- マイク権限要求
- 権限状態確認

**VoiceCaptureError**
```swift
enum VoiceCaptureError: LocalizedError {
    case recordingFailed(underlying: Error)
    case permissionDenied
    case fileOperationFailed(underlying: Error)
    case transcriptionFailed(underlying: Error)
}
```

**AppLogger**
- OSLogを使用
- カテゴリ別ロギング（recording, transcription, fileStorage）

**SettingsManager**
- UserDefaults永続化
- ObservableObject（設定変更の監視）
- 保存ディレクトリ、自動文字起こし設定

#### 5. ViewModels (2ファイル)

**RecordingViewModel** (`@MainActor`)
- 録音状態管理
- タイマー機能
- 音声レベル監視
- エラーハンドリング
- 自動文字起こしトリガー

**TranscriptionViewModel** (`@MainActor`)
- 文字起こし状態管理
- 進捗表示
- エラーハンドリング

#### 6. AppDelegate更新

**追加機能**
- `@MainActor` 追加（Swift Concurrency対応）
- Combine統合
- サービス依存性注入
- RecordingViewModel状態監視
- メニューバーアイコン動的更新

```swift
private func observeRecordingState() {
    recordingViewModel.$isRecording
        .sink { [weak self] isRecording in
            self?.updateMenuBarIcon(isRecording: isRecording)
            self?.updateMenuItems(isRecording: isRecording)
        }
        .store(in: &cancellables)
}
```

## 技術的課題と解決策

### 1. macOS API互換性問題

**問題**
- `AVAudioApplication.requestRecordPermission`はmacOS 14.0+のみ
- プロジェクトターゲット: macOS 12.0

**解決**
```swift
// PermissionsManager.swift:17-19
AVCaptureDevice.requestAccess(for: .audio) { granted in
    completion(granted)
}
```

**参照**: `VoiceCapture/Utilities/PermissionsManager.swift:17`

### 2. Combine AnyCancellable代入エラー

**問題**
```swift
// エラーコード
audioLevelCancellable = audioService.audioLevelPublisher
    .assign(to: &$audioLevel)  // Voidを返す
```

**解決**
```swift
// RecordingViewModel.swift:136-141
audioLevelCancellable = audioService.audioLevelPublisher
    .receive(on: DispatchQueue.main)
    .sink { [weak self] level in
        self?.audioLevel = level
    }
```

**参照**: `VoiceCapture/ViewModels/RecordingViewModel.swift:136`

### 3. 重複ファイル問題

**原因**
- 間違った場所に古いファイルが存在
  - 誤: `/VoiceCapture/Utilities/`
  - 正: `/VoiceCapture/VoiceCapture/Utilities/`

**解決**
1. 重複ファイル削除
2. `project.pbxproj`のグループ構造修正
3. Xcode再起動

### 4. Swift Concurrency エラー

**問題**
- ViewModelは`@MainActor`
- AppDelegateは非MainActorコンテキスト
- ViewModelインスタンス化でエラー

**解決**
```swift
// AppDelegate.swift:12
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
```

**参照**: `VoiceCapture/AppDelegate.swift:12`

### 5. Xcodeプロジェクト参照エラー

**問題**
- Models, Services, Utilities, ViewModelsグループがプロジェクトルートに配置
- 実ファイルは`VoiceCapture/VoiceCapture/`配下

**解決**
- `project.pbxproj`を編集してグループ構造を修正
- すべてのグループをVoiceCaptureグループ配下に移動

## 実装統計

- **新規ファイル**: 14ファイル
- **更新ファイル**: 3ファイル
- **追加コード**: 1024行
- **ビルドエラー**: 0（解消済み）

## コミット履歴

```
4cdd830 - feat: Phase 1 Day 2完了 - MVVM+Services アーキテクチャ実装
afe935e - feat: Phase 1 Day 1完了 - メニューバーアプリ基本実装
```

## 次のステップ（Phase 2）

### 実装予定項目

1. **グローバルホットキー**
   - Carbon Hotkey APIまたはModern API使用
   - 録音開始/停止のショートカット

2. **設定画面UI**
   - SwiftUIウィンドウ
   - 音声品質設定
   - 保存先ディレクトリ選択
   - ホットキー設定

3. **音声品質カスタマイズ**
   - サンプルレート選択
   - ビット深度選択
   - モノラル/ステレオ選択

## 現在の状態

- ✅ ビルド成功
- ✅ Git保存完了
- ✅ GitHub同期完了
- ⏸️ 録音機能テスト未実施
- ⏸️ Phase 2未着手

## 重要な設計原則

1. **Protocol-Oriented Design**
   - すべてのサービスがProtocolで抽象化
   - テスト時のモック作成が容易

2. **Dependency Injection**
   - ViewModelがサービスをProtocol経由で受け取る
   - 疎結合な設計

3. **Swift Concurrency**
   - `@MainActor`で適切なスレッド管理
   - async/awaitによる非同期処理

4. **Combine活用**
   - リアクティブな状態管理
   - 音声レベルのリアルタイム更新

5. **エラーハンドリング**
   - カスタムエラー型（VoiceCaptureError）
   - LocalizedErrorによるユーザーフレンドリーなメッセージ

## 参考資料

- 実装計画: `plan/implementation_plan_mlx_swift.md`
- GitHubリポジトリ: https://github.com/koshoka/mudai_voice
- Apple Developer Documentation: AVFoundation, Combine, SwiftUI
