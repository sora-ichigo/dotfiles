sam_zip_dir="#{default_prefix}/bin/aws-sam-cli-linux-x86_64.zip"
bin_dir="#{default_prefix}/bin"

directory "#{bin_dir}"
http_request "#{sam_zip_dir}" do
  url "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip"
  user node[:user]
  mode "0744"
  not_if "test #{sam_zip_dir}"
end

execute 'Unzip aws-sam-cli' do
  command "unzip #{sam_zip_dir} -d #{bin_dir}/sam-installation"
  not_if "test #{bin_dir}/sam-installation"
end

execute 'sam install' do
  command "#{bin_dir}/sam-installation/install"
  user 'root'
  not_if "test $(which sam)"
end
