#!/usr/bin/env bash
set -u

input=$(cat)
event=$(jq -r '.hook_event_name // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
project=${cwd##*/}

case "$event" in
Notification) message=$(jq -r '.message // "入力を待っています"' <<<"$input") ;;
*) message=$(jq -r '
  (.last_assistant_message // "")
  | gsub("[*`#]"; "") | gsub("\\s+"; " ") | sub("^ "; "") | sub(" $"; "")
  | if . == "" then "応答が完了しました" elif length > 100 then .[0:100] + "…" else . end
' <<<"$input") ;;
esac

title="Claude Code${project:+ ($project)}"

args=(-title "$title" -message "$message" -sound Glass)

tmux=$(command -v tmux)
if [ -n "$tmux" ]; then
  pane=${TMUX_PANE:-}
  session=
  [ -n "$pane" ] && session=$("$tmux" display-message -p -t "$pane" '#S' 2>/dev/null)
  if [ -z "$session" ] && [ -n "$cwd" ]; then
    pane=$(bash "$(dirname "$0")/tmux_pane.sh" "$cwd")
    [ -n "$pane" ] && session=$("$tmux" display-message -p -t "$pane" '#S' 2>/dev/null)
  fi
  if [ -n "$session" ]; then
    args+=(-subtitle "$session" -activate com.github.wez.wezterm -execute "$tmux switch-client -t $pane")
  fi
fi

terminal-notifier "${args[@]}" >/dev/null 2>&1

if [ -n "${CLAUDE_NTFY_TOPIC:-}" ]; then
  curl -fsS -m 5 -H "Title: $title" -d "$message" "https://ntfy.sh/$CLAUDE_NTFY_TOPIC" >/dev/null 2>&1
fi

exit 0
