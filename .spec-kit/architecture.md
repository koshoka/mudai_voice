# VoiceCapture - アーキテクチャ文書

**プロジェクト**: VoiceCapture (mudai_voice)
**作成日**: 2025-10-03
**バージョン**: 1.0.0

---

## 1. システム概要

VoiceCaptureは、macOS専用のメニューバーアプリケーションであり、音声録音と自動文字起こしを提供する。

**主要技術**:
- Swift 5.9+ / SwiftUI / AppKit
- MLX Swift（Whisper medium）
- AVFoundation
- macOS 12.0+（Apple Silicon専用）

---

## 2. アーキテクチャパターン

### 2.1 MVVM + Services

```
┌─────────────────────────────────────────┐
│         VoiceCapture Application         │
├─────────────────────────────────────────┤
│  UI Layer (SwiftUI + AppKit)             │
│  - MenuBarView                           │
│  - SettingsView                          │
│  - AudioLevelMeter                       │
├─────────────────────────────────────────┤
│  ViewModels (Business Logic)             │
│  - RecordingViewModel                    │
│  - SettingsViewModel                     │
│  - TranscriptionViewModel                │
├─────────────────────────────────────────┤
│  Services Layer                          │
│  - AudioRecordingService                 │
│  - TranscriptionService (MLX Swift)      │
│  - FileStorageService                    │
│  - HotKeyService                         │
│  - NotificationService                   │
├─────────────────────────────────────────┤
│  Models                                  │
│  - Recording                             │
│  - Transcription                         │
│  - Settings                              │
└─────────────────────────────────────────┘
```

---

## 3. 技術スタック

### 3.1 現在実装中の機能

| 機能 | 技術スタック | ステータス |
|------|-------------|-----------|
| **voice-capture** | Swift + MLX Swift + AVFoundation | 技術計画完了 |

### 3.2 技術詳細

**voice-capture**:
- **言語**: Swift 5.9+
- **UI**: SwiftUI + AppKit（メニューバー）
- **録音**: AVFoundation
- **文字起こし**: MLX Swift（Whisper medium）
- **ストレージ**: UserDefaults（設定）、FileManager（音声・テキスト）
- **通知**: UserNotifications
- **ホットキー**: Carbon API

---

## 4. データフロー

### 4.1 録音→文字起こしフロー

```
User Input (Hotkey: Cmd+Shift+R)
    ↓
HotKeyService.onHotKeyPressed()
    ↓
RecordingViewModel.toggleRecording()
    ↓
[分岐] isRecording?
    ↓ (NO - 録音開始)
AudioRecordingService.startRecording()
    ↓
@Published var isRecording = true
    ↓
View更新（アイコン赤色、タイマー開始）
    ↓
音量レベルモニタリング開始
    ↓
... 録音中 ...
    ↓
User Input (Hotkey again)
    ↓
AudioRecordingService.stopRecording()
    ↓
FileStorageService.saveWAV(url)
    ↓
NotificationService.sendRecordingComplete()
    ↓
[自動] TranscriptionViewModel.startTranscription(url)
    ↓
TranscriptionService.transcribe(url) [MLX Whisper]
    ↓
FileStorageService.saveMarkdown(text, url)
    ↓
NotificationService.sendTranscriptionComplete()
```

---

## 5. セキュリティ設計

### 5.1 権限管理

- **マイクアクセス**: `NSMicrophoneUsageDescription`
- **システムイベント**: `NSAppleEventsUsageDescription`

### 5.2 データ保護

- **ローカルストレージのみ**: クラウド送信なし
- **ファイル保護**: `completeFileProtection`
- **サンドボックス**: App Sandbox有効

---

## 6. パフォーマンス目標

| 指標 | 目標値 |
|------|--------|
| ホットキー応答時間 | 0.3秒以内 |
| 録音開始時間 | 0.5秒以内 |
| 文字起こし速度（1分音声） | 30秒以内 |
| RTF（Real-Time Factor） | 0.5以下 |
| メモリ使用量（アイドル） | 100MB以下 |
| メモリ使用量（文字起こし中） | 2GB以下 |

---

## 7. 配布戦略

### 7.1 初期版

- **形式**: DMG（ディスクイメージ）
- **署名**: Apple Developer証明書
- **Notarization**: 必須
- **配布**: GitHub Releases

### 7.2 将来版

- **App Store**: 検討中
- **自動更新**: Sparkle（将来的な拡張）

---

## 8. 拡張計画

### 8.1 Phase 2以降の機能

- AI機能拡張（タグ付け、サマリー）
- 全文検索
- エクスポート機能（PDF、SRT字幕）
- 統合機能（Obsidian、Notion）

---

## 9. リスク管理

### 9.1 主要リスク

| リスク | 影響度 | 対策 |
|--------|--------|------|
| MLX Swift統合困難 | 高 | Python Bridgeフォールバック |
| パフォーマンス不足 | 中 | モデルサイズ調整 |
| メモリ使用量過多 | 中 | ストリーミング処理 |

---

## 10. 関連ドキュメント

- [実装計画書](/Users/kk/development/mudai_voice/plan/implementation_plan_mlx_swift.md)
- [仕様書](./.spec-kit/specs/voice-capture/specification.md)
- [技術計画書](./.spec-kit/specs/voice-capture/technical-plan.md)

---

**最終更新日**: 2025-10-03
**次回レビュー**: Phase 1完了時
