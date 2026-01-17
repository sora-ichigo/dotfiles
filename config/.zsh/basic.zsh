# env
setopt IGNOREEOF
setopt no_beep
setopt interactive_comments
setopt glob_dots

# cd
setopt auto_cd
chpwd() { ls -l -a }

# history
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt share_history
setopt inc_append_history
setopt extended_history

# directory stack
setopt auto_pushd
setopt pushd_ignore_dups
DIRSTACKSIZE=100

bindkey -e

# autoload
autoload -U compinit
compinit -u
autoload -Uz colors
colors
autoload -U +X bashcompinit && bashcompinit

# completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

