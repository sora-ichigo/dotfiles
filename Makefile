.PHONY: nix
nix:
	./install.sh

.PHONY: brew
brew:
	brew bundle --file=Brewfile
