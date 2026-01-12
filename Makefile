.PHONY: mitamae
mitamae:
	./bin/mitamae local ./lib/recipe.rb
mitamae-dry:
	./bin/mitamae local -n ./lib/recipe.rb

.PHONY: nix
nix:
	./bin/nix-setup
