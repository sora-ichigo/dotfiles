package 'golang'

gopath = "#{ENV['HOME']}"
gobin = "#{ENV['HOME']}/gobin"


define 'go_install', build: true do
  pkg = params[:name]
  execute "install #{pkg}" do
    command "GOPATH=#{gopath} GOBIN=#{gobin} go install #{params[:build] ? "" : "-d"} #{pkg}"
    not_if "test -e #{gopath}/src/#{pkg}"
  end
end

# command
go_install 'github.com/go-delve/delve/cmd/dlv@latest'

# vim
go_install 'golang.org/x/tools/cmd/godoc@latest'
go_install 'golang.org/x/tools/cmd/goimports@latest'
go_install 'golang.org/x/tools/gopls@latest'

golangcilint_version = "v1.43.0"

execute 'install golangci-lint' do
  command "curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b #{gobin} #{golangcilint_version}"
  not_if 'test $(which golangci-lint)'
end
