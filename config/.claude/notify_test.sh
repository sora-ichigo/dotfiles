#!/usr/bin/env bash
set -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
NOTIFY="$SCRIPT_DIR/notify.sh"

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

mkdir -p "$WORKDIR/bin"
for cmd in terminal-notifier curl tmux; do
  cat >"$WORKDIR/bin/$cmd" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$@" >"$WORKDIR/$cmd.log"
EOF
  chmod +x "$WORKDIR/bin/$cmd"
done
cat >>"$WORKDIR/bin/tmux" <<'EOF'
case "$1" in
display-message) [ "$4" != "%0" ] && echo mysession ;;
list-panes) printf '%b' "${FAKE_PANES:-}" ;;
esac
EOF

PASS=0
FAIL=0

run() {
  rm -f "$WORKDIR"/*.log
  printf '%s' "$1" | PATH="$WORKDIR/bin:$PATH" CLAUDE_NTFY_TOPIC="${2:-}" TMUX_PANE="${3:-}" FAKE_PANES="${4:-}" bash "$NOTIFY"
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

echo "Stop"
run '{"hook_event_name":"Stop","cwd":"/Users/me/ghq/github.com/foo/bar"}'
assert_contains "タイトルにプロジェクト名を含む" "$(log terminal-notifier)" "Claude Code (bar)"
assert_contains "完了メッセージを通知する" "$(log terminal-notifier)" "応答が完了しました"
assert_empty "トピック未設定なら ntfy に送らない" "$(log curl)"
run '{"hook_event_name":"Stop","cwd":"/tmp/bar","last_assistant_message":"テストを追加しました。\n\n**次は** `make test` です"}'
assert_contains "最後の応答を改行をまとめて通知する" "$(log terminal-notifier)" "テストを追加しました。 次は make test です"
long=$(printf 'あ%.0s' $(seq 1 300))
run "{\"hook_event_name\":\"Stop\",\"cwd\":\"/tmp/bar\",\"last_assistant_message\":\"$long\"}"
assert_contains "長い応答は切り詰める" "$(log terminal-notifier)" "$(printf 'あ%.0s' $(seq 1 100))…"
assert_not_contains "長い応答は全文を載せない" "$(log terminal-notifier)" "$(printf 'あ%.0s' $(seq 1 101))"

echo "Notification"
run '{"hook_event_name":"Notification","cwd":"/tmp/baz","message":"Claude needs your permission to use Bash"}'
assert_contains "hook のメッセージをそのまま通知する" "$(log terminal-notifier)" "Claude needs your permission to use Bash"
assert_contains "タイトルにプロジェクト名を含む" "$(log terminal-notifier)" "Claude Code (baz)"

echo "tmux"
run '{"hook_event_name":"Stop","cwd":"/tmp/qux"}' "" "%12"
assert_contains "クリックで元の pane に切り替える" "$(log terminal-notifier)" "$WORKDIR/bin/tmux switch-client -t %12"
assert_contains "クリックで WezTerm を前面に出す" "$(log terminal-notifier)" "com.github.wez.wezterm"
assert_contains "サブタイトルに tmux セッション名を出す" "$(log terminal-notifier)" "$(printf -- '-subtitle\nmysession')"
run '{"hook_event_name":"Stop","cwd":"/tmp/qux"}'
assert_not_contains "tmux 外ではクリック時のコマンドを付けない" "$(log terminal-notifier)" "-execute"
panes='%1\t/Users/me\tzsh\n%2\t/Users/me/repo\tzsh\n%3\t/Users/me/repo\t2.1.285\n%4\t/Users/me/other\t2.1.285\n'
run '{"hook_event_name":"Stop","cwd":"/Users/me/repo/.claude/worktrees/x"}' "" "" "$panes"
assert_contains "TMUX_PANE が無ければ cwd を含む claude の pane に切り替える" "$(log terminal-notifier)" "switch-client -t %3"
assert_contains "TMUX_PANE が無くても WezTerm を前面に出す" "$(log terminal-notifier)" "com.github.wez.wezterm"
run '{"hook_event_name":"Stop","cwd":"/Users/me/repo"}' "" "%0" "$panes"
assert_contains "存在しない TMUX_PANE なら cwd から pane を探す" "$(log terminal-notifier)" "switch-client -t %3"
run '{"hook_event_name":"Stop","cwd":"/Users/me/repo2"}' "" "" '%1\t/Users/me\tzsh\n%5\t/Users/me/repo\t2.1.285\n'
assert_contains "cwd を含む pane が無ければ最も近い親ディレクトリの pane に切り替える" "$(log terminal-notifier)" "switch-client -t %1"
run '{"hook_event_name":"Stop","cwd":"/opt/x"}' "" "" "$panes"
assert_not_contains "該当する pane が無ければクリック時のコマンドを付けない" "$(log terminal-notifier)" "-execute"

echo "ntfy"
run '{"hook_event_name":"Stop","cwd":"/tmp/qux"}' "secret-topic"
assert_contains "トピック宛てに送る" "$(log curl)" "https://ntfy.sh/secret-topic"
assert_contains "本文にメッセージを含む" "$(log curl)" "応答が完了しました"
assert_contains "タイトルヘッダを付ける" "$(log curl)" "Title: Claude Code (qux)"

echo
echo "pass: $PASS, fail: $FAIL"
[ "$FAIL" -eq 0 ]
