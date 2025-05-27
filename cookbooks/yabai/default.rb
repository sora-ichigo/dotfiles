execute "add yabai tap" do
  command "brew tap koekeishiya/formulae"
  not_if "brew tap | grep koekeishiya/formulae"
  user node[:user] if node[:platform] == 'darwin'
end

execute "install yabai" do
  command "brew install koekeishiya/formulae/yabai"
  not_if "which yabai >/dev/null 2>&1"
  user node[:user] if node[:platform] == 'darwin'
end

execute "install skhd" do
  command "brew install koekeishiya/formulae/skhd"
  not_if "which skhd >/dev/null 2>&1"
  user node[:user] if node[:platform] == 'darwin'
end

dotfile '.yabairc'
dotfile '.skhdrc'
