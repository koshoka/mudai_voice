※この仕様書は、MVP（Minimum Viable Product）開発のためのものです。

# VoiceCapture MVP開発仕様書

## プロジェクト概要

**プロジェクト名**: VoiceCapture（仮称）

**コンセプト**: 
録音の不安をゼロに、思考を音声で即座に記録し、自動で文字起こしして整理するmacOSメニューバーアプリ



**ユーザーの課題**:
- 録音中に「ちゃんと録音できているか」という不安がある
- 途中で確認すると思考が浅くなる
- 録音したものを放置してしまう（管理ができない）
- 文字起こしして活用したいが、手間がかかる

---

## MVP機能仕様（Phase 1）

### 1. 録音機能

#### 1.1 グローバルホットキー
- ユーザーが設定した任意のキーコンビネーションで録音開始/停止
- トグル式：同じキーで開始と停止
- デフォルトキー：`Command + Shift + R`（設定で変更可能）

#### 1.2 録音中の視覚的フィードバック
- **メニューバーアイコン**
  - 通常時：マイクアイコン（グレー）
  - 録音中：マイクアイコン（赤）または点滅
- **録音時間表示**
  - フォーマット：`mm:ss`
  - メニューバーまたはポップアップに表示
- **音量レベルメーター**
  - リアルタイムで音量を可視化
  - ユーザーが「録音できている」ことを確認できる

#### 1.3 録音品質
- **フォーマット**: WAV（非圧縮）
- **サンプルレート**: 44.1kHz（デフォルト）
  - 設定で16kHz, 22.05kHz, 44.1kHz, 48kHzから選択可能
- **ビット深度**: 16bit（デフォルト）
  - 設定で16bit/24bitから選択可能
- **チャンネル**: モノラル（デフォルト）
  - 設定でステレオも選択可能

### 2. 自動保存機能

#### 2.1 ファイル名規則
- **形式**: `YYYYMMDD_HHMMSS.wav`
- **例**: `20250103_143022.wav`
- 日時は録音開始時刻を使用

#### 2.2 保存先
- ユーザーが設定で指定したフォルダに保存
- デフォルト：`~/Documents/VoiceCapture/`
- フォルダが存在しない場合は自動作成

#### 2.3 保存完了通知
- macOS通知センターに通知を表示
- 通知内容：
  - タイトル：「録音完了」
  - 本文：「ファイル名: 20250103_143022.wav」
  - アクション：「Finderで開く」ボタン

### 3. 文字起こし機能

#### 3.1 文字起こしエンジン
- **使用モデル**: Whisper medium
- **実装方法**: Whisper.cpp（macOSネイティブ統合）
- **言語**: 日本語（ja）を指定

#### 3.2 実行タイミング
- 録音停止直後に自動実行（デフォルト）
- 設定で自動実行ON/OFFを切り替え可能

#### 3.3 文字起こし中のフィードバック
- メニューバーアイコンに処理中インジケーター表示
- 通知またはポップアップで「文字起こし中...」を表示
- 進捗率を表示（可能であれば）

#### 3.4 出力フォーマット（Markdown）
**ファイル名**: `YYYYMMDD_HHMMSS.md`（WAVファイルと同名）

**フォーマット**:
```markdown
# 録音 YYYY-MM-DD HH:MM:SS

**録音日時**: YYYY年MM月DD日 HH:MM:SS
**録音時間**: mm:ss
**ファイル名**: YYYYMMDD_HHMMSS.wav

---

[文字起こし内容がここに入る]
```

#### 3.5 文字起こし完了通知
- macOS通知センターに通知を表示
- 通知内容：
  - タイトル：「文字起こし完了」
  - 本文：「ファイル名: 20250103_143022.md」
  - アクション：「ファイルを開く」ボタン

### 4. 設定画面（GUI）

#### 4.1 設定項目
1. **ホットキー設定**
   - キーコンビネーションを記録するUI
   - 現在の設定を表示
   - 「録音するキーを押してください」プロンプト

2. **保存先フォルダ**
   - フォルダ選択ダイアログ
   - 現在の保存先パスを表示
   - 「フォルダを選択」ボタン

3. **文字起こし設定**
   - 自動実行ON/OFF（チェックボックス）
   - Whisperモデル選択（将来的にsmall/medium/large）
   - 現状はmedium固定でOK

4. **録音品質設定**
   - サンプルレート選択（ドロップダウン）
   - ビット深度選択（ドロップダウン）
   - チャンネル選択（モノラル/ステレオ）

#### 4.2 設定の保存
- UserDefaultsを使用してローカルに保存
- アプリ再起動時に設定を復元

### 5. メニューバー機能

#### 5.1 メニュー項目
- **録音開始/停止** - ホットキーと同じ機能
- **最後の録音を開く** - Finderで最新のWAVファイルを表示
- **最後の文字起こしを開く** - 最新のMDファイルをデフォルトエディタで開く
- **---**（セパレーター）
- **設定...** - 設定画面を開く
- **VoiceCaptureについて** - バージョン情報等
- **終了** - アプリを終了

---

## 技術スタック

### 開発環境
- **言語**: Swift 5.9以降
- **IDE**: Xcode 15.0以降
- **対象OS**: macOS 12.0 (Monterey) 以降

### フレームワーク・ライブラリ
1. **SwiftUI** - GUI構築
2. **AppKit** - メニューバーアプリ、ホットキー
3. **AVFoundation** - オーディオ録音
4. **Whisper.cpp** - 文字起こし（C++ライブラリのSwiftバインディング）
5. **UserNotifications** - 通知表示

### 外部依存
- **Whisper.cpp**: https://github.com/ggerganov/whisper.cpp
- **Whisper model (medium)**: ダウンロードが必要

---

## プロジェクト構成

```
VoiceCapture/
├── VoiceCapture.xcodeproj
├── VoiceCapture/
│   ├── VoiceCaptureApp.swift          # アプリエントリーポイント
│   ├── AppDelegate.swift              # メニューバー管理
│   ├── Models/
│   │   ├── RecordingManager.swift    # 録音管理
│   │   ├── TranscriptionManager.swift # 文字起こし管理
│   │   └── SettingsManager.swift     # 設定管理
│   ├── Views/
│   │   ├── SettingsView.swift        # 設定画面
│   │   └── StatusView.swift          # 録音状態表示
│   ├── Utilities/
│   │   ├── HotKeyManager.swift       # グローバルホットキー
│   │   └── FileManager+Extensions.swift # ファイル操作
│   ├── Resources/
│   │   ├── Assets.xcassets           # アイコン等
│   │   └── Info.plist
│   └── Whisper/
│       ├── whisper.cpp (統合)
│       └── WhisperBridge.swift       # C++とSwiftのブリッジ
└── Models/                            # Whisperモデルファイル
    └── ggml-medium.bin
```

---

## 実装の詳細

### 1. メニューバーアプリの基本構造

#### VoiceCaptureApp.swift
```swift
import SwiftUI

@main
struct VoiceCaptureApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
```

#### AppDelegate.swift
```swift
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var recordingManager: RecordingManager?
    var hotKeyManager: HotKeyManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // メニューバーアイテム作成
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "mic.fill", accessibilityDescription: "VoiceCapture")
        }
        
        // メニュー構築
        setupMenu()
        
        // 録音マネージャー初期化
        recordingManager = RecordingManager()
        
        // ホットキー設定
        hotKeyManager = HotKeyManager()
        hotKeyManager?.register(keyCode: /* 設定から取得 */) { [weak self] in
            self?.toggleRecording()
        }
    }
    
    func setupMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "録音開始", action: #selector(toggleRecording), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "最後の録音を開く", action: #selector(openLastRecording), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "最後の文字起こしを開く", action: #selector(openLastTranscription), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "設定...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "終了", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func toggleRecording() {
        recordingManager?.toggleRecording()
    }
    
    @objc func openSettings() {
        // 設定ウィンドウを開く
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
```

### 2. 録音管理（RecordingManager.swift）

```swift
import AVFoundation

class RecordingManager: ObservableObject {
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var audioLevel: Float = 0
    
    private var audioRecorder: AVAudioRecorder?
    private var audioEngine: AVAudioEngine?
    private var timer: Timer?
    private var currentRecordingURL: URL?
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        // 録音設定
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        // ファイル名生成
        let fileName = generateFileName()
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent("VoiceCapture").appendingPathComponent(fileName)
        
        // ディレクトリ作成
        try? FileManager.default.createDirectory(at: audioURL.deletingLastPathComponent(), 
                                                  withIntermediateDirectories: true)
        
        // 録音開始
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.record()
            
            isRecording = true
            currentRecordingURL = audioURL
            
            // タイマー開始
            startTimer()
            
            // 音量レベルモニタリング開始
            startAudioLevelMonitoring()
            
        } catch {
            print("録音開始エラー: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        timer?.invalidate()
        
        // 通知を送信
        sendNotification(title: "録音完了", body: "ファイルを保存しました")
        
        // 文字起こし開始
        if SettingsManager.shared.autoTranscribe {
            startTranscription()
        }
        
        recordingTime = 0
    }
    
    private func generateFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return "\(formatter.string(from: Date())).wav"
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recordingTime += 1
        }
    }
    
    private func startAudioLevelMonitoring() {
        audioRecorder?.isMeteringEnabled = true
        // 音量レベルを定期的に更新
    }
}
```

### 3. 文字起こし管理（TranscriptionManager.swift）

```swift
import Foundation

class TranscriptionManager {
    func transcribe(audioURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Whisper.cppを使って文字起こし
            let result = self.runWhisper(audioURL: audioURL)
            
            DispatchQueue.main.async {
                switch result {
                case .success(let text):
                    // Markdownファイルとして保存
                    self.saveAsMarkdown(text: text, audioURL: audioURL)
                    completion(.success(text))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func runWhisper(audioURL: URL) -> Result<String, Error> {
        // Whisper.cppの実行
        // C++ブリッジを通じて実行
        // 実装の詳細は別途
        return .success("文字起こし結果のサンプル")
    }
    
    private func saveAsMarkdown(text: String, audioURL: URL) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        let dateString = formatter.string(from: Date())
        
        let fileName = audioURL.deletingPathExtension().lastPathComponent
        
        let markdown = """
        # 録音 \(dateString)
        
        **録音日時**: \(dateString)
        **録音時間**: \(formatDuration(/* 録音時間 */))
        **ファイル名**: \(fileName).wav
        
        ---
        
        \(text)
        """
        
        let mdURL = audioURL.deletingPathExtension().appendingPathExtension("md")
        try? markdown.write(to: mdURL, atomically: true, encoding: .utf8)
        
        // 通知送信
        sendNotification(title: "文字起こし完了", body: "ファイル: \(fileName).md")
    }
}
```

### 4. ホットキー管理（HotKeyManager.swift）

```swift
import Carbon
import AppKit

class HotKeyManager {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    
    func register(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) {
        // Carbon APIを使ってグローバルホットキーを登録
        // 実装の詳細は別途
    }
    
    func unregister() {
        // ホットキー解除
    }
}
```

### 5. 設定管理（SettingsManager.swift）

```swift
import Foundation

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var saveDirectory: URL
    @Published var autoTranscribe: Bool
    @Published var hotKeyCode: UInt32
    @Published var hotKeyModifiers: UInt32
    @Published var sampleRate: Double
    @Published var bitDepth: Int
    
    init() {
        // UserDefaultsから読み込み
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.saveDirectory = UserDefaults.standard.url(forKey: "saveDirectory") 
            ?? documentsPath.appendingPathComponent("VoiceCapture")
        self.autoTranscribe = UserDefaults.standard.bool(forKey: "autoTranscribe")
        self.hotKeyCode = UInt32(UserDefaults.standard.integer(forKey: "hotKeyCode"))
        self.hotKeyModifiers = UInt32(UserDefaults.standard.integer(forKey: "hotKeyModifiers"))
        self.sampleRate = UserDefaults.standard.double(forKey: "sampleRate")
        self.bitDepth = UserDefaults.standard.integer(forKey: "bitDepth")
    }
    
    func save() {
        UserDefaults.standard.set(saveDirectory, forKey: "saveDirectory")
        UserDefaults.standard.set(autoTranscribe, forKey: "autoTranscribe")
        // 他の設定も保存
    }
}
```

---

## Whisper.cppの統合手順

### 1. Whisper.cppのダウンロードとビルド
```bash
git clone https://github.com/ggerganov/whisper.cpp.git
cd whisper.cpp
make
```

### 2. Whisperモデルのダウンロード
```bash
bash ./models/download-ggml-model.sh medium
```

### 3. Xcodeプロジェクトへの統合
- `whisper.cpp`と`whisper.h`をXcodeプロジェクトに追加
- Bridging Headerを作成してC++コードを呼び出せるようにする

### 4. SwiftからWhisperを呼び出す
```swift
// WhisperBridge.swift
import Foundation

class WhisperBridge {
    func transcribe(audioPath: String, modelPath: String) -> String {
        // C++のwhisper関数を呼び出す
        // 実装の詳細は別途
        return "文字起こし結果"
    }
}
```

---

## 開発の優先順位

### Phase 1: 基本録音機能（1-2日）
1. Xcodeプロジェクト作成
2. メニューバーアプリの基本構造
3. 録音開始/停止機能
4. WAV保存機能
5. 視覚的フィードバック（アイコン変更、時間表示）

### Phase 2: ホットキーと設定（1日）
1. グローバルホットキーの実装
2. 設定画面の作成
3. UserDefaultsでの設定保存

### Phase 3: Whisper統合（2-3日）
1. Whisper.cppのビルドと統合
2. 文字起こし機能の実装
3. Markdown形式での保存

### Phase 4: UX改善（1日）
1. 音量レベルメーター
2. 通知機能
3. 「最後の録音を開く」機能
4. エラーハンドリング

---

## 注意事項とベストプラクティス

### セキュリティ
- マイクへのアクセス権限をInfo.plistに記載
- `NSMicrophoneUsageDescription`を設定

### パフォーマンス
- 文字起こしはバックグラウンドスレッドで実行
- 大きなWAVファイルのメモリ管理に注意

### ユーザビリティ
- 録音中は誤操作を防ぐ
- 文字起こし中はユーザーに進捗を表示
- エラー時は分かりやすいメッセージを表示

---

## Phase 2以降の機能（今回は実装しない）

- オーディオエフェクト（ディエッサー、マキシマイザー等）
- Claude/Gemini APIを使った自動タグ付け
- カテゴリ自動分類
- サマリー自動生成
- 全文検索機能
- ポッドキャスト書き出し機能（MP3エンコード）

---

## 参考資料

- [Swift公式ドキュメント](https://www.swift.org/documentation/)
- [AVFoundation Programming Guide](https://developer.apple.com/documentation/avfoundation)
- [Whisper.cpp GitHub](https://github.com/ggerganov/whisper.cpp)
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)

---

このドキュメントを基にClaude Codeで開発を進めてください。