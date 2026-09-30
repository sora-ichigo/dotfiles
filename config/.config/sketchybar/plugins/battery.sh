#!/usr/bin/env bash

PLUGIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$PLUGIN_DIR/../colors.sh"

batt=$(pmset -g batt)
percent=$(grep -Eo '[0-9]+%' <<<"$batt" | head -1 | tr -d %)
[ -n "$percent" ] || exit 0

case "$percent" in
9[0-9] | 100) icon= color=$WHITE ;;
[6-8][0-9]) icon= color=$WHITE ;;
[3-5][0-9]) icon= color=$WHITE ;;
[1-2][0-9]) icon= color=$ORANGE ;;
*) icon= color=$RED ;;
esac

if grep -q 'AC Power' <<<"$batt"; then
  icon=
  color=$GREEN
fi

sketchybar --set "$NAME" icon="$icon" icon.color="$color"
