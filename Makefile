.PHONY: nix
nix:
	./install.sh

.PHONY: brew
brew:
	brew bundle --file=Brewfile

CLAUDE_SETTINGS := config/.claude/settings.json

.PHONY: claude-code-plugins
claude-code-plugins:
	@jq -r '.extraKnownMarketplaces | to_entries[] | .value.source.repo' $(CLAUDE_SETTINGS) | while read repo; do \
		claude plugin marketplace add "$$repo" 2>/dev/null || true; \
	done
	@jq -r '.enabledPlugins | to_entries[] | select(.value == true) | .key' $(CLAUDE_SETTINGS) | while read plugin; do \
		claude plugin install "$$plugin" 2>/dev/null || true; \
	done
