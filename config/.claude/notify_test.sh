#!/usr/bin/env bash
set -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
NOTIFY="$SCRIPT_DIR/notify.sh"

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

mkdir -p "$WORKDIR/bin"
for cmd in osascript curl; do
  cat >"$WORKDIR/bin/$cmd" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$@" >"$WORKDIR/$cmd.log"
EOF
  chmod +x "$WORKDIR/bin/$cmd"
done

PASS=0
FAIL=0

run() {
  rm -f "$WORKDIR"/*.log
  printf '%s' "$1" | PATH="$WORKDIR/bin:$PATH" CLAUDE_NTFY_TOPIC="${2:-}" bash "$NOTIFY"
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

assert_empty() {
  local name=$1 value=$2
  if [ -z "$value" ]; then ok "$name"; else ng "$name" "expected empty, got: $value"; fi
}

echo "Stop"
run '{"hook_event_name":"Stop","cwd":"/Users/me/ghq/github.com/foo/bar"}'
assert_contains "タイトルにプロジェクト名を含む" "$(log osascript)" "Claude Code (bar)"
assert_contains "完了メッセージを通知する" "$(log osascript)" "応答が完了しました"
assert_empty "トピック未設定なら ntfy に送らない" "$(log curl)"

echo "Notification"
run '{"hook_event_name":"Notification","cwd":"/tmp/baz","message":"Claude needs your permission to use Bash"}'
assert_contains "hook のメッセージをそのまま通知する" "$(log osascript)" "Claude needs your permission to use Bash"
assert_contains "タイトルにプロジェクト名を含む" "$(log osascript)" "Claude Code (baz)"

echo "ntfy"
run '{"hook_event_name":"Stop","cwd":"/tmp/qux"}' "secret-topic"
assert_contains "トピック宛てに送る" "$(log curl)" "https://ntfy.sh/secret-topic"
assert_contains "本文にメッセージを含む" "$(log curl)" "応答が完了しました"
assert_contains "タイトルヘッダを付ける" "$(log curl)" "Title: Claude Code (qux)"

echo
echo "pass: $PASS, fail: $FAIL"
[ "$FAIL" -eq 0 ]
