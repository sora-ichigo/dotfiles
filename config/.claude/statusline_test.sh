#!/usr/bin/env bash
# statusline.sh のテスト。モック JSON を stdin に流して出力を検証する
set -u

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
STATUSLINE="$SCRIPT_DIR/statusline.sh"

TMPDIR=$(mktemp -d)
export TMPDIR
trap 'rm -rf "$TMPDIR"' EXIT

PASS=0
FAIL=0

strip_ansi() {
  sed $'s/\x1b\\[[0-9;]*m//g'
}

# テストごとに git キャッシュを捨てる
run() {
  rm -f "$TMPDIR"/claude-statusline-*
  printf '%s' "$1" | COLUMNS="${2:-200}" bash "$STATUSLINE"
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
  *"$needle"*) ng "$name" "expected NOT to contain: $needle" ;;
  *) ok "$name" ;;
  esac
}

assert_eq() {
  local name=$1 actual=$2 expected=$3
  if [ "$actual" = "$expected" ]; then
    ok "$name"
  else
    ng "$name" "expected [$expected], got [$actual]"
  fi
}

FULL_JSON=$(
  cat <<'JSON'
{
  "cwd": "/tmp/not-a-repo",
  "session_id": "abc123",
  "version": "2.1.220",
  "model": { "id": "claude-opus-5", "display_name": "Opus 5" },
  "workspace": { "current_dir": "/tmp/not-a-repo", "project_dir": "/tmp/not-a-repo" },
  "effort": { "level": "xhigh" },
  "fast_mode": false,
  "context_window": { "used_percentage": 42.3, "context_window_size": 200000 },
  "cost": {
    "total_cost_usd": 1.234,
    "total_duration_ms": 4320000,
    "total_lines_added": 12,
    "total_lines_removed": 3
  },
  "rate_limits": {
    "five_hour": { "used_percentage": 18 },
    "seven_day": { "used_percentage": 4 }
  },
  "pr": { "number": 65, "url": "https://github.com/o/r/pull/65", "review_state": "approved" },
  "output_style": { "name": "default" }
}
JSON
)

# jq でフィールドを差し替えたモックを作る
mock() {
  printf '%s' "$FULL_JSON" | jq -c "$1"
}

echo "statusline.sh"

out=$(run "$FULL_JSON")
line1=$(printf '%s' "$out" | sed -n 1p | strip_ansi)
line2=$(printf '%s' "$out" | sed -n 2p | strip_ansi)

assert_eq "2 行で出力する" "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" "2"
assert_contains "モデル名を表示する" "$line1" "Opus 5"
assert_contains "reasoning effort を表示する" "$line1" "xhigh"
assert_contains "カレントディレクトリ名を表示する" "$line1" "not-a-repo"
assert_contains "PR 番号を表示する" "$line1" "#65"
assert_contains "approved な PR を ✓ で示す" "$line1" "✓"
assert_contains "コンテキスト使用率を表示する" "$line2" "42%"
assert_contains "コンテキストバーを表示する" "$line2" "█"
assert_contains "コストを表示する" "$line2" '$1.23'
assert_contains "経過時間を h/m 形式で表示する" "$line2" "1h12m"
assert_contains "差分行数を表示する" "$line2" "+12/-3"
assert_not_contains "null を出力しない" "$out" "null"

out=$(run "$(mock '{cwd: .cwd, model: .model, workspace: .workspace}')")
assert_eq "最小入力でも 2 行を保つ" "$(printf '%s\n' "$out" | wc -l | tr -d ' ')" "2"
assert_not_contains "最小入力で null を出力しない" "$out" "null"
assert_contains "コンテキスト不明時は 0% とする" "$(printf '%s' "$out" | strip_ansi)" "0%"

out=$(run "$(mock '.pr = null')" | strip_ansi)
assert_not_contains "PR がなければ PR 欄を出さない" "$out" "#"

out=$(run "$(mock '.rate_limits.five_hour.used_percentage = 18')" | strip_ansi)
assert_not_contains "レート制限が低いときは表示しない" "$out" "5h"

out=$(run "$(mock '.rate_limits.five_hour.used_percentage = 72')" | strip_ansi)
assert_contains "5h レート制限が高いときは表示する" "$out" "5h 72%"

out=$(run "$(mock '.rate_limits.seven_day.used_percentage = 88')" | strip_ansi)
assert_contains "7d レート制限が高いときは表示する" "$out" "7d 88%"

out=$(run "$(mock '.context_window.used_percentage = 92')")
assert_contains "コンテキスト逼迫時は赤で描画する" "$out" $'\033[31m'

out=$(run "$(mock '.context_window.used_percentage = 10')")
assert_contains "コンテキストに余裕があれば緑で描画する" "$out" $'\033[32m'

out=$(run "$(mock '.context_window.used_percentage = 70')")
assert_contains "コンテキスト中程度なら黄で描画する" "$out" $'\033[33m'

out=$(run "$(mock '.fast_mode = true')" | strip_ansi)
assert_contains "fast mode を ⚡ で示す" "$out" "⚡"

out=$(run "$(mock '.workspace.git_worktree = "wt-feature"')" | strip_ansi)
assert_contains "worktree 名を表示する" "$out" "wt-feature"

out=$(run "$(mock '.cost.total_duration_ms = 45000')" | strip_ansi)
assert_contains "1 分未満は秒で表示する" "$out" "45s"

out=$(run "$(mock '.cost.total_duration_ms = 300000')" | strip_ansi)
assert_contains "1 時間未満は分で表示する" "$out" "5m"

home_json=$(printf '%s' "$FULL_JSON" | jq -c --arg d "$HOME/ghq/github.com/sora-ichigo/dotfiles" '.cwd = $d | .workspace.current_dir = $d')
out=$(run "$home_json" | strip_ansi)
assert_contains "ホーム配下は ~ に短縮する" "$out" "~/ghq/"
assert_contains "深いパスは中間を省略する" "$out" "…/dotfiles"

narrow=$(run "$FULL_JSON" 40)
too_long=0
while IFS= read -r line; do
  plain=$(printf '%s' "$line" | strip_ansi)
  [ "${#plain}" -gt 40 ] && too_long=1
done <<<"$narrow"
assert_eq "COLUMNS に収まるよう切り詰める" "$too_long" "0"

# git リポジトリ内での挙動
repo="$TMPDIR/repo"
mkdir -p "$repo"
git -C "$repo" init --quiet --initial-branch=main
git -C "$repo" -c user.email=t@t -c user.name=t commit --quiet --allow-empty -m init
repo_json=$(printf '%s' "$FULL_JSON" | jq -c --arg d "$repo" '.cwd = $d | .workspace.current_dir = $d')

out=$(run "$repo_json" | strip_ansi)
assert_contains "git ブランチ名を表示する" "$out" "main"
assert_not_contains "クリーンなリポジトリに dirty マークを付けない" "$out" "main*"

touch "$repo/dirty.txt"
out=$(run "$repo_json" | strip_ansi)
assert_contains "変更があれば dirty マークを付ける" "$out" "main*"

out=$(run "$repo_json" 50 | strip_ansi)
assert_contains "幅が狭くてもディレクトリ名は残す" "$out" "repo"
assert_contains "幅が狭くても git ブランチは残す" "$out" "main"

# キャッシュを消さずに連続実行し、キャッシュ読み出し経路を検証する
first=$(run "$repo_json" 2>/dev/null | strip_ansi)
second=$(printf '%s' "$repo_json" | COLUMNS=200 bash "$STATUSLINE" 2>"$TMPDIR/stderr" | strip_ansi)
assert_eq "キャッシュ再利用時も同じ出力になる" "$second" "$first"
assert_eq "キャッシュ再利用時に警告を出さない" "$(cat "$TMPDIR/stderr")" ""

echo
printf 'pass: %d  fail: %d\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
