# L0 昇格候補

`/docs-sync` が検知した、`docs/L0_concept/policy.md` への昇格候補。
`/concept-maker` がユーザー承認を経て取捨選択・追記する。このファイル自体は
候補のキューであり、L0 の一部ではない。

- docs/L3_implementation/scripts/core-gnome-settings/apply-settings.sh.md:36-39 — /etc/sudoers.d へ NOPASSWD ルールを自動設置する際は visudo -c で検証してから install し、冪等性（既存ルールとの重複防止）を担保する (issue #47)
- docs/L3_implementation/applications/yt-dlp/install.sh.md:18-22 — repo ディレクトリを ~/.config 等へリンクする際は ln -sf ではなく ln -sfn を使う（policy.md の「ln -sf でシンボリックリンク」記述の精緻化。alacritty/espanso/yt-dlp/mpv-player 共通） (issue #62)
