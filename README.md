# nonvoice

**macOS専用のワンボタン録音＋自動文字起こしアプリ**

録音の不安をゼロに、思考を音声で即座に記録し、自動で文字起こしして整理するメニューバーアプリケーション。

## 概要

VoiceCaptureは、Apple Silicon Mac専用の音声録音・文字起こしアプリケーションです。ホットキー一つで録音を開始し、停止すると自動的に高精度な文字起こしが実行されます。

### 主要機能

- ⌨️ **グローバルホットキー**: `Cmd + Shift + R` で瞬時に録音開始/停止
- 📊 **リアルタイムフィードバック**: 音量レベルメーターで録音状態を常時確認
- 💾 **自動保存**: WAV形式で高品質録音、自動的に指定フォルダへ保存
- 🤖 **AI文字起こし**: MLX Whisper (medium) による高速・高精度な日本語認識
- 📝 **Markdown出力**: 即座に編集可能なMarkdown形式で保存

## 技術スタック

- **言語**: Swift 5.9+
- **UI**: SwiftUI + AppKit
- **録音**: AVFoundation
- **文字起こし**: MLX Swift (Whisper medium)
- **対象OS**: macOS 12.0+ (Monterey以降)
- **プロセッサ**: Apple Silicon専用 (M1/M2/M3/M4)

## アーキテクチャ

**MVVM + Services Layer**

```
UI Layer (SwiftUI/AppKit)
    ↓
ViewModels (Business Logic)
    ↓
Services Layer
    ├── AudioRecordingService (AVFoundation)
    ├── TranscriptionService (MLX Swift)
    ├── FileStorageService
    ├── HotKeyService (Carbon API)
    └── NotificationService
```

## プロジェクト構造

```
mudai_voice/
├── .spec-kit/              # Spec-Kit形式の仕様管理
│   ├── specs/voice-capture/
│   │   ├── specification.md      # 詳細機能仕様書
│   │   ├── technical-plan.md     # 技術計画書
│   │   └── approval.json         # 進捗管理
│   └── architecture.md           # アーキテクチャ文書
├── plan/
│   ├── mvp_ver01.md              # 元の仕様書
│   └── implementation_plan_mlx_swift.md  # 詳細実装計画 (約4000行)
├── docs/
│   └── mlx_swift_investigation.md  # 技術調査メモ
└── (将来) VoiceCapture/          # Xcodeプロジェクト
```

## 開発フェーズ

### Phase 1: 基本録音機能（3-4日）
- Xcodeプロジェクト作成
- 録音開始/停止、WAV保存
- 視覚的フィードバック（アイコン、タイマー、音量メーター）

### Phase 2: ホットキーと設定（1-2日）
- グローバルホットキー機能
- 設定画面（SwiftUI）
- UserDefaults永続化

### Phase 3: MLX Swift統合（3-4日）
- Whisperモデル統合
- 文字起こし実装
- Markdown出力

### Phase 4: UX改善（1-2日）
- 通知機能強化
- エラーハンドリング
- パフォーマンス最適化

**総開発期間**: 3-4週間（15営業日）

## 開発状況

**[詳細な進捗状況はPROGRESS.mdを参照](PROGRESS.md)**

- [x] プロジェクト計画完了
- [x] 技術スタック決定（MLX Swift採用）
- [x] 詳細実装計画作成
- [x] Phase 1: 基本録音機能 - 完了・動作確認済み
- [ ] Phase 2: ホットキーと設定 - 次のステップ
- [ ] Phase 3: MLX Swift統合
- [ ] Phase 4: UX改善

### Phase 1完了内容（2025-10-03）

- [x] Xcodeプロジェクト作成
- [x] メニューバーアプリ実装
- [x] 録音機能（AVAudioRecorder）
- [x] WAV形式保存（サンドボックスコンテナ内）
- [x] リアルタイム音声レベルメーター
- [x] 録音タイマー（mm:ss）
- [x] メニューバーアイコン動的変更
- [x] MVVM + Servicesアーキテクチャ
- [x] マイク・通知権限管理
- [x] 録音完了通知

**実録音テスト**: 正常動作確認済み（20251003_222620.wav）

## 主要な技術的決定

### MLX Swift採用（選択肢A）

**理由**:
- Apple Silicon専用最適化（2-4倍高速）
- ネイティブSwift実装
- 外部依存なし（Python不要）
- App Store配布が容易

**代替案**:
- Python Bridge実装（フォールバック）
- whisper.cpp

### Whisper mediumモデル

**理由**: 精度とパフォーマンスのバランス

**パフォーマンス目標**:
- 1分の音声を30秒以内で処理
- RTF（Real-Time Factor）: 0.5以下

## ドキュメント

### 進捗管理
- **[PROGRESS.md](PROGRESS.md)** - 実装進捗の単一情報源（SSOT）
  - チェックリスト形式
  - 動作確認済み項目のマーク
  - 技術的課題と解決策
  - 次のアクション

### 仕様書
- [機能仕様書](.spec-kit/specs/voice-capture/specification.md)
- [技術計画書](.spec-kit/specs/voice-capture/technical-plan.md)
- [元の仕様（MVP）](plan/mvp_ver01.md)

### 実装計画
- [詳細実装計画](plan/implementation_plan_mlx_swift.md) - 約4000行の完全な実装ガイド
  - Phase 1-4の詳細タスク分解
  - 完全なコード例（5つのサービス実装）
  - テスト戦略とチェックリスト
  - リスク分析と対策

### 完了記録
- [Phase 1完了記録](VoiceCapture/plan/20251003_phase1_completion.md)

### 技術調査
- [MLX Swift技術調査](docs/mlx_swift_investigation.md)
  - Whisperサポート状況調査計画
  - パフォーマンスベンチマーク計画
  - フォールバックプラン

### アーキテクチャ
- [システムアーキテクチャ](.spec-kit/architecture.md)

## リスク管理

| リスク | 影響度 | 対策 |
|--------|--------|------|
| MLX Swift統合困難 | 高 | Python Bridgeフォールバック |
| パフォーマンス不足 | 中 | モデルサイズ調整（medium → small） |
| メモリ使用量過多 | 中 | ストリーミング処理、定期的メモリ解放 |

## 参考プロジェクト

- [mojiokoshi_project](https://github.com/koshoka/mojiokoshi_project) - MLX Whisper（Python版）の実装参考

## ライセンス

TBD

## 作成者

[@koshoka](https://github.com/koshoka)

---

**最終更新**: 2025-10-03
**バージョン**: 0.2.0 (Phase 1完了)
**リポジトリ**: https://github.com/koshoka/mudai_voice
