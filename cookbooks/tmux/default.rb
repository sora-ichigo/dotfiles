package 'tmux' do
  if node[:platform] == "darwin"
    user node[:user]
  else
    user 'root'
  end
end

dotfile '.tmux.conf'
dotfile '.tmux'
