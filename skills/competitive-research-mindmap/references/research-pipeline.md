# Research pipeline (subagent contracts)

This mindmap is built by a **fleet of subagents**, not in a single pass. The main agent orchestrates;
Haiku subagents do the research and structuring. Read this file before dispatching.

Total subagents: **5 research (parallel) + 1 synthesis (after)**, all `model: haiku`.

The primary purpose of the map is **feature parity**: surface granular, replicable features so a PM
can see what must be built to match the competitor. General competitive context stays, but features
are the centerpiece — the deepest, richest branches.

## Shared rigor rules (inject into every subagent prompt)

Every subagent inherits the same critical-thinking discipline:

1. **Steelman before critique** — describe what each real competitor is genuinely good at and why a
   customer would rationally choose it. No strawmen.
2. **No fabricated numbers** — never state market size, CAGR, revenue, user counts, or growth
   percentages as precise figures without genuine grounding. Describe trends narratively.
3. **Be specific per industry, not generic** — "growing market with increasing competition" is
   banned filler. Name the actual dynamic or omit the claim.
4. **Surface hidden assumptions** in the subject's premise rather than silently building on them.
5. **So-what test** — every item must inform a real decision (build/skip, prioritize, position).
   Cut true-but-irrelevant items.
6. **Hedge uncertainty inline** — if a claim is not confidently verified, mark `confidence` low and
   phrase the item hedged ("reportedly", "as of <date>"). Prefer omission over invention.
7. **Return JSON only** — the payload schema below, no prose wrapper, no markdown.

## Grounding: live web

Each research subagent is granted **WebSearch** and **WebFetch** and must use them to ground feature
lists and positioning against the current product (docs, pricing pages, changelogs, comparison
pages). Cite the source in each item's `source` field. If a claim rests only on training knowledge,
set `source: "training-knowledge"` and lower `confidence`.

## The 5 research subagents

Dispatch all five in **one message, parallel** (`model: haiku`, WebSearch + WebFetch enabled). Give
each the subject, the identified primary competitor(s), and the shared rigor rules above.

| # | Role | Focus |
|---|------|-------|
| A | Feature — core capabilities | The primary jobs the product does. Its central, headline features and their sub-variants/edge behaviors. |
| B | Feature — integrations & ecosystem | Third-party integrations, APIs/SDKs, marketplace/plugins, import/export, interop, extensibility. |
| C | Feature — admin, UX & platform/ops | Admin/permissions/governance, collaboration, UX affordances, platform coverage (web/mobile/desktop/CLI), security/compliance, observability/ops. **Adapt these axes to the actual product type** — drop axes that don't apply, add ones that do. |
| D | Context — market & audience | Market landscape (adjacent categories, what's converging/fragmenting) + who actually buys/uses this, segmented by role/use pattern. |
| E | Context — use cases & competitor vectors | Concrete jobs-to-be-done ranked by centrality + for each real competitor, steelmanned strengths and exploitable weaknesses. |

Feature agents (A/B/C) must go **granular**: not "has integrations" but the specific integrations
that matter, with parity-relevant detail. This granularity is the point of the whole map.

## Research payload schema (what each subagent returns)

```jsonc
{
  "agent": "A|B|C|D|E",
  "role": "core-capabilities | integrations-ecosystem | admin-ux-platform | market-audience | usecases-competitor-vectors",
  "summary": "1-2 sentence framing of what this agent found",
  "features": [                     // REQUIRED for A/B/C; usually empty for D/E
    {
      "area": "sub-area / route this belongs to (e.g. 'Auth', 'Reporting')",
      "name": "specific granular feature",
      "detail": "short parity-relevant specifics (variant/edge), keep tight",
      "priority": "table-stakes | differentiator | nice-to-have",
      "effort": "low | med | high",   // rough build effort to replicate
      "confidence": "high | med | low",
      "source": "url or 'training-knowledge'"
    }
  ],
  "context": [                      // REQUIRED for D/E; empty for A/B/C
    {
      "branch": "market | audience | usecases | competitor-vectors",
      "point": "specific, non-generic claim",
      "competitor": "name if applicable, else null",
      "confidence": "high | med | low",
      "source": "url or 'training-knowledge'"
    }
  ]
}
```

## The synthesis subagent

After all 5 payloads return, dispatch **one** synthesis subagent (`model: haiku`). Input: the subject,
the product type, and the five JSON payloads. It must:

1. **Dedupe & merge** overlapping features across A/B/C (same feature reported twice → one node, keep
   highest confidence + cite both sources if useful).
2. **Derive dynamic feature routes from the product type** — infer the natural functional
   decomposition for *this* product class (e.g. a dev-tool → CLI / Auth / Integrations /
   Observability; a design tool → Canvas / Collaboration / Assets / Export). Do NOT force a fixed
   taxonomy. Group the granular features under these routes.
3. **Rank** so gaps and table-stakes surface first within each route.
4. **Emit a Mind-Elixir `NodeObj` tree** (see `mind-elixir-schema.md`) where:
   - Feature routes are the **deepest, richest branches**: 3-4 levels
     (route → sub-area → specific feature → variant/edge).
   - Context branches (market, audience, use cases, competitor vectors) are **compact**: 1-2 levels.
   - Every **feature leaf** carries `tags: ["<priority>", "<effort>"]`, e.g.
     `tags: ["table-stakes", "low"]`.
   - Low-confidence items are phrased hedged in the `topic` text.
   - Every node has a unique `id` (slug) and a short `topic`.

### Synthesis output contract

Return **only** JSON: the node tree as the `children` array of root, plus a suggested root topic and
one-line subtitle:

```jsonc
{
  "rootTopic": "<Subject> — Feature Parity Map",
  "subtitle": "one-line framing; note any deviation from default structure",
  "children": [ /* NodeObj[] — feature routes first, then compact context branches */ ]
}
```

The main agent wraps this as `{ nodeData: { id: 'root', topic: rootTopic, children } }`, validates
(unique ids, valid JSON, hedged uncertainty), fills the template, and verifies render.

## Graceful fallback

If the runtime cannot spawn subagents or lacks web tools, the main agent falls back to **single-pass,
knowledge-only** generation following the same structure and rigor rules, and **states this
limitation** in the chat summary (findings may be stale; numbers omitted, claims hedged).
