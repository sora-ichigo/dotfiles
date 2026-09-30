#!/usr/bin/env bash

id=$1
sketchybar --set claude popup.drawing=off

cwd=$(claude agents --json 2>/dev/null | jq -r --arg id "$id" '.[] | select(.id == $id) | .cwd' 2>/dev/null)
pane=$(bash "${CLAUDE_TMUX_PANE_SCRIPT:-$HOME/.claude/tmux_pane.sh}" "$cwd")

if [ -n "$pane" ]; then
  tmux switch-client -t "$pane"
  open -a WezTerm
else
  wezterm start -- claude attach "$id" >/dev/null 2>&1 &
fi
