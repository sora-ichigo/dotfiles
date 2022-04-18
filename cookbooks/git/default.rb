package 'git'

if node[:platform] == 'darwin'
  package 'gh'
else
  github_release 'gh' do
    v = "1.2.1"
    name = "gh_#{v}_#{node[:kernel][:name].downcase}_amd64"

    repo 'cli/cli'
    version "v#{v}"
    archive "#{name}.tar.gz"
    checksum "gh_#{v}_checksums.txt"
    bin "#{name}/bin/gh"
  end
end

dotfile '.gitconfig'
dotfile '.gitignore'
