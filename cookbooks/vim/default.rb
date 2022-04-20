if node[:platform] == 'darwin'
  package 'neovim' do
    options '--HEAD'
  end
else
  directory "#{default_prefix}/bin"
  # FIXME: ~/.local/bin が存在しないと怒られた
  http_request "#{default_prefix}/bin/nvim" do
    url "https://github.com/neovim/neovim/releases/download/v0.6.0/nvim.appimage"
    user node[:user]
    mode "744"
  end
end

directory "#{ENV[HOME]}/.config"
# FIXME: ~/.config/nvim が存在しないと怒られた
# FIXME: NeoBundle を別途インストールしないといけない
dotfile '.config/nvim'
