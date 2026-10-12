# Claude Code Runtime Rules

Companion to `agents-common.md`. Applies only when running in Claude Code CLI.
Tool names from the shared mapping: Agent, AskUserQuestion, Bash.

## Subagent Models

- Set `model: haiku` on every Agent call, including research agents that use WebSearch/WebFetch.
- Use a different model only if the user names it in chat. A model named in a plan counts only if the user approved that plan.
- Fork subagents inherit the parent model. Do not use fork when Haiku is required.
- Default model: Haiku for all subagents unless user explicitly specifies otherwise in this conversation. Use Opus only when user explicitly requests it.

## Attribution (Overrides Claude Code Defaults)

- Do not add a `Co-Authored-By` trailer, "Generated with Claude Code", or any mention of Claude, Anthropic, or AI in commits, PR titles, or PR bodies, unless the user asks.
- Commit messages describe only the change.

## Git Hooks

- Commit rules enforced via PreToolUse hook: blocks mentions of Claude/Anthropic and auto-commit patterns.
- Writing style enforced via PostToolUse hook: warns on emojis and emdashes.

## Environment Hooks

- Python venv activation auto-prepended via PreToolUse hook (no manual `source` needed).
- Hook warns on docker commands.

## Memory

- Auto-memory is available and project-specific - save facts and preferences scoped to the current project only, per the shared Memory rules.

## Scope Estimation

- Estimate scope in approximate Opus tokens consumed (account for deep thinking overhead), not time.

## Skills

- Skills load from `~/.claude/skills` (and compatibility locations). Skill frontmatter `model:` and `allowed-tools:` fields are honored.
