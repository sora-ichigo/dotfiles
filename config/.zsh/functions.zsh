register_keycommand() {
  zle -N $2
  bindkey "$1" $2
}

fzf_history() {
  BUFFER="`history -n 1 | tac | fzf --query "$BUFFER"`"
  CURSOR=$#BUFFER
  zle clear-screen
}
register_keycommand "^r" fzf_history

fzf_git_branch() {
local branch="`git branch --format='%(refname:short)' | fzf`"
  BUFFER="$LBUFFER$branch"
  CURSOR=$#BUFFER
}
register_keycommand "^o" fzf_git_branch

fzf_files() {
  local filepath="$(find . -maxdepth 4 |fzf --preview "bat --color=always --style=header,grid --line-range :100 {}" --prompt 'PATH>')"
  [ -z "$filepath" ] && return
  if [ -n "$LBUFFER" ]; then
    BUFFER="$LBUFFER$filepath"
  else
    if [ -d "$filepath" ]; then
      BUFFER="cd $filepath"
    elif [ -f "$filepath" ]; then
      BUFFER="nvim $filepath"
    fi
  fi
  CURSOR=$#BUFFER
}
register_keycommand "^w" fzf_files

fzf_jump_g() {
  cd ~/ghq/github.com
}
register_keycommand "^g" fzf_jump_g


rubymine() {
  open -na "RubyMine.app" --args "$@"
}
