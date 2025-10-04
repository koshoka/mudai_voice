//
//  ModelDownloadView.swift
//  VoiceCapture
//
//  Created on 2025-10-04.
//

import SwiftUI

struct ModelDownloadView: View {
    @ObservedObject var downloadManager: ModelDownloadManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            // アイコン
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.blue)

            // タイトル
            Text("WhisperKitモデルをダウンロード中")
                .font(.title2)
                .fontWeight(.semibold)

            // ステータステキスト
            statusText
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            // プログレスバー（ダウンロード中のみ）
            if downloadManager.downloadState == .downloading {
                VStack(spacing: 12) {
                    ProgressView(value: downloadManager.downloadProgress, total: 1.0)
                        .progressViewStyle(.linear)
                        .frame(width: 300)

                    Text("\(Int(downloadManager.downloadProgress * 100))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // エラーメッセージ
            if case .failed(let message) = downloadManager.downloadState {
                VStack(spacing: 12) {
                    Text(message)
                        .font(.callout)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)

                    Button("再試行") {
                        Task {
                            try? await downloadManager.downloadModel()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            // 完了状態
            if downloadManager.downloadState == .completed {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("ダウンロード完了")
                        .foregroundStyle(.green)
                }
                .font(.headline)
            }
        }
        .padding(32)
        .frame(width: 450)
    }

    @ViewBuilder
    private var statusText: some View {
        switch downloadManager.downloadState {
        case .idle:
            Text("準備中...")
        case .checking:
            Text("モデルの確認中...")
        case .downloading:
            Text("モデルをダウンロードしています。初回のみ時間がかかります。")
        case .completed:
            Text("モデルのダウンロードが完了しました。VoiceCaptureを使用できます。")
        case .failed:
            Text("ダウンロードに失敗しました")
        }
    }
}

#Preview {
    ModelDownloadView(downloadManager: ModelDownloadManager())
}
