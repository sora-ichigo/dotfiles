#!/usr/bin/env bash
set -u

input=$(cat)
event=$(jq -r '.hook_event_name // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
project=${cwd##*/}

case "$event" in
Notification) message=$(jq -r '.message // "入力を待っています"' <<<"$input") ;;
*) message="応答が完了しました" ;;
esac

title="Claude Code${project:+ ($project)}"

osascript \
  -e 'on run argv' \
  -e 'display notification (item 2 of argv) with title (item 1 of argv) sound name "Glass"' \
  -e 'end run' \
  "$title" "$message" >/dev/null 2>&1

if [ -n "${CLAUDE_NTFY_TOPIC:-}" ]; then
  curl -fsS -m 5 -H "Title: $title" -d "$message" "https://ntfy.sh/$CLAUDE_NTFY_TOPIC" >/dev/null 2>&1
fi

exit 0
