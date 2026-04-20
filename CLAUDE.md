# Claude Code User Preferences

## Git
- Never mention Claude in commit messages. Never auto-commit.
- Suggest commits, but let user decide what to version control.
- `/add-n-commit`: very short commit messages.

## Code Style
- Prefer functions over classes. No over-engineering or unrequested features.

## Planning
- Explore alternate approaches; use `/gather` or `/ask-qna` skills to clarify requirements.
- No code output during planning unless explicitly asked.
- Offer to save plan as temporary .md in project root (delete after implementation).
- Check if README.md needs updating. Offer Haiku switch after planning.

## User Input
- AskUserQuestion for ambiguous design decisions or genuine clarification needs.
- Default to proceeding with confident assumptions.

## Writing Style
- No emojis in any generated content (code, docs, comments, terminal output). Only use if user explicitly requests them.
  - Do NOT generate: "// Fix bug 🐛", "## Setup 🚀", "✓ Success", "Features 🎯", code comments with emoji, or README content with emoji.
- No emdashes (use hyphens/commas instead).
- Post-operation summaries: max 5 lines, 200 words. Only summarize if asked.

## Execution
- Python: `source ~/.venv_gen/bin/activate`. Use `python` not `python3`.
- Docker: ALWAYS use `podman` and it's relevant command instead of docker commands.
    - If a docker command is in the instruction, validate it's equivalent podman command and execute that instead.
- Never auto-test or auto-write tests. Suggest only for critical functionality, write only if user confirms.
- Estimate scope in approximate Opus tokens consumed (account for deep thinking overhead), not time.
- While creating a plan, always include an implementation step to invoke `/make-to-do` skill to create atomic tasks while implementing.
- While implementing a plan, always use `/make-to-do` skill to create task list and then implement. No exceptions, regardless of task size.

## Test Failures
- Analyze root cause before fixing. Determine if failure is a project bug or test issue.
- Fix implementation if wrong, fix test only if expectations are incorrect. Never auto-fix.
