%w(
  wget
  curl
  htop
  make
  gcc
  direnv
  fzf
  gnu-sed
  bat
  lazygit
  coreutils
  libffi
).each do |v|
  package v do
    if node[:platform] == 'darwin'
      user node[:user]
    else
      user 'root'
    end
  end
end
