# `applications/yt-dlp/install.sh`

## 目的・役割

yt-dlp 本体を `/usr/local/bin/yt-dlp` に導入（または更新）し、`applications/yt-dlp/`
ディレクトリ自体を `~/.config/yt-dlp` にシンボリックリンクして repo 内の `config` を
読ませるインストーラ。`sudo` を要する（`install.sh:8-9,13`）。

## 動作の概要と主要ロジック

1. `yt-dlp` コマンドがなければ GitHub releases から `/usr/local/bin/yt-dlp` へ
   `sudo wget` し実行権限を付与（`install.sh:7-10`）。既にあれば `sudo yt-dlp -U` で更新（`install.sh:12-13`）
2. `${CONFIG_DIR}`（`~/.config`）を作成（`install.sh:16`）
3. `ln -sfn "${SCRIPT_DIR}" "${CONFIG_DIR}/yt-dlp"` で repo ディレクトリへリンク（`install.sh:17`）

## 重要な設計判断

### `ln -sf` ではなく `ln -sfn`

再実行時、`~/.config/yt-dlp` は既に repo ディレクトリへの symlink として存在する。
`ln -sf` はこれを辿って repo 内（`applications/yt-dlp/yt-dlp`）に自己参照リンクを
作ってしまうため、`-n` でリンク自体を張り替える（issue #62）。

## 統合ポイント

- 呼び出し元: ルートの `install-all.sh:28`
- リンク対象: `applications/yt-dlp/config`
- テスト: `tests/test_install.sh`（構文チェック、`config` の存在確認、Test 6 で `-sfn` の静的確認）

## 注意事項・既知の制限

- 再実行のたびに `sudo yt-dlp -U` が走る
- `sudo wget` を含むため、AI が自律的に実行することは想定しない（`CLAUDE.md` 参照）。
  テストでも実行はせず静的確認のみ

## 変更履歴（git log より自動生成）

- 22d2117 fix(#62): use ln -sfn for config directory links to stop self-referencing links
- 6b93fec chore(#31): replace t480s-apps-install.sh with per-app install.sh and scripts/core-tools/install.sh
- 8045f0a chore(#29): reorganize root/ dotfiles into applications/ and gnome-extensions/
