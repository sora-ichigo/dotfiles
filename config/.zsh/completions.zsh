# gh
eval "$(gh completion -s zsh)"

# gcloud
if [ -f '/Users/ichigo/google-cloud-sdk/completion.zsh.inc' ]; then
  . '/Users/ichigo/google-cloud-sdk/completion.zsh.inc';
fi
