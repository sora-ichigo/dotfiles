#!/usr/bin/env bash
set -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/../colors.sh"

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

mkdir -p "$WORKDIR/bin"
cat >"$WORKDIR/bin/sketchybar" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$@" >>"$WORKDIR/sketchybar.log"
echo "---" >>"$WORKDIR/sketchybar.log"
EOF
cat >"$WORKDIR/bin/aerospace" <<'EOF'
#!/usr/bin/env bash
case "$1 $2" in
"list-workspaces --all") printf '1\n2\n3\n4\n' ;;
"list-workspaces --focused") printf '%s\n' "${FAKE_FOCUSED:-1}" ;;
"list-windows --all") printf '%b' "${FAKE_WINDOWS:-}" ;;
esac
EOF
cat >"$WORKDIR/bin/icon_map.sh" <<'EOF'
__icon_map() {
  icon_result=":$1:"
}
EOF
chmod +x "$WORKDIR"/bin/*

PASS=0
FAIL=0

run() {
  rm -f "$WORKDIR"/*.log
  FAKE_WINDOWS="$1" FAKE_FOCUSED="${2:-1}" PATH="$WORKDIR/bin:$PATH" "${@:3}" bash "$SCRIPT_DIR/aerospace.sh"
}

log() {
  cat "$WORKDIR/$1.log" 2>/dev/null
}

space() {
  awk -v name="space.$1" '
    $0 == "--set" { getline item; current = item; next }
    current == name && $0 != "---" && $0 !~ /^--/ { print }
  ' "$WORKDIR/sketchybar.log"
}

ok() {
  PASS=$((PASS + 1))
  printf '  \033[32mok\033[0m   %s\n' "$1"
}

ng() {
  FAIL=$((FAIL + 1))
  printf '  \033[31mFAIL\033[0m %s\n' "$1"
  [ $# -gt 1 ] && printf '       %s\n' "$2"
}

assert_contains() {
  local name=$1 haystack=$2 needle=$3
  case "$haystack" in
  *"$needle"*) ok "$name" ;;
  *) ng "$name" "expected to contain: $needle" ;;
  esac
}

assert_eq() {
  local name=$1 actual=$2 expected=$3
  if [ "$actual" = "$expected" ]; then ok "$name"; else ng "$name" "expected: $expected, got: $actual"; fi
}

windows='1|WezTerm\n2|Slack\n2|Google Chrome\n2|Slack\n'

echo "aerospace: 表示"
run "$windows" 1
assert_contains "フォーカス中のワークスペースは背景付きで出す" "$(space 1)" "background.drawing=on"
assert_contains "フォーカス中のワークスペースはアクセント色にする" "$(space 1)" "icon.color=$ACCENT_COLOR"
assert_contains "ウィンドウのアプリアイコンを出す" "$(space 1)" "label=:WezTerm: "
assert_contains "ウィンドウがあるワークスペースは出す" "$(space 2)" "drawing=on"
assert_contains "フォーカスしていないワークスペースは背景を消す" "$(space 2)" "background.drawing=off"
assert_contains "同じアプリのアイコンは 1 つにまとめる" "$(space 2)" "label=:Google Chrome: :Slack: "
assert_contains "空でフォーカスしていないワークスペースは隠す" "$(space 3)" "drawing=off"

echo "aerospace: フォーカス"
run "$windows" 3
assert_contains "空でもフォーカス中なら出す" "$(space 3)" "drawing=on"
assert_contains "フォーカスが外れたワークスペースも中身があれば出す" "$(space 1)" "drawing=on"
run "$windows" 1 env FOCUSED_WORKSPACE=4
assert_contains "イベントで渡されたフォーカス中のワークスペースを優先する" "$(space 4)" "background.drawing=on"

echo "aerospace: まとめて更新"
run "$windows" 1
assert_eq "全ワークスペースを 1 回の sketchybar 呼び出しで更新する" "$(grep -c -- '^---$' "$WORKDIR/sketchybar.log")" "1"

echo "aerospace: アイコン数の上限"
run "$windows" 1 env SPACE_ICON_LIMIT=1
assert_contains "上限を超えるアイコンは出さない" "$(space 2)" "label=:Google Chrome: "

echo
echo "pass: $PASS, fail: $FAIL"
[ "$FAIL" -eq 0 ]
