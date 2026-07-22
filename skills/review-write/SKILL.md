---
name: review-write
description: >-
  Multi-agent writing review that critiques a draft across narrative, structure, CTA, and substance,
  then synthesizes collaborative, teach-don't-rewrite feedback. Use this whenever the user shares a
  piece of writing - an article, blog post, essay, newsletter, sales proposal, marketing copy,
  landing page, or product announcement - and wants it reviewed, edited, critiqued, tightened,
  sharpened, or made more compelling. Trigger it even when the user does not say "review": phrases
  like "give me feedback on this draft", "how can I improve this post", "does this land?", "make this
  punchier", or simply pasting a draft and asking what's weak all qualify. Do NOT use it for
  generating new writing from scratch or for code review.
---

# review-write: Editor-in-Chief Orchestration

- This skill runs a multi-agent writing review. It is a collaborative mentor, not an auto-writer 
- The goal is to teach and sharpen the user's own skills, and not to rewrite their piece for them.
- Tasks are parallelized and compartmentalized to preserve context and speed up execution.
- Edits to the documents are to be done only with user supervision after all the 3 phase models are completed.

## The 3-Phase Model

### Phase 1 - Initialize (sequential, must finish before Phase 2)

Run these in order. Their output becomes immutable context for every downstream agent.

1. **Gather intent** - Follow `references/01-gather-phase.md` to lock in audience, primary
   goal/format, and tone. Ask the user smart, concise questions. Do not proceed until this metadata
   is locked.
2. **Ground references** - Follow `references/02-grounding-reference.md` to build a temporary style
   guide from any reference materials the user provides. If none are provided, the Phase 1 metadata
   becomes the entire grading rubric.

### Phase 2 - Parallel Review (subagent dispatch)

Dispatch four subagents **in a single turn** so they run concurrently. Each one reviews one
dimension and reads only its own reference file, plus the locked metadata and style guide from
Phase 1:

| Subagent | Reference file | Reviews |
|----------|----------------|---------|
| Narrative & Hook | `references/03-narrative-hook.md` | Story arc, framework fit, time-to-value |
| Structural Integrity | `references/04-structural-integrity.md` | Visual rhythm, pacing, tone curve |
| CTA & Conversion | `references/05-cta-conversion.md` | Conclusion, call-to-action, the bridge |
| Substance & Credibility | `references/06-substance-credibility.md` | Evidence, fluff, unique POV |

**Model:** each subagent must run on the **same model the parent (this) agent is using**, unless the
user has explicitly asked for a different model.

**Scratchpads:** each subagent writes its findings to its own hidden scratchpad (use the session
scratchpad directory) with exact line/paragraph references. These are NOT shown to the user yet -
raw per-dimension findings would overwhelm and contradict each other. Synthesis happens in Phase 3.

The subagents operate independently and do not communicate with each other.

### Phase 3 - Synthesis (Editor-in-Chief)

Read every subagent scratchpad, then produce the single user-facing response.

**Resolve conflicts - do not defer them to the user.** Re-prioritize by the article's stated intent
from Phase 1. Example: if Structural Integrity wants to cut a paragraph for rhythm but Substance
wants to add evidence to it, resolve it - "Add the missing evidence, but format it as a bulleted
list so the rhythm is preserved."

## Editor-in-Chief Output Constraints

These constraints are what make the feedback teach rather than replace. Honor them exactly:

- **Format:** Present tactical edits in a git-diff style, grouped by line or paragraph.
- **No full rewrites:** Never rewrite the article for the user. For large narrative or structural
  changes, be descriptive - explain the *why* and give a brief, targeted example of how to execute
  the change, not a wholesale replacement.
- **Explain the mechanism:** For each weak spot, explain *why* it fails (the mechanism), then show a
  before/after snippet of *only that section* to demonstrate the fix. The writer should understand
  the principle, not just copy a patch.

## Extending the System

To add a review dimension, create a new `references/NN-name.md` (with **Purpose**, **Evaluation
Criteria**, and a scratchpad **Output** instruction), then add it to the Phase 2 dispatch table
above. Keep its output format compatible with the synthesis expectations.
