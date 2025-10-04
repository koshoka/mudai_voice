//
//  VoiceCaptureError.swift
//  VoiceCapture
//
//  Created on 2025-10-03.
//

import Foundation

enum VoiceCaptureError: LocalizedError {
    case recordingFailed(underlying: Error)
    case permissionDenied
    case fileOperationFailed(underlying: Error)
    case transcriptionFailed(reason: String)
    case audioEngineNotAvailable
    case invalidAudioFormat
    case diskSpaceInsufficient
    case modelNotAvailable(modelName: String)

    var errorDescription: String? {
        switch self {
        case .recordingFailed(let error):
            return "録音に失敗しました: \(error.localizedDescription)"
        case .permissionDenied:
            return "マイクへのアクセスが許可されていません"
        case .fileOperationFailed(let error):
            return "ファイル操作に失敗しました: \(error.localizedDescription)"
        case .transcriptionFailed(let reason):
            return "文字起こしに失敗しました: \(reason)"
        case .audioEngineNotAvailable:
            return "オーディオエンジンを起動できませんでした"
        case .invalidAudioFormat:
            return "対応していない音声フォーマットです"
        case .diskSpaceInsufficient:
            return "ディスク容量が不足しています"
        case .modelNotAvailable(let modelName):
            return "文字起こしモデル「\(modelName)」が見つかりません"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .recordingFailed:
            return "マイクが正しく接続されているか確認してください。他のアプリでマイクを使用している場合は、そのアプリを終了してから再度お試しください。"
        case .permissionDenied:
            return "システム設定 > プライバシーとセキュリティ > マイク で、VoiceCaptureにマイクへのアクセスを許可してください。"
        case .fileOperationFailed:
            return "保存先フォルダへの書き込み権限があるか確認してください。設定画面から別の保存先フォルダを選択することもできます。"
        case .transcriptionFailed:
            return "音声ファイルが破損している可能性があります。再度録音を行ってください。問題が続く場合は、設定で別の文字起こしモデルを試してください。"
        case .audioEngineNotAvailable:
            return "システムを再起動するか、他のオーディオアプリを終了してから再度お試しください。"
        case .invalidAudioFormat:
            return "現在、M4A、WAV、MP3形式の音声ファイルに対応しています。別の形式で録音を試してください。"
        case .diskSpaceInsufficient:
            return "ディスクの空き容量を確保してから再度お試しください。不要なファイルを削除するか、設定で別の保存先を選択してください。"
        case .modelNotAvailable(let modelName):
            return "設定画面から「\(modelName)」モデルをダウンロードするか、別のモデルを選択してください。"
        }
    }

    var failureReason: String? {
        switch self {
        case .recordingFailed:
            return "オーディオ入力デバイスの初期化に失敗したか、録音中にエラーが発生しました。"
        case .permissionDenied:
            return "アプリにマイクへのアクセス権限が与えられていません。"
        case .fileOperationFailed:
            return "ファイルの読み書き中にエラーが発生しました。"
        case .transcriptionFailed:
            return "音声認識処理中にエラーが発生しました。"
        case .audioEngineNotAvailable:
            return "システムのオーディオエンジンが利用できません。"
        case .invalidAudioFormat:
            return "音声ファイルのフォーマットが正しくありません。"
        case .diskSpaceInsufficient:
            return "保存先のディスク容量が不足しています。"
        case .modelNotAvailable:
            return "指定された文字起こしモデルが利用できません。"
        }
    }
}
