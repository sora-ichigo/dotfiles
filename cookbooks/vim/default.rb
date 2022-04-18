if node[:platform] == 'darwin'
  package 'neovim' do
    options '--HEAD'
  end
else
  http_request "#{default_prefix}/bin/nvim" do
    url "https://github.com/neovim/neovim/releases/download/v0.6.0/nvim.appimage"
    user node[:user]
    mode "744"
  end
end

dotfile '.config/nvim'
