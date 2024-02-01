.PHONY: mitamae
mitamae:
	./bin/mitamae local ./lib/recipe.rb
mitamae-dry:
	./bin/mitamae local -n ./lib/recipe.rb
list-extensions:
	cursor --list-extensions > ./config/Library/Application\ Support/Cursor/User/extensions
