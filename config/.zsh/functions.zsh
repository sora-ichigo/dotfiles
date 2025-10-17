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
  local filepath="$(fd |fzf --preview "bat --color=always --style=header,grid --line-range :100 {}" --prompt 'PATH>')"
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

select_worktree() {
  local worktrees
  worktrees=$(git worktree list --porcelain | awk '/worktree / {print $2}')
  if [[ -z "$worktrees" ]]; then
    echo "No worktrees found."
    return 1
  fi
  local selected
  selected=$(echo "$worktrees" | fzf)
  if [[ -n "$selected" ]]; then
    echo "$selected"
    cd "$selected"
  fi
}
register_keycommand "^j" select_worktree

# 会社の Claude Code 設定用
function set_wantedly_env_vars() {
  if [[ "$PWD" == "$HOME/ghq/github.com/wantedly/"* ]]; then
    export CLAUDE_CODE_USE_BEDROCK=1
    export AWS_REGION=us-east-1
    export AWS_PROFILE=local-bedrock
    export ANTHROPIC_MODEL=arn:aws:bedrock:us-east-1:096233016669:application-inference-profile/w7swxvx62vum
    export ANTHROPIC_SMALL_FAST_MODEL=arn:aws:bedrock:us-east-1:096233016669:application-inference-profile/bs36o7kf43bd
  else
    unset CLAUDE_CODE_USE_BEDROCK
    unset ANTHROPIC_MODEL
    unset ANTHROPIC_SMALL_FAST_MODEL
  fi
}
autoload -U add-zsh-hook
add-zsh-hook chpwd set_wantedly_env_vars
set_wantedly_env_vars
