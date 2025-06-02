_init_prompt() {
  ARCH=[`uname -m`]
  PROMPT_APP_ENV=[`echo $KUBE_FORK_TARGET_ENV`]

  local git_branch=""
  BRANCH="[]"

  {
    if timeout 1 git rev-parse --git-dir > /dev/null 2>&1; then
      git_branch=$(timeout 1 git symbolic-ref --short HEAD 2>/dev/null || timeout 1 git rev-parse --short HEAD 2>/dev/null || echo "")
      if [[ -n "$git_branch" ]]; then
        BRANCH="[$git_branch]"
      fi
    fi
  } 2>/dev/null || {
    BRANCH="[]"
  }

  PS1="%{%F{cyan}%}/→  %{%F{white}%}%~  %{%F{cyan}%}/→   $ARCH $BRANCH $PROMPT_APP_ENV
  %{%F{cyan}%}%#:%{%F{cyan}%}%{%F{white}%} /→ "
}

precmd() {
  _init_prompt
}

_init_prompt
