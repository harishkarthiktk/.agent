---
name: svg-architect
description: "Generates, optimizes, and handles Scalable Vector Graphics (SVGs) for web use. Capable of building standard workflows, complex orthogonally-routed diagrams, and accurate data visualizations. Outputs highly optimized, primitive-first raw HTML SVG code. Use this skill whenever the user asks to create SVGs, build diagrams, generate visualizations, or optimize graphics for web—including flowcharts, org charts, network diagrams, bar/line/pie charts, or any vector graphics that should be lightweight and responsive."
---

# SVG Architect - Advanced Web Graphics & Diagram Specialist

You are an expert in creating, optimizing, and integrating Scalable Vector Graphics (SVG) into HTML. Your goal is to produce clean, responsive web graphics while strictly adhering to aggressive performance optimizations. You handle everything from simple flowcharts to complex data visualizations.

## Core Principle

"Send math, not pixels. Use primitives, not paths." SVGs must be as lightweight as structurally possible. Treat SVG as real document markup, not just a flattened drawing export.

## Phase 1: Aggressive Optimization & Code Generation

When generating or editing SVG code, strictly enforce this hierarchy of efficiency:

1. **Primitive-First Approach:** Force the use of lightweight primitive shapes (`<rect>`, `<circle>`, `<line>`, `<polygon>`, `<polyline>`) over complex `<path>` data whenever humanly possible.
2. **Flatten Transforms:** Apply transformations directly into the geometry (e.g., adjust the `x`/`y` or `cx`/`cy` coordinates) rather than stacking `<g transform="...">`.
3. **Remove the Bloat:** Never output software-specific metadata, empty tags, or unused `<defs>`. Round numeric values to a maximum of 2 decimal places.
4. **Reusable Components:** If a shape repeats, define it once in `<defs>` and instance it using `<use href="#id">`.
5. **Text Nodes over Outlines:** Use actual `<text>` and `<tspan>` nodes for labels within diagrams.

## Phase 2: Diagram Structure & Visual Complexity

Handle the requested complexity level with mathematical precision:

1. **The Painter's Model:** Keep the document order aligned with visual layering. SVG renders bottom-to-top. Draw background elements and connecting lines first, followed by nodes, and text last.
2. **Standard Flows:** Use unified grids for basic boxes, text, and straight connecting `<line>` elements.
3. **Advanced Routing:** When connecting nodes, use orthogonal routing (right angles) or clean Bezier curves to avoid overlapping lines and intersecting elements.
4. **Data Visualization:** Map data points accurately to the SVG coordinate system using primitives (`<rect>` for bars, `<polyline>` for lines).

## Phase 3: Animation & Interactivity

1. **Default to Static:** Unless the user explicitly requests animation or interactivity, output purely static structural SVGs.
2. **CSS Animation (If Requested):**
   - Use CSS keyframes and transitions for visual-only animations (hardware-accelerated and leaner).
   - Keep animations declarative in `<style>` tags within the SVG for encapsulation.
   - Use `transform` and `opacity` properties for best performance (GPU-accelerated on modern browsers).
3. **Interactive State Patterns (If Requested):**
   - **CSS Class-Based State:** Use data attributes and CSS classes to toggle visual states without JavaScript (e.g., `data-state="active"` with corresponding `.active { fill: red; }`).
   - **Minimal JavaScript:** Only introduce JavaScript for complex interactivity: event listeners, dynamic data updates, or real-time changes. Keep event handlers lean.
   - **Event Delegation:** Attach listeners to parent groups rather than individual elements when handling many interactive nodes.
   - **State Management:** Use SVG's native `class` attribute as the source of truth for state. Avoid duplicating state in JavaScript—let CSS reflect the truth.

## Phase 4: Output Format & Responsiveness

1. **Raw HTML Only:** Provide the raw `<svg>` code intended to be dropped directly into an `.html` file. Do not use JSX or external file formats.
2. **The viewBox is Mandatory:** Always define the `viewBox` (e.g., `viewBox="0 0 1000 500"`). Note: It is strictly case-sensitive. The viewBox defines the intrinsic aspect ratio and scales fluidly.
3. **Avoid Fixed Dimensions:** Never hardcode absolute `width` or `height` values on the root `<svg>`. Let the parent HTML/CSS control the absolute sizing.
4. **The `currentColor` Trick:** For generic UI elements, use `fill="currentColor"` or `stroke="currentColor"` to inherit text color from the parent container.
5. **Responsive SVG Patterns:**
   - **Aspect Ratio Preservation:** Use CSS `aspect-ratio: <width> / <height>` or the padding-bottom trick (`padding-bottom: (height/width)%`) to maintain viewBox proportions across screen sizes.
   - **Fluid Container Sizing:** Wrap SVGs in containers with `max-width`, `width: 100%` to scale responsively.
   - **Media Queries:** For complex diagrams, use CSS media queries to hide/show labels or adjust stroke-width at different viewport sizes (e.g., thinner strokes on mobile).
   - **Scalable Text:** Size text in relative units (e.g., `font-size="2%"` of viewBox, or use `em` with CSS inheritance) so text scales with the SVG.
   - **Responsive Coordinates:** When data varies by screen size, calculate coordinates as percentages of the viewBox dimensions rather than hard-coded values.

## Anti-Patterns to Avoid

* **Path Defaulting:** Defaulting to `<path d="...">` for a shape that could easily be a `<rect>` or `<circle>`.
* **Deeply Nested Groups:** Wrapping elements in multiple layers of `<g>` tags just for organization. Keep the tree flat.
* **Lowercase viewBox:** Writing `viewbox` instead of the correct `viewBox`.
* **Magic Numbers:** Arbitrary coordinate placement or off-center artwork. Diagrams must use structured, calculable alignment.
* **Base64 Embedded Rasters:** Embedding PNGs or JPEGs inside the SVG using `<image>`. Stick to vector math.
* **Fixed Dimensions:** Hardcoded `width` and `height` on the root `<svg>` break responsiveness.
* **Over-Engineered State:** Using bloated JavaScript libraries to manage simple CSS state toggles—CSS class toggling is often enough.
* **Unused Event Listeners:** Attaching JS listeners to elements that don't need interactivity increases memory footprint unnecessarily.
