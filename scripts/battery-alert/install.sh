#!/bin/bash

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_USER_DIR="${HOME}/.config/systemd/user"
DEFAULT_POLL_INTERVAL=120

ln -sf "$REPO_DIR/battery_alert.py" ~/.local/bin
ln -sf "$REPO_DIR/.config/systemd/user/battery-alert.service" "$SYSTEMD_USER_DIR"

# .env の POLL_INTERVAL を timer ユニットに反映する。
# テンプレート（__POLL_INTERVAL__）を実値で置換した結果を書き出すため、
# リポジトリ内の .timer はシンボリックリンクではなく生成元として扱う。
POLL_INTERVAL="$DEFAULT_POLL_INTERVAL"
if [ -f "$REPO_DIR/.env" ]; then
    ENV_POLL_INTERVAL=$(grep -E '^POLL_INTERVAL=' "$REPO_DIR/.env" | tail -n 1 | cut -d '=' -f2-)
    if [ -n "$ENV_POLL_INTERVAL" ]; then
        POLL_INTERVAL="$ENV_POLL_INTERVAL"
    fi
fi
# 一時ファイル経由で mv することで、配置先が（過去のインストールによる）
# シンボリックリンクであっても、リンク先を追って書き込んでしまうことを避ける
# （直接 `sed > 配置先` だとリンクを通じてリポジトリ内テンプレートを破壊しうる）
TMP_TIMER_FILE="$(mktemp)"
sed "s/__POLL_INTERVAL__/${POLL_INTERVAL}/g" "$REPO_DIR/.config/systemd/user/battery-alert.timer" > "$TMP_TIMER_FILE"
mv "$TMP_TIMER_FILE" "$SYSTEMD_USER_DIR/battery-alert.timer"

exit 0
