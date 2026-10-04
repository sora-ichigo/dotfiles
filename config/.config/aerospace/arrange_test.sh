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
echo "\$*" >>"$WORKDIR/aerospace.log"
EOF
cat >"$WORKDIR/bin/open" <<EOF
#!/usr/bin/env bash
echo "\$*" >>"$WORKDIR/open.log"
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
  FAKE_WINDOWS="$1" PATH="$WORKDIR/bin:$PATH" bash "$SCRIPT_DIR/arrange.sh"
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

echo "arrange.sh"

run '10 com.github.wez.wezterm 4\n20 md.obsidian 2\n11 com.github.wez.wezterm 1\n31 com.google.Chrome 1\n40 com.tinyspeck.slackmacgap 2\n'
check "WezTerm を 1、Obsidian を 2、Chrome を 3、Slack を 4 に移す" \
  "$(printf '%s\n' \
    'move-node-to-workspace --window-id 10 1' \
    'move-node-to-workspace --window-id 20 2' \
    'move-node-to-workspace --window-id 11 1' \
    'move-node-to-workspace --window-id 31 3' \
    'move-node-to-workspace --window-id 40 4')" \
  "$(log aerospace)"
check "起動済みのアプリは起動しない" "" "$(log open)"
check "SketchyBar を更新する" "--trigger aerospace_workspace_change" "$(log sketchybar)"

run '10 com.github.wez.wezterm 1\n30 com.amazon.Lassen 1\n33 com.apple.finder 4\n32 com.hnc.Discord 6\n20 md.obsidian 2\n31 com.google.Chrome 3\n40 com.tinyspeck.slackmacgap 4\n'
check "1〜4 にある他のアプリを 5 に追い出し、それ以外のワークスペースのアプリは動かさない" \
  "$(printf '%s\n' \
    'move-node-to-workspace --window-id 10 1' \
    'move-node-to-workspace --window-id 30 5' \
    'move-node-to-workspace --window-id 33 5' \
    'move-node-to-workspace --window-id 20 2' \
    'move-node-to-workspace --window-id 31 3' \
    'move-node-to-workspace --window-id 40 4')" \
  "$(log aerospace)"

run '30 com.amazon.Lassen 1\n'
check "起動していないアプリを起動する" \
  "$(printf '%s\n' '-g -b com.github.wez.wezterm' '-g -b md.obsidian' '-g -b com.google.Chrome' '-g -b com.tinyspeck.slackmacgap')" \
  "$(log open)"

run '20 md.obsidian 2\n31 com.google.Chrome 3\n40 com.tinyspeck.slackmacgap 4\n'
check "起動していないアプリだけを起動する" "-g -b com.github.wez.wezterm" "$(log open)"

echo
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
