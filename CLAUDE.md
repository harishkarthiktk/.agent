# Claude Code User Preferences

## Git and Version Control

- Never mention Claude in git commit messages.
- Do not add and commit code without explicit user confirmation.
- Not all changes require commits. Suggest adding and committing, but let the user decide what to version control.

## Code Style and Architecture

- Avoid using classes whenever possible. Prefer functions and simpler constructs.
- Keep code simple and straightforward. Avoid over-engineering or premature abstractions.
- Only add features or improvements explicitly requested, not "nice-to-haves".

## Planning and Documentation

- Always read the project's README.md and local CLAUDE.md at the start to understand project context, setup, dependencies, and requirements.
- Always explore alternate approaches whenever possible and use `AskUserQuestion` tool to gather pointers.
- While planning, do not output code unless the user explicitly asks for it.
- When planning, offer to commit the plan as a temporary .md file to the project root.
- This file can be deleted after implementation is complete.
- While planning also check if there is README.md for the project and if it is required to be updated.
- ALWAYS offer to switch mode to Haiku after planning is completed, before implementation.

## When to Ask for User Input

- Use `AskUserQuestion` strategically for:
  - Ambiguous design decisions where multiple valid approaches exist
  - Hard-to-reverse or destructive actions (e.g., git push --force, deleting files)
  - When genuine clarification is needed about user intent or requirements
- For reversible, local actions, infer intent and proceed without asking
- Default to proceeding with confident assumptions rather than asking for every decision

## Writing Style and Output

- Never use emojis. Use ticks or icons sparingly and only when absolutely necessary.
- Never use emdashes. Replace with hyphens or commas as needed.
- Do not summarize the entire steps completed after an operation. Only summarize if the user explicitly asks.
- Post-operation summaries should be at most 5 lines with a maximum of 200 words total.

## Implementation Guidelines

- Estimate implementation scope in units of approximate tokens consumed, not time required.
- This helps set realistic expectations about complexity rather than duration.

## Operations and Execution Guidelines

- `~/.venv_gen/bin/activate` has the necessary python dependencies. Always use it.
- Always use python and not python3.
- Do not test python scripts automatically, and only test if user asks it to be tested.
- User will always run tests and attempts manually.
- When using the `/add-n-commit` skill, always generate a very short commit message which the user can expand if required.
- Do not write tests without user confirmation. Only propose to write tests if a functionality is critical; but even then suggest to user first and then write test if user confirms.

## Test Failure Analysis

When a test fails, do NOT automatically fix the test. Instead:
1. Analyze whether the failure indicates a project bug or a test issue
2. Examine the actual implementation code to understand behavior
3. Determine the root cause before deciding what to fix
4. Only fix the project code if the implementation is wrong, or fix the test if the test expectations are incorrect

This prevents masking real bugs with incorrect tests or writing tests that don't match actual requirements.
