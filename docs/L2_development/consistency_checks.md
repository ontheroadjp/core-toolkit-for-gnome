# 整合性確認の観点と手順

CI が存在しないため、すべて手動での整合性確認が前提となる。

## 1. スクリプトの構文チェック

```bash
bash -n t480s.sh
bash -n t480s_apps.sh
sh -n .local/bin/gnome-overview-toggle
```

`shellcheck` の設定ファイル（`.shellcheckrc`）はリポジトリ内に
存在しないため、`shellcheck` を使う場合はデフォルトルールで実行する
（未確認: `shellcheck` 自体がこのマシンに導入されているかは
`t480s_apps.sh` のインストール対象リストに含まれていないため、
別途インストールが必要）。

## 2. 実行可能ビットの確認

このリポジトリのスクリプトは実行可能ビットが意味を持つ
（`./t480s.sh` のように直接実行する運用、`t480s_apps.sh:1` 等の
shebang 行を参照）。新しいスクリプトを追加・変更した際は
以下で実行権限を確認する。

```bash
ls -la t480s.sh t480s_apps.sh .local/bin/gnome-overview-toggle
```

## 3. dotfiles シンボリックリンクの整合性確認

`~/.config/alacritty` と `~/.local/bin/gnome-overview-toggle` が
このリポジトリ内のパスを指しているかを確認する。

```bash
readlink -f ~/.config/alacritty
readlink -f ~/.local/bin/gnome-overview-toggle
```

期待される出力はそれぞれ `<このリポジトリの絶対パス>/.config/alacritty`、
`<このリポジトリの絶対パス>/.local/bin/gnome-overview-toggle` と
一致すること（本ドキュメント作成時点で実機にて一致を確認済み）。

## 4. GNOME 設定の反映確認

`t480s.sh` 実行後、対応する `gsettings get` で値が反映されているかを
確認できる。例:

```bash
gsettings get org.gnome.desktop.peripherals.keyboard repeat-interval
gsettings get org.gnome.desktop.wm.keybindings switch-input-source
```

## 5. docs と repo.profile.json の相互整合性

`/init-docs` または `/docs-sync` を再実行する際は、以下を確認する。

- `docs/.ai/repo.profile.json` の `commands` に列挙されたコマンドが、
  実際にリポジトリ内のファイルとして存在するか
  （`commands.*.run` に書かれたパスを `ls` で確認）。
- 本ドキュメント群が参照しているファイルパス・行番号が、
  最新のスクリプト内容とズレていないか
  （スクリプトの行数が変わった場合は該当ドキュメントの行番号根拠を
  更新する）。

## 確認済み事項（参考）

- OSは Ubuntu 24.04.4 LTS (Noble Numbat)。根拠: OS情報ファイル(`os-release`、`/etc` 配下)の
  `PRETTY_NAME="Ubuntu 24.04.4 LTS"`（本コマンド実行時にライブシステムで
  確認。リポジトリ内にOS名を明記したファイルはないため、リポジトリ単体では
  確認できない事項だった）。
