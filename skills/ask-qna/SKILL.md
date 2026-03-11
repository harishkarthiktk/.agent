---
name: ask-qna
description: Demonstrates effective use of AskUserQuestion for gathering clarifications, handling ambiguity, and providing structured guidance through multi-question interactions.
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

## When to Use AskUserQuestion

Use this pattern when any of these scenarios apply:

- **Ambiguous requirements**: User request can be interpreted multiple ways
- **Multiple valid approaches**: Task has several reasonable solutions with different trade-offs
- **Missing information**: You need additional context to proceed effectively
- **Decision points**: User must choose between options before you can continue
- **Configuration choices**: User preferences affect implementation approach
- **Scope clarification**: Need to confirm what should/shouldn't be included
- **Architecture decisions**: Multiple valid architectural patterns available

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

- Include 1-4 questions per interaction (not more)
- Mark recommended options with "(Recommended)"
- Provide brief descriptions for each option explaining trade-offs
- Use header labels (max 12 chars) to categorize questions
- Ask dependent questions only if needed (don't ask all upfront)
- Validate that user's choices make sense together
- Provide clear next steps after gathering answers

## Anti-Patterns to Avoid

- Asking yes/no questions (use options instead)
- Including vague options like "Other approach"
- Asking about hypothetical future needs
- Overwhelming user with 6+ questions at once
- Not providing enough context in option descriptions
- Asking questions you can answer by reading the code
- Treating all options as equally valid without recommendations
