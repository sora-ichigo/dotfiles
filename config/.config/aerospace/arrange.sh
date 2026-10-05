#!/usr/bin/env bash
set -u

LAYOUT=(
  "com.github.wez.wezterm 1"
  "md.obsidian 2"
  "com.google.Chrome 3"
  "com.tinyspeck.slackmacgap 4"
)

SLACK=com.tinyspeck.slackmacgap
SHARED_WORKSPACE=2

workspace_for() {
  local entry
  if [ "$1" = "$SLACK" ] && [ "$(aerospace list-monitors --count)" = 2 ]; then
    echo "$SHARED_WORKSPACE"
    return 0
  fi
  for entry in "${LAYOUT[@]}"; do
    if [ "${entry% *}" = "$1" ]; then
      echo "${entry#* }"
      return 0
    fi
  done
  return 1
}

is_reserved() {
  local entry
  for entry in "${LAYOUT[@]}"; do
    [ "${entry#* }" = "$1" ] && return 0
  done
  return 1
}

spare=0
for entry in "${LAYOUT[@]}"; do
  [ "${entry#* }" -gt "$spare" ] && spare=${entry#* }
done
spare=$((spare + 1))

windows=$(aerospace list-windows --all --format '%{window-id} %{app-bundle-id} %{workspace}')

shared_id=""
while read -r id app current; do
  [ -n "$id" ] || continue
  if ws=$(workspace_for "$app"); then
    aerospace move-node-to-workspace --window-id "$id" "$ws"
    [ "$app" = "$SLACK" ] && [ "$ws" = "$SHARED_WORKSPACE" ] && [ -z "$shared_id" ] && shared_id=$id
  elif is_reserved "$current"; then
    aerospace move-node-to-workspace --window-id "$id" "$spare"
  fi
done <<<"$windows"

[ -n "$shared_id" ] && aerospace layout --window-id "$shared_id" v_tiles

for entry in "${LAYOUT[@]}"; do
  app=${entry% *}
  grep -q " $app " <<<"$windows" || open -g -b "$app"
done

sketchybar --trigger aerospace_workspace_change
