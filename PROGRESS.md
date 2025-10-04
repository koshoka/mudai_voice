# VoiceCapture - 実装進捗状況

**最終更新**: 2025-10-04
**現在のフェーズ**: Phase 4完了・実機テスト準備完了（マイク接続待ち）

---

## 凡例

```
[x] 完了 - 実装済み
[VERIFIED] 動作確認済み - 実装＋テスト完了
[ ] 未着手
[~] 部分完了 - 実装途中
[BLOCKED] ブロック中 - 依存関係により進行不可
```

---

## Phase 1: 基本録音機能

**期間**: 3-4日
**状態**: [VERIFIED] 完了・動作確認済み
**目標**: 録音開始/停止、WAV保存、視覚的フィードバック

### 1.1 プロジェクトセットアップ

- [VERIFIED] Xcodeプロジェクト作成
  - 実装日: 2025-10-03
  - コミット: afe935e
  - 確認内容: プロジェクトビルド成功

- [VERIFIED] Info.plist設定
  - 実装日: 2025-10-03
  - コミット: afe935e
  - 確認内容: マイク権限説明、LSUIElement設定、最小システムバージョン設定

- [VERIFIED] 通知権限設定
  - 実装日: 2025-10-03
  - コミット: d13ca2b
  - 確認内容: NSUserNotificationsUsageDescription追加、動作確認済み

### 1.2 メニューバー構造

- [VERIFIED] AppDelegate.swift実装
  - 実装日: 2025-10-03
  - コミット: 4cdd830, d13ca2b
  - ファイル: VoiceCapture/AppDelegate.swift
  - 確認内容:
    - NSStatusItemによるメニューバー常駐
    - 録音開始/停止メニュー項目
    - 最後の録音を開くメニュー項目
    - 設定メニュー項目（UI未実装）
    - VoiceCaptureについてダイアログ
    - アイコン動的変更（録音中: mic.circle.fill）

- [VERIFIED] Combine統合
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - 確認内容: RecordingViewModelの状態変化を監視してメニューバー更新

### 1.3 MVVM + Services アーキテクチャ

#### Models

- [VERIFIED] Recording.swift
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - ファイル: VoiceCapture/Models/Recording.swift
  - 確認内容: Identifiable, 文字起こしステータス管理

- [VERIFIED] AudioSettings.swift
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - ファイル: VoiceCapture/Models/AudioSettings.swift
  - 確認内容: Codable, デフォルト設定（44.1kHz, 16bit, mono）

#### ViewModels

- [VERIFIED] RecordingViewModel.swift
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - ファイル: VoiceCapture/ViewModels/RecordingViewModel.swift
  - 確認内容:
    - @MainActor対応
    - 録音開始/停止
    - タイマー機能（mm:ss表示）
    - 音声レベル監視（Combine）
    - エラーハンドリング
    - 自動文字起こしトリガー

- [VERIFIED] TranscriptionViewModel.swift（スタブ）
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - ファイル: VoiceCapture/ViewModels/TranscriptionViewModel.swift
  - 確認内容: Phase 3実装用のスタブ実装

#### Services - Protocols

- [VERIFIED] AudioRecordingServiceProtocol.swift
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - ファイル: VoiceCapture/Services/Protocols/AudioRecordingServiceProtocol.swift
  - 確認内容: async/await対応、Combine Publisher定義

- [VERIFIED] FileStorageServiceProtocol.swift
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - ファイル: VoiceCapture/Services/Protocols/FileStorageServiceProtocol.swift

- [VERIFIED] NotificationServiceProtocol.swift
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - ファイル: VoiceCapture/Services/Protocols/NotificationServiceProtocol.swift

#### Services - Implementation

- [VERIFIED] AudioRecordingService.swift
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - ファイル: VoiceCapture/Services/AudioRecordingService.swift
  - 確認内容:
    - AVAudioRecorder使用
    - WAV形式録音
    - リアルタイム音声レベル監視
    - ファイル名生成（YYYYMMDD_HHMMSS.wav）
    - 実録音成功（20251003_222620.wav確認）

- [VERIFIED] FileStorageService.swift
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - ファイル: VoiceCapture/Services/FileStorageService.swift
  - 確認内容:
    - Markdown生成
    - ファイル取得/削除
    - サンドボックスコンテナ対応

- [VERIFIED] NotificationService.swift
  - 実装日: 2025-10-03
  - コミット: 4cdd830, d13ca2b
  - ファイル: VoiceCapture/Services/NotificationService.swift
  - 確認内容:
    - UserNotifications使用
    - 録音完了通知（動作確認済み）
    - 文字起こし完了通知（Phase 3で使用）
    - アクションボタン（Finderで開く）

#### Utilities

- [VERIFIED] PermissionsManager.swift
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - ファイル: VoiceCapture/Utilities/PermissionsManager.swift
  - 確認内容:
    - AVCaptureDevice使用（macOS 12.0互換）
    - マイク権限リクエスト
    - 権限状態確認

- [VERIFIED] VoiceCaptureError.swift
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - ファイル: VoiceCapture/Utilities/VoiceCaptureError.swift
  - 確認内容: LocalizedError, カスタムエラー型

- [VERIFIED] AppLogger.swift
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - ファイル: VoiceCapture/Utilities/AppLogger.swift
  - 確認内容: OSLog使用、カテゴリ別ロギング

- [VERIFIED] SettingsManager.swift
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - ファイル: VoiceCapture/Utilities/SettingsManager.swift
  - 確認内容:
    - UserDefaults永続化
    - ObservableObject
    - 保存ディレクトリ管理

### 1.4 録音機能

- [VERIFIED] 録音開始/停止
  - 実装日: 2025-10-03
  - 動作確認日: 2025-10-03
  - 確認内容: メニューバーから録音開始→停止が正常動作

- [VERIFIED] WAVファイル保存
  - 実装日: 2025-10-03
  - 動作確認日: 2025-10-03
  - 保存先: ~/Library/Containers/com.yourdomain.VoiceCapture/Data/Documents/VoiceCapture/
  - 確認ファイル: 20251003_222620.wav (824KB)

- [VERIFIED] 音量レベルメーター
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - 確認内容: PassthroughSubjectによるリアルタイム音声レベル配信

- [VERIFIED] 録音タイマー表示
  - 実装日: 2025-10-03
  - コミット: 4cdd830
  - 確認内容: mm:ss形式、Timer使用

- [VERIFIED] メニューバーアイコン動的変更
  - 実装日: 2025-10-03
  - 動作確認日: 2025-10-03
  - 確認内容: 録音中に`mic.circle.fill`に変化

### 1.5 権限管理

- [VERIFIED] マイク権限リクエスト
  - 実装日: 2025-10-03
  - 動作確認日: 2025-10-03
  - 確認内容: 初回起動時にダイアログ表示

- [VERIFIED] 通知権限リクエスト
  - 実装日: 2025-10-03
  - 動作確認日: 2025-10-03
  - 確認内容:
    - 初回起動時にダイアログ表示
    - 拒否時のシステム環境設定誘導
    - 通知正常動作確認

### 1.6 テスト

- [ ] ユニットテスト作成
  - 状態: 未着手
  - 対象:
    - RecordingViewModel
    - AudioRecordingService（モック）
    - FileStorageService

- [ ] 統合テスト
  - 状態: 未着手
  - テストケース:
    - 録音開始→停止→ファイル保存フロー
    - 権限エラーハンドリング

---

## Phase 2: ホットキーと設定

**期間**: 2-3日
**状態**: [VERIFIED] 完了・動作確認済み
**目標**: グローバルホットキー、設定画面UI
**実装日**: 2025-10-03

### 2.1 グローバルホットキー

- [VERIFIED] KeyboardShortcuts SPM統合
  - 実装日: 2025-10-03
  - ライブラリ: KeyboardShortcuts by Sindre Sorhus (v2.4.0)
  - 確認内容:
    - SPM依存関係追加成功
    - macOS 12.0互換性確認
    - サンドボックス対応

- [VERIFIED] KeyboardShortcuts.Name拡張定義
  - 実装日: 2025-10-03
  - ファイル: VoiceCapture/Extensions/KeyboardShortcuts+Names.swift
  - 確認内容:
    - .toggleRecording定義
    - デフォルトホットキー: Option + P
    - カスタマイズ可能

- [VERIFIED] AppDelegateにホットキー統合
  - 実装日: 2025-10-03
  - ファイル: VoiceCapture/AppDelegate.swift:141-147
  - 確認内容:
    - setupKeyboardShortcuts()メソッド実装
    - RecordingViewModelと連携
    - Option + P で録音開始/停止動作確認済み

### 2.2 設定画面UI

- [VERIFIED] SettingsView.swift実装
  - 実装日: 2025-10-03
  - ファイル: VoiceCapture/Views/Settings/SettingsView.swift
  - 確認内容:
    - SwiftUIベースのForm UI
    - 保存先ディレクトリ選択（NSOpenPanel）
    - ホットキーレコーダー（KeyboardShortcuts.Recorder）
    - 音声品質Picker（サンプルレート、ビット深度、チャンネル）
    - 自動文字起こしToggle
    - デフォルトリセットボタン
    - macOS 12.0互換性確認（.formStyle削除）

- [VERIFIED] SettingsViewModel.swift実装
  - 実装日: 2025-10-03
  - ファイル: VoiceCapture/ViewModels/SettingsViewModel.swift
  - 確認内容:
    - @MainActor対応
    - SettingsManagerとの双方向バインディング（Combine）
    - リアルタイム設定保存
    - NSOpenPanelによるディレクトリ選択
    - resetToDefaults()メソッド

- [VERIFIED] 設定ウィンドウ管理
  - 実装日: 2025-10-03
  - ファイル: VoiceCapture/AppDelegate.swift:247-266, 283-290
  - 確認内容:
    - openSettings()メソッド実装
    - NSHostingControllerによるSwiftUI統合
    - ウィンドウライフサイクル管理（NSWindowDelegate）
    - メニューから設定画面が正常に開く

### 2.3 音声品質カスタマイズ

- [VERIFIED] AudioSettings拡張
  - 実装日: 2025-10-03
  - ファイル: VoiceCapture/Models/AudioSettings.swift
  - 確認内容:
    - 型安全なenum定義（SampleRate, BitDepth, ChannelCount）
    - CaseIterable + Codable準拠
    - displayNameプロパティ（UI表示用）
    - AVFoundation変換プロパティ（sampleRateValue等）
    - サンプルレート: 44.1kHz, 48kHz
    - ビット深度: 16-bit, 24-bit
    - チャンネル: モノラル, ステレオ

- [VERIFIED] AudioRecordingService更新
  - 実装日: 2025-10-03
  - ファイル: VoiceCapture/Services/AudioRecordingService.swift:74-86
  - 確認内容:
    - buildRecordingSettings()更新
    - SettingsManagerから動的設定取得
    - enum型との統合完了

### 2.4 マイク選択機能（UI実装）

- [x] AudioDevice.swift実装
  - 実装日: 2025-10-04
  - ファイル: VoiceCapture/Models/AudioDevice.swift
  - 確認内容:
    - Identifiable, Codable, Hashable準拠
    - 利用可能なマイクデバイス列挙（AVCaptureDevice）
    - システムデフォルトデバイス定義

- [x] SettingsManagerにマイク管理機能追加
  - 実装日: 2025-10-04
  - ファイル: VoiceCapture/Utilities/SettingsManager.swift
  - 確認内容:
    - selectedAudioDeviceプロパティ追加
    - UserDefaults永続化
    - availableAudioDevicesプロパティ

- [x] SettingsViewModelにマイクバインディング追加
  - 実装日: 2025-10-04
  - ファイル: VoiceCapture/ViewModels/SettingsViewModel.swift
  - 確認内容:
    - selectedAudioDeviceバインディング
    - availableAudioDevices computed property

- [x] SettingsViewにマイク選択UI追加
  - 実装日: 2025-10-04
  - 動作確認日: 2025-10-04
  - ファイル: VoiceCapture/Views/Settings/SettingsView.swift
  - 確認内容:
    - 「録音デバイス」セクション追加
    - Pickerで利用可能なマイク選択可能
    - iPhone Mirroring経由のマイクも表示される

- [~] AudioRecordingServiceでの実装
  - 状態: 未実装（将来対応予定）
  - 理由: AVAudioRecorderは特定デバイス指定に非対応
  - 今後: AVAudioEngineへのリファクタリングが必要

### 2.5 テスト

- [VERIFIED] ホットキー動作確認
  - 実装日: 2025-10-03
  - 確認内容:
    - Option + P で録音開始/停止動作確認済み
    - KeyboardShortcutsライブラリによる競合検出機能あり
    - カスタマイズ可能（設定画面から変更可能）

- [VERIFIED] 設定画面UIテスト
  - 実装日: 2025-10-03-04
  - 確認内容:
    - 設定画面が正常に開く
    - 各UI要素が正常に表示される
    - マイク選択Pickerの動作確認済み（2025-10-04）
    - Whisperモデル選択Pickerの動作確認済み（2025-10-04）

---

## Phase 3: WhisperKit統合（文字起こし機能）

**期間**: 4-5日
**状態**: [~] 部分完了・動作テスト保留中（マイク不在のため）
**目標**: WhisperKit統合、自動文字起こし
**実装日**: 2025-10-04

### 3.1 WhisperKit セットアップ

- [x] macOS最小バージョンを15.0に変更
  - 実装日: 2025-10-04
  - ファイル: Info.plist, project.pbxproj
  - 確認内容:
    - LSMinimumSystemVersion: 15.0
    - MACOSX_DEPLOYMENT_TARGET: 15.0
    - WhisperKit要件（macOS 14.0+）を満たす

- [x] WhisperKitをSPM依存関係に追加
  - 実装日: 2025-10-04
  - リポジトリ: https://github.com/argmaxinc/WhisperKit
  - バージョン: main (f31370f)
  - 確認内容: ビルド成功

- [x] Whisperモデル選択機能
  - 実装日: 2025-10-04
  - ファイル: VoiceCapture/Models/AudioSettings.swift
  - 確認内容:
    - WhisperModel enum追加（small, medium）
    - displayNameプロパティ
    - デフォルト: medium

- [x] SettingsManagerにWhisperモデル管理追加
  - 実装日: 2025-10-04
  - ファイル: VoiceCapture/Utilities/SettingsManager.swift
  - 確認内容:
    - whisperModelプロパティ
    - UserDefaults永続化
    - デフォルト値: medium

- [x] SettingsViewにWhisperモデル選択UI追加
  - 実装日: 2025-10-04
  - 動作確認日: 2025-10-04
  - ファイル: VoiceCapture/Views/Settings/SettingsView.swift
  - 確認内容:
    - Whisperモデル選択Picker追加
    - Small/Medium選択可能
    - ヘルプテキスト表示

- [ ] Whisperモデルダウンロード確認
  - 状態: 未確認（初回実行時に自動ダウンロード）
  - Small: 約500MB
  - Medium: 約1.5GB

### 3.2 TranscriptionService実装

- [x] TranscriptionServiceProtocol.swift実装
  - 実装日: 2025-10-04
  - ファイル: VoiceCapture/Services/Protocols/TranscriptionServiceProtocol.swift
  - 確認内容:
    - transcribe(audioURL:) async throws -> String
    - transcriptionProgress Publisher

- [x] TranscriptionService.swift実装
  - 実装日: 2025-10-04
  - ファイル: VoiceCapture/Services/TranscriptionService.swift
  - 確認内容:
    - WhisperKit初期化（設定からモデル選択）
    - 音声ファイル→テキスト変換
    - 進捗報告（0.0〜1.0）
    - エラーハンドリング
    - AppLoggerログ記録
    - WhisperKit v0.6.0 API対応（配列戻り値）

- [x] TranscriptionViewModel完全実装
  - 実装日: 2025-10-04
  - ファイル: VoiceCapture/ViewModels/TranscriptionViewModel.swift
  - 確認内容:
    - @MainActor対応
    - 文字起こし開始/キャンセル
    - ステータス管理（idle/transcribing/completed/failed）
    - 進捗表示（0.0〜1.0）
    - Markdown保存
    - 通知送信

### 3.3 自動文字起こし統合

- [x] RecordingViewModel統合準備完了
  - 実装日: 2025-10-03（Phase 1）
  - ファイル: VoiceCapture/ViewModels/RecordingViewModel.swift
  - 確認内容:
    - TranscriptionViewModel連携コード実装済み
    - SettingsManagerの自動文字起こし設定参照

- [x] Markdown出力機能
  - 実装日: 2025-10-03（Phase 1）
  - ファイル: VoiceCapture/Services/FileStorageService.swift
  - 確認内容:
    - saveMarkdown(text:audioURL:)実装済み
    - メタデータ埋め込み（日時、ファイル名）

### 3.4 テスト

- [ ] 文字起こし動作確認
  - 状態: 未確認（マイク不在のため保留）
  - 確認予定項目:
    - 録音→自動文字起こし→Markdown保存フロー
    - Small/Mediumモデル切り替え
    - 通知表示

- [ ] 文字起こし精度テスト
  - 状態: 未実施
  - テストケース:
    - 日本語音声
    - 英語音声
    - ノイズ環境

- [ ] パフォーマンステスト
  - 状態: 未実施
  - 測定項目:
    - 処理時間計測（Small vs Medium）
    - メモリ使用量
    - 初回モデルダウンロード時間

---

## Phase 4: UX改善

**期間**: 1日
**状態**: [x] 完了
**目標**: UI/UXの洗練、エラーハンドリング強化
**実装日**: 2025-10-04

### 4.1 視覚的フィードバック強化

- [x] 録音中アニメーション
  - 実装日: 2025-10-04
  - コミット: 330dd62
  - ファイル: VoiceCapture/AppDelegate.swift:246-276
  - 確認内容:
    - Core Animationによるパルスアニメーション実装
    - opacityの滑らかな変化（1.0 ↔ 0.4）
    - 1秒周期のイージングアニメーション（無限ループ）
    - 録音開始/停止で自動ON/OFF
    - プロフェッショナルで控えめな視覚効果

- [x] 通知改善
  - 実装日: 2025-10-04
  - コミット: 330dd62
  - ファイル: VoiceCapture/Services/NotificationService.swift
  - 確認内容:
    - リッチ通知実装（録音時間、ファイルサイズ、文字数表示）
    - 通知カテゴリ管理（録音完了、文字起こし完了）
    - 通知からのアクション実行（Finderで開く、削除）
    - AVFoundationによる音声ファイル詳細情報取得
    - ファイル削除機能（確認ダイアログ付き）

### 4.2 エラーハンドリング

- [x] ユーザーフレンドリーなエラーメッセージ
  - 実装日: 2025-10-04
  - コミット: 330dd62
  - ファイル: VoiceCapture/Utilities/VoiceCaptureError.swift
  - 確認内容:
    - 詳細なエラーメッセージ（errorDescription）
    - 失敗理由の明記（failureReason）
    - 具体的な例を含む説明

- [x] リカバリー提案
  - 実装日: 2025-10-04
  - コミット: 330dd62
  - ファイル: VoiceCapture/Utilities/VoiceCaptureError.swift
  - 確認内容:
    - 実行可能な回復提案（recoverySuggestion）
    - パーミッションエラー時のシステム設定へのショートカット
    - モデル未発見時の設定画面オープン機能

- [x] ログ記録強化
  - 状態: 既存のAppLogger機能で十分
  - AppLogger使用箇所の拡充（アニメーション開始/停止など）

### 4.3 テスト

- [ ] エンドツーエンドテスト
  - 状態: 実機テスト待ち

- [ ] エッジケーステスト
  - 状態: 実機テスト待ち

- [ ] パフォーマンス最適化
  - 状態: 実機テスト後に評価

---

## 技術的課題と解決済み問題

### 解決済み

#### 1. macOS API互換性
- **問題**: AVAudioApplication（macOS 14.0+）とmacOS 12.0ターゲットの不整合
- **解決**: AVCaptureDevice使用（macOS 12.0対応）
- **参照**: VoiceCapture/Utilities/PermissionsManager.swift:17

#### 2. Swift Concurrency
- **問題**: @MainActor ViewModelと非MainActorコンテキストの不整合
- **解決**: AppDelegateに@MainActor追加
- **参照**: VoiceCapture/AppDelegate.swift:12

#### 3. Combine AnyCancellable代入
- **問題**: .assign(to:)がVoidを返す
- **解決**: .sink { [weak self] ... }に変更
- **参照**: VoiceCapture/ViewModels/RecordingViewModel.swift:136

#### 4. 重複ファイル問題
- **問題**: 間違った場所の古いファイルをXcodeがコンパイル
- **解決**: 重複削除 + project.pbxproj修正

#### 5. 通知権限
- **問題**: LSUIElement=trueでは通知ダイアログが自動表示されない
- **解決**: アプリ起動時に明示的に権限チェック、システム環境設定誘導
- **参照**: VoiceCapture/AppDelegate.swift:61-101

#### 6. ホットキーAPI選択（Phase 2）
- **問題**: Carbon HotKey API, CGEventTap, サードパーティライブラリの選択
- **解決**: KeyboardShortcuts (Sindre Sorhus)を採用
- **理由**:
  - macOS 12.0+完全対応
  - SwiftUI統合が優秀（Recorderコンポーネント）
  - 自動競合検出、UserDefaults永続化
  - サンドボックス対応、App Store互換
  - Carbon APIのようなC互換性問題なし
  - CGEventTapのようなAccessibility権限不要
- **参照**: VoiceCapture/Extensions/KeyboardShortcuts+Names.swift

#### 7. macOS 13.0+ API互換性（Phase 2）
- **問題**: `.formStyle(.grouped)` がmacOS 13.0+専用でビルドエラー
- **解決**: `.formStyle(.grouped)` を削除（macOS 12.0でもFormは正常動作）
- **参照**: VoiceCapture/Views/Settings/SettingsView.swift:80

#### 8. NSOpenPanel表示問題（Phase 2）
- **問題**: LSUIElement=trueのメニューバーアプリでNSOpenPanelがXcodeに引き戻される
- **解決**: `NSApp.activate(ignoringOtherApps: true)` + `panel.level = .modalPanel` 追加
- **参照**: VoiceCapture/ViewModels/SettingsViewModel.swift:76-90

#### 9. entitlements権限不足（Phase 2）
- **問題**: サンドボックス環境でNSOpenPanelがクラッシュ
- **解決**: entitlementsに `com.apple.security.files.user-selected.read-write` 追加
- **参照**: VoiceCapture/VoiceCapture.entitlements

#### 10. WhisperKit API変更（Phase 3）
- **問題**: WhisperKit v0.6.0で `transcribe()` の戻り値が `TranscriptionResult?` から `[TranscriptionResult]` に変更
- **解決**: `.text` アクセスを `.first?.text` に変更
- **参照**: VoiceCapture/Services/TranscriptionService.swift:46

#### 11. AVCaptureDevice非推奨API（Phase 2）
- **問題**: `.builtInMicrophone` と `.externalUnknown` がmacOS 14.0で非推奨
- **解決**: `.microphone` と `.external` に変更
- **参照**: VoiceCapture/Models/AudioDevice.swift:36

#### 12. 文字起こしファイルを開く機能（Phase 3-4）
- **問題**: メニューバーの「最後の文字起こしを開く」ボタンが動作しない
- **原因**: TranscriptionViewModelで生成したMarkdownファイルのURLがRecordingViewModelに伝達されていなかった
- **解決**:
  - TranscriptionViewModelに`lastTranscriptionURL`プロパティ追加
  - RecordingViewModelでCombine監視により自動連携
  - MVVM + Combineパターンを維持した疎結合設計
- **参照**:
  - VoiceCapture/ViewModels/TranscriptionViewModel.swift:19,70
  - VoiceCapture/ViewModels/RecordingViewModel.swift:206-212
- **実装日**: 2025-10-04
- **コミット**: 330dd62

### 未解決・要検討

#### 1. ファイル保存場所
- **現状**: サンドボックスコンテナ内（ユーザーがアクセスしにくい）
- **選択肢**:
  - A. サンドボックス無効化（非推奨）
  - B. ダウンロードフォルダなど一般的な場所に保存
  - C. 現状維持（メニューから「最後の録音を開く」で対応）
- **決定**: Phase 2で設定画面からカスタマイズ可能に（解決）
- **状態**: 完了（2025-10-04）

#### 2. マイク選択機能の実装
- **現状**: UI表示のみ、実際の録音には反映されない
- **理由**: AVAudioRecorderは特定デバイス指定に非対応
- **必要な対応**: AudioRecordingServiceをAVAudioEngineベースに書き換え
- **影響**:
  - 録音処理の大幅な変更
  - テスト再実施が必要
- **優先度**: 中（Phase 4以降で対応検討）

#### 3. 文字起こしファイルを開く機能
- **問題**: メニューの「最後の文字起こしを開く」ボタンが動作しない
- **状態**: 未調査
- **優先度**: 高（次の対応項目）

---

## コミット履歴

```
330dd62 - feat: Phase 3修正完了・Phase 4 UX改善実装完了 (2025-10-04)
54953c2 - docs: 次回アクションプランを追加 (2025-10-04)
9f24b96 - feat: Phase 3完了 - WhisperKit統合・マイク選択UI実装 (2025-10-04)
88d8349 - docs: PROGRESS.md作成と進捗管理システム整備 (2025-10-03)
d13ca2b - feat: 通知権限の実装完了 - Phase 1完全動作確認済み (2025-10-03)
4cdd830 - feat: Phase 1 Day 2完了 - MVVM+Services アーキテクチャ実装 (2025-10-03)
afe935e - feat: Phase 1 Day 1完了 - メニューバーアプリ基本実装 (2025-10-03)
```

---

## 次のアクション

### 優先度1: 実機テスト（Phase 3-4の動作確認）

**Phase 3-4完了後の実機テスト**:
1. マイクを接続
2. 録音→自動文字起こし→Markdown保存の全フロー確認
3. Small/Mediumモデルの切り替えテスト
4. 文字起こし精度の確認（日本語・英語）
5. Phase 4実装機能の確認：
   - 録音中のパルスアニメーション
   - リッチ通知の表示
   - エラーハンドリングの動作
   - 通知からのファイル削除機能

**所要時間**: 1〜2時間（初回Whisperモデルダウンロード込み）

### 優先度2: テスト作成（任意）

**ユニットテスト**:
- RecordingViewModel
- TranscriptionViewModel
- AudioRecordingService（モック使用）
- FileStorageService

**統合テスト**:
- 録音→保存フロー
- 録音→文字起こし→保存フロー
- エラーハンドリング各種

**所要時間**: 4〜6時間

### 優先度3: マイク選択機能の実装（将来対応）

**現状**: UI表示のみ、実際の録音には未反映
**必要な作業**: AVAudioRecorder → AVAudioEngine への書き換え
**所要時間**: 4〜6時間

### Phase 4完了時点での状態

**実装完了機能（Phase 1-4）**:
- ✅ 録音開始/停止、WAV保存（Phase 1）
- ✅ グローバルホットキー（Option + P）（Phase 2）
- ✅ 設定画面UI（音質、保存先、Whisperモデル選択）（Phase 2）
- ✅ WhisperKit統合（Small/Medium選択可能）（Phase 3）
- ✅ 自動文字起こしワークフロー（Phase 3）
- ✅ Markdown出力機能（Phase 3）
- ✅ 文字起こしファイルを開く機能（Phase 3修正）
- ✅ 録音中パルスアニメーション（Phase 4）
- ✅ リッチ通知（録音時間・ファイルサイズ表示）（Phase 4）
- ✅ エラーハンドリング強化（Phase 4）
- ✅ 通知からのファイル削除機能（Phase 4）

**動作確認済み（ビルドテスト）**:
- ✅ ビルド成功（Phase 1-4すべて）
- ✅ 設定画面のUI表示
- ✅ メニューバー常駐

**未確認（マイク不在のため）**:
- ⏸ 実際の録音動作
- ⏸ 文字起こし動作
- ⏸ Whisperモデルダウンロード
- ⏸ 文字起こし精度
- ⏸ パフォーマンス
- ⏸ アニメーション・通知の実動作

**既知の制限事項**:
- ⚠️ マイク選択がUI表示のみ（実録音には反映されない - AVAudioEngine化が必要）

---

**注**: このファイルは実装進捗の単一情報源（Single Source of Truth）として機能します。実装完了後は必ず `[ ]` を `[x]` または `[VERIFIED]` に更新してください。
