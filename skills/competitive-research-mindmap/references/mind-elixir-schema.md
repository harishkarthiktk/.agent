# Mind-Elixir data schema (verified from source, mind-elixir-core)

Do not deviate from this shape — it was confirmed against `src/types/index.ts` and the built `dist/MindElixir.js` in the `SSShooter/mind-elixir-core` repository, not assumed from memory.

## Top-level data passed to `mind.init(data)`

```ts
type MindElixirData = {
  nodeData: NodeObj        // REQUIRED — the root node. NOT a bare node object at the top level.
  arrows?: Arrow[]         // optional, omit unless cross-branch links are genuinely useful
  summaries?: Summary[]    // optional, omit
  direction?: 0 | 1 | 2 | 3
  theme?: Theme            // optional, omit — rely on default theme + template CSS
  compact?: boolean
  meta?: Record<string, any>
}
```

The most common mistake is passing a bare node (`{ topic, id, children }`) as the whole `data` argument. This will not render. Always wrap it: `{ nodeData: { ...root node... } }`.

## Node shape (`NodeObj`, recursive via `children`)

```ts
interface NodeObj {
  topic: string             // REQUIRED — visible label text, keep short
  id: string                // REQUIRED — unique across the whole tree
  children?: NodeObj[]      // nested nodes, same shape, recursively
  style?: {
    fontSize?: string
    fontFamily?: string
    color?: string
    background?: string
    fontWeight?: string
    width?: string
    border?: string
    textDecoration?: string
  }
  tags?: (string)[]         // small labeled chips on the node, optional
  icons?: string[]          // emoji, optional
  hyperLink?: string        // optional link out (e.g. to a competitor's site)
  expanded?: boolean        // defaults to true; set false to start a branch collapsed
}
```

## Parity signals via `tags` (this skill's convention)

Every **feature leaf** carries exactly two `tags`: a priority and an effort value, in that order:

```jsonc
{
  "id": "auth-scim",
  "topic": "SAML SCIM provisioning (reportedly Enterprise-tier only)",
  "tags": ["table-stakes", "low"]   // priority: table-stakes|differentiator|nice-to-have ; effort: low|med|high
}
```

- Priority vocabulary: `table-stakes`, `differentiator`, `nice-to-have`.
- Effort vocabulary: `low`, `med`, `high`.
- Optionally use `icons` (a single emoji) as a quick gap marker if useful — do not overload.
- Keep the parity signal in `tags`, never baked into the `topic` string. `topic` stays short and
  scannable; the tags render as chips on the node.

## CDN embed (confirmed working, no bundler required)

```html
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/mind-elixir/dist/style.css" />
...
<script type="module">
  import MindElixir from 'https://cdn.jsdelivr.net/npm/mind-elixir/dist/MindElixir.js'
  const mind = new MindElixir({ el: '#map', direction: MindElixir.SIDE })
  mind.init({ nodeData: { id: 'root', topic: 'Root', children: [] } })
</script>
```

`MindElixir.LEFT === 0`, `MindElixir.RIGHT === 1`, `MindElixir.SIDE === 2` (branches radiate both sides of root — generally the best default for a multi-branch competitive-research mindmap).

## Minimal valid example

```json
{
  "nodeData": {
    "id": "root",
    "topic": "Example Subject",
    "children": [
      {
        "id": "branch-1",
        "topic": "Market Landscape",
        "children": [
          { "id": "branch-1-1", "topic": "Adjacent category X is converging in" }
        ]
      }
    ]
  }
}
```
