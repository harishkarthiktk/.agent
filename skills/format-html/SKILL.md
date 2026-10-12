---
name: format-html
description: Use when converting markdown documents to HTML format. Provide raw markdown (file path or inline content) and generate clean, simple HTML body with inline CSS styling. Triggers on requests to "convert to HTML", "markdown to HTML", "generate HTML from markdown", or when markdown needs to be published as HTML.
compatibility: Requires Read/Write tools for file handling
---

## Overview

This skill converts markdown documents into simple, self-contained HTML with inline CSS. It:
- Parses markdown and converts to semantic HTML elements
- Applies inline CSS for clean, portable output
- Generates HTML body content only (no `<html>`, `<head>`, `<body>` wrapper tags)
- Preserves markdown structure and formatting
- Asks for approval before finalizing

## Process

### Step 1: Receive Input

The user provides either:
- A file path to a markdown file, or a file can be tagged as `@filename`
- Inline markdown text content

### Step 2: Parse and Convert

1. **Analyze markdown structure**: Identify headings, paragraphs, lists, code blocks, links, emphasis
2. **Plan CSS styling**: Default simple styles (fonts, spacing, colors) for readability
3. **Convert elements**:
   - `# Headings` → `<h1>`, `<h2>`, etc. with size/weight styling
   - `**bold**` → `<strong>` with weight
   - `*italic*` → `<em>` with style
   - `- lists` → `<ul>/<li>` with spacing
   - `` `code` `` → `<code>` with monospace/background
   - `[link](url)` → `<a href>` with color
   - Code blocks → `<pre><code>` with background
   - Paragraphs → `<p>` with line-height

### Step 3: Apply Inline CSS

Style rules applied inline on elements:

```css
/* Headings */
h1, h2, h3, h4, h5, h6 { font-weight: bold; margin: 1.2em 0 0.5em 0; }
h1 { font-size: 2em; }
h2 { font-size: 1.6em; }
h3 { font-size: 1.3em; }

/* Body text */
p { margin: 0.8em 0; line-height: 1.6; }

/* Lists */
ul, ol { margin: 0.8em 0 0.8em 2em; }
li { margin: 0.4em 0; }

/* Code */
code { font-family: monospace; background: #f5f5f5; padding: 0.2em 0.4em; }
pre { background: #f5f5f5; padding: 1em; overflow-x: auto; margin: 0.8em 0; }
pre code { background: none; padding: 0; }

/* Links */
a { color: #0066cc; text-decoration: none; }
a:hover { text-decoration: underline; }

/* Emphasis */
strong { font-weight: bold; }
em { font-style: italic; }
```

### Step 4: Generate HTML Body

Output is HTML content ONLY (no wrapper tags):

```html
<h1 style="font-weight: bold; margin: 1.2em 0 0.5em 0; font-size: 2em;">Title</h1>
<p style="margin: 0.8em 0; line-height: 1.6;">Paragraph text.</p>
<ul style="margin: 0.8em 0 0.8em 2em;">
  <li style="margin: 0.4em 0;">Item 1</li>
</ul>
```

Ready to paste into existing HTML documents or email templates.

### Step 5: Present and Get Approval

Show the generated HTML and ask:
- "Does this look correct?"
- "Any styling adjustments needed?"
- "Ready to save?"

### Step 6: Finalize

Once user approves:
1. Write the HTML to a `.html` file using Write tool
2. Provide the file path

## Example Input and Output

**Markdown Input:**
```markdown
# Getting Started

This is a **guide** to using our *amazing* tool.

## Installation

1. Download the package
2. Run setup
3. You're done!

See the [documentation](https://docs.example.com) for details.

```python
import tool
tool.start()
```
```

**HTML Output:**
```html
<h1 style="font-weight: bold; margin: 1.2em 0 0.5em 0; font-size: 2em;">Getting Started</h1>
<p style="margin: 0.8em 0; line-height: 1.6;">This is a <strong style="font-weight: bold;">guide</strong> to using our <em style="font-style: italic;">amazing</em> tool.</p>
<h2 style="font-weight: bold; margin: 1.2em 0 0.5em 0; font-size: 1.6em;">Installation</h2>
<ol style="margin: 0.8em 0 0.8em 2em;">
  <li style="margin: 0.4em 0;">Download the package</li>
  <li style="margin: 0.4em 0;">Run setup</li>
  <li style="margin: 0.4em 0;">You're done!</li>
</ol>
<p style="margin: 0.8em 0; line-height: 1.6;">See the <a href="https://docs.example.com" style="color: #0066cc; text-decoration: none;">documentation</a> for details.</p>
<pre style="background: #f5f5f5; padding: 1em; overflow-x: auto; margin: 0.8em 0;"><code style="font-family: monospace;">import tool
tool.start()</code></pre>
```

## Tips for Better Results

- If markdown has special formatting needs, ask user for custom CSS before converting
- Preserve all markdown structure; only add semantic HTML and inline styles
- Keep CSS simple and portable (works in email clients, docs, web)
- Code blocks preserve formatting exactly as written
- Links open in default behavior (no target=_blank unless requested)

## Common Use Cases

- Converting README.md to standalone HTML
- Generating HTML email newsletters from markdown
- Creating portable documentation snippets
- Converting meeting notes to shareable HTML format

---

## Implementation Notes

- Always read the full markdown before converting to identify all element types
- Apply inline styles directly on each element (no `<style>` tags)
- Preserve markdown line breaks and spacing intent
- If markdown is malformed, note it and ask for clarification
- Output contains ONLY the HTML body content - no doctype, html, head, or body tags
