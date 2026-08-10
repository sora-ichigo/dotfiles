#!/usr/bin/env bash
# Claude Code の 2 行ステータスライン
#   1 行目: モデル / effort / ディレクトリ / worktree / git / PR
#   2 行目: コンテキスト使用率バー / 経過時間 / コスト / 差分行数 / レート制限
# 端末幅 (COLUMNS) に収まらない場合は優先度の低いセグメントから落とす
set -u

input=$(cat)

R=$'\033[0m'
DIM=$'\033[2m'
BOLD=$'\033[1m'
CYAN=$'\033[36m'
BLUE=$'\033[34m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
MAGENTA=$'\033[35m'

COLS=${COLUMNS:-120}
[ "$COLS" -gt 0 ] 2>/dev/null || COLS=120
SEP="  "

# 区切りは US(0x1f)。IFS がタブだと空フィールドが畳まれてしまう
IFS=$'\037' read -r MODEL EFFORT FAST DIR WORKTREE CTX_PCT CTX_USED CTX_SIZE COST DURATION_MS ADDED REMOVED RL5 RL7 PR_NUM PR_STATE <<<"$(
  printf '%s' "$input" | jq -r '
    [
      (.model.display_name // "?"),
      (.effort.level // ""),
      (if .fast_mode then "1" else "" end),
      (.workspace.current_dir // .cwd // ""),
      (.workspace.git_worktree // .worktree.name // ""),
      (.context_window.used_percentage // 0),
      (if .context_window.total_input_tokens or .context_window.total_output_tokens
       then (.context_window.total_input_tokens // 0) + (.context_window.total_output_tokens // 0)
       else "" end),
      (.context_window.context_window_size // ""),
      (.cost.total_cost_usd // ""),
      (.cost.total_duration_ms // ""),
      (.cost.total_lines_added // 0),
      (.cost.total_lines_removed // 0),
      (.rate_limits.five_hour.used_percentage // ""),
      (.rate_limits.seven_day.used_percentage // ""),
      (.pr.number // ""),
      (.pr.review_state // "")
    ] | map(tostring) | join("")' 2>/dev/null
)"
: "${MODEL:=?}"

# ANSI エスケープを除いた文字列と長さを STRIPPED / VLEN に入れる（fork を避けるため戻り値は使わない）
strip_ansi() {
  local s=$1 out=""
  while [[ $s == *$'\033['* ]]; do
    out+="${s%%$'\033['*}"
    s=${s#*$'\033['}
    s=${s#*m}
  done
  STRIPPED="$out$s"
}

vlen() {
  strip_ansi "$1"
  VLEN=${#STRIPPED}
}

repeat() {
  local i
  REP=""
  for ((i = 0; i < $2; i++)); do REP+="$1"; done
}

SEG_PRIO=()
SEG_TEXT=()

seg() {
  [ -n "$2" ] || return 0
  SEG_PRIO+=("$1")
  SEG_TEXT+=("$2")
}

join_segs() {
  local i
  JOINED=""
  for ((i = 0; i < ${#SEG_TEXT[@]}; i++)); do
    [ "${SEG_PRIO[$i]}" -gt "$1" ] && continue
    [ -n "$JOINED" ] && JOINED+="$SEP"
    JOINED+="${SEG_TEXT[$i]}"
  done
}

# 幅に収まる最大の優先度で組み立て、それでも溢れるなら色を捨てて切り詰める
render() {
  local p
  for p in 3 2 1 0; do
    join_segs "$p"
    vlen "$JOINED"
    [ "$VLEN" -le "$COLS" ] && break
  done
  if [ "$VLEN" -gt "$COLS" ]; then
    JOINED="${STRIPPED:0:$((COLS - 1))}…"
  fi
  printf '%s\n' "$JOINED"
  SEG_PRIO=()
  SEG_TEXT=()
}

# レベル 0: ホーム配下を ~ に置き換えただけ / 1: 4 階層以上なら中間を … に畳む / 2: 末尾のみ
shorten_dir() {
  local level=$2 p=${1/#$HOME/\~} parts n

  if [ "$level" -ge 2 ]; then
    printf '%s' "${1##*/}"
    return 0
  fi

  local IFS=/
  read -ra parts <<<"$p"
  n=${#parts[@]}
  if [ "$level" -ge 1 ] && [ "$n" -gt 3 ]; then
    printf '%s/%s/…/%s' "${parts[0]}" "${parts[1]}" "${parts[n - 1]}"
  else
    printf '%s' "$p"
  fi
}

fmt_duration() {
  local s=$(($1 / 1000))
  if [ "$s" -lt 60 ]; then
    printf '%ds' "$s"
  elif [ "$s" -lt 3600 ]; then
    printf '%dm' "$((s / 60))"
  else
    printf '%dh%02dm' "$((s / 3600))" "$(((s % 3600) / 60))"
  fi
}

# git status は重いので 1 秒キャッシュする
git_segment() {
  local dir=$1
  [ -n "$dir" ] && [ -d "$dir" ] || return 0
  git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  # stat は BSD/GNU で書式オプションが非互換なので、時刻はキャッシュの 1 行目に持たせる
  local key cache now cached_at
  key=$(printf '%s' "$dir" | cksum | cut -d' ' -f1)
  cache="${TMPDIR:-/tmp}/claude-statusline-$key"
  now=$(date +%s)
  if [ -f "$cache" ]; then
    IFS= read -r cached_at <"$cache"
    case ${cached_at:-x} in
    *[!0-9]*) cached_at=0 ;;
    esac
    if [ "$((now - cached_at))" -lt 1 ]; then
      tail -n +2 "$cache"
      return 0
    fi
  fi

  local branch dirty="" color counts behind ahead out
  branch=$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null) ||
    branch=$(git -C "$dir" rev-parse --short HEAD 2>/dev/null)
  [ -n "$branch" ] || return 0
  [ "${#branch}" -gt 24 ] && branch="${branch:0:23}…"

  if [ -n "$(git -C "$dir" status --porcelain 2>/dev/null | head -1)" ]; then
    dirty="*"
    color=$YELLOW
  else
    color=$GREEN
  fi

  out="${color}⎇ ${branch}${dirty}${R}"
  counts=$(git -C "$dir" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
  if [ -n "$counts" ]; then
    behind=${counts%%[!0-9]*}
    ahead=${counts##*[!0-9]}
    [ "${ahead:-0}" -gt 0 ] 2>/dev/null && out+=" ${CYAN}↑${ahead}${R}"
    [ "${behind:-0}" -gt 0 ] 2>/dev/null && out+=" ${MAGENTA}↓${behind}${R}"
  fi

  printf '%s\n%s' "$now" "$out" >"$cache"
  printf '%s' "$out"
}

context_bar() {
  local pct=$1 width=20 filled color bar
  [ "$COLS" -lt 60 ] && width=10
  filled=$(((pct * width + 50) / 100))
  [ "$filled" -gt "$width" ] && filled=$width
  [ "$filled" -lt 0 ] && filled=0

  if [ "$pct" -ge 85 ]; then
    color=$RED
  elif [ "$pct" -ge 60 ]; then
    color=$YELLOW
  else
    color=$GREEN
  fi

  repeat "█" "$filled"
  bar=$REP
  repeat "░" "$((width - filled))"
  printf '%s▕%s%s▏ %d%%%s' "$color" "$bar" "$REP" "$pct" "$R"
}

# 使用率が高いときだけ出す
rate_segment() {
  local label=$1 pct=$2 color=$YELLOW
  [ -n "$pct" ] || return 0
  pct=$(printf '%.0f' "$pct" 2>/dev/null) || return 0
  [ "$pct" -ge 50 ] || return 0
  [ "$pct" -ge 85 ] && color=$RED
  printf '%s%s %d%%%s' "$color" "$label" "$pct" "$R"
}

fmt_tokens() {
  local n=$1
  if [ "$n" -lt 1000 ]; then
    printf '%d' "$n"
  elif [ "$n" -lt 1000000 ]; then
    if [ "$((n % 1000))" -lt 100 ]; then
      printf '%dk' "$((n / 1000))"
    else
      printf '%d.%dk' "$((n / 1000))" "$(((n % 1000) / 100))"
    fi
  elif [ "$((n % 1000000))" -lt 100000 ]; then
    printf '%dM' "$((n / 1000000))"
  else
    printf '%d.%dM' "$((n / 1000000))" "$(((n % 1000000) / 100000))"
  fi
}

GIT_SEG=$(git_segment "$DIR")

PR_SEG=""
if [ -n "$PR_NUM" ]; then
  case "$PR_STATE" in
  approved) PR_MARK="${GREEN} ✓${R}" ;;
  changes_requested) PR_MARK="${RED} ✗${R}" ;;
  pending) PR_MARK="${YELLOW} ●${R}" ;;
  draft) PR_MARK="${DIM} ◌${R}" ;;
  *) PR_MARK="" ;;
  esac
  PR_SEG="${DIM}PR${R} #${PR_NUM}${PR_MARK}"
fi

build_line1() {
  SEG_PRIO=()
  SEG_TEXT=()
  seg 0 "${BOLD}${CYAN}◆ ${MODEL}${R}"
  [ -n "$FAST" ] && seg 2 "${YELLOW}⚡${R}"
  [ -n "$EFFORT" ] && seg 2 "${DIM}${EFFORT}${R}"
  [ -n "$DIR" ] && seg 0 "${BLUE}$(shorten_dir "$DIR" "$1")${R}"
  [ -n "$WORKTREE" ] && seg 3 "${MAGENTA}⑂ ${WORKTREE}${R}"
  seg 1 "$GIT_SEG"
  seg 3 "$PR_SEG"
}

# セグメントを落とすより先にパスを縮めて、余った幅を使い切る
LINE1=""
for p in 3 2 1 0; do
  for d in 0 1 2; do
    build_line1 "$d"
    join_segs "$p"
    vlen "$JOINED"
    if [ "$VLEN" -le "$COLS" ]; then
      LINE1=$JOINED
      break 2
    fi
  done
done
[ -n "$LINE1" ] || LINE1="${STRIPPED:0:$((COLS - 1))}…"
printf '%s\n' "$LINE1"

SEG_PRIO=()
SEG_TEXT=()

PCT=$(printf '%.0f' "${CTX_PCT:-0}" 2>/dev/null) || PCT=0
seg 0 "$(context_bar "$PCT")"

if [ -n "$CTX_USED" ] && [ -n "$CTX_SIZE" ]; then
  seg 1 "${DIM}$(fmt_tokens "${CTX_USED%%.*}")/$(fmt_tokens "${CTX_SIZE%%.*}")${R}"
fi

[ -n "$DURATION_MS" ] && seg 1 "${DIM}⏱ $(fmt_duration "${DURATION_MS%%.*}")${R}"
[ -n "$COST" ] && seg 1 "${DIM}\$$(printf '%.2f' "$COST")${R}"

if [ "${ADDED:-0}" -gt 0 ] 2>/dev/null || [ "${REMOVED:-0}" -gt 0 ] 2>/dev/null; then
  seg 2 "${GREEN}+${ADDED}${R}${DIM}/${R}${RED}-${REMOVED}${R}"
fi

seg 2 "$(rate_segment 5h "$RL5")"
seg 2 "$(rate_segment 7d "$RL7")"

render
