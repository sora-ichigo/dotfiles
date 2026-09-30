#!/usr/bin/env bash

PLUGIN_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

name=$(sketchybar --query claude 2>/dev/null | jq -r --argjson n "$1" '.popup.items[$n - 1] // empty' 2>/dev/null)
if [ -z "$name" ]; then
  sketchybar --set claude popup.drawing=off
  exit 0
fi

bash "$PLUGIN_DIR/claude_attach.sh" "${name#claude.agent.}"
