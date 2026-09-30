#!/usr/bin/env bash

PLUGIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$PLUGIN_DIR/../colors.sh"
source "$(command -v icon_map.sh)"

sid=$1
focused=${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}

icons=""
while IFS= read -r app; do
  [ -n "$app" ] || continue
  __icon_map "$app"
  icons+="$icon_result "
done < <(aerospace list-windows --workspace "$sid" --format '%{app-name}' | sort -u)

if [ "$sid" = "$focused" ]; then
  sketchybar --set "$NAME" drawing=on background.drawing=on icon.color="$ACCENT_COLOR" label="$icons"
elif [ -n "$icons" ]; then
  sketchybar --set "$NAME" drawing=on background.drawing=off icon.color="$WHITE" label="$icons"
else
  sketchybar --set "$NAME" drawing=off
fi
