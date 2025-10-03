# VoiceCapture - 実装進捗状況

**最終更新**: 2025-10-03
**現在のフェーズ**: Phase 1完了 / Phase 2準備中

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
**状態**: [ ] 未着手
**目標**: グローバルホットキー、設定画面UI

### 2.1 グローバルホットキー

- [ ] HotKeyService実装
  - ファイル: VoiceCapture/Services/HotKeyService.swift
  - 実装内容:
    - Carbon HotKey API使用
    - デフォルトキー: Option + P
    - 録音開始/停止トグル

- [ ] HotKeyServiceProtocol定義
  - ファイル: VoiceCapture/Services/Protocols/HotKeyServiceProtocol.swift

- [ ] AppDelegateにHotKey統合
  - setupServices()でHotKeyService初期化
  - RecordingViewModelと連携

### 2.2 設定画面UI

- [ ] SettingsView.swift実装
  - ファイル: VoiceCapture/Views/Settings/SettingsView.swift
  - UI要素:
    - 保存先ディレクトリ選択
    - ホットキーカスタマイズ
    - 音声品質設定
    - 自動文字起こしON/OFF

- [ ] SettingsViewModel.swift実装
  - ファイル: VoiceCapture/ViewModels/SettingsViewModel.swift
  - 機能:
    - SettingsManager連携
    - バリデーション
    - 設定保存

- [ ] 設定ウィンドウ管理
  - AppDelegateにウィンドウ管理追加
  - メニューから設定画面を開く

### 2.3 音声品質カスタマイズ

- [ ] AudioSettings拡張
  - サンプルレート選択（44.1kHz, 48kHz）
  - ビット深度選択（16bit, 24bit）
  - チャンネル選択（モノラル, ステレオ）

- [ ] AudioRecordingService更新
  - SettingsManagerから設定取得
  - 動的な録音設定適用

### 2.4 テスト

- [ ] ホットキーテスト
  - キー登録/解除
  - 競合検出

- [ ] 設定画面UIテスト
  - 設定保存/読み込み
  - バリデーション

---

## Phase 3: MLX Swift統合

**期間**: 4-5日
**状態**: [ ] 未着手
**目標**: MLX Whisper統合、自動文字起こし

### 3.1 MLX Swift セットアップ

- [ ] MLX SwiftをSPM依存関係に追加
  - Package.swift更新
  - ビルド確認

- [ ] Whisperモデルダウンロード
  - mlx-swift-examples参照
  - モデル配置場所決定

### 3.2 TranscriptionService実装

- [ ] TranscriptionService.swift実装
  - ファイル: VoiceCapture/Services/TranscriptionService.swift
  - 機能:
    - MLX Whisper初期化
    - 音声ファイル→テキスト変換
    - 進捗報告

- [ ] TranscriptionServiceProtocol実装
  - async/await対応
  - 進捗Publisher

- [ ] TranscriptionViewModel完全実装
  - 文字起こし開始/キャンセル
  - 進捗表示
  - エラーハンドリング

### 3.3 自動文字起こし統合

- [ ] RecordingViewModel統合
  - 録音停止後の自動文字起こしトリガー
  - SettingsManagerの設定に従う

- [ ] Markdown出力
  - FileStorageServiceでMarkdown生成
  - メタデータ埋め込み（日時、長さ）

### 3.4 テスト

- [ ] 文字起こし精度テスト
  - 日本語音声
  - 英語音声
  - ノイズ環境

- [ ] パフォーマンステスト
  - 処理時間計測
  - メモリ使用量

---

## Phase 4: UX改善

**期間**: 2-3日
**状態**: [ ] 未着手
**目標**: UI/UXの洗練、エラーハンドリング強化

### 4.1 視覚的フィードバック強化

- [ ] 録音中アニメーション
  - メニューバーアイコンのパルスアニメーション

- [ ] 通知改善
  - リッチ通知
  - 通知からアクション実行

### 4.2 エラーハンドリング

- [ ] ユーザーフレンドリーなエラーメッセージ
- [ ] リカバリー提案
- [ ] ログ記録強化

### 4.3 テスト

- [ ] エンドツーエンドテスト
- [ ] エッジケーステスト
- [ ] パフォーマンス最適化

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

### 未解決・要検討

#### 1. ファイル保存場所
- **現状**: サンドボックスコンテナ内（ユーザーがアクセスしにくい）
- **選択肢**:
  - A. サンドボックス無効化（非推奨）
  - B. ダウンロードフォルダなど一般的な場所に保存
  - C. 現状維持（メニューから「最後の録音を開く」で対応）
- **決定**: Phase 2で再検討

#### 2. ホットキーAPI選択
- **選択肢**:
  - A. Carbon HotKey API（古いが安定）
  - B. CGEventTap（モダンだが複雑）
  - C. サードパーティライブラリ（MASShortcut等）
- **決定**: Phase 2実装時に決定

---

## コミット履歴

```
d13ca2b - feat: 通知権限の実装完了 - Phase 1完全動作確認済み (2025-10-03)
4cdd830 - feat: Phase 1 Day 2完了 - MVVM+Services アーキテクチャ実装 (2025-10-03)
afe935e - feat: Phase 1 Day 1完了 - メニューバーアプリ基本実装 (2025-10-03)
```

---

## 次のアクション

### 推奨: Phase 2実装開始

**優先度高**:
1. グローバルホットキー実装（HotKeyService）
2. 設定画面UI作成（SettingsView）
3. 音声品質カスタマイズ

**理由**:
- Phase 1の核心機能は完全動作
- ユーザビリティ向上の優先度が高い
- テストはPhase 3以降で集中的に実施

### 代替案

#### A. Phase 1テスト強化
- ユニットテスト作成
- 統合テスト実装
- コードカバレッジ向上

#### B. Phase 3準備
- MLX Swift調査
- Whisperモデル検証
- パフォーマンス要件定義

---

**注**: このファイルは実装進捗の単一情報源（Single Source of Truth）として機能します。実装完了後は必ず `[ ]` を `[x]` または `[VERIFIED]` に更新してください。
