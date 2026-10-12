# OpenCode v2 Runtime Rules

Companion to `agents-common.md`. Applies only when running in OpenCode CLI v2.
Tool names from the shared mapping: `shell`, `question`, `subagent`.

## Subagent Models

- Spawn subagents with the `subagent` tool. Do not set a model unless the user names one in chat; otherwise the subagent runs the session's default model.
- If the user names Haiku, pass the full provider-qualified ID (e.g. `anthropic/claude-haiku-...`). Look up the exact ID with the models tool first; never guess it.
- There is no fork concept: every subagent starts with fresh context. Pass all relevant context in the prompt.
- Default session model is whatever the session runs (e.g. `opencode/glm-5.3-flash`). Use Opus-class models only when the user explicitly requests them.

## Skills

- Skills load from `~/.agents/skills` (global compatibility) and project `.opencode/skills`. Source of truth: `~/.agent/skills`.
- Skill frontmatter `model:` and `allowed-tools:` fields are INERT in OpenCode. If a skill requires a specific model or Haiku per user rules, delegate the work to a SUBAGENT instead of relying on frontmatter.
- SKILL `add-n-commit` is registered but may not appear in the advertised skill list. If the user asks for it and it is not listed, load it explicitly by ID or read `~/.agent/skills/add-n-commit/SKILL.md` and follow it.

## Hooks / Plugins

- Do not assume PreToolUse/PostToolUse hooks exist. Hook behavior comes from OpenCode plugins (`tool.execute.before` / `tool.execute.after`).
- If no plugin enforces the writing-style rules (no emojis, no emdashes), validate manually before outputting, per the shared Instruction Adherence section.
- If no plugin auto-activates the Python venv, activate `~/.venv_gen` manually before Python commands.
- If no plugin warns on docker commands, self-enforce the podman preference.

## Tasks

- There is no native task tool. SKILL `make-to-do` + the `.todo` file is the primary task mechanism. If the skill is unavailable, use `.todo` only and tell the user once (per shared rules).

## Memory

- No native auto-memory. Persist confirmed facts and explicit user preferences into the project's `AGENTS.md`, per the shared Per-Project Setup and Memory rules.

## Attribution

- OpenCode adds no attribution by default. The shared no-attribution rule still applies: no `Co-Authored-By`, no model or AI mentions in commits/PRs unless the user asks.

## Scope Estimation

- Estimate scope in approximate tokens consumed (account for reasoning overhead), not time.

## Configuration

- Global instructions load via `instructions` array in `~/.config/opencode/opencode.json`. Rules files: `~/.config/opencode/AGENTS.md` (global), `AGENTS.md` or `.opencode/` (project).
- `@file.md` references inside instructions files are a lazy convention only - do not rely on them; use the `instructions` config for deterministic loading.
