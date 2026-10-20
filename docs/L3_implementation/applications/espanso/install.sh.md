# `applications/espanso/install.sh`

## 目的・役割

espanso（Wayland 版 .deb）を導入し、`espanso-toggle` を `~/.local/bin` に、
`applications/espanso/` ディレクトリ自体を `~/.config/espanso` にシンボリックリンクする
インストーラ。未インストール時は `wget` と `sudo apt install` を行う（`install.sh:8-16`）。

## 動作の概要と主要ロジック

1. `espanso` コマンドがなければ GitHub releases から
   `espanso-debian-wayland-amd64.deb` を取得して `sudo apt install`（`install.sh:8-13`）。
   既にあればスキップ
2. `${BIN_DIR}`（`~/.local/bin`）と `${CONFIG_DIR}`（`~/.config`）を作成（`install.sh:18`）
3. `espanso-toggle` に実行権限を付与し `${BIN_DIR}/espanso-toggle` へ `ln -sf`（`install.sh:20-21`）
4. `ln -sfn "${SCRIPT_DIR}" "${CONFIG_DIR}/espanso"` で repo ディレクトリへリンク（`install.sh:23`）
5. `espanso service register` / `start` を手動で実行するよう案内する（`install.sh:27-31`）

## 重要な設計判断

### 設定ディレクトリのリンクは `ln -sfn`

再実行時、`~/.config/espanso` は既に repo ディレクトリへの symlink として存在する。
`ln -sf` はこれを辿って repo 内（`applications/espanso/espanso`）に自己参照リンクを
作ってしまうため、`-n` でリンク自体を張り替える（issue #62）。
`espanso-toggle` はファイルへのリンクなのでこの問題は起きず、`ln -sf` のままにしている。

## 統合ポイント

- 呼び出し元: ルートの `install-all.sh:33`
- リンク対象: `applications/espanso/`（`config/`, `match/`）、`applications/espanso/espanso-toggle`
- `espanso-toggle` は GNOME custom keybinding（F9）から呼ばれる
- テスト: `tests/test_install.sh`（構文チェック、`espanso-toggle` の存在確認、Test 6 で `-sfn` の静的確認）

## 注意事項・既知の制限

- `wget` / `sudo apt install` を含むため、AI が自律的に実行することは想定しない（`CLAUDE.md` 参照）。
  テストでも実行はせず静的確認のみ
- `match/private.yml` は `.gitignore` 対象

## 変更履歴（git log より自動生成）

- 22d2117 fix(#62): use ln -sfn for config directory links to stop self-referencing links
- 6b93fec chore(#31): replace t480s-apps-install.sh with per-app install.sh and scripts/core-tools/install.sh
- 8045f0a chore(#29): reorganize root/ dotfiles into applications/ and gnome-extensions/
- da97c47 feat(espanso): add toggle script, installer, GNOME shortcut, and base matches
