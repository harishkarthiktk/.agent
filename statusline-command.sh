#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir=$(basename "$cwd")

ESC=$(printf '\033')
RESET="${ESC}[0m"
CYAN="${ESC}[36m"
BLUE="${ESC}[34m"
YELLOW="${ESC}[33m"
MAGENTA="${ESC}[35m"
GREEN="${ESC}[32m"
DIM="${ESC}[2m"

# Git branch (blue)
git_part=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    dirty=""
    if ! git -C "$cwd" --no-optional-locks diff --quiet HEAD 2>/dev/null; then
      dirty="*"
    fi
    git_part=" ${BLUE}git:${branch}${dirty}${RESET}"
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

# Session duration
duration_part=""
tty_id=$(tty 2>/dev/null | tr '/' '_')
if [ -n "$tty_id" ]; then
  start_file="/tmp/claude-statusline-start${tty_id}"
  if [ ! -f "$start_file" ]; then
    touch "$start_file"
  fi
  if [ "$(uname)" = "Darwin" ]; then
    start_ts=$(stat -f '%m' "$start_file")
  else
    start_ts=$(stat -c '%Y' "$start_file")
  fi
  now_ts=$(date +%s)
  elapsed=$(( now_ts - start_ts ))
  if [ "$elapsed" -ge 3600 ]; then
    hrs=$(( elapsed / 3600 ))
    mins=$(( (elapsed % 3600) / 60 ))
    duration_part=" ${DIM}${hrs}h${mins}m${RESET}"
  else
    mins=$(( elapsed / 60 ))
    duration_part=" ${DIM}${mins}m${RESET}"
  fi
fi

printf "%s%s%s%s %s%s%s%s%s%s" "${CYAN}" "$dir" "${RESET}" "$git_part" "${YELLOW}" "$model" "${RESET}" "$zsh_part" "$ctx_part" "$duration_part"
