#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir=$(basename "$cwd")

# Real escape character for ANSI codes
ESC=$(printf '\033')
RESET="${ESC}[0m"
CYAN="${ESC}[36m"
BLUE="${ESC}[34m"
YELLOW="${ESC}[33m"
MAGENTA="${ESC}[35m"
GREEN="${ESC}[32m"
RED="${ESC}[31m"

# Git branch (blue)
git_part=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    git_part=" ${BLUE}git:${branch}${RESET}"
  fi
fi

# Model (yellow)
model=$(echo "$input" | jq -r '.model.display_name')

# Zsh version (magenta)
zsh_version=$(zsh --version 2>/dev/null | awk '{print $2}')
zsh_part=""
if [ -n "$zsh_version" ]; then
  zsh_part=" ${MAGENTA}zsh:${zsh_version}${RESET}"
fi

# Context usage (green) - only after first API call
ctx_part=""
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used" ]; then
  used_int=$(printf '%.0f' "$used")
  ctx_part=" ${GREEN}ctx:${used_int}%${RESET}"
fi

# Rate limit usage from transcript files (red)
# Sums output tokens across all sessions within time windows.
# Cap defaults are approximate for Claude Max (5x plan). Override via env vars:
#   CLAUDE_5H_CAP_TOKENS  (default: 1000000)
#   CLAUDE_7D_CAP_TOKENS  (default: 10000000)
PROJECTS_DIR="${HOME}/.claude/projects"
CAP_5H="${CLAUDE_5H_CAP_TOKENS:-1000000}"
CAP_7D="${CLAUDE_7D_CAP_TOKENS:-10000000}"

rate_part=""
if [ -d "$PROJECTS_DIR" ] && command -v jq > /dev/null 2>&1; then
  now_epoch=$(date +%s)
  cutoff_5h=$((now_epoch - 18000))
  cutoff_7d=$((now_epoch - 604800))

  tokens_5h=0
  tokens_7d=0

  while IFS= read -r jsonl_file; do
    [ -f "$jsonl_file" ] || continue
    result=$(jq -r --argjson c5 "$cutoff_5h" --argjson c7 "$cutoff_7d" '
      select(.type == "assistant" and .message.usage != null) |
      .ts as $ts |
      (.message.usage.output_tokens // 0) as $tok |
      if ($ts >= $c5) then "5h \($tok)" else empty end,
      if ($ts >= $c7 and $ts < $c5) then "7d \($tok)" else empty end
    ' "$jsonl_file" 2>/dev/null)
    while IFS=' ' read -r window tok; do
      case "$window" in
        5h) tokens_5h=$((tokens_5h + tok)) ;;
        7d) tokens_7d=$((tokens_7d + tok)) ;;
      esac
    done <<EOF
$result
EOF
  done <<FINDEOF
$(find "$PROJECTS_DIR" -name "*.jsonl" 2>/dev/null)
FINDEOF

  # tokens_7d accumulates only the 5h-to-7d window above; add 5h tokens for total 7d
  tokens_7d_total=$((tokens_7d + tokens_5h))

  pct_5h=$(( (tokens_5h * 100) / CAP_5H ))
  pct_7d=$(( (tokens_7d_total * 100) / CAP_7D ))

  rate_part=" ${RED}5h:${pct_5h}% 7d:${pct_7d}%${RESET}"
fi

printf "%s%s%s%s %s%s%s%s%s%s" "${CYAN}" "$dir" "${RESET}" "$git_part" "${YELLOW}" "$model" "${RESET}" "$zsh_part" "$ctx_part" "$rate_part"
