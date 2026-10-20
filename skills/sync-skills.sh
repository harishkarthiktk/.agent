#!/usr/bin/env bash
set -euo pipefail

SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
TARGETS=("$HOME/.agents/skills" "$HOME/.claude/skills")

FIX_CONFLICTS=false
CLEAN_ORPHANS=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --fix-conflicts) FIX_CONFLICTS=true ;;
    --clean-orphans) CLEAN_ORPHANS=true ;;
    --force) FIX_CONFLICTS=true; CLEAN_ORPHANS=true ;;
    --dry-run) DRY_RUN=true ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

EXCLUDE="sync-skills\.sh|\.DS_Store|^z_archive_.*"

summary_ok=0
summary_new=0
summary_conflict=0
summary_fixed=0
summary_orphan=0
summary_cleaned=0

timestamp="$(date +%Y%m%d%H%M%S)"

run() {
  if $DRY_RUN; then
    printf '  [DRY-RUN]'; printf ' %q' "$@"; echo
  else
    "$@"
  fi
}

sync_target() {
  local target="$1"
  local target_name
  target_name="$(basename "$target")"

  echo "=== TARGET: $target ==="

  if [ ! -d "$target" ]; then
    echo "  Creating target directory..."
    run mkdir -p "$target"
  fi

  for skill_path in "$SOURCE"/*/; do
    local skill
    skill="$(basename "$skill_path")"
    skill_path="${skill_path%/}"

    if echo "$skill" | grep -qE "^($EXCLUDE)$"; then
      continue
    fi

    local target_ent="$target/$skill"

    if [ -L "$target_ent" ]; then
      local link_target
      link_target="$(readlink "$target_ent")"
      local resolved_source="$(cd "$skill_path" && pwd -P)"
      local resolved_target="$(cd "$(dirname "$target_ent")" && cd "$(dirname "$link_target")" 2>/dev/null && pwd -P 2>/dev/null || echo "")"
      local resolved
      if [ -n "$resolved_target" ]; then
        resolved="$resolved_target/$(basename "$link_target")"
      else
        resolved="$link_target"
      fi
      if [ "$resolved" = "$resolved_source" ]; then
        echo "  [OK]      $skill -> already synced"
        summary_ok=$((summary_ok + 1))
      else
        echo "  [CONFLICT] $skill -> symlink points elsewhere: $link_target"
        summary_conflict=$((summary_conflict + 1))
        if $FIX_CONFLICTS; then
          run rm "$target_ent"
          run ln -s "$skill_path" "$target_ent"
          echo "     -> [FIXED] replaced symlink"
          summary_fixed=$((summary_fixed + 1))
        fi
      fi
    elif [ -e "$target_ent" ]; then
      local ent_kind="file"
      [ -d "$target_ent" ] && ent_kind="directory"
      echo "  [CONFLICT] $skill -> real $ent_kind exists"
      summary_conflict=$((summary_conflict + 1))
      if $FIX_CONFLICTS; then
        local bak="$target_ent.bak.$timestamp"
        run mv "$target_ent" "$bak"
        run ln -s "$skill_path" "$target_ent"
        echo "     -> [FIXED] backed up as $(basename "$bak")"
        summary_fixed=$((summary_fixed + 1))
      fi
    else
      echo "  [NEW]     $skill -> linking"
      summary_new=$((summary_new + 1))
      run ln -s "$skill_path" "$target_ent"
    fi
  done
}

clean_orphans_in_target() {
  local target="$1"

  while read -r orphan; do
    local name
    name="$(basename "$orphan")"
    local link_target
    link_target="$(readlink "$orphan")"

    case "$link_target" in
      "$SOURCE"/*|"$SOURCE/")
        echo "  [ORPHAN]  $name -> source deleted: $link_target"
        summary_orphan=$((summary_orphan + 1))
        if $CLEAN_ORPHANS; then
          run rm "$orphan"
          echo "     -> [CLEANED] removed dead symlink"
          summary_cleaned=$((summary_cleaned + 1))
        fi
        ;;
      *) ;;
    esac
  done < <(find -L "$target" -maxdepth 1 -type l 2>/dev/null)
}

for target in "${TARGETS[@]}"; do
  echo ""
  sync_target "$target"
  clean_orphans_in_target "$target"
done

echo ""
echo "=== SUMMARY ==="
echo "  [OK]      $summary_ok already synced"
echo "  [NEW]     $summary_new symlinks created"
echo "  [CONFLICT] $summary_conflict conflicts found"
echo "  [FIXED]   $summary_fixed conflicts resolved"
echo "  [ORPHAN]  $summary_orphan dead symlinks found"
echo "  [CLEANED] $summary_cleaned dead symlinks removed"