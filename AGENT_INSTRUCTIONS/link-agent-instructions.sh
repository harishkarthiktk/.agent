#!/usr/bin/env bash
# Symlink agent instruction files into ~/.claude and ~/.agents.
# Linux and macOS. Safe to re-run.

set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
STAMP="$(date +%Y%m%d-%H%M%S)"

# "source-file:target-dir"
LINKS=(
  "CLAUDE.md:$HOME/.claude"
  "claude-specific.md:$HOME/.claude"
  "AGENTS.md:$HOME/.agents"
  "agents-common.md:$HOME/.agents"
)

link_file() {
  local src="$1"
  local dst="$2"

  if [ -L "$dst" ]; then
    if [ "$(readlink "$dst")" = "$src" ]; then
      echo "ok       $dst"
      return
    fi
    rm "$dst"
  elif [ -e "$dst" ]; then
    mv "$dst" "$dst.bak-$STAMP"
    echo "backup   $dst -> $dst.bak-$STAMP"
  fi

  ln -s "$src" "$dst"
  echo "linked   $dst -> $src"
}

for entry in "${LINKS[@]}"; do
  name="${entry%%:*}"
  target_dir="${entry#*:}"
  src="$SRC_DIR/$name"

  if [ ! -f "$src" ]; then
    echo "missing  $src" >&2
    exit 1
  fi

  mkdir -p "$target_dir"
  link_file "$src" "$target_dir/$name"
done
