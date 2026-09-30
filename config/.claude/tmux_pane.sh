#!/usr/bin/env bash

cwd=$1
[ -n "$cwd" ] || exit 0

tmux list-panes -a -F '#{pane_id}	#{pane_current_path}	#{pane_current_command}' 2>/dev/null | awk -F '\t' -v cwd="$cwd" '
  $2 == cwd || index(cwd, $2 "/") == 1 {
    score = length($2) * 2 + ($3 == "claude" || $3 ~ /^[0-9]+\.[0-9]+\.[0-9]+$/)
    if (score > best) { best = score; id = $1 }
  }
  END { print id }
'
