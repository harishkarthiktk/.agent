---
name: add-n-commit
description: Stages changes and generates a commit message from the actual diff using conventional commit format (type(scope): description). User message is optional - used as a hint, not the source. Use when you want to commit pending changes with an accurate, diff-driven message.
allowed-tools: Bash
model: haiku
user-invocable: true
---

# Add n Commit

Stage changes, generate a conventional commit message from the staged diff, confirm, commit. Never push.

```
/add-n-commit                          # stage all, generate message from diff
/add-n-commit 'hint message'           # stage all, hint guides tone/intent
/add-n-commit src/feature/ 'hint'      # stage specific path, use hint
```

Prefix every git command with `rtk` (e.g. `rtk git status`) for token-efficient output.

## Steps

### 1 - Check for changes

Run `rtk git status`. If nothing to commit, show the clean status and abort.

If changes are already staged and the invocation would stage more, list the additional files that staging will add before proceeding - do not silently widen a commit the user pre-staged.

### 2 - Risky file detection

Check the status output for files matching (case-insensitively):
`.env`, `*.env.*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*secret*`, `*credential*`, `*password*`

If any match: list them, warn the user, and ask "Proceed with staging these files?" before continuing.

### 3 - Stage

Stage exactly what the invocation asks for: `rtk git add <paths>` if paths were given, otherwise `rtk git add .` for all changes. If it fails, surface the exact error verbatim and abort.

### 4 - Read the diff

Run `rtk git diff --staged --stat` first. If the stat summary is enough to write an accurate message, stop there; otherwise run `rtk git diff --staged` for the full diff.

If nothing is staged (per `rtk git status`), inform the user and abort. A stat showing only binary changes is still committable - do not abort on an empty text diff alone.

### 5 - Generate the message

- Strict conventional commit format: `type(scope): description`
- Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`, `perf`
- The diff is the source of truth; a user hint only guides tone and intent
- No mention of Claude, AI, model names, "automated", or similar; no co-author footers
- No emojis, tick icons, or cross icons

### 6 - Confirm
- If there are multiple levels of commits possible, stage them incrementally and commit incrementally using relevant message.
- Show the message labeled "(round 1 of X)" and ask for confirmation.
- Show each commit process, get confirmation and then move to next.

### 7 - Commit and show result

```bash
rtk git commit -m "$(cat <<'EOF'
type(scope): your message here
EOF
)"
```

If the commit fails, surface the exact error verbatim and abort. On success, run `rtk git log -1 --oneline`. Never push, force push, or rewrite history - the user pushes separately.

## Example

```
/add-n-commit 'contact form fixes'
```

Reads the staged diff and generates:
`fix(contact-form): validate email format and fix label alignment`
