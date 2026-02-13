.PHONY: nix
nix:
	./install.sh

.PHONY: brew
brew:
	brew bundle --file=Brewfile

CLAUDE_SETTINGS := config/.claude/settings.json
CLAUDE_MCP := config/.claude/mcp.json
SECRETS_CONFIG := config/secrets.json

# secrets.json の 1Password 参照パスから実際の値を取得し、~/.secrets に環境変数として書き出す
# .zshrc から source されるため、すべてのディレクトリで有効になる
.PHONY: secrets
secrets:
	@echo "Fetching secrets from 1Password..."
	@jq -r 'to_entries[] | "export \(.key)=\"$$(op read \"\(.value)\")\"" ' $(SECRETS_CONFIG) | while read line; do \
		eval "echo $$line"; \
	done > ~/.secrets
	@echo "Secrets written to ~/.secrets"

# settings.json と mcp.json の定義に基づき、Claude Code のプラグインと MCP サーバーをセットアップする
# 注意: claude mcp add は同名の MCP が既に登録されているとスキップされる
#       mcp.json の設定を変更した場合は、先に `claude mcp remove <name>` で削除してから再実行すること
.PHONY: claude-code
claude-code:
	@jq -r '.extraKnownMarketplaces | to_entries[] | .value.source.repo' $(CLAUDE_SETTINGS) | while read repo; do \
		claude plugin marketplace add "$$repo" 2>/dev/null || true; \
	done
	@jq -r '.enabledPlugins | to_entries[] | select(.value == true) | .key' $(CLAUDE_SETTINGS) | while read plugin; do \
		claude plugin install "$$plugin" 2>/dev/null || true; \
	done
	@jq -r '.mcpServers | to_entries[] | "\(.key) \(.value.command) \(.value.args | join(" "))"' $(CLAUDE_MCP) | while read name cmd args; do \
		claude mcp add "$$name" --scope user -- $$cmd $$args 2>/dev/null || true; \
	done
