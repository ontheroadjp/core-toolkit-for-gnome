# `tests/test_install.sh`

## 目的・役割

`install-all.sh` と各 `install.sh` の構文・構成を検証する手動実行用テスト。
CI は存在しないため、変更時に `bash tests/test_install.sh` で実行する。
独自の pass/fail カウンタを持ち、1件でも FAIL があれば終了コード 1 を返す（`test_install.sh:186-189`）。

## 動作の概要と主要ロジック

| Test | 内容 | 根拠 |
|------|------|------|
| 1 | `INSTALL_SCRIPTS` の各スクリプトを shellcheck（なければ `bash -n`）で構文チェック | `test_install.sh:13-52` |
| 2 | install.sh が参照するファイルの存在確認 | `test_install.sh:54-73` |
| 3 | `install-all.sh` が各 per-app install.sh を呼んでいることを確認 | `test_install.sh:75-96` |
| 4 | 旧 `t480s-apps-install.sh` が導入していたツールが新スクリプト群でカバーされていることを確認 | `test_install.sh:98-125` |
| 5 | 旧 `t480s-apps-install.sh` が削除済みであることを確認 | `test_install.sh:127-136` |
| 6 | 設定ディレクトリへのリンクが `ln -sfn` であることの静的確認と、alacritty installer の再実行で repo 内にリンクが作られないことの動作確認 | `test_install.sh:138-182` |

## 重要な設計判断

### Test 6: 静的確認と、副作用のない installer だけの動作確認

`ln -sf DIR LINK` は再実行時に既存の LINK（ディレクトリへの symlink）を辿り、
repo 内に自己参照リンクを作る（issue #62）。対象 4 スクリプト（alacritty, espanso,
yt-dlp, mpv-player）は `^ln -sf "${SCRIPT_DIR}" "${CONFIG_DIR}/` に一致する行が
ないことを grep で確認する（`test_install.sh:152-160`）。

動作確認は `$HOME` しか触らない `applications/alacritty/install.sh` に限り、
`mktemp -d` の一時 `HOME` で2回実行して、`applications/alacritty/alacritty` が
作られないこと、`~/.config/alacritty` が repo ディレクトリを指すことを確認する
（`test_install.sh:162-182`）。espanso / yt-dlp は `sudo` / `wget` を伴うため実行しない。

## 統合ポイント

- 対象: `install-all.sh`, `scripts/core-tools/install.sh`, `applications/*/install.sh`
- 関連: `tests/lint_shell.sh`（リポジトリ全体の shellcheck）
- 手順: `docs/L2_development/test.md`, `docs/L2_development/operation_model.md`

## 注意事項・既知の制限

- 機能テストではなく構文・構成の検証が中心。Test 6 の動作確認のみ実際に installer を実行する
- Test 6 の動作確認は、開始時点で `applications/alacritty/alacritty` が既に存在すると FAIL として扱い、
  実行をスキップする（既存のリンクを誤ってテスト結果とみなさないため）
- 2026-10-20 時点で `scripts/core-tools/install.sh` が shellcheck SC1091（`. /etc/os-release`、info）で
  Test 1 を FAIL させており、全体の終了コードは 1 になる（本テストの変更とは無関係）

## 変更履歴（git log より自動生成）

- 4b20ff6 feat(#64): add ncdu to core-tools installer
- 29d3a4c fix(#62): use ln -sfn for config directory links to stop self-referencing links (#63)
- f4d961c Sync keyd kj-escape state with FEP switching and automate install/keybinding/sudoers setup (#48)
- cc53830 feat(#38): add docker to core tools installer
- f246c6e fix: stop overriding alacritty desktop entry
- d3f2eab chore: rename install.sh to install-all.sh and add manual steps for settings scripts
- c0e1c6f test(#32): add lint_shell.sh and consolidate install.sh tests under tests/
- 6b93fec chore(#31): replace t480s-apps-install.sh with per-app install.sh and scripts/core-tools/install.sh
