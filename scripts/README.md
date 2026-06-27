# scripts

GNOME デスクトップ環境の入力・通知・音声入力に関するスクリプト群。
各サブディレクトリが独立した機能を持ち、それぞれ単独でインストール・利用できる。

## サブディレクトリ一覧

| ディレクトリ | 種別 | 概要 |
|---|---|---|
| [`core-tools/`](core-tools/README.md) | シェルスクリプト | 開発基盤ツール（gh, ghq, mise, claude, codex 等）の一括インストール |
| [`fep-switcher/`](fep-switcher/README.md) | GNOME 拡張機能 | 入力ソース切替 D-Bus サービス（コアコンポーネント） |
| [`app-switch-us-input/`](app-switch-us-input/README.md) | GNOME 拡張機能 | ターミナルフォーカス時に自動で US 入力へ切替 |
| [`tmux-switch-us-input/`](tmux-switch-us-input/README.md) | シェルスクリプト | tmux ペイン切替時に US 入力へ切替 |
| [`vim-switch-us-input/`](vim-switch-us-input/README.md) | Vim プラグイン | Vim Insert モード終了時に US 入力へ切替 |
| [`voice-input/`](voice-input/README.md) | シェルスクリプト | whisper.cpp を使ったオフライン音声入力 |
| [`battery-alert/`](battery-alert/README.md) | Python + systemd | バッテリー残量低下のデスクトップ通知 |

## 入力ソース切替の依存関係

`fep-switcher@local` が D-Bus サービスを提供するコアであり、他のクライアントはこれを呼び出す構造になっている。

```
fep-switcher@local（GNOME 拡張）
        ↑ D-Bus: SwitchToUs()
        ├── app-switch-us-input@local（GNOME 拡張）  ← ウィンドウフォーカス
        ├── switch-input-to-us（シェルスクリプト）   ← tmux ペイン切替
        └── vim-switch-us-input.vim（Vim プラグイン）← Insert モード終了
```

`fep-switcher@local` を有効化しておくことがこれら全クライアントの前提条件。

## インストール（全体）

ルートの `install.sh` が以下を一括で設定する。

```bash
./install.sh
```

- `fep-switcher@local` / `app-switch-us-input@local` をシンボリックリンクで登録・有効化
- `switch-input-to-us` を `~/.local/bin/` にリンク
- tmux・espanso の手動設定手順を表示

各スクリプトを個別にインストールする場合はそれぞれのサブディレクトリの README を参照。
