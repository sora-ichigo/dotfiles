autoload -U compinit
compinit -u
autoload -Uz colors
colors
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/Cellar/tfenv/2.2.2/versions/1.0.9/terraform terraform
fpath=(/usr/local/share/zsh-completions $fpath)

source ~/.zsh/prompt.zsh
source ~/.zsh/exports.zsh
source ~/.zsh/aliases.zsh
source ~/.zsh/functions.zsh
source ~/.zsh/completions.zsh
