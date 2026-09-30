#!/usr/bin/env bash

PLUGIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PANE_SCRIPT=${CLAUDE_TMUX_PANE_SCRIPT:-$HOME/.claude/tmux_pane.sh}
source "$PLUGIN_DIR/../colors.sh"

if ! json=$(claude agents --json 2>/dev/null) || ! rows=$(jq -r '
  map(select(.kind == "background"))
  | map(. + {rank: (if .state == "working" then 1 elif .state == "done" then 2 else 0 end)})
  | sort_by(.rank)
  | .[]
  | [.id, .rank, (.name // "untitled"), (.cwd | sub("/\\.claude/worktrees/.*$"; "") | split("/") | last), .cwd]
  | @tsv
' <<<"$json" 2>/dev/null); then
  sketchybar --set "$NAME" icon.color="$RED" label.drawing=off
  exit 0
fi

popup=$(sketchybar --query "$NAME" 2>/dev/null | jq -r '(.popup.drawing // "off"), (.popup.items[]?)' 2>/dev/null)
drawing=$(head -n 1 <<<"$popup")
existing=$(tail -n +2 <<<"$popup")

ids=()
keys=()
icons=()
colors=()
labels=()

waiting=0
working=0
done_count=0
while IFS=$'\t' read -r id rank title repo cwd; do
  [ -n "$id" ] || continue
  case "$rank" in
  0) waiting=$((waiting + 1)); icon=󰋗; color=$YELLOW ;;
  1) working=$((working + 1)); icon=󰔟; color=$GREEN ;;
  *) done_count=$((done_count + 1)); icon=󰄬; color=$GREY ;;
  esac
  pane=$(bash "$PANE_SCRIPT" "$cwd")
  ids+=("$id")
  keys+=("${pane:-none}")
  icons+=("$icon")
  colors+=("$color")
  labels+=("$title · $repo")
done <<<"$rows"

groups=$( (printf '%s\n' "${keys[@]}" | grep -E '^%[0-9]+$' | sed 's/^%//' | sort -n -u | sed 's/^/%/'; printf '%s\n' "${keys[@]}" | grep -m 1 '^none$') 2>/dev/null)

args=()
desired=()
number=0
while IFS= read -r key; do
  [ -n "$key" ] || continue
  header="claude.group.${key#%}"
  desired+=("$header")
  first=
  for i in "${!ids[@]}"; do
    [ "${keys[$i]}" = "$key" ] || continue
    [ -n "$first" ] || first=${ids[$i]}
    desired+=("claude.agent.${ids[$i]}")
    args+=(--set "claude.agent.${ids[$i]}" icon="${icons[$i]}" icon.color="${colors[$i]}" icon.padding_left=14 label="${labels[$i]}" click_script="$PLUGIN_DIR/claude_attach.sh ${ids[$i]}")
  done
  if [ "$key" = "none" ]; then
    args+=(--set "$header" icon.drawing=off label="tmux pane なし" label.color="$GREY" click_script="")
  else
    number=$((number + 1))
    name=$(tmux -u display-message -p -t "$key" '#S · #{b:pane_current_path}' 2>/dev/null)
    label=${name:-$key}
    [ "$number" -le 9 ] && label="$number $label"
    args+=(--set "$header" icon.drawing=off label="$label" label.color="$BLUE" click_script="$PLUGIN_DIR/claude_attach.sh $first")
  fi
done <<<"$groups"

changed=
if [ "$(printf '%s\n' "${desired[@]}")" != "$existing" ]; then
  changed=1
  structure=()
  while IFS= read -r name; do
    [ -n "$name" ] && structure+=(--remove "$name")
  done <<<"$existing"
  for name in "${desired[@]}"; do
    structure+=(--add item "$name" popup."$NAME")
  done
  args=("${structure[@]}" "${args[@]}")
fi

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
