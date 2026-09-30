#!/usr/bin/env bash

sketchybar --set claude popup.drawing=off

root=$(ghq root)
repos=()
while IFS= read -r repo; do
  repos+=("$repo")
done < <(ghq list)

repo=$(osascript \
  -e 'on run argv' \
  -e 'activate' \
  -e 'choose from list argv with title "Claude" with prompt "リポジトリを選択"' \
  -e 'end run' \
  "${repos[@]}") || exit 0
[ -n "$repo" ] && [ "$repo" != "false" ] || exit 0

prompt=$(osascript \
  -e 'activate' \
  -e "text returned of (display dialog \"$repo で実行するプロンプト\" default answer \"\" with title \"Claude\")") || exit 0
[ -n "$prompt" ] || exit 0

cd "$root/$repo" || exit 0
claude --bg "$prompt" >/dev/null 2>&1
sketchybar --trigger claude_agents_update
