package 'zsh'

if node[:platform] != 'darwin'
  dotfile '.zshrc.Linux'

  execute "chsh -s /bin/zsh #{node[:user]}" do
    only_if "getent passwd #{node[:user]} | cut -d: -f7 | grep -q '^/bin/bash$'"
    user 'root'
  end
end

dotfile '.zsh'
dotfile '.zshrc'
