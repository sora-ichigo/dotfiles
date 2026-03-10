---
description: CIとDevin Reviewが通っているかチェックし、失敗していれば修正&プッシュを繰り返す
---

現在のブランチのPRに対して、CIとDevin Reviewのステータスをチェックします。失敗している場合は原因を特定・修正し、プッシュして再度チェックを繰り返します。

## 手順

1. 現在のブランチのPR情報を取得する
   ```bash
   gh pr view --json number,url -q '.number'
   ```
2. PRのチェックステータスを確認する (`gh pr checks`)
3. Devin Review のコメントを取得する（後述の手順に従う）
4. CIがすべてpassかつDevin Reviewに Red 指摘がなければ完了を報告して終了
5. 問題がある場合は以下を繰り返す:
   a. 失敗原因を特定する
      - CIの場合: `gh run view <run-id> --log-failed` でログを取得
      - Devin Reviewの場合: 下記「Devin Review の確認方法」に従う
   b. 原因を分析し、コードを修正する
   c. `/commit-push` スキルの手順に従ってコミット&プッシュする
   d. CIが再実行されるのを待つ（`gh pr checks --watch --fail-fast` を使用、タイムアウト5分）
   e. Devin Review の再レビューを待つ（プッシュ後5〜10分程度かかる）
   f. 再度チェックステータスとDevin Reviewコメントを確認する
   g. まだ問題があれば a に戻る

## Devin Review の確認方法

Devin Review は `devin-ai-integration[bot]` としてPRにインラインコメントを投稿する。

### コメントの取得

```bash
# owner/repo を取得
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
PR_NUM=$(gh pr view --json number -q .number)

# Devin Review のインラインコメント（ファイルに対するコメント）を取得
gh api "repos/${REPO}/pulls/${PR_NUM}/comments" | jq '[.[] | select(.user.login == "devin-ai-integration[bot]")] | .[] | {path: .path, line: .line, body: .body}'

# Devin Review の全体コメント（PR本体へのコメント）を取得
gh api "repos/${REPO}/issues/${PR_NUM}/comments" | jq '[.[] | select(.user.login == "devin-ai-integration[bot]")] | .[] | {body: .body}'
```

### Severity レベル（絵文字による分類）

Devin Review はコメントに絵文字で深刻度を示す:

| 絵文字 | レベル | 意味 | 対応 |
|---|---|---|---|
| 🔴 (Red) | Severe | バグの可能性が高い問題。AIが高確信度で検出 | **必須修正** |
| 🟡 (Yellow) | Warning | 潜在的なリスクや改善点 | 推奨だが任意。明らかに妥当な場合のみ修正 |
| ⚪ (Gray) | FYI | 情報提供・参考コメント | **対応不要**。無視してよい |

### 対応方針

- **Red（🔴）のみ必須で修正する**
- Yellow（🟡）は内容を確認し、明らかにバグや重大な問題であれば修正する。スタイルや好みの問題はスキップ
- Gray（⚪）は無視する
- 指摘が的外れな場合（コンテキスト不足による誤検知など）はスキップしてよい

## 重要な注意事項

- **最大5回まで**のリトライとする。5回修正しても通らない場合はユーザーに状況を報告して判断を仰ぐ
- 修正は失敗の原因に対して最小限の変更にとどめる
- CIの失敗とDevin Reviewの指摘は別々に対応する
- 各リトライごとに、何が失敗していて何を修正したかを簡潔に報告する
