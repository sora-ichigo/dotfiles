package 'zsh'

if ENV["SHELL"] != "bin/zsh"
  execute "chsh -s /bin/zsh #{node[:user]}"
end

dotfile '.zsh'
dotfile '.zshrc'
