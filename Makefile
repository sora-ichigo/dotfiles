.PHONY: nix
nix:
	./bin/nix-setup

.PHONY: brew
brew:
	brew bundle --file=Brewfile
