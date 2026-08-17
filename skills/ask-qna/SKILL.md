---
name: ask-qna
description: Best practices for using AskUserQuestion to gather clarifications, handle ambiguity, and guide decisions with structured multi-option interactions. Works both standalone and within plan mode.
allowed-tools: Bash
model: haiku
user-invocable: true
---

# Ask QnA Skill

## What This Does

This skill demonstrates best practices for using the `AskUserQuestion` tool to:
- Gather critical user input before proceeding with tasks
- Clarify ambiguous requirements
- Present recommendations within questions
- Handle multiple decision points in a single interaction
- Guide users toward optimal choices
- Make smart decisions about when to ask (and when not to)

## Core Principle

**Ask first, act second — but ask smart.** Not everything needs a question. Use AskUserQuestion for genuine ambiguity and decisions that matter. For things you can confidently infer from the codebase or context, just proceed. This skill works in two contexts:
- **Standalone**: Before starting a task where clarity is needed
- **Inside plan mode**: To gather requirements before finalizing your plan

## When to Use AskUserQuestion

Use this pattern when any of these scenarios apply:

- **Ambiguous requirements**: User request can be interpreted multiple ways
- **Multiple valid approaches**: Task has several reasonable solutions with different trade-offs
- **Missing information**: You need additional context to proceed effectively
- **Decision points**: User must choose between options before you can continue
- **Configuration choices**: User preferences affect implementation approach
- **Scope clarification**: Need to confirm what should/shouldn't be included
- **Architecture decisions**: Multiple valid architectural patterns available
- **Mid-execution surprises**: You discover something unexpected during work (dependency conflict, missing context) that needs user judgment

## When NOT to Use AskUserQuestion

Avoid asking when:

- **You can determine it by reading the code**: If the user says "fix the login bug", read the login code first — you might not need to ask anything
- **It has an obvious answer**: Don't ask yes/no questions where the answer is clear from context
- **It's trivial**: Choosing between two equivalent variable names doesn't warrant a question — just decide
- **It's hypothetical**: Don't ask about future features or "what if" scenarios — focus on the actual task at hand

## What to Ask: The Framework

When you do ask, focus on four dimensions:

1. **What** — What is the concrete deliverable? (A file? A refactor? A plan? A fix?)
2. **Where** — Which files, directories, or systems are involved?
3. **Constraints** — Are there style preferences, tech restrictions, or things to avoid?
4. **Scope** — How far should this go? (Minimal fix vs thorough overhaul? This file only vs entire project?)

## Using Ask-QnA: Two Contexts

### Standalone (Outside Plan Mode)
Use this skill when you're mid-task and need to clarify something, or when starting a task where requirements are unclear but you don't need a full plan. Ask the questions, process the answers, and proceed directly.

### Inside Plan Mode
Invoke this skill (or follow its patterns) while you're in `EnterPlanMode`. Ask clarifying questions, incorporate the answers into your plan, finalize the plan, then exit and execute. This is the recommended pattern for non-trivial work.

## Recommended Scenarios

### Scenario 1: Feature Implementation with Multiple Approaches
```
User asks: "Add authentication to my app"

Questions to ask:
1. Auth method? (Session-based, JWT, OAuth)
   - Recommended: Session-based (simpler for most apps)
2. What data to store? (Username/password, social login, etc.)
   - Recommended: Username and password
3. Should I also set up database schema?
   - Recommended: Yes, include schema
```

### Scenario 2: Refactoring with Scope Ambiguity
```
User asks: "Refactor the API module"

Questions to ask:
1. Which parts? (Recommended: All endpoints)
   - All endpoints
   - Just error handling
   - Just validation logic
2. Target architecture? (Recommended: Modular structure)
   - Modular by feature
   - Modular by responsibility
   - Keep current structure
3. Include tests? (Recommended: Yes)
   - Yes, update existing tests
   - Yes, add new tests
   - No tests
```

### Scenario 3: Configuration with Recommendations
```
User asks: "Set up testing framework"

Questions to ask:
1. Which framework? (Recommended: Jest)
   - Jest
   - Vitest
   - Mocha
2. Test types? (Recommended: Unit + Integration)
   - Unit tests only
   - Integration tests only
   - Both unit and integration
3. Coverage requirements? (Recommended: 80%)
   - No threshold
   - 50%
   - 80%
```

### Scenario 4: Handling Mixed Changes
```
User asks: "Clean up the codebase"

Questions to ask:
1. What to clean? (Recommended: All of the below)
   - Unused variables
   - Formatting issues
   - Dead code
   - Deprecated APIs
2. Scope? (Recommended: Entire project)
   - Single file
   - Specific directory
   - Entire project
3. Create commits? (Recommended: Separate commits per type)
   - Single commit for all
   - Separate commits per category
   - Don't commit
```

## Implementation Pattern

When implementing a skill that uses AskUserQuestion:

1. Check if task is unambiguous
2. If ambiguous or multiple valid approaches exist, prepare questions
3. Use AskUserQuestion to gather input with:
   - Clear, specific questions (1-4 questions)
   - Descriptive option labels (2-4 options each)
   - A recommended option marked clearly
   - Helpful descriptions for each option
4. Process answers and proceed with implementation
5. If user provides "Other" option, use that custom input

## Key Best Practices

- **Every question must have at least 2 options.** A question with one option has no real decision in it. If you only have one path, state it as the approach you're taking and proceed - do not wrap it in AskUserQuestion.
- Include 1-4 questions per interaction (not more)
- Mark recommended options with "(Recommended)" in the label
- Provide brief descriptions for each option explaining trade-offs
- Use header labels (max 12 chars) to categorize questions
- Use `multiSelect: true` when choices are not mutually exclusive (e.g., "Which of these do you want?")
- Use the `preview` field with markdown when comparing code snippets, UI layouts, or configuration options — helps users see the trade-offs visually
- Ask dependent questions only if needed (don't ask all upfront)
- Validate that user's choices make sense together
- Provide clear next steps after gathering answers

## Anti-Patterns to Avoid

- Passing fewer than 2 options to any question - the tool will reject the entire call with a validation error; state the single path as your approach instead
- Asking yes/no questions (use options instead)
- Asking yes/no questions that have obvious answers (if the answer is clear, don't ask)
- Asking for confirmation on every small decision (trivial choices don't warrant questions)
- Including vague options like "Other approach"
- Asking about hypothetical future needs
- Overwhelming user with 6+ questions at once
- Not providing enough context in option descriptions
- Asking questions you can answer by reading the code
- Treating all options as equally valid without recommendations
