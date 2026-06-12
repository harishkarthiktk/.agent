# Claude Code Status Line

## What it shows

The status line appears at the bottom of every Claude Code session.

| Segment | Color | Source |
|---------|-------|--------|
| Directory | cyan | basename of working directory |
| `git:<branch>[*]` | blue | current branch via `git symbolic-ref`; `*` = uncommitted changes |
| Model name | yellow | `model.display_name` from stdin JSON |
| `zsh:<version>` | magenta | `zsh --version` |
| `ctx:<pct>%` | green | `context_window.used_percentage` from stdin JSON |
| `<N>m` or `<N>h<M>m` | dim | session duration since first invocation (per tty) |

**Example:**

```
rustScrapper git:main* Claude Haiku zsh:5.9 ctx:23% 42m
```

---

## Installation

### 1. Place the script

```bash
cp ~/.agent/statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

### 2. Update `~/.claude/settings.json`

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/statusline-command.sh"
  }
}
```

### 3. Restart Claude Code

---

## Script

Full contents of `~/.claude/statusline-command.sh`:

```sh
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
```

---

## Rate Limits (removed feature - reference only)

A previous version of the script calculated 5h and 7d rate limit percentages by scanning `.jsonl` transcript files under `~/.claude/projects/` and summing `output_tokens` from assistant messages within rolling windows.

- **5h window**: last 18,000 seconds
- **7d window**: last 604,800 seconds

Cap defaults were reverse-engineered from observed `/usage` values on a Claude Max 5x plan (calibrated 2026-04-30):

| Window | Default Cap | Env Var Override |
|--------|-------------|------------------|
| 5h | 95,000 tokens | `CLAUDE_5H_CAP_TOKENS` |
| 7d | 1,900,000 tokens | `CLAUDE_7D_CAP_TOKENS` |

This was removed because caps vary by model tier and Anthropic's internal weighting is unknown, causing persistent drift vs. `/usage`. The native `rate_limits` JSON field (`.rate_limits.five_hour.used_percentage`) is more reliable if populated by your Claude Code version.

**Known fix (2026-04-30):** Original script used `.ts` (null) instead of `.timestamp` for record timestamps. Fix was to parse `.timestamp` via:
```jq
(.timestamp[0:19] + "Z" | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime) as $ts
```

---

## Dependencies

- `jq` - required for JSON parsing
- `git` - for branch display (optional, skipped if not a git repo)
- `zsh` - for version display (optional)

Install `jq`: `brew install jq` (macOS) / `apt install jq` (Debian/Ubuntu)

---

## Troubleshooting

- **Status line not appearing**: verify `statusLine` block in `~/.claude/settings.json`, confirm script exists and is executable, check `jq` is on PATH
- **Colors missing**: use a modern terminal (iTerm2, kitty, alacritty)
- **Git branch missing**: expected in non-git directories
- **ctx% missing**: only populates after the first API call in a session
