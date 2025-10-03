# VoiceCapture - 技術計画書

**プロジェクト名**: VoiceCapture
**機能名**: voice-capture
**作成日**: 2025-10-03
**バージョン**: 1.0.0
**ステータス**: 技術計画完了

---

## 1. 技術スタック

### 1.1 採用技術

**言語・フレームワーク**:
- Swift 5.9以降
- SwiftUI（UI構築）
- AppKit（メニューバーアプリ）
- AVFoundation（オーディオ録音）
- MLX Swift（Whisper文字起こし）

**対象プラットフォーム**:
- macOS 12.0 (Monterey) 以降
- Apple Silicon（M1/M2/M3/M4）専用

**依存関係管理**:
- Swift Package Manager (SPM)

### 1.2 アーキテクチャパターン

**MVVM + Services + Coordinator**:
- Model: データモデル（Recording、Transcription、Settings）
- View: SwiftUI/AppKit（UI）
- ViewModel: ビジネスロジック
- Services: コアビジネスロジック（録音、文字起こし、ファイル管理）
- Coordinator: アプリライフサイクル管理

---

## 2. システムアーキテクチャ

### 2.1 レイヤー構成

```
┌────────────────────────────────────┐
│  Presentation Layer (UI)            │
│  - SwiftUI Views                    │
│  - AppKit (MenuBar)                 │
└────────────────────────────────────┘
         ↓
┌────────────────────────────────────┐
│  ViewModel Layer                    │
│  - RecordingViewModel               │
│  - SettingsViewModel                │
│  - TranscriptionViewModel           │
└────────────────────────────────────┘
         ↓
┌────────────────────────────────────┐
│  Services Layer                     │
│  - AudioRecordingService            │
│  - TranscriptionService             │
│  - FileStorageService               │
│  - HotKeyService                    │
│  - NotificationService              │
└────────────────────────────────────┘
         ↓
┌────────────────────────────────────┐
│  Frameworks & Libraries             │
│  - MLX Swift                        │
│  - AVFoundation                     │
│  - UserNotifications                │
│  - Combine                          │
└────────────────────────────────────┘
```

### 2.2 データフロー

**録音→文字起こしフロー**:
```
User (Hotkey)
  → HotKeyService
  → RecordingViewModel
  → AudioRecordingService
  → [録音実行]
  → FileStorageService (WAV保存)
  → NotificationService (録音完了通知)
  → TranscriptionViewModel
  → TranscriptionService (MLX Whisper)
  → FileStorageService (Markdown保存)
  → NotificationService (文字起こし完了通知)
```

---

## 3. 主要コンポーネント設計

### 3.1 AudioRecordingService

**責務**: 音声録音の管理

**主要メソッド**:
- `startRecording() async throws`
- `stopRecording() async throws -> URL`
- `audioLevelPublisher: AnyPublisher<Float, Never>`

**技術詳細**:
- AVAudioRecorderを使用
- リアルタイム音量モニタリング
- WAV形式（PCM、44.1kHz、16bit、モノラル）

### 3.2 TranscriptionService

**責務**: MLX Swiftを使用した文字起こし

**主要メソッド**:
- `transcribe(audioURL: URL) async throws -> String`
- `transcribeWithProgress(audioURL: URL, progressCallback:) async throws -> String`

**技術詳細**:
- MLX Swift Whisper medium モデル
- async/awaitによる非同期処理
- Actorによる並行処理の安全性確保

### 3.3 FileStorageService

**責務**: ファイルI/O管理

**主要メソッド**:
- `saveMarkdown(text: String, audioURL: URL) async throws -> URL`
- `getRecentRecordings(limit: Int) async throws -> [Recording]`
- `deleteRecording(_ recording: Recording) async throws`

**技術詳細**:
- アトミック書き込み
- ファイル保護レベル: completeFileProtection

### 3.4 HotKeyService

**責務**: グローバルホットキー管理

**主要メソッド**:
- `register(keyCode: UInt32, modifiers: UInt32, callback:) throws`
- `unregister()`

**技術詳細**:
- Carbon APIを使用
- システムレベルのキーイベント監視

---

## 4. MLX Swift統合

### 4.1 モデル管理

**モデル**:
- Whisper medium（約1.5GB）
- 配置場所: `VoiceCapture/MLX/WhisperModel/ggml-medium.bin`

**ロード方法**:
```swift
let model = try WhisperModel.load(path: modelPath)
```

### 4.2 文字起こし実装

**基本パターン**:
```swift
actor TranscriptionService {
    private let whisperModel: WhisperModel

    func transcribe(audioURL: URL) async throws -> String {
        let result = try await whisperModel.transcribe(
            audioPath: audioURL.path,
            language: "ja"
        )
        return result.text
    }
}
```

### 4.3 パフォーマンス最適化

**目標**:
- 1分の音声を30秒以内で処理
- RTF（Real-Time Factor）: 0.5以下

**最適化手法**:
- Apple Silicon専用最適化（MLX）
- バックグラウンドスレッドでの実行
- メモリ効率的な処理

---

## 5. セキュリティ設計

### 5.1 権限管理

**必要な権限**:
- マイクアクセス (`NSMicrophoneUsageDescription`)
- システムイベント (`NSAppleEventsUsageDescription`)

**実装**:
```swift
class PermissionsManager {
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .audio, completionHandler: completion)
    }
}
```

### 5.2 データ保護

**ファイル保護**:
```swift
try data.write(to: url, options: [.completeFileProtection, .atomic])
```

**サンドボックス**:
- App Sandbox有効化
- ユーザー選択ファイルへのアクセスのみ

---

## 6. テスト戦略

### 6.1 ユニットテスト

**対象**:
- ViewModels（90%以上のカバレッジ）
- Services（85%以上のカバレッジ）

**テストフレームワーク**:
- XCTest

### 6.2 統合テスト

**対象**:
- 録音→保存フロー
- 録音→文字起こし→保存フロー

### 6.3 UIテスト

**対象**:
- メニューバー操作
- 設定画面操作

---

## 7. エラーハンドリング

### 7.1 エラー定義

```swift
enum VoiceCaptureError: LocalizedError {
    case microphonePermissionDenied
    case recordingFailed(underlying: Error)
    case transcriptionFailed(underlying: Error)
    case fileSystemError(underlying: Error)
    case hotKeyRegistrationFailed
    case modelNotFound
    case insufficientStorage
}
```

### 7.2 エラーリカバリー

**リトライロジック**:
- 文字起こし失敗時: 3回までリトライ
- 指数バックオフ使用

**ユーザー通知**:
- 分かりやすいエラーメッセージ
- リカバリー方法の提示

---

## 8. パフォーマンス要件

### 8.1 応答時間

| 操作 | 目標時間 |
|------|---------|
| ホットキー応答 | 0.3秒以内 |
| 録音開始 | 0.5秒以内 |
| UI更新 | 100ms以内 |

### 8.2 リソース使用量

| リソース | 制限 |
|---------|------|
| メモリ（アイドル） | 100MB以下 |
| メモリ（録音中） | 200MB以下 |
| メモリ（文字起こし中） | 2GB以下 |

---

## 9. 配布計画

### 9.1 配布形式

**初期版**:
- DMG（ディスクイメージ）
- 署名とNotarization

**将来版**:
- App Store配布（検討中）

### 9.2 バージョニング

**セマンティックバージョニング**:
- `1.0.0`: 初期リリース
- `1.x.x`: 機能追加
- `x.0.0`: 破壊的変更

---

## 10. 代替技術案

### 10.1 Python Bridge（フォールバック）

**採用条件**:
- MLX Swift統合が困難な場合

**実装パターン**:
```swift
class PythonBridgeTranscriptionService {
    func transcribe(audioURL: URL) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: pythonPath)
        process.arguments = [scriptPath, audioURL.path]
        // ... プロセス実行
    }
}
```

**メリット**:
- 既存のmojiokoshi_projectコードを活用
- 実装が早い

**デメリット**:
- Python環境が必要
- 配布が複雑

---

## 11. 実装フェーズ

### Phase 1: 基本録音機能（3-4日）
- Xcodeプロジェクト作成
- 録音開始/停止
- WAV保存
- 視覚的フィードバック

### Phase 2: ホットキーと設定（1-2日）
- グローバルホットキー
- 設定画面
- UserDefaults永続化

### Phase 3: MLX Swift統合（3-4日）
- MLX Swift調査
- Whisperモデル統合
- 文字起こし実装
- Markdown出力

### Phase 4: UX改善（1-2日）
- 通知機能
- エラーハンドリング
- パフォーマンス最適化

---

## 12. リスク管理

### 12.1 技術リスク

| リスク | 影響度 | 確率 | 対策 |
|--------|--------|------|------|
| MLX Swift統合困難 | 高 | 中 | Python Bridgeフォールバック |
| パフォーマンス不足 | 中 | 低 | モデルサイズ調整 |
| メモリ使用量過多 | 中 | 中 | ストリーミング処理 |

---

## 13. 関連ドキュメント

- [仕様書](./specification.md)
- [実装計画書](/Users/kk/development/mudai_voice/plan/implementation_plan_mlx_swift.md)
- [技術調査メモ](/Users/kk/development/mudai_voice/docs/mlx_swift_investigation.md)

---

**最終更新日**: 2025-10-03
**作成者**: VoiceCapture Development Team
**バージョン**: 1.0.0
