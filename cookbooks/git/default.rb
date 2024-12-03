package 'git'
# FIXME: ssh-key の用意をする必要がある

if node[:platform] == 'darwin'
  package 'gh'
  package 'ghq'
elsif node[:platform] == 'ubuntu' || node[:platform] == 'debian'
  execute 'install gh' do
    command `
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
      sudo apt update
      sudo apt install gh
    `
    not_if 'test $(which gh)'
  end
end

dotfile '.gitconfig'
dotfile '.gitignore'
dotfile '.git_template'
dotfile '.config/gh/config.yml'
