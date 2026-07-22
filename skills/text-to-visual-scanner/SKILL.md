---
name: text-to-visual-scanner
description: >
  Analyzes a document to identify sections that could be replaced or supplemented
  by visual components (diagrams, mindmaps, flowcharts, timelines, etc.).
  Produces a markdown report with line/paragraph references, recommended visual type,
  and a content brief for each identified opportunity.
  
  Use this skill whenever reviewing or working with technical specs, architecture docs,
  process documentation, requirements, or educational content with dense text. Trigger on:
  "visualize", "diagram", "reduce text", "make clearer", "hard to follow", or anytime
  you spot sequences, hierarchies, comparisons, or data that could scan faster as a visual.
  Also suggest proactively when a user shares dense documentation that would benefit from
  visual breakdown.
---

# Text-to-Visual Scanner

Given a document, scan through it and identify passages that would benefit from
being converted into a visual component. For each opportunity found, produce a
structured entry that can serve as a creative brief for someone (or an AI) to
create that visual later.

## What to look for

Scan the document for these patterns. Not every match needs to be flagged — use
judgment. A two-sentence sequence doesn't need a flowchart. Focus on passages
where a visual would genuinely improve comprehension, reduce cognitive load, or
replace a dense wall of text.

| When you see... | Consider suggesting... |
|---|---|
| Sequential steps, processes, workflows, how-to instructions | Flowchart |
| Hierarchies, taxonomies, nested categories, parent-child relationships | Mindmap or tree diagram |
| Comparisons, pros/cons, trade-offs, feature matrices | Comparison table or matrix |
| Chronological events, dated milestones, historical progressions | Timeline |
| Entities with attributes and relationships between them | Entity-relationship or class diagram |
| System components interacting, data flows, request paths | Architecture diagram |
| Numerical trends, statistics buried in prose, before/after numbers | Bar chart, line chart, or pie chart |
| Cause-and-effect chains, multiple contributing factors | Causal loop or fishbone diagram |
| Spatial layouts, geographic relationships, floor plans | Map or spatial diagram |
| Cycles, feedback loops, iterative processes | Cycle diagram |
| Decision trees, if-then logic, branching conditions | Decision tree |
| Layers of abstraction, stacked concepts, dependency chains | Layered diagram or dependency graph |

## Brief examples by visual type

To see what quality briefs look like, here are minimal examples:

**Flowchart brief:** "User login flow: User enters credentials → System validates
against DB → On match, create session and redirect to dashboard; on mismatch,
display error and allow 3 retry attempts before locking account for 15 minutes."

**Mindmap brief:** "Deployment considerations: Performance (caching, CDN, DB indexing),
Security (auth, encryption, rate limits), Reliability (monitoring, backups, failover),
Compliance (logging, data retention, GDPR)."

**Timeline brief:** "API versioning history: v1 (2020) → v2 (2021, breaking changes) →
v3 (2023, GraphQL support) → Current: v4 (2024, streaming). Each version includes
deprecation period of 12 months."

Use these as quality standards — your briefs should be similarly concrete and specific.

## Output format

Produce a single markdown file. Structure it as follows:

### Report header

Start with a brief summary: document name (if known), total opportunities found, and
a one-sentence overview.

### Per-opportunity entry

For each identified opportunity, use this exact structure:

```markdown
## [Numeric ID]: [Short Descriptive Title]

- **Location:** [line numbers or paragraph reference, e.g., "Lines 12-18" or "Paragraph starting with 'The system processes...'"]
- **Visual type:** [Flowchart / Mindmap / Timeline / etc.]
- **Excerpt:** > [Quote the relevant text — keep it short, just enough to identify the passage]
- **Visual content brief:** [Describe what the visual should show. Include:
  - The key elements/nodes/entities that should appear
  - How they relate to each other
  - Any sequence, hierarchy, or grouping that matters
  - Specific labels, values, or data points to include
  - The main insight the visual should convey at a glance]
```

### Ordering

List opportunities in the order they appear in the source document. If the document
is long, consider grouping related opportunities under a higher-level heading for
that section of the document.

## Principles

**Be selective.** A document might have 50 things that *could* be visualized. Flag
the ones where a visual actually adds value — where the text is dense, confusing,
or where a diagram would make the point faster than reading. Aim for quality over
quantity.

**Be specific in the brief.** "A flowchart showing the login process" is weak.
"A flowchart showing: User enters credentials → System validates → On success,
redirect to dashboard; on failure, show error and allow retry (max 3 attempts) →
On 3rd failure, lock account for 15 minutes." That gives whoever creates the visual
enough detail to work with.

**Brief length target:** 2-4 sentences. Aim for complete specificity without
copy-pasting the source. Include key elements, relationships, labels, and numbers —
but condensed. If you're writing more than 5 sentences, distill it by removing
supporting context and keeping only what the visual must show.

**Preserve the document's own terminology.** If the document calls something a
"Thingamajig Processing Engine," use that exact term in the brief. Don't genericize.

**Don't repeat the document.** The brief should be a distillation, not a
copy-paste. Extract what matters for the visual and leave the surrounding prose
behind.

## Next steps: Turning briefs into visuals

This skill identifies and briefs visualization opportunities — it does not generate
the visuals themselves. After producing a report, hand off to a diagram-generation
skill to create the actual visual:

- **Flowchart / decision tree / sequence / architecture diagrams** → Use `design-doc-mermaid`
  (for Mermaid-format diagrams) or `excalidraw-diagram-generator` (for editable drawings).
- **Mindmap / hierarchy / entity-relationship diagrams** → Use `excalidraw-diagram-generator`.
- **Numerical charts / trends / dashboards** → Use `dataviz` (with proper design system
  and color handling).
- **Lightweight SVG diagrams / org charts / network diagrams** → Use `svg-architect`.

The user decides whether and which skill to hand off to — this scanner only surfaces
opportunities and briefs.
