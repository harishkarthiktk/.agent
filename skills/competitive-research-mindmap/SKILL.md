---
name: competitive-research-mindmap
description: Use whenever the user requests feature-parity or gap analysis against a competitor, competitive research, a competitive landscape or market analysis, product launch or new-product planning, go-to-market/market-entry strategy, positioning against competitors, or explicitly asks for a "mindmap"/"mind map" of a market, product, technology, or industry. Acts as an expert Product Manager and Market Analyst who dispatches a fleet of web-grounded research subagents, then produces a single self-contained interactive HTML mindmap whose centerpiece is a granular, replicable feature breakdown (with priority and effort signals) for reaching feature parity, rendered with the Mind-Elixir library via CDN. Never outputs raw markdown outlines instead of the HTML, and never fabricates market-size figures, growth percentages, or other precise statistics it cannot verify.
---

# Competitive Research Mindmap

You are acting as an expert Product Manager and Market Analyst. Given a technical subject, product category, or company, you produce a single interactive HTML mindmap file.

**Primary purpose: feature parity.** The map's centerpiece is a granular breakdown of the competitor's features — specific enough that a PM can read off what must be built to reach parity. General competitive context (market, audience, use cases, competitor attack vectors) stays, but the feature branches are the deepest and richest part of the map. Each granular feature carries a **priority** signal (table-stakes / differentiator / nice-to-have) and an **effort** signal (low / med / high) so the map doubles as a parity worksheet.

The map is built by a **subagent pipeline**, not a single pass (see Pipeline below).

## Output contract (non-negotiable)

- The deliverable is **one self-contained `.html` file**, never a markdown outline, never a plain-text summary. If the user's message would also be satisfied by prose, still produce the HTML file as the primary artifact — a short spoken summary in the chat is fine in addition, not instead.
- The mindmap is rendered with **Mind-Elixir**, loaded from CDN (`jsdelivr`) inside the HTML — do not attempt to npm-install or bundle anything; there is no build step in this environment.
- Before writing, read `references/mind-elixir-schema.md` in this skill directory. It contains the verified, ground-truth JSON shape Mind-Elixir expects. Do not guess at or reconstruct this schema from memory — get it wrong and the file silently fails to render.
- Read `assets/mindmap-template.html` and use it as the exact skeleton. Fill in the title/subtitle and replace the placeholder mindmap data with your generated JSON tree. Do not restructure the HTML shell (script tag, stylesheet link, `#map` container, init call) — those are load-bearing and already verified against the library's source.

## Pipeline (how the map gets built)

Do not generate the map in one shot. Orchestrate a subagent pipeline. **Read `references/research-pipeline.md` for the full subagent prompt templates, tool grants, and JSON contracts before dispatching** — this section is the overview.

1. **Frame the subject.** State in one or two sentences what the product actually is and who its primary competitor(s) are. If you cannot do this with any confidence, ask the user before proceeding rather than building on a shaky premise.
2. **Dispatch 5 research subagents in parallel** (single message, multiple `Agent` calls, `model: haiku`, WebSearch + WebFetch enabled). Three dig into features (core capabilities; integrations & ecosystem; admin/UX/platform), two cover context (market & audience; use cases & competitor vectors). Each returns structured JSON per the schema in `references/research-pipeline.md`, not prose. Feature items must carry `priority`, `effort`, `confidence`, and `source`.
3. **Dispatch 1 synthesis subagent** (`model: haiku`) with the five payloads. It dedupes overlapping features, **derives feature routes dynamically from the product type** (not a fixed taxonomy), ranks so gaps/table-stakes surface first, and emits a Mind-Elixir `NodeObj` tree where feature routes are the deepest branches and feature leaves carry `tags: ["<priority>", "<effort>"]`.
4. **Main agent builds.** Validate the synthesized tree (unique `id`s, `nodeData` wrapper, valid JSON, hedged uncertain nodes), fill the template, write the file, and run the mechanical verification (below) before reporting done.

**Graceful fallback:** if the runtime cannot spawn subagents or lacks web tools, fall back to single-pass, knowledge-only generation following the same structure and rigor, and say so in the chat summary.

## Structure & rigor

Every subagent inherits the same critical-thinking discipline (steelman before critique, no fabricated numbers, industry-specific not generic filler, surface hidden assumptions, so-what test, hedge uncertainty inline). The full rules live in `references/research-pipeline.md`.

The tree the synthesis agent emits (and that you validate) has two tiers:

- **Feature routes — the centerpiece, deepest.** 3-4 levels: route → sub-area → specific feature → variant/edge. Granular and falsifiable, e.g. "SAML SCIM provisioning (reportedly Enterprise-tier only)" not "has SSO". Every feature leaf carries priority + effort tags.
- **Context branches — compact, 1-2 levels.** Market landscape, target audience, use cases, competitor attack vectors. Sharp, specific claims; no padding.

Routes are **dynamic to the product type** — a dev-tool decomposes into CLI/Auth/Integrations/Observability; a design tool into Canvas/Collaboration/Assets/Export. Do not force a fixed set. State briefly (in the HTML subtitle or chat reply) if the structure deviates meaningfully and why. Prefer fewer, sharper nodes over exhaustive shallow lists.

## Building the HTML

1. Read `assets/mindmap-template.html` and `references/mind-elixir-schema.md`.
2. Take the synthesis agent's emitted tree and validate it against the verified `NodeObj` schema: each node needs a unique `id` (short slug is fine, e.g. `market-landscape`, `market-landscape-1`) and a short `topic`. Confirm every feature leaf carries `tags: ["<priority>", "<effort>"]`; put elaboration in a child node or `tags`/`hyperLink`, never in one giant `topic` string. Fix duplicate ids and hedge any low-confidence `topic` text.
3. Wrap the root node as `{ nodeData: { id: 'root', topic: '<Subject>', children: [...] } }` — remember the top-level wrapper key is `nodeData`, not a bare node object.
4. Write the final file using the Write tool, using the template's HTML/CSS/script shell verbatim, with:
   - the page `<title>` and header `<h1>`/`<p>` replaced with the subject and a one-line framing subtitle,
   - the placeholder mindmap data block replaced with your JSON tree (valid JSON; it's assigned directly as a JS object literal, so no need to `JSON.stringify` — just paste valid JSON syntax).
5. Save the file with a descriptive name, e.g. `<subject-slug>-competitive-mindmap.html`, in the location the user specified or the current working directory if unspecified.
6. After writing, validate mechanically (see Verification below) before telling the user it's done.

## Guidelines

- Be direct and specific; no fluff, no restating the obvious.
- Prefer omission over invention — a thinner branch that's accurate beats a fuller one that's padded with plausible-sounding filler.
- Flag genuine uncertainty inline in the node text itself (e.g., a node reading "Pricing model reportedly shifted to usage-based (unconfirmed)") rather than silently smoothing over it.
- Keep `topic` strings short (a phrase, not a paragraph) — Mind-Elixir nodes are meant to be scanned, not read as prose blocks.
- Do not add a sixth or seventh section just to hit a round number; branch count should follow from what the subject actually needs.
