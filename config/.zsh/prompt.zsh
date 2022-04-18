_init_prompt() {
  ARCH=[`uname -m`]
  PROMPT_APP_ENV=[`echo $KUBE_FORK_TARGET_ENV`]
  BRANCH=[`git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="refs/heads/"} {print $NF}'`]
  PS1="%{%F{cyan}%}/→  %{%F{white}%}%~  %{%F{cyan}%}/→   $ARCH $BRANCH $PROMPT_APP_ENV
  %{%F{cyan}%}%#:%{%F{cyan}%}%{%F{white}%} /→ "
}

precmd() { 
  _init_prompt
}

_init_prompt
