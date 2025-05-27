_init_prompt() {
  ARCH=[`uname -m`]
  PROMPT_APP_ENV=[`echo $KUBE_FORK_TARGET_ENV`]

  local git_branch=""
  if git rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "")
    if [[ -n "$git_branch" ]]; then
      BRANCH="[$git_branch]"
    else
      BRANCH="[]"
    fi
  else
    BRANCH="[]"
  fi

  PS1="%{%F{cyan}%}/→  %{%F{white}%}%~  %{%F{cyan}%}/→   $ARCH $BRANCH $PROMPT_APP_ENV
  %{%F{cyan}%}%#:%{%F{cyan}%}%{%F{white}%} /→ "
}

precmd() {
  _init_prompt
}

_init_prompt
