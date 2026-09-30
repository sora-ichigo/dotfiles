#!/usr/bin/env bash

PLUGIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$PLUGIN_DIR/../colors.sh"
source "$(command -v icon_map.sh)"

slots=${SPACE_APP_SLOTS:-3}
focused=${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}
windows=$(aerospace list-windows --all --format '%{workspace}|%{app-name}' | sort -u)

args=()
for sid in $(aerospace list-workspaces --all); do
  icons=()
  while IFS='|' read -r ws app; do
    [ "$ws" = "$sid" ] && [ -n "$app" ] || continue
    __icon_map "$app"
    icons+=("$icon_result")
  done <<<"$windows"

  first=${icons[0]:-}
  if [ "$sid" = "$focused" ]; then
    args+=(--set "space.$sid" drawing=on background.drawing=on icon.color="$ACCENT_COLOR" label="$first")
  elif [ -n "$first" ]; then
    args+=(--set "space.$sid" drawing=on background.drawing=off icon.color="$WHITE" label="$first")
  else
    args+=(--set "space.$sid" drawing=off label="")
  fi

  for ((i = 1; i <= slots; i++)); do
    if [ "$i" -lt ${#icons[@]} ]; then
      args+=(--set "space.$sid.$i" drawing=on icon="${icons[$i]}")
    else
      args+=(--set "space.$sid.$i" drawing=off)
    fi
  done
done

sketchybar "${args[@]}"
