//
//  TranscriptionService.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation
import Combine
import WhisperKit
import AVFoundation

class TranscriptionService: TranscriptionServiceProtocol {
    // MARK: - Properties

    private var whisperKit: WhisperKit?
    private let settingsManager = SettingsManager.shared
    let transcriptionProgress = PassthroughSubject<Float, Never>()

    // MARK: - TranscriptionServiceProtocol

    func transcribe(audioURL: URL) async throws -> String {
        AppLogger.transcription.info("Starting transcription for: \(audioURL.lastPathComponent)")

        do {
            // WhisperKitの初期化（モデル選択）
            try await initializeWhisperKit()

            guard let whisperKit = whisperKit else {
                throw VoiceCaptureError.transcriptionFailed(reason: "WhisperKitの初期化に失敗しました")
            }

            // 進捗報告: 0% (開始)
            transcriptionProgress.send(0.0)

            // 音声ファイルの長さを取得して進捗推定に使用
            let audioAsset = AVURLAsset(url: audioURL)
            let audioDuration = try await audioAsset.load(.duration)
            let totalSeconds = CMTimeGetSeconds(audioDuration)

            AppLogger.transcription.info("Audio duration: \(totalSeconds) seconds")

            // 音声ファイルをロード
            AppLogger.transcription.info("Loading audio file...")
            transcriptionProgress.send(0.1)

            // Phase 2: DecodingOptions設定の検証
            var decodeOptions = DecodingOptions()
            decodeOptions.language = "ja"  // ISO 639-1 code for Japanese
            decodeOptions.task = .transcribe  // NOT .translate (which converts to English)
            decodeOptions.detectLanguage = false  // Disable auto-detection to prevent override

            // 句読点を含むプロンプトを設定（モデルに句読点付きスタイルを促す）
            let punctuationPrompt = "こんにちは。今日は良い天気ですね。文字起こしを正確に行います。"
            if let tokenizer = whisperKit.tokenizer {
                let promptTokens = tokenizer.encode(text: punctuationPrompt)
                decodeOptions.promptTokens = promptTokens
                AppLogger.transcription.info("✓ Punctuation prompt set: '\(punctuationPrompt)' (\(promptTokens.count) tokens)")
            }

            AppLogger.transcription.info("✓ DecodingOptions configured:")
            AppLogger.transcription.info("  - language: \(decodeOptions.language ?? "nil")")
            AppLogger.transcription.info("  - task: \(decodeOptions.task)")
            AppLogger.transcription.info("  - detectLanguage: \(decodeOptions.detectLanguage)")
            AppLogger.transcription.info("  - promptTokens: \(decodeOptions.promptTokens?.count ?? 0) tokens")

            let startTime = Date()
            var callbackCount = 0

            let transcriptionResult = try await whisperKit.transcribe(
                audioPath: audioURL.path,
                decodeOptions: decodeOptions,
                callback: { [weak self] progress in
                    // WhisperKitのcallbackから進捗を推定
                    callbackCount += 1

                    // 経過時間ベースの推定
                    let elapsed = Date().timeIntervalSince(startTime)
                    // WhisperKitの処理速度は音声長の約2〜5倍（モデルによる）
                    // すべての音声で進捗を表示（短い音声でもフィードバックを提供）
                    let estimatedProgress = min(Float(elapsed / (totalSeconds * 3.0)), 0.95)
                    self?.transcriptionProgress.send(0.1 + estimatedProgress * 0.85)

                    return nil
                }
            )

            // Phase 3: 結果の検証
            guard let result = transcriptionResult.first else {
                throw VoiceCaptureError.transcriptionFailed(reason: "文字起こし結果が取得できませんでした")
            }

            let transcribedText = result.text

            if transcribedText.isEmpty {
                throw VoiceCaptureError.transcriptionFailed(reason: "文字起こし結果が空です")
            }

            // 結果の言語情報を確認（言語トークン変換の成功/失敗を検証）
            AppLogger.transcription.info("✓ Transcription result:")
            AppLogger.transcription.info("  - detected language: \(result.language)")
            AppLogger.transcription.info("  - text length: \(transcribedText.count) characters")
            AppLogger.transcription.info("  - text preview: \(String(transcribedText.prefix(100)))")

            // 警告: 日本語を指定したのに英語が検出された場合
            if decodeOptions.language == "ja" && result.language == "en" {
                AppLogger.transcription.warning("⚠️ WARNING: Japanese was requested but English was detected!")
                AppLogger.transcription.warning("⚠️ This indicates language token conversion may have failed")
                AppLogger.transcription.warning("⚠️ Model '\(whisperKit.modelVariant)' may not support Japanese")
            }

            AppLogger.transcription.info("Transcription completed successfully")

            // 進捗報告: 100% (完了)
            transcriptionProgress.send(1.0)

            return transcribedText

        } catch let error as VoiceCaptureError {
            AppLogger.transcription.error("Transcription failed: \(error.localizedDescription)")
            throw error
        } catch {
            AppLogger.transcription.error("Transcription failed with unexpected error: \(error.localizedDescription)")
            throw VoiceCaptureError.transcriptionFailed(reason: error.localizedDescription)
        }
    }

    // MARK: - Private Methods

    private func initializeWhisperKit() async throws {
        // 既に初期化済みの場合はスキップ
        if whisperKit != nil {
            AppLogger.transcription.info("WhisperKit already initialized")
            return
        }

        // モデル名を取得（"small" または "medium"）
        let modelVariant = settingsManager.whisperModel.rawValue
        AppLogger.transcription.info("Initializing WhisperKit with model: '\(modelVariant)'")

        do {
            // WhisperKitConfigを作成してWhisperKitを初期化
            // verbose: true でモデル検索の詳細ログを出力
            let config = WhisperKitConfig(
                model: modelVariant,
                verbose: true,
                // download: true はデフォルトで有効
                // 初回はHuggingFaceからモデルをダウンロードし、
                // 2回目以降はローカルキャッシュ (~/.cache/huggingface/) から読み込みます
                download: true
            )

            AppLogger.transcription.info("WhisperKit config created - model: '\(modelVariant)', verbose: true, download: true")
            AppLogger.transcription.info("Downloading model from HuggingFace (first time only)...")

            whisperKit = try await WhisperKit(config)

            AppLogger.transcription.info("WhisperKit initialized successfully with model: '\(modelVariant)'")

            // Phase 1: モデル情報の検証
            if let whisperKit = whisperKit {
                AppLogger.transcription.info("✓ Model variant loaded: \(whisperKit.modelVariant)")
                AppLogger.transcription.info("✓ Is multilingual model: \(whisperKit.textDecoder.isModelMultilingual)")
            }

        } catch let error as NSError {
            AppLogger.transcription.error("Failed to initialize WhisperKit: \(error.localizedDescription)")
            AppLogger.transcription.error("Error domain: \(error.domain), code: \(error.code)")
            AppLogger.transcription.error("Error userInfo: \(error.userInfo)")

            // より詳細なエラーメッセージを提供
            let errorMessage: String

            // ネットワークエラーの判定
            if error.domain == NSURLErrorDomain {
                switch error.code {
                case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                    errorMessage = """
                    インターネット接続が必要です。
                    初回起動時はHuggingFaceからモデルをダウンロードします。
                    ダウンロード後はオフラインで使用できます。
                    """
                case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                    errorMessage = """
                    HuggingFaceに接続できません。
                    ネットワーク設定を確認してください。
                    プロキシやファイアウォールの設定が必要な場合があります。
                    """
                case NSURLErrorTimedOut:
                    errorMessage = "接続がタイムアウトしました。もう一度お試しください。"
                default:
                    errorMessage = "ネットワークエラーが発生しました: \(error.localizedDescription)"
                }
            } else if error.localizedDescription.contains("Model not found") ||
                      error.localizedDescription.contains("model search must return a single model") {
                errorMessage = """
                モデル '\(modelVariant)' の検索に失敗しました。
                詳細: \(error.localizedDescription)

                考えられる原因:
                - モデル名の曖昧性（複数のモデルにマッチ）
                - インターネット接続の問題

                インターネット接続を確認してください。
                """
            } else {
                errorMessage = "WhisperKitの初期化に失敗しました: \(error.localizedDescription)"
            }

            throw VoiceCaptureError.transcriptionFailed(reason: errorMessage)
        }
    }
}
