# VoiceCapture Phase 2 統合ガイド

## 実装完了済みファイル

### 新規作成ファイル (3つ)
1. `/Users/kk/development/mudai_voice/VoiceCapture/VoiceCapture/Extensions/KeyboardShortcuts+Names.swift`
2. `/Users/kk/development/mudai_voice/VoiceCapture/VoiceCapture/ViewModels/SettingsViewModel.swift`
3. `/Users/kk/development/mudai_voice/VoiceCapture/VoiceCapture/Views/Settings/SettingsView.swift`

### 修正済みファイル (4つ)
1. `/Users/kk/development/mudai_voice/VoiceCapture/VoiceCapture/Models/AudioSettings.swift`
   - enum型の追加 (SampleRate, BitDepth, ChannelCount)
   - displayName プロパティ
   - 変換用プロパティ (sampleRateValue, bitDepthValue, channelCountValue)

2. `/Users/kk/development/mudai_voice/VoiceCapture/VoiceCapture/Services/AudioRecordingService.swift`
   - buildRecordingSettings() を更新して新しいenum型を使用

3. `/Users/kk/development/mudai_voice/VoiceCapture/VoiceCapture/AppDelegate.swift`
   - settingsWindow プロパティ追加
   - openSettings() 実装
   - setupKeyboardShortcuts() 準備（コメントアウト）
   - NSWindowDelegate 実装

4. `/Users/kk/development/mudai_voice/VoiceCapture/VoiceCapture/Utilities/AppLogger.swift`
   - settings カテゴリ追加

## 手動作業が必要な項目

### 1. Xcodeプロジェクトに新規ファイルを追加

Xcodeで以下の手順を実施：

1. Xcodeでプロジェクトを開く
2. 以下のファイルをプロジェクトに追加（右クリック > Add Files to "VoiceCapture"...）:
   - `Extensions/KeyboardShortcuts+Names.swift`
   - `ViewModels/SettingsViewModel.swift`
   - `Views/Settings/SettingsView.swift`

### 2. KeyboardShortcuts SPM依存関係の追加

Xcodeで以下の手順を実施：

1. プロジェクトナビゲーターでプロジェクトルートを選択
2. "VoiceCapture" ターゲットを選択
3. "General" タブ → "Frameworks, Libraries, and Embedded Content" セクション
4. "+" ボタンをクリック
5. "Add Other..." → "Add Package Dependency..."
6. URL入力: `https://github.com/sindresorhus/KeyboardShortcuts`
7. バージョン: "Up to Next Major" (最新版)
8. "Add Package" をクリック
9. "KeyboardShortcuts" を選択して "Add Package" をクリック

### 3. コメント解除

SPM依存関係追加後、以下のファイルのコメントを解除：

#### AppDelegate.swift
- 13行目: `// import KeyboardShortcuts` → `import KeyboardShortcuts`
- 45-47行目: `setupKeyboardShortcuts()` 呼び出しのコメント解除
- 139-148行目: `setupKeyboardShortcuts()` メソッド全体のコメント解除

#### KeyboardShortcuts+Names.swift
- ファイル全体のコメント解除（8-17行目）

#### SettingsView.swift
- 10行目: `// import KeyboardShortcuts` → `import KeyboardShortcuts`
- 31-37行目: KeyboardShortcuts.Recorder セクションのコメント解除

## 動作確認チェックリスト

### 基本動作
- [ ] アプリがビルド・起動できる
- [ ] メニューバーアイコンが表示される
- [ ] "設定..." メニュー項目をクリックで設定ウィンドウが開く

### 設定画面UI
- [ ] 保存先ディレクトリが表示される
- [ ] "変更..." ボタンでディレクトリ選択ダイアログが開く
- [ ] サンプルレートの選択が機能する（44.1 kHz / 48 kHz）
- [ ] ビット深度の選択が機能する（16-bit / 24-bit）
- [ ] チャンネルの選択が機能する（モノラル / ステレオ）
- [ ] 自動文字起こしのトグルが機能する
- [ ] "デフォルトに戻す" ボタンが機能する
- [ ] 設定ウィンドウを閉じても再度開ける

### 音声品質設定の反映
- [ ] 設定変更後に録音を開始し、生成されたファイルのプロパティを確認
  - サンプルレート、ビット深度、チャンネル数が設定通りか

### KeyboardShortcuts機能（SPM追加後）
- [ ] 設定画面に "ホットキー" セクションが表示される
- [ ] ホットキーのカスタマイズが可能
- [ ] Option + P（デフォルト）で録音開始/停止が動作する
- [ ] カスタマイズしたホットキーが保存される

### 永続化
- [ ] アプリを再起動しても設定が保持される
- [ ] ホットキー設定が保持される

## トラブルシューティング

### ビルドエラー: "No such module 'KeyboardShortcuts'"
→ SPM依存関係が正しく追加されていません。上記「2. KeyboardShortcuts SPM依存関係の追加」を実施してください。

### AppLogger.settings が見つからない
→ AppLogger.swift の変更が反映されていません。プロジェクトをクリーンビルドしてください（Product → Clean Build Folder）。

### 設定ウィンドウが表示されない
→ SettingsView.swift と SettingsViewModel.swift がXcodeプロジェクトに追加されているか確認してください。

### 音声設定が反映されない
→ AudioSettings.swift の変更により、既存のUserDefaults値との互換性がない可能性があります。アプリの設定をリセットするか、UserDefaultsをクリアしてください。

## 次のステップへの推奨事項

1. **Phase 3: 文字起こし機能の強化**
   - WhisperモデルのローカルまたはAPI統合
   - 文字起こし進捗表示
   - エラーハンドリングの改善

2. **Phase 4: ファイル管理UI**
   - 録音一覧表示
   - 検索・フィルタリング機能
   - タグ付け機能

3. **テストの追加**
   - SettingsViewModelのユニットテスト
   - AudioSettings enumのテスト
   - 設定永続化のテスト

4. **アクセシビリティ対応**
   - VoiceOver対応
   - キーボードナビゲーション改善

## 発見した問題・改善提案

### 潜在的な問題
1. **UserDefaults互換性**: AudioSettingsの構造変更により、既存ユーザーの設定が読み込めなくなる可能性
   - **提案**: マイグレーション処理の追加

2. **設定ウィンドウの複数インスタンス**: 現在は単一インスタンスだが、ユーザーが誤って複数開こうとした場合の挙動
   - **提案**: 現在の実装（単一インスタンス + 前面表示）で問題なし

3. **ホットキーの衝突**: システムやアプリのホットキーと衝突する可能性
   - **提案**: KeyboardShortcuts ライブラリが自動で処理（問題なし）

### 改善提案
1. **設定のバリデーション**:
   - 保存先ディレクトリの書き込み権限チェック
   - ディスク容量チェック

2. **設定のエクスポート/インポート**:
   - 設定をJSONでエクスポート
   - 他のMacへの設定移行を容易に

3. **プリセット機能**:
   - "高音質", "標準", "省スペース" などのプリセット
   - カスタムプリセットの保存

## ライセンスと著作権

KeyboardShortcuts ライブラリ:
- ライセンス: MIT License
- 作者: Sindre Sorhus
- URL: https://github.com/sindresorhus/KeyboardShortcuts

## 最終更新

2025-10-03
