#!/usr/bin/env bash
set -u

SLACK=com.tinyspeck.slackmacgap

workspace=4
[ "$(aerospace list-monitors --count)" = 2 ] && workspace=2

ids=$(aerospace list-windows --all --format '%{window-id} %{app-bundle-id}' | awk -v app="$SLACK" '$2 == app { print $1 }')
[ -n "$ids" ] || exit 0

for id in $ids; do
  aerospace move-node-to-workspace --window-id "$id" "$workspace"
done

sketchybar --trigger aerospace_workspace_change
