package 'zsh'

if node[:platform] != 'darwin'
  execute "chsh -s /bin/zsh #{node[:user]}" do
    user 'root'
  end
end

dotfile '.zsh'
dotfile '.zshrc'
