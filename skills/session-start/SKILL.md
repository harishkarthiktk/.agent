---
name: session-start
description: Load and apply the user's personal CLAUDE.md preferences at session start. This skill should trigger automatically on every session start to read the user's global Claude Code configuration from ~/.claude/CLAUDE.md and apply all preferences, rules, and instructions silently without any output or confirmation. Use this skill at the beginning of every conversation to ensure all user preferences are active before starting any work.
compatibility: Requires filesystem access to ~/.claude/CLAUDE.md
---

# Session Start - Auto-Load Preferences

Load the user's global CLAUDE.md configuration silently and apply it to the session.

## What This Does

1. Reads `~/.claude/CLAUDE.md`
2. Parses all instructions, rules, and preferences
3. Applies them silently to the current session
4. No output, no confirmation needed

## When to Use

Invoke this skill at the very beginning of each Claude Code session. It should run automatically before any other work begins, so the user's preferences are active throughout the session.

## How It Works

The skill reads your personal CLAUDE.md file and extracts all instructions across these sections:

- **Git**: Commit message style, version control behavior
- **Code Style**: Preferred patterns, what to avoid
- **Planning**: How to approach design decisions
- **User Input**: When to ask clarifying questions
- **Communication Style**: Tone, caveman lite status, interaction mode
- **Writing Style**: No emojis, no emdashes, filler words to avoid
- **Honesty**: When to flag uncertainty
- **About Me**: Role, tech stack, expertise level, what to skip in explanations
- **Per-Project Setup**: How to handle project-specific configuration
- **Execution**: Language-specific setup, Docker/Podman, testing approach
- **Test Failures**: How to analyze and fix
- **Models**: Default model selection, when to use which model
- **Command Permissions**: Which Bash commands need approval
- **Memory**: How to manage persistent context

All preferences apply silently. No acknowledgment needed.

## Example

When you invoke session-start at the beginning of a session:

- The user's preferred model (default Sonnet, unless overridden) is noted
- Caveman lite mode is activated if specified
- Communication style rules are understood
- Code style preferences are applied to future edits
- Git rules are known (no auto-commit, no Claude mentions, etc.)

The skill produces no output. It simply ensures all downstream Claude behavior respects the preferences.
