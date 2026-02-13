.PHONY: nix
nix:
	./install.sh

.PHONY: brew
brew:
	brew bundle --file=Brewfile

CLAUDE_SETTINGS := config/.claude/settings.json
CLAUDE_MCP := config/.claude/mcp.json
SECRETS_CONFIG := config/secrets.json

.PHONY: secrets
secrets:
	@echo "Fetching secrets from 1Password..."
	@jq -r 'to_entries[] | "export \(.key)=\"$$(op read \"\(.value)\")\"" ' $(SECRETS_CONFIG) | while read line; do \
		eval "echo $$line"; \
	done > ~/.envrc
	@direnv allow ~
	@echo "Secrets written to ~/.envrc"

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
