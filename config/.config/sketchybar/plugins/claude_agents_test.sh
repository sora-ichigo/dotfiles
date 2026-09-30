#!/usr/bin/env bash
set -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/../colors.sh"

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

mkdir -p "$WORKDIR/bin" "$WORKDIR/root/github.com/foo/bar"
cat >"$WORKDIR/bin/sketchybar" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$@" >>"$WORKDIR/sketchybar.log"
EOF
cat >"$WORKDIR/bin/claude" <<EOF
#!/usr/bin/env bash
{ pwd; printf '%s\n' "\$@"; } >>"$WORKDIR/claude.log"
[ "\$1 \$2" = "agents --json" ] && printf '%s' "\${FAKE_JSON:-[]}"
exit "\${FAKE_EXIT:-0}"
EOF
cat >"$WORKDIR/bin/ghq" <<EOF
#!/usr/bin/env bash
case "\$1" in
root) echo "$WORKDIR/root" ;;
list) printf 'github.com/foo/bar\ngithub.com/baz/qux\n' ;;
esac
EOF
cat >"$WORKDIR/bin/osascript" <<'EOF'
#!/usr/bin/env bash
case "$*" in
*"choose from list"*) printf '%s\n' "${FAKE_CHOICE:-false}" ;;
*"display dialog"*) [ -n "${FAKE_PROMPT+x}" ] || exit 1; printf '%s\n' "$FAKE_PROMPT" ;;
esac
EOF
cat >"$WORKDIR/bin/wezterm" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$@" >>"$WORKDIR/wezterm.log"
EOF
chmod +x "$WORKDIR"/bin/*

PASS=0
FAIL=0

reset_logs() {
  rm -f "$WORKDIR"/*.log
}

agents() {
  reset_logs
  FAKE_JSON="$1" FAKE_EXIT="${3:-0}" NAME=claude SENDER="${2:-routine}" PATH="$WORKDIR/bin:$PATH" bash "$SCRIPT_DIR/claude_agents.sh"
}

log() {
  cat "$WORKDIR/$1.log" 2>/dev/null
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

assert_not_contains() {
  local name=$1 haystack=$2 needle=$3
  case "$haystack" in
  *"$needle"*) ng "$name" "expected not to contain: $needle" ;;
  *) ok "$name" ;;
  esac
}

assert_empty() {
  local name=$1 value=$2
  if [ -z "$value" ]; then ok "$name"; else ng "$name" "expected empty, got: $value"; fi
}

sessions='[
  {"id":"aaaa1111","cwd":"/Users/me/ghq/github.com/foo/bar/.claude/worktrees/fix-x","kind":"background","name":"fix login bug","status":"busy","state":"working"},
  {"id":"bbbb2222","cwd":"/Users/me/ghq/github.com/foo/baz","kind":"background","name":"write blog outline","status":"idle","state":"done"},
  {"id":"cccc3333","cwd":"/Users/me/ghq/github.com/foo/qux","kind":"background","name":"review pr","status":"idle","state":"done"},
  {"id":"dddd4444","cwd":"/Users/me/ghq/github.com/foo/interactive","kind":"interactive","name":"live session","status":"busy","state":"working"}
]'

echo "claude_agents: 一覧"
agents "$sessions"
assert_contains "状態ごとの件数をラベルに出す" "$(log sketchybar)" "label=1 working · 2 done"
assert_contains "作業中があればアイコンを緑にする" "$(log sketchybar)" "icon.color=$GREEN"
assert_contains "古い行を消してから描き直す" "$(log sketchybar)" '/claude\.agent\..*/'
assert_contains "バックグラウンドセッションごとにポップアップ行を足す" "$(log sketchybar)" "$(printf 'claude.agent.aaaa1111\npopup.claude')"
assert_contains "行にセッション名とリポジトリ名を出す" "$(log sketchybar)" "label=fix login bug · bar"
assert_contains "行のクリックで attach する" "$(log sketchybar)" "claude_attach.sh aaaa1111"
assert_not_contains "インタラクティブセッションは出さない" "$(log sketchybar)" "dddd4444"
assert_contains "新規作成の行を出す" "$(log sketchybar)" "claude_new.sh"

echo "claude_agents: 入力待ち"
agents '[{"id":"eeee5555","cwd":"/tmp/a","kind":"background","name":"x","status":"idle","state":"needs_input"},{"id":"ffff6666","cwd":"/tmp/b","kind":"background","name":"y","status":"busy","state":"working"}]'
assert_contains "working と done 以外は入力待ちとして数える" "$(log sketchybar)" "label=1 waiting · 1 working"
assert_contains "入力待ちがあればアイコンを黄色にする" "$(log sketchybar)" "icon.color=$YELLOW"

echo "claude_agents: セッションなし"
agents '[]'
assert_contains "セッションが無ければラベルを隠す" "$(log sketchybar)" "label.drawing=off"
assert_contains "セッションが無ければアイコンを灰色にする" "$(log sketchybar)" "icon.color=$GREY"
assert_not_contains "行を足さない" "$(log sketchybar)" "popup.claude
claude.agent"

echo "claude_agents: 取得失敗"
agents '' routine 1
assert_contains "claude が失敗したらアイコンを赤にする" "$(log sketchybar)" "icon.color=$RED"

echo "claude_agents: クリック"
agents "$sessions" mouse.clicked
assert_contains "クリックでポップアップを開閉する" "$(log sketchybar)" "popup.drawing=toggle"

new() {
  reset_logs
  PATH="$WORKDIR/bin:$PATH" bash "$SCRIPT_DIR/claude_new.sh"
}

echo "claude_new"
FAKE_CHOICE="github.com/foo/bar" FAKE_PROMPT="fix the flaky test" new
assert_contains "選んだリポジトリで起動する" "$(log claude)" "$WORKDIR/root/github.com/foo/bar"
assert_contains "入力したプロンプトでバックグラウンドセッションを作る" "$(log claude)" "$(printf -- '--bg\nfix the flaky test')"
assert_contains "作成後にバーを更新する" "$(log sketchybar)" "claude_agents_update"
FAKE_CHOICE="false" FAKE_PROMPT="x" new
assert_empty "リポジトリ選択をキャンセルしたら作らない" "$(log claude)"
FAKE_CHOICE="github.com/foo/bar" new
assert_empty "プロンプト入力をキャンセルしたら作らない" "$(log claude)"
FAKE_CHOICE="github.com/foo/bar" FAKE_PROMPT="" new
assert_empty "プロンプトが空なら作らない" "$(log claude)"

echo "claude_attach"
reset_logs
PATH="$WORKDIR/bin:$PATH" bash "$SCRIPT_DIR/claude_attach.sh" aaaa1111
sleep 0.2
assert_contains "WezTerm の新しいウィンドウで attach する" "$(log wezterm)" "$(printf 'start\n--\nclaude\nattach\naaaa1111')"
assert_contains "attach 後にポップアップを閉じる" "$(log sketchybar)" "popup.drawing=off"

echo
echo "pass: $PASS, fail: $FAIL"
[ "$FAIL" -eq 0 ]
