#!/usr/bin/env bash

cores=$(sysctl -n hw.ncpu)
percent=$(ps -A -o %cpu= | awk -v cores="$cores" '{ sum += $1 } END { printf "%d", sum / cores }')
[ "$percent" -gt 100 ] && percent=100

sketchybar --push "$NAME" "$(awk -v p="$percent" 'BEGIN { printf "%.2f", p / 100 }')" \
  --set "$NAME" label="$percent%"
