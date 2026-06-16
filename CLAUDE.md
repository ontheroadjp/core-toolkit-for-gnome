# CLAUDE.md

このファイルは AI エージェント（Claude Code）がこのリポジトリで作業する際の
運用起点である。詳細な設計判断・根拠は `docs/` 配下を参照すること
（`docs/.ai/repo.profile.json` の `primary_docs` がエントリポイント）。

## このリポジトリについて

Lenovo ThinkPad T480s (Ubuntu 24.04 LTS / GNOME) 向けの個人用シェルスクリプト・
dotfiles 集。アプリケーションコード・CI・テストは存在しない。
詳細: [docs/L0_concept/concept.md](docs/L0_concept/concept.md)。

## Custom / Command の使い分け（AI向けルール）

- task.md: ドキュメント変更を伴う実装に特化。issue 自動生成〜実装〜ドラフト PR 作成まで。docs/* は変更しない。
- patch.md: ドキュメント変更を伴わない軽微な修正に特化。issue/PR 不要。branch + commit → ユーザーが main へマージ。スコープが広がった場合は /task へエスカレーション。
- docs-sync.md: git diff を事実として docs を最小更新し、ドラフト PR を公開する。HARD STOP 時は /init-docs を要求して終了する。
- init-docs.md: repo の実態把握と設計ドキュメント再構築。重い初期化。docs-sync が説明不能になった時点でここに戻る。

## このリポジトリ固有の注意点

- `t480s.sh` / `t480s_apps.sh` は `sudo` を要する行を含む
  （バッテリー充電閾値、apt install 等）。AI が自律的にこれらを実行することは
  想定しない。実行内容の説明・修正案の提示まではAIの役割、実行はユーザー判断。
- `curl | sh` / `wget | sudo tee` 形式のリモートインストーラ
  （`t480s_apps.sh:60,69-71,94,123`）を変更する際は、出典URLの正当性を
  必ず確認すること。
- `.config/` と `.local/bin/` はホームディレクトリへのシンボリックリンク先として
  実機で使われている（`docs/L1_project/repository_structure.md` の未確認事項1参照）。
  これらのパス配下のファイルを編集すると、即座に実機の挙動に影響する可能性がある。
- コミット時は `git add -A` / `git add .` を使わず、変更ファイルを個別に
  ステージングする。
