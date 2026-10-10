#!/usr/bin/env bash

PLUGIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$PLUGIN_DIR/../colors.sh"
source "$(command -v icon_map.sh)"

focused=${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}
windows=$(aerospace list-windows --all --format '%{workspace}|%{app-name}' | sort -u)

args=()
for sid in $(aerospace list-workspaces --all); do
  icons=""
  count=0
  while IFS='|' read -r ws app; do
    [ "$ws" = "$sid" ] && [ -n "$app" ] || continue
    [ -n "${SPACE_ICON_LIMIT:-}" ] && [ "$count" -ge "$SPACE_ICON_LIMIT" ] && break
    __icon_map "$app"
    icons+="$icon_result "
    count=$((count + 1))
  done <<<"$windows"

  font="sketchybar-app-font:Regular:15.0"
  [ "$count" -ge 2 ] && font="sketchybar-app-font:Regular:13.0"

  if [ "$sid" = "$focused" ]; then
    args+=(--set "space.$sid" drawing=on background.drawing=on icon.color="$ACCENT_COLOR" label="$icons" label.font="$font")
  elif [ -n "$icons" ]; then
    args+=(--set "space.$sid" drawing=on background.drawing=off icon.color="$TEXT_COLOR" label="$icons" label.font="$font")
  else
    args+=(--set "space.$sid" drawing=off label="")
  fi
done

sketchybar "${args[@]}"
