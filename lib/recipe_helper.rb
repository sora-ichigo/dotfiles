MItamae::RecipeContext.class_eval do
  # CURSOR_RULE_START: dotfiles
  # dotfilesの使い方と設定方法に関するドキュメント
  #
  # # dotfilesの使い方
  #
  # ## 新しいパッケージをインストールする方法
  #
  # ### 通常のHomebrew パッケージ (Formula) をインストールする場合
  #
  # 1. `cookbooks/[パッケージ名]` ディレクトリを作成する
  #    ```
  #    mkdir -p cookbooks/[パッケージ名]
  #    ```
  #
  # 2. `cookbooks/[パッケージ名]/default.rb` ファイルを作成し、パッケージのインストール設定を追加する
  #    ```ruby
  #    package '[パッケージ名]'
  #    ```
  #
  #    **重要**: パッケージ名は `brew info [パッケージ名]` で確認できる正確な名前を使用してください。
  #    例えば、`rg` コマンドは実際には `ripgrep` パッケージです。
  #
  # 3. `roles/darwin/default.rb` (macOSの場合) または対応するプラットフォームのroleファイルに、パッケージを追加する
  #    ```ruby
  #    include_cookbook '[パッケージ名]'
  #    ```
  #
  # ### Homebrew Cask (GUI アプリケーション) をインストールする場合
  #
  # 1. `cookbooks/[パッケージ名]` ディレクトリを作成する
  #    ```
  #    mkdir -p cookbooks/[パッケージ名]
  #    ```
  #
  # 2. `cookbooks/[パッケージ名]/default.rb` ファイルを作成し、Caskパッケージのインストール設定を追加する
  #    ```ruby
  #    brew_cask_package '[パッケージ名]'
  #    ```
  #
  #    **重要**: パッケージ名は `brew info --cask [パッケージ名]` で確認できる正確な名前を使用してください。
  #    また、アプリケーション名が通常と異なる場合は、`lib/recipe_helper.rb` の `app_name_map` にマッピングを追加してください。
  #
  # 3. `roles/darwin/default.rb` (macOSの場合) または対応するプラットフォームのroleファイルに、パッケージを追加する
  #    ```ruby
  #    include_cookbook '[パッケージ名]'
  #    ```
  #
  # ## 例: neovimパッケージのインストール設定 (Formula)
  #
  # 1. cookbooks/neovimディレクトリを作成
  #    ```
  #    mkdir -p cookbooks/neovim
  #    ```
  #
  # 2. cookbooks/neovim/default.rbファイルを作成
  #    ```ruby
  #    package 'neovim'
  #    ```
  #
  # 3. roles/darwin/default.rbファイルに以下の行を追加
  #    ```ruby
  #    include_cookbook 'neovim'
  #    ```
  #
  # ## 例: Visual Studio Codeのインストール設定 (Cask)
  #
  # 1. cookbooks/vscodeディレクトリを作成
  #    ```
  #    mkdir -p cookbooks/vscode
  #    ```
  #
  # 2. cookbooks/vscode/default.rbファイルを作成
  #    ```ruby
  #    brew_cask_package 'visual-studio-code'
  #    ```
  #
  # 3. roles/darwin/default.rbファイルに以下の行を追加
  #    ```ruby
  #    include_cookbook 'vscode'
  #    ```
  # CURSOR_RULE_END: dotfiles

  def include_cookbook(name)
    root_dir = File.expand_path('../..', __FILE__)
    include_recipe File.join(root_dir, 'cookbooks', name, 'default')
  end

  def include_role(name)
    root_dir = File.expand_path('../..', __FILE__)
    include_recipe File.join(root_dir, 'roles', name, 'default')
  end

  def has_package?(name)
    result = run_command("dpkg-query -f '${Status}' -W #{name.shellescape} | grep -E '^(install|hold) ok installed$'", error: false)
    result.exit_status == 0
  end

  def brew_prefix
    arch = `uname -m`.chomp
    case arch
    when 'x86_64'; '/usr/local'
    when 'arm64';  '/opt/homebrew'
    else fail "unknown arch: #{arch}"
    end
  end

  def default_prefix
    "#{ENV["HOME"]}/.local"
  end

  # Homebrew Caskパッケージをインストールするためのヘルパーメソッド
  # パッケージが既にインストールされている場合はスキップします
  def brew_cask_package(name)
    # パッケージ名とアプリケーション名のマッピング（必要に応じて追加）
    app_name_map = {
      'meetingbar' => 'MeetingBar',
      '1password' => '1Password',
      '1password-cli' => 'op',
      'shottr' => 'Shottr',
      'rubymine' => 'RubyMine',
      'chatgpt' => 'ChatGPT'
    }

    # デフォルトではパッケージ名を大文字にしたものをアプリケーション名とする
    app_name = app_name_map[name] || name.capitalize

    execute "install #{name} cask" do
      command "brew install --cask #{name}"
      # アプリケーションがすでに存在するかチェック
      # CLIツールの場合は which を使用
      if app_name == 'op'
        not_if "which #{app_name} >/dev/null 2>&1"
      else
        # 通常のアプリケーションの場合は /Applications ディレクトリをチェック
        not_if "ls /Applications/#{app_name}.app >/dev/null 2>&1 || ls ~/Applications/#{app_name}.app >/dev/null 2>&1"
      end
      user node[:user] if node[:platform] == 'darwin'
    end
  end
end
