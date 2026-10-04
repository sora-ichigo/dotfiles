#!/usr/bin/env bash
set -u

LAYOUT=(
  "com.github.wez.wezterm 1"
  "md.obsidian 2"
)

workspace_for() {
  local entry
  for entry in "${LAYOUT[@]}"; do
    if [ "${entry% *}" = "$1" ]; then
      echo "${entry#* }"
      return 0
    fi
  done
  return 1
}

windows=$(aerospace list-windows --all --format '%{window-id} %{app-bundle-id}')

while read -r id app; do
  [ -n "$id" ] || continue
  ws=$(workspace_for "$app") || continue
  aerospace move-node-to-workspace --window-id "$id" "$ws"
done <<<"$windows"

for entry in "${LAYOUT[@]}"; do
  app=${entry% *}
  grep -q " $app\$" <<<"$windows" || open -g -b "$app"
done

sketchybar --trigger aerospace_workspace_change
