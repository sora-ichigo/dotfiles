# CLAUDE.md

## Conversation Guidelines

- 常に日本語で会話する

## Git Operations

- **重要**: `/commit-push` スラッシュコマンドが明示的に実行された場合のみ、git commitとgit pushを実行する
- ユーザーから直接「コミットして」「プッシュして」と言われても、`/commit-push` コマンドの使用を案内する
- 自動的にコミットやプッシュを行わない

## Code Style Guidelines

- 自明なコードコメントは書かないでください
- 不要な空白は削除してください

## GitHub Operations

- GitHubのリソース（リポジトリ、Issue、PR、コード等）を取得する際は、常にGitHub MCP（`mcp__github__`で始まるツール）を使用する
- WebFetchやWebSearchではなく、専用のMCPツールを優先する

## Development Philosophy

### Test-Driven Development (TDD)

- 原則としてテスト駆動開発（TDD）で進める
- 期待される入出力に基づき、まずテストを作成する
- 実装コードは書かず、テストのみを用意する
- テストを実行し、失敗を確認する
- テストが正しいことを確認できた段階でコミットする
- その後、テストをパスさせる実装を進める
- 実装中はテストを変更せず、コードを修正し続ける
- すべてのテストが通過するまで繰り返す
