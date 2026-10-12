#!/usr/bin/env bash
# extract_frames.sh - extract PNG frames from a video at the timestamps
# listed in a timestamps.txt metadata file (see video-frame-extraction skill).
#
# Usage: ./extract_frames.sh <video_file> <timestamps_txt> <output_dir>

set -euo pipefail

VIDEO="${1:?Usage: extract_frames.sh <video_file> <timestamps_txt> <output_dir>}"
TIMESTAMPS="${2:?Missing timestamps.txt path}"
OUTDIR="${3:?Missing output directory}"

mkdir -p "$OUTDIR"

while IFS='|' read -r index timestamp label method notes; do
  # skip comment/header lines
  [[ "$index" =~ ^[[:space:]]*# ]] && continue
  [[ -z "${index// }" ]] && continue

  index=$(echo "$index" | xargs)
  timestamp=$(echo "$timestamp" | xargs)
  label=$(echo "$label" | xargs)

  outfile="${OUTDIR}/${index}_${label}.png"

  ffmpeg -y -ss "$timestamp" -i "$VIDEO" -frames:v 1 -q:v 2 "$outfile" \
    2> /dev/null

  echo "extracted: $outfile"
done < "$TIMESTAMPS"

echo "done. frames written to $OUTDIR"
