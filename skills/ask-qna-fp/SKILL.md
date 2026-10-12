---
name: ask-qna-fp
description: Using AskUserQuestion with First Principles philosophy to break down ambiguity to fundamentals, bring clarity, handle edge cases, and guide decisions through structured multi-option interactions. Works both standalone and within plan mode.
allowed-tools: Bash
model: haiku
user-invocable: true
---

# Ask QnA Skill

## What This Does

This skill demonstrates First Principles-based questioning using `AskUserQuestion` to:
- Break ambiguity down to fundamental assumptions and unknowns
- Question what is actually true vs. what is assumed
- Isolate irreducible core decisions from derived ones
- Surface hidden constraints and dependencies
- Guide users to make choices grounded in fundamentals, not convention
- Distinguish between questions that clarify vs. questions that defer decisions

## Core Principle: First Principles Breakdown

**Break assumptions into fundamentals — then ask.** First Principles questioning means:
1. **Identify assumptions**: What are we taking for granted?
2. **Question each assumption**: Is this actually true, or just convention?
3. **Find irreducible facts**: What cannot be broken down further?
4. **Build from there**: Make decisions grounded in those fundamentals, not on what's typical

Only ask about genuine uncertainties rooted in fundamentals—not about surface-level choices that follow from core facts. This skill works in two contexts:
- **Standalone**: When facing ambiguity, first break it into fundamental questions
- **Inside plan mode**: Use First Principles to identify what must be clarified before planning

## When to Use AskUserQuestion: First Principles Signals

Use this pattern when you've identified a **fundamental uncertainty** that cannot be resolved by analysis alone:

- **Conflicting assumptions**: Different interpretations stem from different foundational beliefs about the problem
- **Irreducible dependencies**: A core decision creates downstream branches that all depend on it
- **Unstated constraints**: You've uncovered a hidden requirement that changes everything (legal, compliance, technical limit)
- **True trade-offs**: Options offer fundamentally different benefits/costs, not surface variations
- **User intent unknown**: You can't infer what success looks like from context alone
- **Scope boundaries**: What counts as "in/out of scope" stems from the user's actual priorities
- **Mid-execution discovery**: You've hit something that invalidates your assumptions (discovered dependency, missing context, constraint change)

Ask only about **fundamental choices** — avoid questions about implementation details that follow from a core decision already made.

## When NOT to Use AskUserQuestion: First Principles Test

Avoid asking when the answer is **derivable from fundamentals** already established:

- **Derives from core facts**: If a core decision is made, derived choices follow logically — don't ask about them (e.g., "if auth is JWT, then you need token refresh" is derivable, don't ask)
- **Observable in context**: The code, architecture, or codebase already reveals the answer — read first
- **Convention over preference**: The choice has an obvious "right" answer in this project's style — don't ask
- **Hypothetical future need**: Asking about future features clouds today's decision — focus on the concrete task
- **Surfaced by data**: Running a search, check, or analysis answers it — don't ask when you can test

## What to Ask: The First Principles Framework

When building questions, break down to **fundamental dimensions**, not surface traits:

1. **Irreducible core choice** — What is the one decision that cannot be derived from other facts? (Not "which files" but "what is this system fundamentally for?")
2. **Competing values** — Which core values conflict? (Performance vs. readability, flexibility vs. simplicity, safety vs. speed)
3. **Hidden assumption** — What are we assuming that might not be true? (User has X skill level? System handles Y scale? Project has Z timeline?)
4. **Non-negotiable constraint** — What external fact cannot be changed? (Legal requirement, hardware limit, organizational standard)

Then derive implementation choices *from* these fundamentals. Don't ask about derived choices separately.

## Using Ask-QnA: Two Contexts

### Standalone (Outside Plan Mode)
Use when facing a specific ambiguity mid-task. Break the ambiguity to its fundamental question(s), ask only about irreducible choices, process answers, and proceed. Avoid asking about derived choices — once a fundamental is settled, implement the rest without asking.

### Inside Plan Mode
Use while in `EnterPlanMode` to identify and isolate the fundamental decisions that the plan depends on. Ask only about irreducibles, then use those answers to derive your plan structure. Incorporate answers into the plan's foundation. This prevents planning loops that circle back to "but what if we chose differently?"

## Recommended Scenarios

### Scenario 1: Feature Implementation — Break to Fundamentals
```
User asks: "Add authentication to my app"

First Principles analysis:
- Surface confusion: "which auth?" (3+ options, feels like equal choices)
- Fundamental question: "Who controls the user database?" (self-hosted vs. delegated)
  - If delegated (OAuth), session management is implicit
  - If self-hosted, you own token lifecycle
- This one choice cascades: it determines if you need refresh tokens, whether you manage credentials, where user data lives

Question to ask (ONE, not three):
1. Should we manage user credentials ourselves or delegate to a third party? (Recommended: Delegate if possible - fewer security concerns)
   - Self-hosted: We store passwords, manage sessions, own credential security
   - Third-party: OAuth/external provider, they manage credentials
   
Then implement derived choices from that answer (if delegated → use OAuth flow, if self-hosted → session + refresh token pattern).
```

### Scenario 2: Refactoring — Surface the Actual Problem First
```
User asks: "Refactor the API module"

First Principles analysis:
- Surface confusion: "which parts? which pattern? do we test?" (3+ questions)
- Fundamental question: "What is broken? What is the refactor actually solving?"
  - If it's "code is hard to change" → organize by feature/responsibility?
  - If it's "tests are slow" → need isolation/mocking?
  - If it's "errors aren't consistent" → need centralized error handling?
- The problem determines the structure, not the other way around

Question to ask (ONE, focused on the actual pain point):
1. What is the refactor solving? (Recommended: Hard to change/maintain)
   - The code is hard to change or maintain (suggest: organize by feature/responsibility)
   - Tests are slow or brittle (suggest: isolate layers, add test structure)
   - Errors are inconsistent or hard to debug (suggest: centralize error handling)
   - Performance problems (suggest: identify bottlenecks first before restructuring)

Then derive structure and test strategy from that answer.
```

### Scenario 3: Configuration — Identify Constraints, Derive Tools
```
User asks: "Set up testing framework"

First Principles analysis:
- Surface confusion: "which framework? which types? coverage target?" (3 questions)
- Fundamental constraint: "What is the constraint?" 
  - Speed (CI/developer feedback loop)?
  - Coverage (safety/risk reduction)?
  - Integration (browser/API testing)?
  - Maintenance (who writes tests, how often)?
- Framework choice is derived from constraint, not arbitrary

Question to ask (ONE, about the actual constraint):
1. What is the testing constraint? (Recommended: Fast feedback loops for developers)
   - Tight feedback loop: Developers need fast CI (suggests: Jest or Vitest, fast isolated unit tests)
   - Comprehensive coverage: Risk reduction matters more (suggests: broad test types, coverage threshold)
   - Complex integrations: API or browser behavior matters (suggests: integration tests, Playwright/Cypress)
   - Low maintenance burden: Team size or skill level is a factor (suggests: simple setup, good examples)

Then pick framework and test strategy from the answer.
```

### Scenario 4: Vague Request — Ask About the Actual Goal
```
User asks: "Clean up the codebase"

First Principles analysis:
- Surface confusion: "what kind of cleanup? how much? how to commit?" (3 questions)
- Fundamental question: "What is 'clean' in this context?" (Not obvious)
  - Does "clean" mean "easy to maintain"? → Focus on unused code, complexity
  - Does it mean "follows the style guide"? → Focus on formatting, naming
  - Does it mean "safe to build on"? → Focus on dead code, deprecated APIs
  - Does it mean "fast to read"? → Focus on duplication, clarity

Question to ask (ONE, about the actual goal):
1. What does 'clean' mean for this project? (Recommended: Easy to maintain)
   - Easy to maintain: Remove dead code, unused variables, fix complexity
   - Follows standards: Format, naming, style consistency
   - Safe to modify: Remove deprecations, consolidate similar patterns
   - All of the above (suggest: phased approach, prioritize by impact)

Then determine scope (whole codebase or hotspots?) from what's actually needed, not upfront.
```

## Implementation Pattern: First Principles Breakdown

When facing ambiguity:

1. **Identify what's actually unclear**: Is it a fundamental choice or a derived detail?
2. **Break to irreducibles**: What is the one core decision that everything else depends on?
3. **Eliminate false choices**: Do some "options" actually derive from a common fundamental? Collapse them.
4. **Ask ONE question** (or 2-3 if truly independent): Use AskUserQuestion with:
   - A question about the actual fundamental, not surface-level choices
   - 2-4 options that represent genuinely different paths
   - A recommended option with *why* it's recommended (constraint-based, not convention)
   - Brief descriptions linking each option to consequences
5. **Derive everything else** from the answer: Implement derived choices without asking again
6. **If user provides "Other"**: Incorporate that fundamental, then derive the rest

## Key Best Practices: First Principles Focus

- **Ask about irreducibles, not details.** Before asking, verify the question is about a fundamental choice, not something derivable from an already-made decision. If it's derivable, don't ask.
- **One question per fundamental** (max 3 if truly independent). Each question should address an irreducible core choice.
- **Every question needs 2+ genuinely different paths.** If options all lead to the same outcome, you've asked about a detail, not a fundamental.
- **Mark recommended options with "(Recommended)" and explain the constraint it satisfies**, not just convention (e.g., "Recommended: Delegate auth — reduces security ownership").
- **Option descriptions should show *consequences*, not features.** Link each option to what it enables/prevents downstream.
- **Use `preview` for contrasting approaches**, not for prettifying a single path. Show what's actually different.
- **Collapse derived options**: If the user answers question 1, can question 2's answer be derived? If yes, don't ask it separately.
- **Provide clear next steps**: After gathering fundamentals, state what you'll derive from the answers before proceeding.
- **Use `multiSelect: true` only for independent factors** that don't cascade into each other.

## Anti-Patterns to Avoid: First Principles Violations

- **Asking about derived choices**: If fundamental X is set, don't ask about detail Y that follows from X. Derive it.
- **Stacking questions without hierarchy**: Asking 3 related questions when 1 fundamental answers all 3. Collapse them.
- **Asking "which tool?" without asking "what problem?"**: Tool choice derives from the problem, not the reverse. Ask about the problem.
- **Yes/no questions**: These rarely identify fundamentals. Rephrase to show competing values or constraints.
- **Vague options** like "Other approach" — use specific, contrasting paths with clear downstream consequences.
- **Hypothetical future scenarios**: "What if we need to scale?" later — focus on today's irreducible choice.
- **Asking for confirmation on trivial details**: If the user's answer to Q1 makes Q2 obvious, don't ask Q2.
- **Too many options** (5+): If you have 5+ options, you've probably mixed multiple fundamentals into one question. Break it down.
- **Treating all options as equal**: The recommendation should reflect actual constraints (speed, safety, simplicity, risk), not just convention.
- **Asking questions you could answer by analysis**: Try first to derive the answer from context, code, or constraints before asking.
