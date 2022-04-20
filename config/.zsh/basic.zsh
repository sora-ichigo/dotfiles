# env
setopt IGNOREEOF

# cd
setopt auto_cd
chpwd() { ls -l -a }

# hitory
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt share_history

# directory stack
setopt auto_pushd
setopt pushd_ignore_dups
DIRSTACKSIZE=100

bindkey -e
