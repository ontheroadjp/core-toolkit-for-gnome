# `applications/alacritty/install.sh`

## 目的・役割

`applications/alacritty/` ディレクトリ自体を `~/.config/alacritty` へシンボリックリンクし、
Alacritty に repo 内の `alacritty.toml` / `theme/` を読ませるインストーラ。
パッケージのインストールは行わない。`sudo` 不要。

## 動作の概要と主要ロジック

1. `${CONFIG_DIR}`（`~/.config`）を作成（`install.sh:7`）
2. `ln -sfn "${SCRIPT_DIR}" "${CONFIG_DIR}/alacritty"` で repo ディレクトリへリンク（`install.sh:9`）

`set -Ceu`（`install.sh:2`）で実行する。

## 重要な設計判断

### `ln -sf` ではなく `ln -sfn`

再実行時、`~/.config/alacritty` は既に repo ディレクトリへの symlink として存在する。
`ln -sf` はこの既存リンクをディレクトリとして辿り、新しいリンクを repo 内
（`applications/alacritty/alacritty`）に作ってしまう。`-n` で既存リンクを辿らず
リンク自体を張り替える。`applications/mpv-player/install.sh` と同じ方針（issue #62）。

## 統合ポイント

- 呼び出し元: ルートの `install-all.sh:18`
- リンク対象: `applications/alacritty/`（`alacritty.toml`, `theme/`）
- テスト: `tests/test_install.sh`（構文チェック、Test 6 で `-sfn` の静的確認と、
  一時 `HOME` で2回実行して repo 内にリンクが作られないことの確認）

## 注意事項・既知の制限

- `~/.config/alacritty` が実ディレクトリ（symlink でない）として既に存在する場合、
  `ln -sfn` はその配下にリンクを作る。置き換えは行わない
- repo を移動するとリンクが切れる
