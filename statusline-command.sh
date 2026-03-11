#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir=$(basename "$cwd")
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  git_branch=$(git --git-dir="$cwd/.git" --work-tree="$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$git_branch" ]; then
    git_branch=" [$git_branch]"
  fi
fi
model=$(echo "$input" | jq -r '.model.display_name')
cost_fmt=$(printf '$%.2f' "$cost")
printf "<%s> \033[34m%s\033[0m\033[33m%s\033[0m \033[35m(%s)\033[0m" "$cost_fmt" "$dir" "$git_branch" "$model"
