---
name: video-frame-extraction
description: Extract key frames from one or more video files using ffmpeg scene detection or AI-driven analysis, producing named PNG frames, a structured timestamps.txt metadata file, a reusable extract_frames.sh script, and a frame-quality verification report. Use this skill whenever the user wants to pull screenshots, thumbnails, slides, or key moments out of a video (recording, webinar, lecture, demo) for a deck, doc, or summary, especially when they hand over a video plus a subtitle file (VTT/SRT), meeting notes, or a list of timestamps to anchor the extraction to specific moments. Also use it for batch frame extraction across multiple videos, or when the user asks to "grab frames at these timestamps," "screenshot the slide changes," "pull key frames from this recording," or references matching frames to a transcript/notes file.
model: Haiku
---

# Video Frame Extraction

Extract representative frames from video files and package them with metadata and
a script the user can rerun without you. The workflow has two independent halves
that meet in the middle:

1. Figuring out *when* to grab a frame (timestamp generation).
2. Actually grabbing it, naming it, and verifying it's not garbage.

Treat these as separable steps because the timestamp source (ffmpeg scene
detection vs. a reference document vs. AI analysis) changes far more often than
the extraction/verification mechanics.

## Bundled Resources

- `scripts/extract_frames.sh` — reusable bash script to extract frames at given timestamps.
- `scripts/verify_frames.py` — quality verification script for extracted frames.

## Step 1: Collect inputs

You need at minimum a video file path. Optionally, the user may also hand you a
reference document, or several videos for batch processing. Before doing
anything else, confirm what you're working with:

- Video path(s). If the user says "these videos" or points at a folder, glob for
  common containers (`.mp4`, `.mov`, `.mkv`, `.webm`, `.avi`).
- Reference document(s), if any: subtitles, meeting notes, a timestamp list, a
  markdown outline of the talk, a JSON export from another tool. These are
  optional but, when present, they are usually a better source of *semantic*
  labels ("Q&A starts", "architecture diagram") than raw scene detection is.
- Whether the user wants a specific number of frames, a specific density (e.g.
  "one frame every 2 minutes"), or coverage of specific moments they already
  know about.

Run `ffprobe` on each video first to get duration, resolution, and frame rate.
You'll need these for sanity checks later and to avoid requesting a timestamp
past the end of the file.

```bash
ffprobe -v error -select_streams v:0 \
  -show_entries stream=width,height,r_frame_rate,duration \
  -of default=noprint_wrappers=1 "$VIDEO"
```

## Step 2: Parse the reference document, if one exists

Reference documents are useful but arrive in whatever format the user happens to
have lying around. Detect the format instead of asking the user to convert it
first; sniffing is cheap and each format below is easy to distinguish.

| Signal | Format | Parse approach |
|---|---|---|
| First line is `WEBVTT` | VTT | Timestamps are `HH:MM:SS.mmm --> HH:MM:SS.mmm`, cue text follows on the next line(s). |
| Numeric sequence markers with `HH:MM:SS,mmm --> HH:MM:SS,mmm` | SRT | Same idea as VTT but comma-separated milliseconds and a leading cue-number line. |
| Starts with `{` or `[` | JSON | Look for common shapes: array of `{timestamp, label}`, or `{events: [...]}`. If the shape is unfamiliar, print a few objects and infer the fields rather than guessing blindly. |
| Everything else that's text | Markdown / plain text | Scan line by line for anything that looks like a timestamp: `MM:SS`, `HH:MM:SS`, or `[HH:MM:SS]`. Whatever text sits next to it (same line, or the nearest heading above it) becomes the label. Markdown headings (`##`) often mark chapter boundaries even without an explicit timestamp next to them — if a heading has no timestamp, don't invent one; flag it for AI analysis instead (see Step 3). |

For any format, the goal is the same: produce a list of `(timestamp, label,
confidence)` candidates. Confidence is high when the source is an explicit
timestamp; low when you inferred it from a heading or approximate phrase
("towards the end he shows the pricing slide").

If the user hands you a format that doesn't cleanly fit the table (a Word doc, a
Slack thread pasted as text, whatever), don't reject it — read it as plain text
and apply the same "find timestamp-shaped strings, attach nearby text as label"
heuristic. Flexibility here matters more than strict format matching.

## Step 3: Generate timestamps

**Default method: ffmpeg scene-change detection.** This is the primary method
because it's fast, deterministic, and needs no video understanding from a model
— it just measures pixel-level change between consecutive frames.

```bash
ffmpeg -i "$VIDEO" -filter:v "select='gt(scene,0.3)',showinfo" \
  -f null - 2> scene_log.txt
```

Parse `scene_log.txt` for lines containing `pts_time:` to get candidate cut
timestamps. `0.3` is a reasonable default threshold for slide/scene changes in
a screen recording or presentation; lower it (e.g. `0.15`) for subtler
transitions, raise it (e.g. `0.4-0.5`) if you're getting noise from camera
shake or gradual fades. If the reference document already gave you explicit
timestamps, treat scene detection as a supplement, not a replacement — merge
the two lists and dedupe anything within a couple seconds of each other,
keeping the reference-document label when both agree on a moment.

**Override method: AI analysis (Sonnet), used when:**
- The user explicitly passes `--use-ai`.
- Scene detection returns implausibly few or many cuts (e.g. zero cuts in a
  10-minute video, or hundreds of cuts every second, both of which mean the
  scene threshold isn't matching this video's actual content).
- The reference document demands precision that scene detection can't verify —
  e.g. it names a specific slide or moment by description ("the frame where
  the architecture diagram first appears") rather than a timestamp, and you
  need to actually look at candidate frames to confirm which one matches.

When AI analysis is needed, don't ask a model to "watch" the whole video —
that's not how this works and burns time for no benefit. Instead: extract a
sparse grid of candidate frames first (e.g. every 5-10 seconds, or at every
scene-detected cut if that list exists), then have Sonnet look at that
frame grid alongside the reference text and pick/label the ones that matter.
This turns "AI video analysis" into "AI image analysis over a manageable frame
set," which is both cheaper and something you can actually verify by eye
afterward. Record `"method": "ai"` and a short justification in the metadata
for every timestamp Sonnet selects, so it's clear later which frames came from
measurement versus judgment.

Whichever method produces the final timestamp list, sort it, dedupe, and
clip anything past `duration - 0.1s` from the ffprobe result in Step 1.

## Step 4: Write frames/timestamps.txt

Before extracting anything, write the metadata file. This makes the extraction
script trivial (it just reads this file) and gives the user a reviewable plan
before you spend time on ffmpeg calls.

Create `frames/timestamps.txt` as a simple pipe-delimited table (easy to read by
eye and by the extraction script alike):

```
# index | timestamp | label | method | confidence/notes
01 | 00:00:12.500 | Intro_Title_Slide | scene | high
02 | 00:01:47.020 | Architecture_Diagram | reference:vtt | high
03 | 00:03:15.000 | Pricing_Slide | ai | medium - inferred from "shows pricing" in notes.md
```

- `index`: zero-padded two-digit sequence number, matching the frame filenames.
- `timestamp`: `HH:MM:SS.mmm`, exactly what you'll pass to ffmpeg's `-ss`.
- `label`: short, filesystem-safe (underscores, no spaces/slashes/punctuation
  ffmpeg or the OS would choke on), derived from the reference text or, absent
  one, a generic description of the visual change ("Scene_Change_03").
- `method`: `scene`, `reference:<format>`, or `ai`, so anyone reading this later
  knows how much to trust each row.
- `confidence/notes`: `high`/`medium`/`low` plus a one-line reason when it's not
  obviously high (exact timestamp from a reference document is always high;
  AI-inferred or approximate-language-derived timestamps are medium/low).

For batch processing across multiple videos, write one `timestamps.txt` per
video, in that video's own frame output directory (see Step 5), rather than one
combined file — keeps each video's provenance and re-run behavior independent.

## Step 5: Run frame extraction

Use the bundled `scripts/extract_frames.sh` script:

```bash
chmod +x scripts/extract_frames.sh
./scripts/extract_frames.sh <video_file> <timestamps_txt> <output_dir>
```

The script reads the `timestamps.txt` metadata file (from Step 4) and extracts
each frame at the specified timestamp. It's parameterized for video path and
output directory, so you can rerun it after hand-editing `timestamps.txt` or
point it at a new video.

## Step 6: Run batch extraction

For a single video, run the script once. For multiple videos, loop over them,
giving each its own output subdirectory (`frames/<video_basename>/`) so
filenames never collide and each video's `timestamps.txt` stays scoped to it:

```bash
for video in "${VIDEOS[@]}"; do
  base=$(basename "$video" | sed 's/\.[^.]*$//')
  outdir="frames/${base}"
  ./extract_frames.sh "$video" "${outdir}/timestamps.txt" "$outdir"
done
```

Generate each video's `timestamps.txt` (Step 4) inside its own `outdir` before
calling the script for that video.

## Step 7: Verify frame quality

Use the bundled `scripts/verify_frames.py` to check that extracted frames are
actually useful:

```bash
./scripts/verify_frames.py <frames_dir> <expected_width> <expected_height>
```

The script runs these checks on every PNG:
- File exists and has non-trivial size.
- Not blank/black (mean brightness check).
- Not blurry (Laplacian variance, if OpenCV available).
- Resolution matches expected values.
- No unintended duplicates (perceptual hash comparison).

Results are written to `frames/verification_report.txt` in this format:

```
01_Intro_Title_Slide.png | OK | size_bytes=450000 | mean_brightness=142 | resolution=1920x1080
02_Architecture_Diagram.png | OK | size_bytes=520000 | mean_brightness=201 | resolution=1920x1080
03_Pricing_Slide.png | FAIL_BRIGHTNESS | size_bytes=45000 | mean_brightness=8 | resolution=1920x1080
```

For frames that fail or warn (e.g., FAIL_BRIGHTNESS, WARN_BLUR), nudge the
timestamp forward by ~0.3-0.5s, re-extract, and update `timestamps.txt` so
the script stays reproducible on rerun.

## Output summary

When done, the user should have, per video:

```
frames/<video_name>/
  timestamps.txt          # structured metadata driving the extraction
  extract_frames.sh       # reusable, rerunnable extraction script
  verification_report.txt # per-frame quality check results
  01_Label_One.png
  02_Label_Two.png
  ...
```

Tell the user directly which frames (if any) needed a retry or manual review,
and which timestamp-generation method was used, so they know how much to trust
the labeling versus double-checking it themselves.
