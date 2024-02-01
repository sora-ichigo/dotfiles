dotfile "Library/Application Support/Cursor/User/settings.json"
dotfile "Library/Application Support/Cursor/User/keybindings.json"
dotfile "Library/Application Support/Cursor/User/extensions"

execute 'Install extensions' do
  command `
cat $HOME/Library/Application Support/Cursor/User/extensions | while read line
do
code --install-extension $line
done
  `
end

