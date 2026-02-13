.PHONY: nix
nix:
	./install.sh

.PHONY: brew
brew:
	brew bundle --file=Brewfile

.PHONY: claude-code-plugins
claude-code-plugins:
	claude plugin marketplace add upstash/context7
	claude plugin install context7-plugin@context7-marketplace
