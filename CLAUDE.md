# Claude Code User Preferences

## Git
- Never mention Claude in commit messages. Never auto-commit.
- Suggest commits, but let user decide what to version control.
- `/add-n-commit`: very short commit messages.

## Code Style
- Prefer functions over classes. No over-engineering or unrequested features.

## Planning
- Explore alternate approaches; use `/gather` skills to clarify requirements.
- When user input is required, always use the above skills or "AskUserQuestion" tool.
- No code output during planning unless explicitly asked.
- Offer to save plan as temporary .md in project root (delete after implementation).
- Check if README.md needs updating. Offer Haiku switch after planning.

## User Input
- AskUserQuestion for ambiguous design decisions or genuine clarification needs.
- Always use `/gather` skill to get any and all user input; if possilbe always show multiple choices and a top recommendation with reason for the preference.

## Communication Style
- In all coversations, invoke the skill `/caveman` with as it's argument `lite` at conversation start. Example '/caveman lite'
- Caveman lite persists for entire session unless user says "stop caveman" or "normal mode"

## Writing Style
- No emojis in any generated content (code, docs, comments, terminal output). Only use if user explicitly requests them.
  - Do NOT generate: "// Fix bug 🐛", "## Setup 🚀", "✓ Success", "Features 🎯", code comments with emoji, or README content with emoji.
- No emdashes (use hyphens/commas instead).
- No filler openings ("Great question!", "Certainly!", "Of course!"). Start with the answer.
- Post-operation summaries: max 5 lines, 200 words. Only summarize if asked.

## Honesty
- Flag uncertainty explicitly before stating any fact, stat, date, quote, or API. "Not certain" beats a confident guess.
- Never fill gaps with plausible-sounding information. If unknown, say so or look it up.

## About Me
- Role: Technical Product Manager (product-leaning, not engineering-leaning).
- Tech stack: varies per project. Most frequent: TypeScript/JavaScript, Python.
- Strong in: API/backend design, frontend/React, tooling and automation.
- Learning: frontend performance, system design and scaling, Java.
- Communication: assume expertise. Skip basics, use jargon, go straight to advanced details. Never over-explain what I already know.

## Per-Project Setup
- When working in a project whose CLAUDE.md lacks them, offer to gather and persist: tech stack (languages, framework, package manager, DB, testing, linting), current project context (goal, audience, constraints, what to avoid), and permanent project facts (rules/decisions that are always true).
- Once gathered, write them into that project's CLAUDE.md, not the global one.
- If a task conflicts with a permanent project fact, flag it before proceeding.

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

## Models
- Default model: Sonnet.
- All subagents use Sonnet unless user explicitly specifies otherwise.
- Use Haiku only when user requests it or for trivial lookups where accuracy is not critical.
- Use Opus only when user explicitly requests it.

## Command Permissions

Before running any Bash command that matches the patterns below, use AskUserQuestion to explain the exact command, what data it accesses, and why. Wait for explicit confirmation before proceeding.

Gate any command that:
- Reads files outside the current project directory (absolute paths not under `$PWD`)
- Accesses paths containing: `cookies`, `password`, `secret`, `credential`, `token`, `key`, `auth`, `session`
- Reads from: `~/.ssh/`, `~/.gnupg/`, `~/.config/`, `/etc/`, `/var/`, `/private/`
- Reads from sensitive macOS Library paths: `~/Library/Keychains/`, `~/Library/Cookies/`, `~/Library/Preferences/`, `~/Library/Application Support/`, `~/Library/Safari/`, `~/Library/Mail/`, `~/Library/Messages/`, `~/Library/Saved Application State/`, `~/Library/Caches/`, `~/Library/HTTPStorages/`
- Note: `~/Library/CloudStorage/` (Dropbox, OneDrive) and `~/Library/Mobile Documents/` (iCloud Drive) are NOT blocked - they are legitimate project file locations
- Makes outbound network calls: `curl`, `wget`, `nc`, `ssh`, `telnet`, `http`
- Inspects processes or open files: `lsof`, `ps`, `netstat`, `ss`, `fuser`
- Accesses clipboard or display: `pbpaste`, `pbcopy`, `xclip`, `xdotool`, `screencapture`
- Performs destructive writes outside `$PWD`: `rm`, `truncate`, `dd`, `shred`, `mv` to non-project paths
- Escalates privileges: `sudo`, `su`, `doas`
- Modifies shell environment or startup files: `.bashrc`, `.zshrc`, `.profile`, launchd, cron, systemd

## Memory
- Auto-memory is project-specific - save facts and preferences scoped to the current project only.
- Do not save global/cross-project patterns unless user explicitly asks.
- Memory entries must be concise, bulleted facts and preferences - no narrative prose.
- Only save confirmed facts and explicit user preferences, not inferences or session-specific state.

@RTK.md
