#!/bin/bash

set -eux
GITHUB_REPO="github.com/igsr5/dotfiles"
WORKDIR="${HOME}/${GITHUB_REPO}"

installRepository() {
  local url="https://${GITHUB_REPO}/archive/refs/heads/master.tar.gz"
  curl -L "${url}" | tar xvz

  mv -f dotfiles-master "${WORKDIR}"
}

if [ ! -d $WORKDIR ]; then
  mkdir -p $HOME/github.com/igsr5
  installRepository
fi

cd $WORKDIR

bin/setup

bin/mitamae local $@ lib/recipe.rb
