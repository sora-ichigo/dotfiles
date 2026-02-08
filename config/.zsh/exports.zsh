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

# mise
eval "$(mise activate zsh)"

# go
export PATH=$PATH:$HOME/gobin
export GOPATH=$HOME
export GOBIN=$HOME/gobin

# flutterfile
export PATH=$PATH:$HOME/.pub-cache/bin

# Java
if (/usr/libexec/java_home > /dev/null 2>&1); then
  export JAVA_HOME=$(/usr/libexec/java_home)
fi
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# Haskell
[ -f "/Users/ichigo/.ghcup/env" ] && source "/Users/ichigo/.ghcup/env" # ghcup-env

# Deno
export PATH="/Users/ichigo/.deno/bin:$PATH"

# postgresql
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# direnv
eval "$(direnv hook zsh)"

# openssl
export PATH="/opt/homebrew/opt/openssl@1.1/bin:$PATH"

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

# libpq
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# https://stackoverflow.com/questions/52671926/rails-may-have-been-in-progress-in-another-thread-when-fork-was-called
export DISABLE_SPRING=true
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# gnu-sed
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin
