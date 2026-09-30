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

  if [ "$sid" = "$focused" ]; then
    args+=(--set "space.$sid" drawing=on background.drawing=on icon.color="$ACCENT_COLOR")
  elif [ ${#icons[@]} -gt 0 ]; then
    args+=(--set "space.$sid" drawing=on background.drawing=off icon.color="$WHITE")
  else
    args+=(--set "space.$sid" drawing=off)
  fi

  for ((i = 1; i <= slots; i++)); do
    if [ "$i" -le ${#icons[@]} ]; then
      args+=(--set "space.$sid.$i" drawing=on icon="${icons[$((i - 1))]}")
    else
      args+=(--set "space.$sid.$i" drawing=off)
    fi
  done
done

sketchybar "${args[@]}"
