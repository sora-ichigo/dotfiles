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
for cmd in wezterm open; do
  cat >"$WORKDIR/bin/$cmd" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$@" >>"$WORKDIR/$cmd.log"
EOF
done
cat >"$WORKDIR/bin/tmux" <<EOF
#!/usr/bin/env bash
case "\$1" in
list-panes) printf '%b' "\${FAKE_PANES:-}" ;;
*) printf '%s\n' "\$@" >>"$WORKDIR/tmux.log" ;;
esac
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

compact_agents() {
  reset_logs
  FAKE_JSON="$1" CLAUDE_AGENTS_COMPACT=1 NAME=claude SENDER=routine PATH="$WORKDIR/bin:$PATH" bash "$SCRIPT_DIR/claude_agents.sh"
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

echo "claude_agents: 開閉状態"
agents "$sessions" mouse.clicked
assert_not_contains "クリックイベントでもポップアップの開閉状態は変えない" "$(log sketchybar)" "popup.drawing"
agents "$sessions" claude_agents_update
assert_not_contains "更新でポップアップの開閉状態を変えない" "$(log sketchybar)" "popup.drawing"

echo "claude_agents: コンパクト表示"
compact_agents "$sessions"
assert_contains "入力待ちと作業中の合計だけをラベルに出す" "$(log sketchybar)" "label=1
label.drawing=on"
compact_agents '[{"id":"eeee5555","cwd":"/tmp/a","kind":"background","name":"x","status":"idle","state":"needs_input"},{"id":"ffff6666","cwd":"/tmp/b","kind":"background","name":"y","status":"busy","state":"working"}]'
assert_contains "入力待ちも合計に含める" "$(log sketchybar)" "label=2
label.drawing=on"
compact_agents '[{"id":"bbbb2222","cwd":"/tmp/a","kind":"background","name":"x","status":"idle","state":"done"}]'
assert_contains "完了済みだけならラベルを隠す" "$(log sketchybar)" "label.drawing=off"
assert_contains "コンパクト表示でも行は出す" "$(log sketchybar)" "claude.agent.bbbb2222"

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

attach() {
  reset_logs
  FAKE_JSON="$1" FAKE_PANES="$2" CLAUDE_TMUX_PANE_SCRIPT="$SCRIPT_DIR/../../../.claude/tmux_pane.sh" PATH="$WORKDIR/bin:$PATH" bash "$SCRIPT_DIR/claude_attach.sh" aaaa1111
}

echo "claude_attach"
attach "$sessions" '%1\t/Users/me\tzsh\n%2\t/Users/me/ghq/github.com/foo/bar\tzsh\n%3\t/Users/me/ghq/github.com/foo/bar\t2.1.285\n'
assert_contains "セッションの cwd に近い claude の tmux pane に切り替える" "$(log tmux)" "$(printf 'switch-client\n-t\n%%3')"
assert_contains "WezTerm を前面に出す" "$(log open)" "WezTerm"
assert_empty "pane があれば新しいウィンドウは開かない" "$(log wezterm)"
assert_contains "切り替え後にポップアップを閉じる" "$(log sketchybar)" "popup.drawing=off"
attach "$sessions" '%1\t/opt\tzsh\n'
for _ in $(seq 1 20); do
  [ -s "$WORKDIR/wezterm.log" ] && break
  sleep 0.1
done
assert_contains "pane が無ければ WezTerm の新しいウィンドウで attach する" "$(log wezterm)" "$(printf 'start\n--\nclaude\nattach\naaaa1111')"
assert_empty "pane が無ければ tmux は切り替えない" "$(log tmux)"

echo
echo "pass: $PASS, fail: $FAIL"
[ "$FAIL" -eq 0 ]
