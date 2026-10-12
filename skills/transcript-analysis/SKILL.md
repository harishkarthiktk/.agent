---
name: transcript-analysis
description: Analyze media transcripts (VTT/SRT/markdown/text), identify key content, extract presenters/pricing/timelines, generate comprehensive markdown summary with embedded tables
model: Sonnet
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Transcript Analysis

Turn a raw meeting/webinar/demo transcript (any format) plus any supporting
reference files into a single, structured markdown document: presenters,
sections, topics, pricing, roadmap/timeline, and tech decisions, all captured
in embedded tables.

## When to use this skill

Trigger when the user provides or points to any of:
- `.vtt` or `.srt` caption/subtitle files
- Plain `.txt` transcripts (e.g. "Recording Transcript.txt")
- Markdown transcripts or notes
- Any combination of the above plus supplementary references (slide decks,
  pricing sheets, prior summaries, chat logs) that should inform the analysis

And the user asks to "analyze this transcript", "summarize this
call/webinar/demo", "extract presenters and pricing", "turn this into a
doc", or similar.

## Workflow

### 1. Auto-detect input format

Before parsing, identify what you're dealing with:

- **VTT** (`WEBVTT` header, `HH:MM:SS.mmm --> HH:MM:SS.mmm` cue timing,
  optional cue identifiers/settings on the timing line).
- **SRT** (sequential integer index, `HH:MM:SS,mmm --> HH:MM:SS,mmm` timing
  using commas, blank line between cues).
- **Plain text** (no timing markers at all, or loosely formatted
  `Speaker: text` lines, possibly with timestamps in brackets like `[00:12:34]`).
- **Markdown** (existing headers, bullet structure, possibly a prior summary
  to refine rather than regenerate from scratch).
- **Other references** (PDFs, slide exports, pricing sheets, prior notes) —
  treat these as supplementary evidence, not the primary timeline source.
  Cross-reference them for numbers, product names, and roadmap items that
  may be spoken about ambiguously in the transcript but stated precisely in
  a reference doc.

Use `rtk read <file>` or `rtk grep` to sample the first ~50 lines and confirm
format before committing to a parse strategy. Do not assume — mixed
transcript bundles (e.g. a `.vtt` plus a `.txt` "Recording Transcript" of the
same session) are common; reconcile them rather than picking one arbitrarily.

### 2. Normalize into a speaker-attributed timeline

Regardless of source format, produce an internal normalized form of
`{timestamp | speaker | utterance}` records:

- VTT/SRT: strip cue numbers and formatting tags (`<v Speaker>`, `<b>`,
  etc.), keep start timestamps, merge consecutive cues from the same speaker
  into one utterance block.
- Plain text/markdown with `Speaker: text` lines: parse directly; if no
  explicit speaker labels exist, infer speaker turns from context (name
  mentions, "as I mentioned", role references) and flag inferred attributions
  as such rather than stating them as fact.
- If timestamps are absent, fall back to sequential ordering and note in the
  output that the document has no time axis.

### 3. Extract presenters

- List every distinct speaker/presenter identified.
- For each, capture: name (as stated or inferred), role/title if mentioned,
  and approximate share of the session (rough proportion of speaking turns
  or duration — not required to be exact, flag as approximate).
- If a presenter is named in a reference file (e.g. an attendee list or
  slide deck) but attribution in the transcript is unclear, use the
  reference to resolve it and note the source.

### 4. Identify key sections

- Segment the timeline into logical sections (e.g. "Intro", "Product Demo",
  "Pricing Discussion", "Roadmap", "Q&A") based on topic shifts, not fixed
  time intervals.
- For each section, note approximate start time (if available) and a
  one-line description of what was covered.

### 5. Extract structured data

Pull out anything that is naturally tabular or decision-like:

- **Pricing**: plans, tiers, dollar amounts, discounts, billing cadence.
  If numbers conflict between transcript and a reference file, prefer the
  reference file's precision but note the transcript's phrasing.
- **Timelines/roadmap**: dates, quarters, milestone names, "coming soon"
  items, explicitly stated deadlines.
- **Tech decisions**: named tools, frameworks, architecture choices,
  explicit "we decided to X because Y" statements — capture the decision and
  its stated rationale separately.
- Do not fabricate numbers or dates that aren't stated or clearly implied.
  If a figure is unclear or garbled (common in auto-generated captions),
  mark it `[unclear]` rather than guessing.

### 6. Cross-reference supplementary files

For any additional user-provided reference (slides, prior notes, pricing
sheets):

- Use it to disambiguate transcript content (spelling of product names,
  exact pricing, correct attribution).
- Do not treat it as a second independent transcript to summarize separately
  — it supports the primary transcript-derived narrative.
- Cite inline which claims came from a reference vs. the transcript itself
  when there's any ambiguity, e.g. `(per pricing sheet)`.

### 7. Generate the markdown output

Produce **one** markdown document with this structure:

```markdown
---
title: <session title>
source_files: [<list of input files used>]
date_analyzed: <ISO date>
presenters: [<names>]
---

# <Session Title> — Transcript Analysis

## Overview
<2-4 sentence summary of what the session was and why it matters>

## Presenters

| Name | Role | Approx. Share |
|---|---|---|
| ... | ... | ... |

## Key Sections

| Timestamp | Section | Summary |
|---|---|---|
| ... | ... | ... |

## Pricing

| Plan/Tier | Price | Billing | Notes |
|---|---|---|---|
| ... | ... | ... | ... |

## Roadmap / Timeline

| Date/Quarter | Milestone | Status | Source |
|---|---|---|---|
| ... | ... | ... | ... |

## Tech Decisions

| Decision | Rationale | Stated By |
|---|---|---|
| ... | ... | ... |

## Open Questions / Unclear Items
<anything marked [unclear], unresolved Q&A, or follow-ups mentioned>

## Notable Quotes
<optional — only if there are quotable, attributable statements worth preserving verbatim>
```

Omit any table section entirely (don't leave it empty) if the transcript has
no content for it — e.g. a pure demo with no pricing talk should have no
"Pricing" section at all.

### 8. Offer expansion or alternate summaries

After producing the primary document, offer — do not auto-generate unless
asked:
- A deeper expansion of any single section (e.g. full pricing breakdown with
  per-seat math, or a verbatim Q&A appendix).
- An alternate summary format for a different audience (e.g. an
  exec-summary-only version, or a sales-facing pricing one-pager).
- Regeneration with a narrower or wider section granularity if the initial
  segmentation doesn't match what the user expected.

Follow the user's `/gather`-style clarification pattern if the ask is
ambiguous (e.g. "summarize this" with no further detail) — surface the
above three expansion options as explicit choices with a recommendation,
rather than guessing scope.

## Output rules

- Single file output. Do not split into multiple markdown files unless the
  user explicitly asks for separate documents.
- No emojis, no em dashes.
- Do not fabricate presenter names, numbers, or dates not present in the
  source material or its references. State "not mentioned" or `[unclear]`
  instead of guessing.
- Preserve source attribution when reconciling conflicting information across
  multiple input files.
