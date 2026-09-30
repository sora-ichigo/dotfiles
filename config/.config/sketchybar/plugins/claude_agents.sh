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

popup=$(sketchybar --query "$NAME" 2>/dev/null | jq -r '(.popup.drawing // "off"), (.popup.items[]?)' 2>/dev/null)
drawing=$(head -n 1 <<<"$popup")
existing=$'\n'$(tail -n +2 <<<"$popup")$'\n'
wanted=$'\n'
changed=
names=()
icons=()
colors=()
labels=()
clicks=()

waiting=0
working=0
done_count=0
while IFS=$'\t' read -r id rank title repo; do
  [ -n "$id" ] || continue
  case "$rank" in
  0) waiting=$((waiting + 1)); icon=󰋗; color=$YELLOW ;;
  1) working=$((working + 1)); icon=󰔟; color=$GREEN ;;
  *) done_count=$((done_count + 1)); icon=󰄬; color=$GREY ;;
  esac
  names+=("claude.agent.$id")
  icons+=("$icon")
  colors+=("$color")
  labels+=("$title · $repo")
  clicks+=("$PLUGIN_DIR/claude_attach.sh $id")
  wanted+="claude.agent.$id"$'\n'
done <<<"$rows"

args=()
order=()
while IFS= read -r name; do
  [ -n "$name" ] || continue
  case "$wanted" in
  *$'\n'"$name"$'\n'*)
    for i in "${!names[@]}"; do
      [ "${names[$i]}" = "$name" ] && order+=("$i")
    done
    ;;
  *) args+=(--remove "$name"); changed=1 ;;
  esac
done <<<"$existing"

for i in "${!names[@]}"; do
  case "$existing" in
  *$'\n'"${names[$i]}"$'\n'*) ;;
  *) args+=(--add item "${names[$i]}" popup."$NAME"); order+=("$i"); changed=1 ;;
  esac
done

number=0
for i in "${order[@]}"; do
  number=$((number + 1))
  label=${labels[$i]}
  [ "$number" -le 9 ] && label="$number $label"
  args+=(--set "${names[$i]}" icon="${icons[$i]}" icon.color="${colors[$i]}" label="$label" click_script="${clicks[$i]}")
done

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

if [ -n "$changed" ] && [ "$drawing" = "on" ]; then
  args+=(--set "$NAME" popup.drawing=off --set "$NAME" popup.drawing=on)
fi

sketchybar "${args[@]}"
