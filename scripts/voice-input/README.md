# voice-input

whisper.cpp を使ったオフライン音声入力システム。
`Ctrl+Shift+=` でマイク録音をトグルし、文字起こし結果を Wayland クリップボードへコピーする。

## 仕組み

```
Ctrl+Shift+=（GNOME カスタムキーバインド）
    ↓
voice-input.sh toggle
    ├── 録音中でない場合 → arecord で録音開始（PID を /tmp に保存）
    │       通知「Recording...」
    └── 録音中の場合
            → arecord を停止
            → whisper-server（localhost:8178）へ WAV ファイルを HTTP POST
            → テキストを wl-copy でクリップボードにコピー
            → 通知「Copied to clipboard」
```

whisper-server は systemd ユーザーサービスとして常駐し、
ログイン時に自動起動する（常駐プロセスの CPU/メモリ消費は事実上ゼロ、推論時のみ使用）。

## ファイル構成

| ファイル | 役割 |
|---|---|
| `voice-input.sh` | 録音トグル・文字起こし・クリップボードコピーのメインスクリプト |
| `install.sh` | whisper.cpp ビルド・モデルダウンロード・systemd サービス登録・GNOME キーバインド登録 |
| `.config/systemd/user/voice-input-whisper.service` | whisper-server の systemd ユーザーサービス定義 |

## 環境変数

| 変数 | デフォルト | 説明 |
|---|---|---|
| `VOICE_INPUT_LANGUAGE` | `ja` | 文字起こし言語（`auto` で自動検出、ただし低速） |
| `VOICE_INPUT_SERVER_URL` | `http://127.0.0.1:8178/inference` | whisper-server エンドポイント |
| `VOICE_INPUT_RECORD_FILE` | `/tmp/voice-input-record.wav` | 録音ファイルのパス |
| `VOICE_INPUT_PID_FILE` | `/tmp/voice-input.pid` | 録音プロセスの PID ファイル |

## インストール

```bash
# 初回のみ（whisper.cpp のビルドに 5〜10 分かかる）
./scripts/voice-input/install.sh
```

`install.sh` が以下を自動で行う:

1. 依存ツールの確認（`cmake`, `arecord`, `curl`, `wl-copy`, `notify-send` 等）
2. whisper.cpp を `~/.local/lib/whisper.cpp` にクローン・ビルド
3. ggml-base モデル（約 142 MB）を `~/.local/share/whisper-models/` にダウンロード
4. `voice-input-whisper.service` を systemd ユーザーサービスとして登録・起動
5. GNOME カスタムキーバインドに `Ctrl+Shift+=` を登録

## 依存パッケージ

```bash
sudo apt install build-essential cmake libasound2-dev curl wl-clipboard libnotify-bin git
```

## 使い方

| 操作 | 動作 |
|---|---|
| `Ctrl+Shift+=` | 録音開始（通知が表示される） |
| `Ctrl+Shift+=`（2回目） | 録音停止 → 文字起こし → クリップボードへコピー |
| `Ctrl+V` | 文字起こし結果の貼り付け |

## 動作確認

```bash
# systemd サービスの状態確認
systemctl --user status voice-input-whisper.service

# スクリプト単体テスト
./scripts/voice-input/voice-input.sh toggle
```
