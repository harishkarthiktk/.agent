# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

The `review-write` skill is a multi-agent writing review system. It orchestrates parallel subagents to analyze different aspects of written content (narrative structure, tone, substance, CTAs) and synthesizes their findings into collaborative feedback. The design prioritizes teaching over auto-correction.

## How It Runs

This skill is plain markdown - there is no build, test, or lint step. Claude executes it by reading `SKILL.md` and following the 3-phase flow, loading `references/NN-*.md` on demand. Verify changes by invoking the skill on a sample draft: confirm it asks gather questions first, locks metadata, dispatches the four Phase-2 subagents, then returns synthesized git-diff-style feedback without rewriting the whole piece. Keep `references/` path citations in sync when renaming files - dangling `NN-*` references silently break the dispatch.

## Architecture

The skill follows the standard skill layout: a `SKILL.md` entry point plus on-demand `references/` files (progressive disclosure).

**Master Orchestration** (`SKILL.md`)
- Carries the YAML frontmatter (`name`, `description`) that makes the skill discoverable and triggerable
- Defines the 3-phase execution model: Initialize → Parallel Review → Synthesis
- Specifies Editor-in-Chief output constraints (git-diff format, no full rewrites, explain the mechanism of failure)
- Governs conflict resolution when subagent advice conflicts
- Dispatches the Phase 2 subagents on the same model as the parent agent unless the user specifies otherwise

**Initialization Phases** (`references/01-gather-phase.md`, `references/02-grounding-reference.md`)
- Phase 1: Extract user intent (audience, format, tone) to lock metadata
- Phase 2: Build a temporary style guide from reference materials (if provided)
- Both must complete before parallel subagents can execute

**Parallel Subagents** (`references/03` through `references/06`)
- Each subagent focuses on one review dimension
- Each outputs findings to hidden scratchpads (not user-visible until synthesis)
- Subagents operate independently and do not communicate with each other

**Key Constraints**
- Never rewrite the article for the user
- Always explain the "why" behind feedback
- Highlight weak spots with before/after snippets of *only that section*
- Resolve structural conflicts in the synthesis phase (don't defer to the user)

## Design Decisions

**Modular Phases:** Each `references/NN-*.md` file is a self-contained prompt for a specific review phase. This allows reordering, adding, or removing phases without breaking the master orchestration in `SKILL.md`.

**Metadata Lock:** Phases 01 and 02 must execute sequentially and finish before parallelization. The metadata (audience, format, tone, style guide) becomes immutable context for all downstream agents.

**No Auto-Rewrite:** The system is designed to teach the writer, not replace them. This means feedback must be surgical (specific line/paragraph references) and pedagogical (explain the mechanism, not just the fix).

## Extending the System

To add a new review phase:
1. Create a new file `references/NN-phase-name.md` following the existing template
2. Define the **Purpose**, **Evaluation Criteria**, and scratchpad **Output** sections
3. Update the Phase 2 dispatch table in `SKILL.md` to include the new dimension
4. Ensure the new phase's output format is compatible with the Editor-in-Chief's synthesis expectations

To customize for a specific content type (e.g., technical documentation, marketing copy):
- Extend `references/02-grounding-reference.md` to extract additional style guide dimensions
- Modify the narrative frameworks in `references/03-narrative-hook.md` to include domain-specific patterns
- Adjust CTA evaluation criteria in `references/05-cta-conversion.md` to match content intent

## Integration Notes

- Subagents should write findings to scratchpads using consistent formatting (line numbers, clear categorization)
- The Editor-in-Chief resolves conflicts by re-prioritizing based on the article's stated intent (from Phase 01)
- If a user provides no reference materials in Phase 02, the system relies entirely on Phase 01 metadata as the grading rubric
