# Phase 3: 文字起こし機能 セットアップ手順

## 実装完了項目

✅ macOS最小バージョンを15.0に変更
✅ AudioSettingsにWhisperModel enum追加
✅ SettingsManagerにwhisperModelプロパティ追加
✅ SettingsViewにWhisperモデル選択Picker追加
✅ TranscriptionServiceProtocol定義
✅ TranscriptionService実装
✅ TranscriptionViewModel完全実装
✅ VoiceCaptureErrorの修正（transcriptionFailed対応）

## 🚨 ビルド前に必須の手順

### 1. WhisperKit SPM依存関係の追加

Xcodeで以下の手順を実行してください：

1. プロジェクトファイル `VoiceCapture.xcodeproj` をXcodeで開く
2. メニューから **File → Add Package Dependencies...** を選択
3. 検索欄に以下のURLを入力：
   ```
   https://github.com/argmaxinc/WhisperKit
   ```
4. Dependency Rule: **Up to Next Major Version** を選択（最新バージョンを使用）
5. **Add Package** をクリック
6. ターゲット **VoiceCapture** にチェックが入っていることを確認
7. **Add Package** をクリックして完了

### 2. 新規ファイルをXcodeプロジェクトに追加

以下の2つのファイルをXcodeプロジェクトに追加する必要があります：

#### 2-1. TranscriptionServiceProtocol.swift

1. Xcodeのプロジェクトナビゲータで **Services/Protocols** フォルダを右クリック
2. **Add Files to "VoiceCapture"...** を選択
3. 以下のファイルを選択：
   ```
   VoiceCapture/Services/Protocols/TranscriptionServiceProtocol.swift
   ```
4. **Options**で以下を確認：
   - ✅ Copy items if needed: チェックを外す（既にプロジェクト内にあるため）
   - ✅ Add to targets: VoiceCapture にチェック
5. **Add** をクリック

#### 2-2. TranscriptionService.swift

1. Xcodeのプロジェクトナビゲータで **Services** フォルダを右クリック
2. **Add Files to "VoiceCapture"...** を選択
3. 以下のファイルを選択：
   ```
   VoiceCapture/Services/TranscriptionService.swift
   ```
4. **Options**で以下を確認：
   - ✅ Copy items if needed: チェックを外す
   - ✅ Add to targets: VoiceCapture にチェック
5. **Add** をクリック

### 3. ビルド実行

1. Xcodeで **Product → Clean Build Folder** (⇧⌘K) を実行
2. **Product → Build** (⌘B) を実行
3. エラーがないことを確認

## 動作確認手順

### 1. 初回起動時の確認

1. アプリを起動
2. マイクアクセス権限が求められたら許可
3. 通知権限が求められたら許可

### 2. Whisperモデル設定の確認

1. メニューバーアイコンをクリック
2. **設定...** を選択
3. **文字起こし** セクションを確認
4. **Whisperモデル** のPickerで **Small** または **Medium** が選択できることを確認

### 3. 文字起こし機能のテスト

1. **自動文字起こし** をオンにする（デフォルトでオン）
2. メニューバーアイコンから **録音開始** を選択
3. 何か話す（例：「これはテストです」）
4. **録音停止** を選択
5. 通知で録音完了が表示される
6. 数秒後、文字起こし完了の通知が表示される
7. **最後の文字起こしを開く** で結果を確認

## トラブルシューティング

### WhisperKitのモデルダウンロード

初回実行時、WhisperKitは自動的にモデルをダウンロードします：

- **Small モデル**: 約500MB
- **Medium モデル**: 約1.5GB

ダウンロードには時間がかかる場合があります。インターネット接続を確認してください。

### ビルドエラー

#### "Cannot find 'WhisperKit' in scope"

→ WhisperKitのSPM依存関係が追加されていません。上記の手順1を実行してください。

#### "Cannot find type 'TranscriptionServiceProtocol' in scope"

→ 新規ファイルがプロジェクトに追加されていません。上記の手順2を実行してください。

### 実行時エラー

#### "WhisperKitの初期化に失敗しました"

→ macOS 15.0以降を使用しているか確認してください。

#### "文字起こし結果が空です"

→ 録音時に音声が正しく入力されているか確認してください。

## 実装の詳細

### アーキテクチャ

```
┌─────────────────────────────────────┐
│         AppDelegate                 │
│  (依存性注入・セットアップ)          │
└─────────────────────────────────────┘
              │
              ├─→ RecordingViewModel
              │   ├─→ AudioRecordingService
              │   ├─→ FileStorageService
              │   ├─→ NotificationService
              │   └─→ TranscriptionViewModel
              │
              └─→ TranscriptionViewModel
                  ├─→ TranscriptionService (WhisperKit)
                  ├─→ FileStorageService
                  └─→ NotificationService
```

### ファイル変更一覧

#### 新規作成

- `Services/Protocols/TranscriptionServiceProtocol.swift`
- `Services/TranscriptionService.swift`

#### 更新

- `Info.plist` - macOS 15.0最小バージョン
- `project.pbxproj` - macOS 15.0 Deployment Target
- `Models/AudioSettings.swift` - WhisperModel enum追加
- `Utilities/SettingsManager.swift` - whisperModelプロパティ追加
- `ViewModels/SettingsViewModel.swift` - whisperModelバインディング追加
- `Views/Settings/SettingsView.swift` - Whisperモデル選択Picker追加
- `ViewModels/TranscriptionViewModel.swift` - 完全実装
- `Utilities/VoiceCaptureError.swift` - transcriptionFailed修正

## 次のステップ

Phase 3完了後、以下の機能拡張が可能です：

1. **UI改善**: 文字起こし進捗表示
2. **履歴機能**: 過去の録音・文字起こし一覧表示
3. **編集機能**: 文字起こし結果の編集・修正
4. **エクスポート**: PDF、テキスト形式での出力
5. **クラウド同期**: iCloud Driveとの連携

---

最終更新: 2025-10-04
