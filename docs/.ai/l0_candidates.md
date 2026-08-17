# L0 昇格候補

`/docs-sync` が検知した、`docs/L0_concept/policy.md` への昇格候補。
`/concept-maker` がユーザー承認を経て取捨選択・追記する。このファイル自体は
候補のキューであり、L0 の一部ではない。

- docs/L3_implementation/scripts/core-gnome-settings/apply-settings.sh.md:36-39 — /etc/sudoers.d へ NOPASSWD ルールを自動設置する際は visudo -c で検証してから install し、冪等性（既存ルールとの重複防止）を担保する (issue #47)
- docs/L3_implementation/diagnostics/key-input-management/capture-ctrl-stuck-diagnostics.sh.md:29-33 — root権限が必要な調査・診断スクリプトは sudo の呼び出しや認証キャッシュ（sudo -v 等）を内部で行わず、ユーザーがスクリプト起動時に手動で sudo を付与する運用にする (issue #52)
