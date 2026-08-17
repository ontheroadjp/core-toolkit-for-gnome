---
name: capture-ctrl-stuck-diagnostics-sh
description: Manual per-stream keyd/libinput/ibus event logger used to gather evidence for the Ctrl-stuck bug (#51)
metadata:
  type: project
---

## 目的・役割

issue #51（Ctrl+Space で FEP を切り替えた際、Mozc の未確定変換と重なると Ctrl が
押しっぱなし状態になる不具合）の原因切り分けのため、keyd・libinput・ibus の
イベント/ログを個別にファイルへ記録する手動実行ツール
（`capture-ctrl-stuck-diagnostics.sh:1-33`）。`applications/keyd/` ではなく
`diagnostics/key-input-management/` に置かれているのは、対象が keyd 単体ではなく
ibus・GNOME Shell 拡張（`scripts/fep-switcher/`）・D-Bus を横断する事象のため
（`diagnostics/README.md` 参照）。

## 動作概要

- `$1` に出力先ディレクトリ、`$2` にモード（`keyd`/`libinput`/`ibus`）を取る
  （`capture-ctrl-stuck-diagnostics.sh:9-11`）。引数が2個でない、またはモードが
  不正な場合は使い方を表示して `exit 1`（`capture-ctrl-stuck-diagnostics.sh:4-9,26-27`）。
- モードごとに実行するコマンドを決定するだけで、権限まわりの分岐や事前チェックは
  一切行わない（`capture-ctrl-stuck-diagnostics.sh:13-24`）:
  - `keyd`: `keyd monitor -t`
  - `libinput`: `libinput debug-events`
  - `ibus`: `journalctl --user -u org.freedesktop.IBus.session.GNOME -f`
- 出力先ディレクトリを作成し、`<output-dir>/<mode>.log` へ `tee` で標準出力と
  同時に書き出す（`capture-ctrl-stuck-diagnostics.sh:29-32`）。フォアグラウンド実行
  のため、ユーザーが Ctrl+C を押すとそのまま終了しログが残る。

## 重要な設計判断

- `keyd`/`libinput` モードは root 権限を要するが、スクリプト内部では `sudo` の
  呼び出し・認証キャッシュ（`sudo -v` 等）を一切行わない。ユーザーがスクリプト
  自体を `sudo` を付けて起動する運用とし、権限不足の場合は各コマンドが出す
  ネイティブなエラー（例: `failed to open /dev/input/eventN`）でそのまま失敗させる。
  これは「ユーザーが手動で sudo を判断・実行する」という明示的な要件によるもの
  （诊断ツールが暗黙に昇格を行わないようにするため）。
- `libinput-tools`（`libinput` コマンド）が未インストールの場合も、スクリプトは
  事前チェックを行わない。`command not found` という bash ネイティブのエラーで
  十分説明的なため、独自のチェック・案内メッセージは追加していない
  (`diagnostics/key-input-management/README.md` の「前提」節に事前インストールの
  必要性を明記することで補っている)。
- 3系統（keyd/libinput/ibus）を1プロセス内で同時オーケストレーションせず、
  ユーザーが別ターミナルで個別に起動する設計にしている。バックグラウンド
  ジョブ管理や sudo プロンプトの多重化を避け、各ストリームの開始・終了を
  ユーザーが明示的に制御できるようにするため。

## 統合ポイント

- 呼び出し元: なし（ユーザーが手動でターミナルから直接実行する。CI・
  install.sh・他スクリプトからは呼ばれない）
- 呼び出し先: `keyd monitor`、`libinput debug-events`、`journalctl`
  （いずれも読み取り専用、システム状態を変更しない）
- 関連: `applications/keyd/default.conf`（`[control] space = scrolllock`）、
  `applications/keyd/fep-toggle.sh`、`scripts/fep-switcher/extension.js`
  （いずれも issue #51 の調査対象コンポーネント）

## 注意事項・既知の制限

- `libinput` モードはこのツールが動作確認された環境では `libinput-tools`
  パッケージが未インストールだった（`libinput: command not found` で失敗する
  ことを確認済み）。実機検証前に `sudo apt install libinput-tools` が必要。
- 実際のバグ再現（Mozc 未確定変換 + CapsLock+Space）を伴う採取・原因特定は
  本ツールのスコープ外（issue #53 で実施）。本ツールは非再現のドライラン
  （数秒起動 → Ctrl+C → ログファイル生成確認）のみで動作確認済み。
