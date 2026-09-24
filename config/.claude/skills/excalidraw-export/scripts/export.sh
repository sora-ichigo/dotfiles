#!/usr/bin/env bash
set -euo pipefail

PLAYWRIGHT_VERSION=1.63.0
EXCALIDRAW_UTILS_VERSION=0.1.5
DEPS_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-excalidraw-export"
STAMP="$DEPS_DIR/.installed-$PLAYWRIGHT_VERSION-$EXCALIDRAW_UTILS_VERSION"

if [ ! -f "$STAMP" ]; then
  mkdir -p "$DEPS_DIR"
  [ -f "$DEPS_DIR/package.json" ] || echo '{"private":true}' > "$DEPS_DIR/package.json"
  npm install --prefix "$DEPS_DIR" --no-audit --no-fund --silent \
    "playwright@$PLAYWRIGHT_VERSION" "@excalidraw/utils@$EXCALIDRAW_UTILS_VERSION" >&2
  "$DEPS_DIR/node_modules/.bin/playwright" install chromium >&2
  rm -f "$DEPS_DIR"/.installed-*
  touch "$STAMP"
fi

EXCALIDRAW_EXPORT_DEPS_DIR="$DEPS_DIR" exec node "$(dirname "$0")/export.mjs" "$@"
