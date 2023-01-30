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
eval "$(rbenv init -)"

# nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"

# go
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/gobin
export GOPATH=$HOME
export GOBIN=$HOME/gobin

# flutter
export PATH=$PATH:$HOME/flutter/bin

# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-17.0.1.jdk/Contents/Home

# Haskell
[ -f "/Users/ichigo/.ghcup/env" ] && source "/Users/ichigo/.ghcup/env" # ghcup-env

# Deno
export PATH="/Users/ichigo/.deno/bin:$PATH"

# mysql
export PATH="/opt/homebrew/opt/mysql@5.7/bin:$PATH"

# postgresql@14
export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"
export PGDATA=/opt/homebrew/bin/postgres

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

