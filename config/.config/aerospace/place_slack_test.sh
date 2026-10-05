#!/usr/bin/env bash
set -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

mkdir -p "$WORKDIR/bin"
cat >"$WORKDIR/bin/aerospace" <<EOF
#!/usr/bin/env bash
if [ "\$1" = "list-windows" ]; then
  printf '%b' "\${FAKE_WINDOWS:-}"
  exit 0
fi
if [ "\$1" = "list-monitors" ]; then
  echo "\${FAKE_MONITORS:-1}"
  exit 0
fi
echo "\$*" >>"$WORKDIR/aerospace.log"
EOF
cat >"$WORKDIR/bin/sketchybar" <<EOF
#!/usr/bin/env bash
echo "\$*" >>"$WORKDIR/sketchybar.log"
EOF
chmod +x "$WORKDIR"/bin/*

PASS=0
FAIL=0

run() {
  rm -f "$WORKDIR"/*.log
  FAKE_WINDOWS="$1" FAKE_MONITORS="$2" PATH="$WORKDIR/bin:$PATH" bash "$SCRIPT_DIR/place_slack.sh"
}

log() {
  cat "$WORKDIR/$1.log" 2>/dev/null
}

check() {
  if [ "$2" = "$3" ]; then
    PASS=$((PASS + 1))
    printf '  \033[32mok\033[0m   %s\n' "$1"
  else
    FAIL=$((FAIL + 1))
    printf '  \033[31mFAIL\033[0m %s\n' "$1"
    printf '       expected: %q\n       actual:   %q\n' "$2" "$3"
  fi
}

echo "place_slack.sh"

run '20 md.obsidian 2\n40 com.tinyspeck.slackmacgap 4\n41 com.tinyspeck.slackmacgap 6\n' 2
check "モニターが 2 枚なら Slack のウィンドウをすべて 2 に移す" \
  "$(printf '%s\n' \
    'move-node-to-workspace --window-id 40 2' \
    'move-node-to-workspace --window-id 41 2')" \
  "$(log aerospace)"
check "SketchyBar を更新する" "--trigger aerospace_workspace_change" "$(log sketchybar)"

run '20 md.obsidian 2\n40 com.tinyspeck.slackmacgap 2\n' 1
check "モニターが 1 枚なら Slack を 4 に移す" "move-node-to-workspace --window-id 40 4" "$(log aerospace)"

run '20 md.obsidian 2\n40 com.tinyspeck.slackmacgap 2\n' 3
check "モニターが 3 枚なら 2 がサブに割り当たらないので Slack を 4 に移す" "move-node-to-workspace --window-id 40 4" "$(log aerospace)"

run '20 md.obsidian 2\n' 2
check "Slack が起動していなければ何もしない" "" "$(log aerospace)"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
