#!/bin/bash
set -eu
GITHUB_REPO="github.com/igsr5/dotfiles"
WORKDIR="${HOME}/${GITHUB_REPO}"

hasCommand() {
  return `type $1 > /dev/null 2>&1`
}

download() {
  local github_url="https://${GITHUB_REPO}"

  if hasCommand "git"; then
    git clone --recursive "${github_url}" "${WORKDIR}"
  elif hasCommand "curl" || hasCommand "wget"; then
    local zip_url="${github_url}/archive/refs/heads/master.tar.gz"

    if hasCommand "curl"; then
      curl -L "${zip_url}"
    elif hasCommand "wget"; then
      wget -O "${zip_url}"
    fi | tar xv -

    mv -f dotfiles-master "${WORKDIR}"
  else
    exit 1
  fi
}

if [ ! -d $WORKDIR ]; then
  mkdir $HOME/github.com/igsr5
  download
fi

cd $WORKDIR

bin/setup

case "$(uname)" in
  "Darwin")  bin/mitamae local lib/recipe.rb ;;
  *) sudo -E bin/mitamae local lib/recipe.rb ;;
esac

