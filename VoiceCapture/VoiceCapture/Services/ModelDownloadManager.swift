//
//  ModelDownloadManager.swift
//  VoiceCapture
//
//  Created on 2025-10-04.
//

import Foundation
import Combine
import WhisperKit

@MainActor
class ModelDownloadManager: ObservableObject {
    // MARK: - Published Properties

    @Published var downloadState: DownloadState = .idle
    @Published var downloadProgress: Double = 0.0
    @Published var errorMessage: String?

    // MARK: - Properties

    private let settingsManager = SettingsManager.shared
    private var whisperKit: WhisperKit?

    // MARK: - Download State

    enum DownloadState: Equatable {
        case idle
        case checking
        case downloading
        case completed
        case failed(String)
    }

    // MARK: - Model Check

    /// 選択されたモデルが既にダウンロード済みかチェック
    func isModelDownloaded() async -> Bool {
        let modelName = settingsManager.whisperModel.rawValue

        // WhisperKitのモデルキャッシュディレクトリを確認
        // WhisperKitは ~/.cache/huggingface/ にモデルをキャッシュする
        let cacheDir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".cache")
            .appendingPathComponent("huggingface")

        // モデル名に対応するディレクトリが存在するかチェック
        let modelDir = cacheDir.appendingPathComponent(modelName)

        let exists = FileManager.default.fileExists(atPath: modelDir.path)
        AppLogger.modelDownload.info("Model \(modelName) exists: \(exists)")

        return exists
    }

    // MARK: - Model Download

    /// モデルをダウンロード
    func downloadModel() async throws {
        let modelName = settingsManager.whisperModel.rawValue

        AppLogger.modelDownload.info("Starting model download with name: '\(modelName)'")
        downloadState = .downloading
        downloadProgress = 0.0
        errorMessage = nil

        do {
            // WhisperKitConfigを作成
            // verbose: true でモデル検索の詳細ログを出力
            let config = WhisperKitConfig(
                model: modelName,
                verbose: true,
                download: true
            )

            AppLogger.modelDownload.info("WhisperKit config created - model: '\(modelName)', verbose: true, download: true")

            // 進捗シミュレーション（WhisperKitは進捗コールバックを提供しないため）
            // バックグラウンドで進捗を更新
            let progressTask = Task {
                for i in 1...9 {
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
                    if !Task.isCancelled {
                        await MainActor.run {
                            self.downloadProgress = Double(i) / 10.0
                        }
                    }
                }
            }

            // WhisperKitを初期化（これによりモデルがダウンロードされる）
            AppLogger.modelDownload.info("Initializing WhisperKit with model: '\(modelName)'...")
            whisperKit = try await WhisperKit(config)

            // 進捗タスクをキャンセル
            progressTask.cancel()

            // 完了
            downloadProgress = 1.0
            downloadState = .completed

            AppLogger.modelDownload.info("Model download completed: \(modelName)")

        } catch let error as NSError {
            AppLogger.modelDownload.error("Model download failed: \(error.localizedDescription)")
            AppLogger.modelDownload.error("Error domain: \(error.domain), code: \(error.code)")
            AppLogger.modelDownload.error("Error userInfo: \(error.userInfo)")

            let message = createErrorMessage(from: error, modelName: modelName)
            errorMessage = message
            downloadState = .failed(message)

            throw VoiceCaptureError.transcriptionFailed(reason: message)
        }
    }

    /// モデルのダウンロードチェックとダウンロード実行
    func ensureModelDownloaded() async throws {
        downloadState = .checking

        // モデルが既にダウンロード済みかチェック
        if await isModelDownloaded() {
            AppLogger.modelDownload.info("Model already downloaded")
            downloadState = .completed
            return
        }

        // ダウンロードが必要
        AppLogger.modelDownload.info("Model not found, starting download...")
        try await downloadModel()
    }

    // MARK: - Error Handling

    private func createErrorMessage(from error: NSError, modelName: String) -> String {
        // ネットワークエラーの判定
        if error.domain == NSURLErrorDomain {
            switch error.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                return """
                インターネット接続が必要です。
                モデルのダウンロードにはネットワーク接続が必要です。
                ダウンロード後はオフラインで使用できます。
                """
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                return """
                HuggingFaceに接続できません。
                ネットワーク設定を確認してください。
                """
            case NSURLErrorTimedOut:
                return "接続がタイムアウトしました。もう一度お試しください。"
            default:
                return "ネットワークエラーが発生しました: \(error.localizedDescription)"
            }
        } else if error.localizedDescription.contains("Model not found") ||
                  error.localizedDescription.contains("model search must return a single model") {
            return """
            モデル '\(modelName)' の検索に失敗しました。
            詳細: \(error.localizedDescription)

            考えられる原因:
            - モデル名の曖昧性（複数のモデルにマッチ）
            - インターネット接続の問題

            インターネット接続を確認してください。
            """
        } else {
            return "モデルのダウンロードに失敗しました: \(error.localizedDescription)"
        }
    }

    // MARK: - Reset

    func reset() {
        downloadState = .idle
        downloadProgress = 0.0
        errorMessage = nil
    }
}
