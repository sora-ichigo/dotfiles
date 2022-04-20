if node[:platform] == 'darwin'
  package 'golang'
elsif node[:platform] == 'ubuntu'
  # FIXME: うまく動いていない
  # execute "install go" do
  #   command "
  #     curl -LO https://go.dev/dl/go1.18beta1.linux-amd64.tar.gz
  #     tar -C /usr/local -xzf go1.18beta1.linux-amd64.tar.gz
  #   "
  # end
end

gopath = "#{ENV['HOME']}"
gobin = "#{ENV['HOME']}/gobin"

define 'go_install', version: "latest" do
  pkg = params[:name]
  pkg_bin_name = pkg.split("/").last

  execute "install #{pkg}" do
    command "GOPATH=#{gopath} GOBIN=#{gobin} go install #{pkg}@#{params[:version]}"
    not_if "test -e #{gobin}/#{pkg_bin_name}"
  end
end

# FIXME: ubuntu でうまく動かなかった
# error: can't load package: package github.com/go-delve/delve/cmd/dlv@latest: cannot use path@version syntax in GOPATH mode
if node[:platform] == 'darwin'
  packages = %w(
    github.com/go-delve/delve/cmd/dlv@latest
    golang.org/x/tools/cmd/godoc@latest
    golang.org/x/tools/cmd/goimports@latest
    golang.org/x/tools/gopls@latest
  )

  packages.each do |v|
    url = v.split("@")[0]
    version = v.split("@")[1]

    go_install url do
      version version
    end
  end

  golangcilint_version = "v1.43.0"

  execute 'install golangci-lint' do
    command "curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b #{gobin} #{golangcilint_version}"
    not_if 'test $(which golangci-lint)'
  end
end
