package 'postgresql@17' do
  if node[:platform] == "darwin"
    user node[:user]
  else
    user 'root'
  end
end
