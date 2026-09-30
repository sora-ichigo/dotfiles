#!/usr/bin/env bash
set -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/../colors.sh"

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

mkdir -p "$WORKDIR/bin"
cat >"$WORKDIR/bin/sketchybar" <<EOF
#!/usr/bin/env bash
if [ "\$1" = "--query" ]; then
  printf '%s' "\${FAKE_QUERY:-{\"popup\":{\"drawing\":\"off\",\"items\":[]}}}"
  exit 0
fi
printf '%s\n' "\$@" >>"$WORKDIR/sketchybar.log"
EOF
cat >"$WORKDIR/bin/claude" <<EOF
#!/usr/bin/env bash
{ pwd; printf '%s\n' "\$@"; } >>"$WORKDIR/claude.log"
[ "\$1 \$2" = "agents --json" ] && printf '%s' "\${FAKE_JSON:-[]}"
exit "\${FAKE_EXIT:-0}"
EOF
for cmd in wezterm open; do
  cat >"$WORKDIR/bin/$cmd" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$@" >>"$WORKDIR/$cmd.log"
EOF
done
cat >"$WORKDIR/bin/tmux" <<EOF
#!/usr/bin/env bash
utf8=
[ "\$1" = "-u" ] && utf8=1 && shift
case "\$1" in
display-message) echo "label-\$4" ;;
list-panes)
  if [ -n "\$utf8" ]; then
    printf '%b' "\${FAKE_PANES:-}"
  else
    printf '%b' "\${FAKE_PANES:-}" | tr '\t' '_'
  fi
  ;;
*) printf '%s\n' "\$@" >>"$WORKDIR/tmux.log" ;;
esac
EOF
chmod +x "$WORKDIR"/bin/*

PASS=0
FAIL=0

reset_logs() {
  rm -f "$WORKDIR"/*.log
}

PANE_SCRIPT="$SCRIPT_DIR/../../../.claude/tmux_pane.sh"
panes='%3\t/Users/me/ghq/github.com/foo/bar\t2.1.285\n%5\t/Users/me/ghq/github.com/foo\tzsh\n'

agents() {
  reset_logs
  FAKE_JSON="$1" FAKE_EXIT="${3:-0}" FAKE_PANES="${FAKE_PANES:-$panes}" CLAUDE_TMUX_PANE_SCRIPT="$PANE_SCRIPT" NAME=claude SENDER="${2:-routine}" PATH="$WORKDIR/bin:$PATH" bash "$SCRIPT_DIR/claude_agents.sh"
}

compact_agents() {
  reset_logs
  FAKE_JSON="$1" FAKE_PANES="$panes" CLAUDE_TMUX_PANE_SCRIPT="$PANE_SCRIPT" CLAUDE_AGENTS_COMPACT=1 NAME=claude SENDER=routine PATH="$WORKDIR/bin:$PATH" bash "$SCRIPT_DIR/claude_agents.sh"
}

added() {
  awk '$0 == "item" { getline name; printf "%s ", name }' "$WORKDIR/sketchybar.log" 2>/dev/null
}

props() {
  awk -v name="$1" '
    $0 == "--set" { getline item; current = item; next }
    /^--/ { current = ""; next }
    current == name { print }
  ' "$WORKDIR/sketchybar.log" 2>/dev/null
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

assert_eq() {
  local name=$1 actual=$2 expected=$3
  if [ "$actual" = "$expected" ]; then ok "$name"; else ng "$name" "expected: $expected, got: $actual"; fi
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

order="claude.group.3 claude.agent.aaaa1111 claude.group.5 claude.agent.bbbb2222 claude.agent.cccc3333 "

echo "claude_agents: 一覧"
agents "$sessions"
assert_contains "状態ごとの件数をラベルに出す" "$(log sketchybar)" "label=1 working · 2 done"
assert_contains "作業中があればアイコンを緑にする" "$(log sketchybar)" "icon.color=$GREEN"
assert_eq "tmux pane ごとに見出しを置き、その下にセッションを並べる" "$(added)" "$order"
assert_contains "見出しに番号と pane の名前を出す" "$(props claude.group.3)" "label=1 label-%3"
assert_contains "見出しの番号は表示順に振る" "$(props claude.group.5)" "label=2 label-%5"
assert_contains "見出しのクリックでその pane に飛ぶ" "$(props claude.group.5)" "claude_attach.sh bbbb2222"
assert_contains "セッション行にセッション名とリポジトリ名を出す" "$(props claude.agent.aaaa1111)" "label=fix login bug · bar"
assert_not_contains "セッション行には番号を付けない" "$(props claude.agent.aaaa1111)" "label=1 "
assert_contains "セッション行のクリックで attach する" "$(props claude.agent.aaaa1111)" "claude_attach.sh aaaa1111"
assert_not_contains "インタラクティブセッションは出さない" "$(log sketchybar)" "dddd4444"
assert_not_contains "新規作成の行は出さない" "$(log sketchybar)" "claude.agent.new"

echo "claude_agents: pane なし"
FAKE_PANES='%3\t/Users/me/ghq/github.com/foo/bar\t2.1.285\n' agents "$sessions"
assert_eq "pane が無いセッションは末尾のグループにまとめる" "$(added)" "claude.group.3 claude.agent.aaaa1111 claude.group.none claude.agent.bbbb2222 claude.agent.cccc3333 "
assert_contains "pane が無いグループは番号を付けずに見出しを出す" "$(props claude.group.none)" "label=tmux pane なし"

echo "claude_agents: 更新"
FAKE_QUERY="{\"popup\":{\"drawing\":\"on\",\"items\":[$(printf '"%s",' $order | sed 's/,$//')]}}" agents "$sessions"
assert_not_contains "構成が変わらなければ行を消さない" "$(log sketchybar)" "--remove"
assert_eq "構成が変わらなければ行を足さない" "$(added)" ""
assert_not_contains "構成が変わらなければ開き直さない" "$(log sketchybar)" "popup.drawing"
assert_contains "構成が変わらなくても中身は更新する" "$(props claude.agent.aaaa1111)" "label=fix login bug · bar"
FAKE_QUERY='{"popup":{"drawing":"on","items":["claude.group.3","claude.agent.aaaa1111","claude.agent.zzzz9999"]}}' agents "$sessions"
assert_contains "構成が変わったら古い行を消す" "$(log sketchybar)" "$(printf -- '--remove\nclaude.agent.zzzz9999')"
assert_eq "構成が変わったら正しい順に作り直す" "$(added)" "$order"
assert_contains "開いている間に構成が変わったら開き直して表示する" "$(log sketchybar)" "$(printf 'popup.drawing=off\n--set\nclaude\npopup.drawing=on')"
FAKE_QUERY='{"popup":{"drawing":"off","items":["claude.agent.zzzz9999"]}}' agents "$sessions"
assert_not_contains "閉じているポップアップは開かない" "$(log sketchybar)" "popup.drawing"

echo "claude_agents: 入力待ち"
agents '[{"id":"eeee5555","cwd":"/tmp/a","kind":"background","name":"x","status":"idle","state":"needs_input"},{"id":"ffff6666","cwd":"/tmp/b","kind":"background","name":"y","status":"busy","state":"working"}]'
assert_contains "working と done 以外は入力待ちとして数える" "$(log sketchybar)" "label=1 waiting · 1 working"
assert_contains "入力待ちがあればアイコンを黄色にする" "$(log sketchybar)" "icon.color=$YELLOW"

echo "claude_agents: セッションなし"
agents '[]'
assert_contains "セッションが無ければラベルを隠す" "$(log sketchybar)" "label.drawing=off"
assert_contains "セッションが無ければアイコンを灰色にする" "$(log sketchybar)" "icon.color=$GREY"
assert_eq "行を足さない" "$(added)" ""

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

select_row() {
  reset_logs
  FAKE_JSON="$sessions" FAKE_QUERY='{"popup":{"drawing":"on","items":["claude.group.3","claude.agent.aaaa1111","claude.group.5","claude.agent.bbbb2222","claude.group.none","claude.agent.cccc3333"]}}' FAKE_PANES="$panes" CLAUDE_TMUX_PANE_SCRIPT="$PANE_SCRIPT" PATH="$WORKDIR/bin:$PATH" bash "$SCRIPT_DIR/claude_select.sh" "$1"
}

echo "claude_select"
select_row 2
assert_contains "番号の見出しの pane に切り替える" "$(log tmux)" "$(printf 'switch-client\n-t\n%%5')"
select_row 3
assert_empty "pane が無いグループは番号で選べない" "$(log tmux)"
assert_empty "範囲外の番号では新しいウィンドウも開かない" "$(log wezterm)"
assert_contains "範囲外の番号でもポップアップは閉じる" "$(log sketchybar)" "popup.drawing=off"

echo
echo "pass: $PASS, fail: $FAIL"
[ "$FAIL" -eq 0 ]
