#!/usr/bin/env bash

cwd=$1
[ -n "$cwd" ] || exit 0

paths=$cwd
while IFS= read -r link; do
  target=$(cd "$link" 2>/dev/null && pwd -P) || continue
  case "$cwd" in
  "$target" | "$target"/*) paths+=$'\n'"$link${cwd#"$target"}" ;;
  esac
done < <(find "${GHQ_ROOT:-$HOME/ghq}" -mindepth 3 -maxdepth 3 -type l 2>/dev/null)

tmux -u list-panes -a -F '#{pane_id}	#{pane_current_path}	#{pane_current_command}' 2>/dev/null | PANE_PATHS=$paths awk -F '\t' '
  BEGIN { n = split(ENVIRON["PANE_PATHS"], paths, "\n") }
  {
    for (i = 1; i <= n; i++) {
      if ($2 == paths[i] || index(paths[i], $2 "/") == 1) {
        score = length($2) * 2 + ($3 == "claude" || $3 ~ /^[0-9]+\.[0-9]+\.[0-9]+$/)
        if (score > best) { best = score; id = $1 }
      }
    }
  }
  END { print id }
'
