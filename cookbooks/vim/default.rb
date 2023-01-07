if node[:platform] == 'darwin'
  package 'neovim' do
    options '--HEAD'
  end
else
  directory "#{default_prefix}/bin"
  http_request "#{default_prefix}/bin/nvim" do
    url "https://github.com/neovim/neovim/releases/download/v0.6.0/nvim.appimage"
    user node[:user]
    mode "0744"
  end
end

directory "#{ENV["HOME"]}/.config"
dotfile '.config/nvim'

directory "#{ENV["HOME"]}/.vim/bundle"
git "#{ENV["HOME"]}/.vim/bundle/neobundle.vim" do
  repository "https://github.com/Shougo/neobundle.vim"
  user node[:user]
  not_if "test -e #{ENV["HOME"]}/.vim/bundle/neobundle.vim"
end

git "#{ENV["HOME"]}/.local/share/nvim/site/pack/packer/opt/packer.nvim" do
  repository "https://github.com/wbthomason/packer.nvim"
  user node[:user]
  not_if "test -e #{ENV["HOME"]}/.local/share/nvim/site/pack/packer/opt/packer.nvim"
end
