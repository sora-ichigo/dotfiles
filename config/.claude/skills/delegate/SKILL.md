---
description: 作業を委譲する独立した background Claude Code セッションを起動する（claude --background、agent view で管理）
disable-model-invocation: true
---

現在のディレクトリを起点に `claude --background` で独立した Claude Code セッションを起動し、渡された作業を委譲します。起動したセッションは agent view（`claude agents`）で管理でき、サブエージェントとは異なり独立したセッションとして扱われます。

## 手順

1. `/delegate <ざっくりした依頼>` の引数を受け取る。引数が空なら、何を委譲したいかユーザーに尋ねる。
2. 依頼内容を、独立セッションが単体で完遂できる**自己完結したプロンプト**に整形する。
   - background セッションは今の会話の context を一切引き継がないため、必要な背景・対象ファイル・完了条件をすべてプロンプトに書き込む。
   - 目的が曖昧な場合は先にユーザーに確認する。
3. `claude --background "<整形したプロンプト>"` を実行する。
   - プロンプトはシェルに渡すため、含まれる二重引用符やバッククォート等を適切にエスケープする。
4. 出力されたセッション ID と管理コマンドをユーザーに報告する。

## 管理コマンド

- `claude agents` — セッション一覧（agent view）
- `claude logs <id>` — 直近の出力を確認
- `claude attach <id>` — このターミナルで開く
- `claude stop <id>` — 停止

## 注意事項

- context を引き継がないので、「さっきの件」「上記の」といった指示語はプロンプトに残さず、具体的に展開する。
- push・PR 作成・デプロイなど外部影響や破壊的操作を委譲する場合は、ガードレール（main/master へ直接コミットしない、force push/merge しない、ブランチや worktree で作業する等）をプロンプトに明記するか、事前にユーザーへ確認する。
- 委譲後は「起動しただけ」であり完了ではない。結果は `claude logs <id>` や agent view で確認する。
