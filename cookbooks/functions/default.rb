define :dotfile, source: nil do
  source = params[:source] || params[:name]
  target_path = File.join(ENV['HOME'], params[:name])
  target_dir = File.dirname(target_path)

  # リンク先のディレクトリが存在しない場合は作成する
  execute "mkdir -p #{target_dir}" do
    command "mkdir -p #{target_dir}"
    user node[:user]
    not_if "test -d #{target_dir}"
  end

  link target_path do
    to File.expand_path("../../../config/#{source}", __FILE__)
    user node[:user]
    force true
  end
end
