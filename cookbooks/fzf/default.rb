if node[:platform] == 'darwin'
  package 'fzf'
else
  # FIXME: Ubuntu で入らない
  # sudo apt install fzf なら入る
end
