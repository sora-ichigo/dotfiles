# gh
eval "$(gh completion -s zsh)"

# gcloud
if [ -f '/Users/ichigo/google-cloud-sdk/completion.zsh.inc' ]; then
  . '/Users/ichigo/google-cloud-sdk/completion.zsh.inc';
fi

# terraform
if [ $(uname) = "Darwin" ]; then
  complete -o nospace -C /opt/homebrew/Cellar/tfenv/2.2.2/versions/1.0.9/terraform terraform
  fpath=(/usr/local/share/zsh-completions $fpath)
fi

# gh
eval "$(gh completion -s zsh)"
