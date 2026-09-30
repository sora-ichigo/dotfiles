#!/usr/bin/env bash

PLUGIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

id=$(sketchybar --query claude 2>/dev/null | jq -r --argjson n "$1" '
  .popup.items as $items
  | [range(0; $items | length) | select($items[.] | test("^claude\\.group\\.[0-9]+$"))] as $headers
  | ($headers[$n - 1] // empty) as $h
  | ($items[$h + 1] // "") | select(startswith("claude.agent.")) | ltrimstr("claude.agent.")
' 2>/dev/null)
if [ -z "$id" ]; then
  sketchybar --set claude popup.drawing=off
  exit 0
fi

bash "$PLUGIN_DIR/claude_attach.sh" "$id"
