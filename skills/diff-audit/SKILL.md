---
name: diff-audit
description: Audits git diff to verify that all code changes (new imports, libraries, logic, public API) are reflected in dependency files, README, CLAUDE.md/agent files, and changelogs. Use this skill whenever the user asks to "audit changes", "check if docs are up to date", "review what the diff misses", "sync docs with code", "check if dependencies are updated", "validate my changes", or wants to ensure the git delta is fully documented before committing or pushing. Also trigger when the user says "did I miss anything" or "is everything updated" after making code changes.
---

# Diff Audit Skill

You are auditing a git diff to find documentation and dependency gaps. Your job is to be fast and precise - you work *only* from the diff, not full files, except for targeted spot-checks.

## Phase 1: Bootstrap (read project identity)

Before auditing, read:
1. `README.md` (first 60 lines only) - to understand project type, stack, purpose
2. `CLAUDE.md` if present (full) - to understand agent/workflow conventions
3. `git diff HEAD` (or `git diff --cached` if staged) - the full delta

From this, determine:
- **Project type**: detect from file extensions and config files present (see references/)
- **Audit targets**: which dependency and doc files exist in the repo

## Phase 2: Parse the delta efficiently

Run: `git diff HEAD` (unstaged) and `git diff --cached` (staged). Merge both.

From the `+` lines only (new additions), extract:

### New imports / library usage
- **Python**: lines matching `^+\s*(import |from .* import)` → candidate new deps
- **Node/JS/TS**: lines matching `^+.*require\(|^+.*from ['"]` → candidate new deps
- **Go**: lines matching `^+\s*"[a-z].*"` inside import blocks
- **Rust**: lines matching `^+\s*use ` or `^+.*extern crate`
- **Generic**: any `+` line that looks like a library import in the file's language

### New public API surface
- New function/class/method definitions that are exported or public-facing
- New CLI flags, env vars, config keys (look for `argparse`, `dotenv`, `os.environ`, `process.env`, `flags.String` patterns)
- New HTTP routes or endpoints

### New behavior / logic worth documenting
- New major code blocks (functions > 10 lines added)
- New file additions (entire new modules)
- Deleted or renamed public symbols (breaking changes)

## Phase 3: Spot-check targets

For each audit target file, do a **targeted read** - not the full file, just enough to verify presence:

| File | What to check | How |
|------|--------------|-----|
| `requirements.txt` / `pyproject.toml` / `setup.py` | New deps from diff present? | `grep` for each candidate dep name |
| `package.json` | New deps in `dependencies` or `devDependencies`? | Read `dependencies` section only |
| `go.mod` / `Cargo.toml` / `Gemfile` | New deps present? | `grep` for each candidate |
| `README.md` | New features/flags/env vars mentioned? | Grep for key terms |
| `CLAUDE.md` | New tools, patterns, commands referenced? | Grep for key terms |
| `CHANGELOG.md` / `HISTORY.md` / `CHANGES.md` | Unreleased section updated? | Read last 30 lines |
| `agents/*.md` / `.claude/` files | New workflows or tools described? | Grep for key terms |

For project-type-specific rules, read the relevant reference file from `references/`.

## Phase 4: Build the gap checklist

Produce a markdown checklist grouped by target file. Mark each item clearly:

```
## Diff Audit Report

### Dependency files
- [ ] `requirements.txt` - missing `httpx` (used in src/client.py:+12)
- [x] `package.json` - `axios` already listed

### README.md
- [ ] New `--verbose` flag not documented (added in cli.py:+45)
- [ ] `AUTH_TOKEN` env var not mentioned (added in config.py:+8)

### CLAUDE.md
- [ ] New `fetch_data()` utility not described in agent instructions

### CHANGELOG.md
- [ ] No entry for this change set in [Unreleased] section
```

If a target file doesn't exist in the repo, note it as "not present - consider adding".

If nothing is missing, say so clearly.

## Phase 5: Convert to TodoList and fix

After presenting the checklist:
1. Use `TodoWrite` to create tasks for each `[ ]` item
2. Work through each task:
   - For dependency files: add the missing line(s)
   - For README/CLAUDE.md: draft the minimal addition (a bullet, a line, a flag entry)
   - For CHANGELOG: add an entry under `[Unreleased]` or today's date
3. After each fix, mark the task complete with `TodoWrite`

Be minimal in your additions - don't rewrite docs, just add what's missing.

## Project type references

Load the relevant reference file when you need project-specific patterns:

- Python project → read `references/python.md`
- Node/JS/TS project → read `references/nodejs.md`
- Go project → read `references/go.md`
- Polyglot or unknown → use generic patterns above, apply common sense

If the project type isn't covered, use the generic patterns. The reference files contain extra patterns and edge cases for each ecosystem.

## Key principles

- Work from the diff, not from full files. Full file reads are expensive and unnecessary - the diff *is* the truth of what changed.
- Be precise about line references - always cite `file:line` so the user can verify.
- Don't flag things that were already in docs before the diff. You're auditing the *delta*, not the whole codebase.
- If you're unsure whether a dep is truly new (might be transitive), note the uncertainty.
- Don't add noise. A short accurate report is better than a long speculative one.
