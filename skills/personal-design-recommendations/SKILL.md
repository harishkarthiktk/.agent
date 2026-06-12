---
name: personal-design-recommendations
description: Provides actionable design recommendations for creating reusable, simple designs that generate better code. Covers component structure, naming conventions, design tokens, and layout patterns that help AI assistants produce consistent, maintainable code. Works with any design tool or framework.
allowed-tools: None
user-invocable: true
---

# Design Recommendations

## What This Does

Provides targeted recommendations for structuring your design files to enable better code generation and maintain design-to-code consistency. Covers best practices for components, naming, variables, layout, and documentation.

## How to Use

Invoke with a question or area you want recommendations for:

```
/design-recommendations components and naming
/design-recommendations how to organize my design file
/design-recommendations spacing and layout
```

## Instructions

When the user invokes `/design-recommendations [topic]`:

1. Identify the design area or challenge they're asking about
2. Provide focused recommendations from these key areas:

### Use Components
- Suggest converting repeated patterns (buttons, cards, inputs, nav items) into components
- Explain how components enable reuse and consistency across your design and code
- Recommend creating a component hierarchy (atoms, molecules, organisms if helpful) with clear naming
- Note that well-documented components help AI systems generate accurate, maintainable code
- Suggest designing components to be modularly independent (avoiding unnecessary interdependencies)
- Include specifications for component variants, states (hover, active, disabled), and keyboard interactions
- Document accessibility requirements for each component (ARIA roles, focus management, screen reader text)

### Link Components to Code (Code Connect)
- This is the primary way to ensure code consistency with design
- Without proper linking, code generation relies on AI inference
- Recommend establishing clear mapping between design components and code components
- Suggest version-controlled component documentation

### Use Design Tokens and Variables
- Recommend applying design tokens or variables for spacing, color, radius, and typography
- Explain how tokens create a single source of truth across your design system
- Suggest semantic naming (e.g., spacing-sm, color-primary, radius-md)
- Note how tokens reduce redundancy and improve maintainability across tools and implementations

### Use Clear, Semantic Names
- Replace auto-generated names (Frame1268, Group5) with intent-driven ones
- Examples: CardContainer, ProductImage, CTA_Button, FormInput
- Explain how naming helps AI understand what it's working with and what functionality to implement
- Suggest naming conventions (e.g., ComponentType_Purpose_State)

### Use Constraint-Based or Responsive Layouts
- Recommend using constraint-based or responsive layout systems for predictable layouts
- Explain how it avoids absolute positioning and communicates layout intent to code
- Suggest testing layouts at different sizes to verify responsive behavior before code generation
- Note that well-structured layouts typically result in cleaner, more predictable generated code

### Use Annotations
- Recommend adding annotations to convey design intent that's hard to capture visually
- Include how something should behave (interactive states, animations)
- Document alignment rules, responsive breakpoints, and transitions
- Suggest using annotations for accessibility notes and interactions

### Documentation and Developer Resources
- Recommend linking to or documenting component specifications, design system references, or style guides
- Suggest including usage guidelines, accessibility notes, and implementation patterns
- Note that clear documentation provides context for more informed code generation and team alignment

### Build for Accessibility
- Include semantic HTML elements, ARIA attributes, and keyboard navigation in design specifications
- Recommend color combinations that meet WCAG AA contrast ratios (4.5:1 for normal text)
- Suggest theme variants (light, dark, high-contrast) designed for different user needs
- Document focus indicators, keyboard interactions, and screen reader expectations
- Note that accessible design is essential for legal compliance and inclusive user experiences

### Three-Tier Token Architecture
- Recommend organizing tokens into three layers: Primitives (raw values), Semantic (contextual references), and Component-specific
- Example: Create primitive tokens like `color-blue-500`, then map to semantic token `color-brand-primary`, then use in components
- Explain how this structure allows easy theme switching and reduces maintenance burden
- Suggest exporting tokens in W3C Design Token Community Group format for cross-platform compatibility

### Support Flexible Component Composition
- Recommend building components with composition patterns (compound components, slots) rather than fixed rigid structures
- Suggest clear prop interfaces showing required vs. optional parameters
- Explain how flexibility enables better code generation and easier adaptation to different use cases
- Note that modular components without interdependencies are easier for AI systems to generate and reuse

3. Provide 2-3 recommendations most relevant to their question
4. Use concrete examples from their specific context if they mention a design challenge
5. Explain the "why" - how each recommendation improves code generation or maintainability
6. Keep recommendations actionable and implementable

## Examples

**User:** /design-recommendations naming conventions

**Claude:** Provides recommendations like:
- Replace "Group45" with semantic names like "HeaderNavigation" or "AuthForm"
- Use component-type prefixes (Button_Primary, Card_Product, Input_Email)
- For variants/states, add suffixes (Button_Primary_Hover, Button_Primary_Disabled)
- Document your naming system so AI assistants understand your intent

**User:** /design-recommendations how do I structure for code generation

**Claude:** Recommends starting with:
1. Create components for all reusable patterns
2. Apply variables to spacing, color, and typography
3. Name layers semantically to match code structure
4. Use Auto Layout to communicate responsive intent
5. Add annotations for complex interactions

## Design for AI-Assisted Code Generation

When structuring designs for optimal code generation:

1. **Explicit Intent**: Use semantic names and annotations to communicate functionality, behavior, and state
2. **Token-First Approach**: Define design tokens before creating components - ensure all spacing, colors, and typography use tokens
3. **Complete Specifications**: Include all component states (default, hover, active, disabled, focus, error) in your design
4. **Clear Variants**: Use component variants to show different prop combinations - helps AI understand configuration options
5. **Keyboard & Interaction Design**: Annotate interactive elements with keyboard shortcuts, focus indicators, and expected behaviors
6. **Responsive Clarity**: Show how layouts adapt at different breakpoints - use constraint-based layout systems when possible
7. **Accessibility First**: Include ARIA requirements, color contrast notes, and screen reader text in component specifications

## Important Notes

- Recommendations should be practical and implementable across any design tool
- Focus on design structure that enables better code generation and consistency
- Explain the connection between design decisions and code quality
- Provide context about why each recommendation matters - the "why" helps AI understand design intent
- Offer to go deeper into any specific area if user asks
- Emphasize that simple, clear, reusable designs are easier for AI to understand and generate correctly
- Encourage documentation that bridges design intent and code implementation
