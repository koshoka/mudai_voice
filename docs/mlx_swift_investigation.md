# MLX Swift技術調査レポート

**プロジェクト**: VoiceCapture (mudai_voice)
**調査日**: 2025-10-03
**調査者**: Development Team
**バージョン**: 1.0

---

## 目次

1. [調査目的](#1-調査目的)
2. [MLX Swift概要](#2-mlx-swift概要)
3. [Whisperサポート状況](#3-whisperサポート状況)
4. [実装パターン調査](#4-実装パターン調査)
5. [パフォーマンス分析](#5-パフォーマンス分析)
6. [代替案の準備](#6-代替案の準備)
7. [調査結論](#7-調査結論)

---

## 1. 調査目的

### 1.1 主要な調査項目

このドキュメントは、VoiceCaptureプロジェクトにおけるMLX Swift採用の技術的実現可能性を調査するためのものである。

**調査すべき項目**:
1. MLX SwiftがWhisperモデルをサポートしているか
2. サンプルコードやドキュメントが存在するか
3. 既存のmojiokoshi_project（MLX Python版）の知見を活用できるか
4. パフォーマンスが要件を満たすか
5. 実装の複雑度はどの程度か

### 1.2 成功基準

以下の条件を満たす場合、MLX Swift採用を確定する：

- [ ] WhisperモデルをSwiftからロードできる
- [ ] 音声ファイルを文字起こしできる
- [ ] 日本語認識が機能する
- [ ] 1分の音声を30秒以内で処理できる
- [ ] 実装複雑度が許容範囲（2週間以内で実装可能）

---

## 2. MLX Swift概要

### 2.1 MLXとは

**MLX (Machine Learning for X)**:
- Appleが開発したApple Silicon専用の機械学習フレームワーク
- Metal Performance Shaders（MPS）を直接活用
- NumPyライクなAPI
- Swift、Python、C++バインディングを提供

**公式リポジトリ**:
- Swift版: https://github.com/ml-explore/mlx-swift
- Python版: https://github.com/ml-explore/mlx

### 2.2 MLX Swiftの特徴

**メリット**:
1. **Apple Silicon最適化**
   - Metal APIの直接活用
   - Unified Memory Architectureの効率的利用
   - 従来のフレームワークより2-4倍高速

2. **Swiftネイティブ**
   - 型安全
   - async/await対応
   - SwiftUIとの統合が容易

3. **軽量**
   - 外部ランタイム不要
   - アプリケーションバンドルに含められる

**デメリット**:
1. **新しいフレームワーク**
   - ドキュメントが少ない可能性
   - コミュニティが小さい

2. **Apple Silicon専用**
   - Intel Macでは動作しない
   - クロスプラットフォーム展開が困難

### 2.3 調査アクションアイテム

#### Phase 3開始前に実施すべき調査

```bash
# 1. リポジトリのクローン
git clone https://github.com/ml-explore/mlx-swift.git
cd mlx-swift

# 2. Whisper関連の検索
grep -r "whisper" . --include="*.swift"
grep -r "speech" . --include="*.swift"
grep -r "transcribe" . --include="*.swift"

# 3. サンプルコードの確認
find . -name "Examples" -type d
find . -name "*Example*.swift"

# 4. ドキュメントの確認
find . -name "*.md" | xargs grep -i whisper
find . -name "Documentation" -type d

# 5. Package.swiftの確認
cat Package.swift | grep -A 10 "products"
cat Package.swift | grep -A 10 "targets"

# 6. テストコードの確認
find . -name "*Tests.swift" | xargs grep -i whisper
```

---

## 3. Whisperサポート状況

### 3.1 調査ポイント

#### 3.1.1 MLX Swiftでのモデルサポート

**確認事項**:
- [ ] Whisperモデルのロード方法
- [ ] 対応モデル形式（GGML、SafeTensors、CoreML）
- [ ] モデルサイズ（tiny、base、small、medium、large）
- [ ] 言語サポート（日本語対応確認）

**調査コマンド例**:
```swift
// テストスクリプト: test_whisper_load.swift
import MLX

do {
    // モデルロードのテスト
    let modelPath = "/path/to/ggml-medium.bin"
    // let model = try WhisperModel.load(path: modelPath)
    // 実際のAPIは公式ドキュメントを参照

    print("Model loaded successfully")
} catch {
    print("Model load failed: \(error)")
}
```

#### 3.1.2 既存のMLX Python実装との比較

**既存プロジェクトの分析**:
`/Users/kk/windsurf-ai/mojiokoshi_project/transcribe.py`を参照し、以下を確認：

```python
# Python版の実装（参考）
import mlx_whisper

result = mlx_whisper.transcribe(
    audio_path,
    path_or_hf_repo="mlx-community/whisper-large-v3-mlx",
    language="ja"
)
```

**Swift版で必要な要素**:
1. モデルパスの指定
2. 音声ファイルの読み込み
3. 言語指定（"ja"）
4. 文字起こし実行
5. 結果の取得

### 3.2 モデルフォーマット調査

#### 3.2.1 サポートされるフォーマット

**確認項目**:
- [ ] GGML形式（whisper.cppと互換）
- [ ] SafeTensors形式
- [ ] CoreML形式
- [ ] カスタム形式

**既存モデルの活用**:
既存のmojiokoshi_projectで使用しているMLX Whisperモデルを確認：

```bash
# 既存プロジェクトで使用しているモデルの確認
cd /Users/kk/windsurf-ai/mojiokoshi_project
python3 -c "import mlx_whisper; print(mlx_whisper.__file__)"

# モデルの保存場所を確認
ls -lh ~/.cache/huggingface/hub/ | grep whisper
```

#### 3.2.2 モデルダウンロード方法

**オプション1: Hugging Faceから直接**
```bash
# Hugging Face CLIを使用
pip install huggingface_hub

# モデルダウンロード
huggingface-cli download mlx-community/whisper-medium-mlx
```

**オプション2: whisper.cppのモデル変換**
```bash
# whisper.cppをクローン
git clone https://github.com/ggerganov/whisper.cpp
cd whisper.cpp

# モデルダウンロード
bash ./models/download-ggml-model.sh medium

# 変換（必要な場合）
# python convert-ggml-to-mlx.py models/ggml-medium.bin
```

**オプション3: 既存のPython版モデルを流用**
```bash
# mojiokoshi_projectで使用しているモデルをコピー
cp -r ~/.cache/huggingface/hub/models--mlx-community--whisper-medium-mlx \
      /Users/kk/development/mudai_voice/VoiceCapture/VoiceCapture/MLX/WhisperModel/
```

### 3.3 Whisper API調査

#### 3.3.1 推定されるSwift API

MLX Swiftの一般的なパターンから推測されるAPI：

```swift
// 推定されるAPI（実際のAPIは公式ドキュメントを参照）
import MLX
import MLXWhisper

// モデルロード
let model = try WhisperModel.load(path: modelPath)

// 文字起こし
let result = try await model.transcribe(
    audioPath: "/path/to/audio.wav",
    language: "ja",
    task: .transcribe
)

print(result.text)
```

#### 3.3.2 調査スクリプトのプロトタイプ

```swift
// InvestigationScript.swift
// Phase 3開始直後に実行するスクリプト

import Foundation
import MLX

func investigateMLXWhisper() async {
    print("=== MLX Whisper調査開始 ===\n")

    // 1. MLXの初期化確認
    print("1. MLX初期化確認")
    // let device = mx.defaultDevice()
    // print("   デバイス: \(device)")

    // 2. モデルファイルの存在確認
    print("\n2. モデルファイル確認")
    let modelPath = "/path/to/ggml-medium.bin"
    let modelExists = FileManager.default.fileExists(atPath: modelPath)
    print("   モデル存在: \(modelExists)")

    // 3. テスト音声ファイル作成
    print("\n3. テスト音声ファイル作成")
    let testAudioPath = createTestAudio()
    print("   テスト音声: \(testAudioPath)")

    // 4. 文字起こしテスト（実際のAPIを使用）
    print("\n4. 文字起こしテスト")
    do {
        // let result = try await performTranscription(audioPath: testAudioPath)
        // print("   結果: \(result)")
        print("   → APIの実装待ち")
    } catch {
        print("   エラー: \(error)")
    }

    print("\n=== 調査完了 ===")
}

func createTestAudio() -> String {
    // 簡単なWAVファイルを生成
    // または既存のテストファイルを使用
    return "/tmp/test_audio.wav"
}

// 実行
Task {
    await investigateMLXWhisper()
}
```

---

## 4. 実装パターン調査

### 4.1 Python版の実装パターン分析

#### 4.1.1 mojiokoshi_projectの実装

既存の`/Users/kk/windsurf-ai/mojiokoshi_project/transcribe.py`から学べること：

**主要な実装パターン**:

```python
# 1. モデルの指定
MODEL_SIZE = "large-v3"
LANGUAGE = "ja"

# 2. 文字起こし実行
result = mlx_whisper.transcribe(
    str(audio_input_path),
    path_or_hf_repo=f"mlx-community/whisper-{MODEL_SIZE}-mlx",
    language=LANGUAGE,
    verbose=True
)

# 3. 結果の取得
text = result["text"]
segments = result.get("segments", [])
```

**Swift版への変換**:

```swift
// Swift版の等価実装
let modelSize = "large-v3"
let language = "ja"

let result = try await whisper.transcribe(
    audioPath: audioInputPath,
    model: "whisper-\(modelSize)-mlx",
    language: language,
    verbose: true
)

let text = result.text
let segments = result.segments
```

#### 4.1.2 エラーハンドリングパターン

**Python版**:
```python
try:
    result = mlx_whisper.transcribe(audio_path)
except Exception as e:
    print(f"文字起こしエラー: {e}")
    return None
```

**Swift版**:
```swift
do {
    let result = try await whisper.transcribe(audioPath: audioPath)
    return result.text
} catch let error as WhisperError {
    AppLogger.transcription.error("Whisperエラー: \(error)")
    throw VoiceCaptureError.transcriptionFailed(underlying: error)
} catch {
    AppLogger.transcription.error("予期しないエラー: \(error)")
    throw VoiceCaptureError.transcriptionFailed(underlying: error)
}
```

### 4.2 非同期処理パターン

#### 4.2.1 Swift Concurrency活用

```swift
actor TranscriptionService {
    private let whisperModel: WhisperModel

    func transcribe(audioURL: URL) async throws -> String {
        // Actorによる並行処理の安全性確保
        return try await performTranscription(audioURL: audioURL)
    }

    private func performTranscription(audioURL: URL) async throws -> String {
        // 重い処理をバックグラウンドで実行
        return try await Task.detached(priority: .userInitiated) {
            // Whisper実行
            let result = try await self.whisperModel.transcribe(audioPath: audioURL.path)
            return result.text
        }.value
    }
}
```

#### 4.2.2 進捗報告パターン

```swift
func transcribeWithProgress(
    audioURL: URL,
    progressCallback: @escaping (Float) -> Void
) async throws -> String {
    var progress: Float = 0.0

    // チャンク処理での進捗報告
    let chunks = try await preprocessAudio(audioURL)

    for (index, chunk) in chunks.enumerated() {
        let chunkResult = try await transcribeChunk(chunk)

        progress = Float(index + 1) / Float(chunks.count)
        progressCallback(progress)
    }

    return combineResults(chunks)
}
```

### 4.3 メモリ管理パターン

#### 4.3.1 大容量モデルのメモリ管理

```swift
class WhisperModelManager {
    private var loadedModel: WhisperModel?
    private let modelPath: String

    func getModel() async throws -> WhisperModel {
        if let model = loadedModel {
            return model
        }

        // 遅延ロード
        let model = try await WhisperModel.load(path: modelPath)
        loadedModel = model
        return model
    }

    func unloadModel() {
        loadedModel = nil
        // 明示的なメモリ解放
    }

    deinit {
        unloadModel()
    }
}
```

---

## 5. パフォーマンス分析

### 5.1 ベンチマーク計画

#### 5.1.1 測定項目

**計測すべき指標**:
1. **モデルロード時間**
   - 初回ロード: 許容値 5秒以内
   - 2回目以降: キャッシュ活用

2. **文字起こし速度**
   - 1分の音声: 30秒以内で処理
   - リアルタイム係数（RTF）: 0.5以下が目標

3. **メモリ使用量**
   - モデルサイズ: medium（約1.5GB）
   - 実行時メモリ: 2GB以内

4. **精度**
   - 日本語認識率: 主観評価で80%以上

#### 5.1.2 ベンチマークスクリプト

```swift
// BenchmarkScript.swift
import Foundation

class WhisperBenchmark {
    func runBenchmark() async throws {
        print("=== Whisper Performance Benchmark ===\n")

        // 1. モデルロード時間計測
        let modelLoadStart = Date()
        let model = try await loadModel()
        let modelLoadTime = Date().timeIntervalSince(modelLoadStart)
        print("モデルロード時間: \(String(format: "%.2f", modelLoadTime))秒")

        // 2. 文字起こし速度計測
        let testFiles = [
            ("30秒音声", "/path/to/test_30s.wav"),
            ("1分音声", "/path/to/test_60s.wav"),
            ("3分音声", "/path/to/test_180s.wav")
        ]

        for (name, path) in testFiles {
            let start = Date()
            let result = try await model.transcribe(audioPath: path)
            let duration = Date().timeIntervalSince(start)

            let audioDuration = getAudioDuration(path)
            let rtf = duration / audioDuration

            print("\n\(name):")
            print("  処理時間: \(String(format: "%.2f", duration))秒")
            print("  RTF: \(String(format: "%.2f", rtf))")
            print("  文字数: \(result.text.count)")
        }

        // 3. メモリ使用量計測
        let memoryUsage = getMemoryUsage()
        print("\nメモリ使用量: \(String(format: "%.2f", Double(memoryUsage) / 1024 / 1024))MB")
    }

    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        return kerr == KERN_SUCCESS ? info.resident_size : 0
    }
}
```

### 5.2 既存実装（Python版）のパフォーマンス

**mojiokoshi_projectの実績**:
- デバイス: Apple Silicon M4 Pro
- モデル: large-v3
- 処理速度: 約2-4倍高速（従来比）

**参考データ**（`MLX_WHISPER_USAGE_GUIDE.md`より）:

```
| 項目 | MLX版 | 従来版 |
|------|-------|--------|
| GPU活用 | MPS直接 | CUDA互換層 |
| 処理速度 | **2-4倍高速** | 標準 |
| メモリ使用 | **最適化** | 大きめ |
| 電力効率 | **優秀** | 普通 |
```

**Swift版への期待値**:
- Python版と同等かそれ以上のパフォーマンス
- ネイティブ実装による低レイテンシ
- メモリ管理の効率化

---

## 6. 代替案の準備

### 6.1 フォールバックプラン: Python Bridge

#### 6.1.1 実装パターン

MLX Swift統合が困難な場合の代替実装：

```swift
class PythonBridgeTranscriptionService: TranscriptionServiceProtocol {
    private let pythonPath: String
    private let scriptPath: String

    init() {
        self.pythonPath = "/usr/bin/python3" // または仮想環境のPython
        self.scriptPath = Bundle.main.path(forResource: "transcribe_cli", ofType: "py")!
    }

    func transcribe(audioURL: URL) async throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: pythonPath)
        process.arguments = [scriptPath, audioURL.path]

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            throw VoiceCaptureError.transcriptionFailed(underlying: NSError(
                domain: "PythonBridge",
                code: Int(process.terminationStatus),
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            ))
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: outputData, encoding: .utf8) ?? ""
    }
}
```

#### 6.1.2 Python CLIスクリプト

```python
#!/usr/bin/env python3
# transcribe_cli.py
# Swift から呼び出される文字起こしスクリプト

import sys
import mlx_whisper

def main():
    if len(sys.argv) < 2:
        print("Usage: transcribe_cli.py <audio_file>", file=sys.stderr)
        sys.exit(1)

    audio_path = sys.argv[1]

    try:
        result = mlx_whisper.transcribe(
            audio_path,
            path_or_hf_repo="mlx-community/whisper-medium-mlx",
            language="ja"
        )

        print(result["text"])
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
```

#### 6.1.3 配布時の考慮事項

**Python環境の同梱**:

```bash
# pyinstallerを使用してスタンドアロン実行ファイルを作成
pip install pyinstaller

pyinstaller --onefile --add-data "models:models" transcribe_cli.py

# 生成された実行ファイルをアプリバンドルに含める
cp dist/transcribe_cli VoiceCapture.app/Contents/Resources/
```

**Swiftからの呼び出し更新**:
```swift
let bundleResourcePath = Bundle.main.resourcePath!
let pythonExecutable = "\(bundleResourcePath)/transcribe_cli"

process.executableURL = URL(fileURLWithPath: pythonExecutable)
process.arguments = [audioURL.path]
```

### 6.2 判断基準

**MLX Swiftを採用する条件**:
- [ ] ドキュメントが十分に存在する
- [ ] サンプルコードが動作する
- [ ] パフォーマンスが要件を満たす
- [ ] 実装複雑度が許容範囲
- [ ] コミュニティサポートが期待できる

**Python Bridgeにフォールバックする条件**:
- [ ] 上記のいずれかが満たされない
- [ ] Phase 3の初期2日で実現可能性が低いと判断
- [ ] ベンチマークで期待値を下回る

**切り替えタイミング**:
- Phase 3開始から48時間以内に判断
- 遅くともPhase 3の5日目（Day 10）までに決定

---

## 7. 調査結論

### 7.1 Phase 3開始時の調査チェックリスト

Phase 3の最初の2日間で以下を実施：

#### Day 6（Phase 3 Day 1）
- [ ] MLX Swiftリポジトリのクローン
- [ ] Whisper関連コードの検索
- [ ] ドキュメントの精読
- [ ] サンプルコードの実行
- [ ] Package.swiftの設定
- [ ] 簡単なテストスクリプトの実行

#### Day 7（Phase 3 Day 2）
- [ ] Whisperモデルのダウンロード
- [ ] モデルロードのテスト
- [ ] 簡単な文字起こしテスト
- [ ] パフォーマンスベンチマーク
- [ ] MLX Swift採用の最終判断

### 7.2 Go/No-Go判断基準

**Go（MLX Swift採用）**:
```
✅ Whisperモデルをロードできた
✅ 文字起こしが動作した
✅ 日本語が認識された
✅ パフォーマンスが許容範囲
✅ 実装複雑度が許容範囲
→ MLX Swift実装を継続
```

**No-Go（Python Bridgeに切り替え）**:
```
❌ 上記のいずれかが不可
→ Python Bridge実装に即座に切り替え
→ 既存のmojiokoshi_projectコードを活用
→ 配布時はPython環境を同梱
```

### 7.3 調査報告書テンプレート

Phase 3の初期調査完了後、以下の形式で報告：

```markdown
# MLX Swift調査完了報告

**調査日**: YYYY-MM-DD
**調査者**: [Your Name]

## 調査結果サマリ

- [x] MLX Swiftリポジトリ調査完了
- [x] Whisperサポート状況確認
- [x] サンプルコード実行成功/失敗
- [x] パフォーマンスベンチマーク実施

## 主要な発見事項

1. **Whisperサポート**: [詳細]
2. **API仕様**: [詳細]
3. **パフォーマンス**: [ベンチマーク結果]
4. **実装複雑度**: [評価]

## 最終判断

- [ ] **Go**: MLX Swift実装を継続
- [ ] **No-Go**: Python Bridgeに切り替え

**理由**: [詳細な理由]

## 次のステップ

- [具体的なアクション]
```

---

## 8. 参考リンク

### 8.1 公式ドキュメント

- [MLX Swift GitHub](https://github.com/ml-explore/mlx-swift)
- [MLX Python GitHub](https://github.com/ml-explore/mlx)
- [Apple ML Docs](https://developer.apple.com/machine-learning/)

### 8.2 既存プロジェクト

- [mojiokoshi_project](/Users/kk/windsurf-ai/mojiokoshi_project) - MLX Whisper（Python版）

### 8.3 コミュニティ

- [MLX Discord](https://discord.gg/mlx)（実際のリンクを確認）
- [Swift Forums](https://forums.swift.org/)
- [Hugging Face - MLX Models](https://huggingface.co/mlx-community)

---

**最終更新日**: 2025-10-03
**次回更新**: Phase 3開始時（Day 7完了後）
