# core-tools

Ubuntu 24.04 環境の開発基盤として必要な汎用ツールを一括インストールするスクリプト。
このリポジトリ内に設定ファイルが存在しないツール（`gh`、`ghq`、`mise`、`claude`、`codex` 等）の導入を担う。

## インストール内容（9ステップ）

| ステップ | 内容 | 手段 |
|---|---|---|
| 1 | 開発基盤ツール（`git`, `tmux`, `fzf`, `bat`, `vim-gtk3`, `jq`, `yq` 等） | apt |
| 2 | システムユーティリティ（`hyperfine`, `rclone`, `gocryptfs`, `gpaste-2`） | apt |
| 3 | システム監視ツール（`htop`, `nethogs`, `iftop`, `whois`, `arp-scan`） | apt |
| 4 | GNOME Shell Extension Manager | apt |
| 5 | mise + Node.js 24 | `curl https://mise.run \| sh` |
| 6 | gh（GitHub CLI） | apt キーリング登録 + apt install |
| 7 | ghq | GitHub Releases から zip 取得 → `/usr/local/bin` へ配置 |
| 8 | Claude Code | `curl -fsSL https://claude.ai/install.sh \| bash` |
| 9 | Codex CLI | `mise exec node@24 -- npm install -g @openai/codex` |

ステップ 5〜9 は `command -v` で導入済みを確認してからインストールする（冪等）。

## インストール

```bash
./scripts/core-tools/install.sh
```

> **注意:** `sudo` が必要。ネットワーク接続が必要。
