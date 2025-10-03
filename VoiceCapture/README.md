# VoiceCapture - macOS Menubar Application

音声録音と文字起こしを行うmacOSメニューバーアプリケーション

## プロジェクト情報

- **Product Name**: VoiceCapture
- **Bundle Identifier**: com.yourdomain.VoiceCapture
- **Minimum macOS**: 12.0
- **Interface**: SwiftUI
- **Language**: Swift 5.0+

## 機能

- メニューバーのみ表示（Dockアイコンなし）
- マイク録音機能
- 文字起こし機能
- グローバルホットキー対応

## プロジェクト構造

```
VoiceCapture/
├── VoiceCapture.xcodeproj/         # Xcodeプロジェクトファイル
│   ├── project.pbxproj              # プロジェクト設定
│   └── project.xcworkspace/         # ワークスペース設定
└── VoiceCapture/                    # ソースコード
    ├── VoiceCaptureApp.swift        # アプリケーションエントリーポイント
    ├── AppDelegate.swift            # メニューバー管理
    ├── Info.plist                   # アプリケーション設定
    ├── VoiceCapture.entitlements    # アプリケーション権限
    └── Assets.xcassets/             # アセットカタログ
```

## ビルド方法

### Xcodeで開く

```bash
open VoiceCapture.xcodeproj
```

### コマンドラインでビルド

```bash
xcodebuild -project VoiceCapture.xcodeproj -scheme VoiceCapture -configuration Debug build
```

## 必要な権限

このアプリケーションは以下の権限が必要です：

- **マイクアクセス** (NSMicrophoneUsageDescription)
  - 音声を録音して文字起こしするために使用

- **Apple Eventsアクセス** (NSAppleEventsUsageDescription)
  - グローバルホットキーを登録するために使用

- **Entitlements**:
  - `com.apple.security.device.audio-input` - マイク入力
  - `com.apple.security.automation.apple-events` - Apple Eventsアクセス

## 実装済み機能

- メニューバーアイコン表示（SF Symbol: mic.fill）
- 基本メニュー項目：
  - 録音開始
  - 最後の録音を開く
  - 最後の文字起こしを開く
  - 設定...
  - VoiceCaptureについて
  - 終了

## 今後実装予定の機能

- 実際の録音機能
- 文字起こし機能（MLX Swift統合）
- 設定画面
- ホットキー登録
- ファイル管理
- 通知機能

## 開発環境

- macOS 12.0以降
- Xcode 15.0以降
- Swift 5.0以降

## ライセンス

[ライセンス情報を追加してください]

## 作成日

2025-10-03
