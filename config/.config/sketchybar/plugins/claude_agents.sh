#!/usr/bin/env bash

PLUGIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$PLUGIN_DIR/../colors.sh"

if ! json=$(claude agents --json 2>/dev/null) || ! rows=$(jq -r '
  map(select(.kind == "background"))
  | map(. + {rank: (if .state == "working" then 1 elif .state == "done" then 2 else 0 end)})
  | sort_by(.rank)
  | .[]
  | [.id, .rank, (.name // "untitled"), (.cwd | sub("/\\.claude/worktrees/.*$"; "") | split("/") | last)]
  | @tsv
' <<<"$json" 2>/dev/null); then
  sketchybar --set "$NAME" icon.color="$RED" label.drawing=off
  exit 0
fi

waiting=0
working=0
done_count=0
args=(--remove '/claude\.agent\..*/')
args+=(--add item claude.agent.new popup."$NAME"
  --set claude.agent.new icon=󰐕 icon.color="$BLUE" label="New session"
  click_script="$PLUGIN_DIR/claude_new.sh")

while IFS=$'\t' read -r id rank title repo; do
  [ -n "$id" ] || continue
  case "$rank" in
  0) waiting=$((waiting + 1)); icon=󰋗; color=$YELLOW ;;
  1) working=$((working + 1)); icon=󰔟; color=$GREEN ;;
  *) done_count=$((done_count + 1)); icon=󰄬; color=$GREY ;;
  esac
  args+=(--add item "claude.agent.$id" popup."$NAME"
    --set "claude.agent.$id" icon="$icon" icon.color="$color" label="$title · $repo"
    click_script="$PLUGIN_DIR/claude_attach.sh $id")
done <<<"$rows"

parts=()
[ "$waiting" -gt 0 ] && parts+=("$waiting waiting")
[ "$working" -gt 0 ] && parts+=("$working working")
[ "$done_count" -gt 0 ] && parts+=("$done_count done")

if [ "$waiting" -gt 0 ]; then
  color=$YELLOW
elif [ "$working" -gt 0 ]; then
  color=$GREEN
else
  color=$GREY
fi

if [ -n "${CLAUDE_AGENTS_COMPACT:-}" ]; then
  active=$((waiting + working))
  if [ "$active" -gt 0 ]; then
    args+=(--set "$NAME" icon.color="$color" label="$active" label.drawing=on)
  else
    args+=(--set "$NAME" icon.color="$color" label.drawing=off)
  fi
elif [ ${#parts[@]} -gt 0 ]; then
  label=$(printf ' · %s' "${parts[@]}")
  args+=(--set "$NAME" icon.color="$color" label="${label:3}" label.drawing=on)
else
  args+=(--set "$NAME" icon.color="$color" label.drawing=off)
fi

sketchybar "${args[@]}"
