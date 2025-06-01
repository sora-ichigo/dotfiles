export LANG=en_US.UTF-8

export EDITOR=nvim
export TERM=xterm-256color

if [ $(uname) = "Darwin" ]; then
  # homebrew
  eval $(/opt/homebrew/bin/brew shellenv)
fi

export PATH=$PATH:$HOME/.bin

# nvim
export PATH="$PATH:$HOME/.local/bin"

# vim
export PATH="$PATH:/usr/bin/vim"

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH="$HOME/.rbenv/shims:$PATH"
eval "$(rbenv init -)"

# rbenv
export PATH="$HOME/.nodenv/bin:$PATH"
export PATH="$HOME/.nodenv/shims:$PATH"
eval "$(nodenv init -)"
export PATH="$(npm prefix -g)/bin:$PATH"

# nodebrew
# export PATH=$HOME/.nodebrew/current/bin:$PATH

# pyenv
if [ -x "$(command -v pyenv)" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
fi

# go
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/gobin
export GOPATH=$HOME
export GOBIN=$HOME/gobin

# dart
export PATH=$PATH:$HOME/.pub-cache/bin

# flutter
export PATH=$PATH:$HOME/flutter/bin

# Java
if (/usr/libexec/java_home > /dev/null 2>&1); then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi

# Haskell
[ -f "/Users/ichigo/.ghcup/env" ] && source "/Users/ichigo/.ghcup/env" # ghcup-env

# Deno
export PATH="/Users/ichigo/.deno/bin:$PATH"

# mysql
export PATH="/opt/homebrew/opt/mysql@5.7/bin:$PATH"

# postgresql@14
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export PGDATA="/opt/homebrew/bin/postgres@17"

# direnv
eval "$(direnv hook zsh)"

# openssl
export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/openssl@1.1/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@1.1/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@1.1/lib/pkgconfig"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=/usr/local/opt/openssl@1.1"

# bat
export BAT_THEME="Solarized (light)"

# wantedly
export PATH=$HOME/.wantedly/bin:$PATH

# google-cloud-sdk
export PATH=$HOME/google-cloud-sdk/bin:$PATH
if [ -f '/Users/ichigo/google-cloud-sdk/path.zsh.inc' ]; then
  . '/Users/ichigo/google-cloud-sdk/path.zsh.inc';
fi

# github
export GIT_SSH_COMMAND="ssh -i ~/.ssh/github.pem"

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/libpq/lib"
export CPPFLAGS="-I/opt/homebrew/opt/libpq/include"

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

export PATH="$PATH:/Users/wantedly546/Library/Android/sdk/cmdline-tools/latest/bin"

export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

export JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home"

# libffi
export LDFLAGS="-L/opt/homebrew/opt/libffi/lib"
export CPPFLAGS="-I/opt/homebrew/opt/libffi/include"

export PKG_CONFIG_PATH="/opt/homebrew/opt/libffi/lib/pkgconfig"

# https://stackoverflow.com/questions/52671926/rails-may-have-been-in-progress-in-another-thread-when-fork-was-called
export DISABLE_SPRING=true
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# gnu-sed
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
