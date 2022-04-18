#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
# if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
#   source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
# fi
# 
# # Customize to your needs...
# #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
# export SDKMAN_DIR="/home/ichigo/.sdkman"
# [[ -s "/home/ichigo/.sdkman/bin/sdkman-init.sh" ]] && source "/home/ichigo/.sdkman/bin/sdkman-init.sh"


# ====================================================
# Original custom from here
# ====================================================
 
# prompt
function _init_prompt() {
  ARCH=[`uname -m`]
  PROMPT_APP_ENV=[`echo $KUBE_FORK_TARGET_ENV`]
  BRANCH=[`git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="refs/heads/"} {print $NF}'`]
  PS1="%{%F{cyan}%}/→  %{%F{white}%}%~  %{%F{cyan}%}/→   $ARCH $BRANCH $PROMPT_APP_ENV
  %{%F{cyan}%}%#:%{%F{cyan}%}%{%F{white}%} /→ "
}
_init_prompt
precmd() { 
  _init_prompt
}

# env
export GITHUB_ACCESS_TOKEN=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

setopt IGNOREEOF

# cd
setopt auto_cd
function chpwd() { ls -l -a }

# hitory
HISTFILE=~/.zsh_history         # 履歴の保存先
HISTSIZE=1000000                # メモリに保存される履歴の件数
SAVEHIST=1000000                # 保存される履歴の件数
setopt hist_ignore_all_dups     # コマンド履歴がダブってたら古い方を消す
setopt hist_ignore_space        # スペースから始まるコマンドを履歴に追加しない
setopt hist_reduce_blanks       # 履歴追加時に余分なスペースを削除
setopt share_history            # 同時に起動したzshの間で履歴共有

# directory stack
setopt auto_pushd           # ディレクトリスタックに追加（`cd +<Tab>`で履歴表示）
setopt pushd_ignore_dups    # pushd時にすでにスタックに含まれてた場合は追加しない
DIRSTACKSIZE=100            # ディレクトリスタック保存件数

# command completion
eval "$(gh completion -s zsh)"

# autoload
autoload -U compinit
compinit -u
autoload -Uz colors
colors
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/Cellar/tfenv/2.2.2/versions/1.0.9/terraform terraform

# homebrew
eval $(/opt/homebrew/bin/brew shellenv)

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
export GOPATH=$HOME
export GOBIN=$HOME/gobin
export PATH=$PATH:$GOBIN

# Java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-17.0.1.jdk/Contents/Home

# Haskell
[ -f "/Users/ichigo/.ghcup/env" ] && source "/Users/ichigo/.ghcup/env" # ghcup-env

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

# fpath
fpath=(/usr/local/share/zsh-completions $fpath)

# alias
alias v='LANG=C nvim'
alias so='source'
alias ...='cd ../..'
alias gosrc='cd ~/go/src/'
alias ls='exa -l -a'
alias valec='AWS_SDK_LOAD_CONFIG=1 valec'

alias gs='git status'
alias gb='git branch'
alias gc='git checkout'
alias gctm='git commit -m'
alias ga='git add'
alias gd='git diff'
alias gl='git log'
alias gcma='git checkout master'
alias gfo='git fetch origin'
alias gmom='git merge origin/master'
alias gpom='git push origin HEAD'

# function
bindkey '^r' run-command-with-peco
bindkey '^o' peco-git-checkout
bindkey '^w' peco-path
bindkey '^g' cd-git

zle -N run-command-with-peco
zle -N peco-git-checkout
zle -N peco-path
zle -N cd-git

function run-command-with-peco() {
  BUFFER="`history -n 1 | tac | fzf --query "$BUFFER"`"
  CURSOR=$#BUFFER
  zle clear-screen
}

function peco-git-checkout {
local branch="`git branch --format='%(refname:short)' | fzf`"
  BUFFER="$LBUFFER$branch"
  CURSOR=$#BUFFER
}

function peco-path() {
  local filepath="$(find . -maxdepth 4 |fzf --preview "bat --color=always --style=header,grid --line-range :100 {}" --prompt 'PATH>')"
  [ -z "$filepath" ] && return
  if [ -n "$LBUFFER" ]; then
    BUFFER="$LBUFFER$filepath"
  else
    if [ -d "$filepath" ]; then
      BUFFER="cd $filepath"
    elif [ -f "$filepath" ]; then
      BUFFER="nvim $filepath"
    fi
  fi
  CURSOR=$#BUFFER
}

function cd-git {
  cd ~/github.com
}

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ichigo/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ichigo/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ichigo/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ichigo/google-cloud-sdk/completion.zsh.inc'; fi
