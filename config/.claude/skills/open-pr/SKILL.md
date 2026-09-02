---
description: 現在のブランチのPRをブラウザで開く
allowed-tools: Bash(gh pr view:*)
disable-model-invocation: true
---

現在のブランチに紐づくPRをブラウザで開きました。

実行結果: !`gh pr view --web 2>&1`

上の結果を1行で報告するだけにとどめる。PRが存在しない場合もその旨を伝えるだけで、PRの作成は行わない。
