---
name: add-n-commit
description: Stages changes and generates a commit message from the actual diff using conventional commit format (type(scope): description). User message is optional - used as a hint, not the source. Use when you want to commit pending changes with an accurate, diff-driven message.
allowed-tools: Bash
model: haiku
user-invocable: true
---

# Add n Commit

## What This Does

1. Stages changes (all, or specific paths you provide)
2. Reads `git diff --staged` to understand what actually changed
3. Generates a conventional commit message from the diff (user message is optional hint)
4. Confirms with you before committing
5. Shows the result

## How to Use

```
/add-n-commit                          # stage all, generate message from diff
/add-n-commit 'hint message'           # stage all, use hint to guide message tone/intent
/add-n-commit src/feature/ 'hint'      # stage specific path, use hint
```

## Instructions

When the user invokes `/add-n-commit`:

### Step 1 - Check for changes

Run `git status`. If nothing to commit, show the clean status and abort.

### Step 2 - Risky file detection

Before staging, check the output of `git status` for files matching these patterns:
`.env`, `*.env.*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*secret*`, `*credential*`, `*password*`

If any match:
- List the matched files explicitly
- Warn the user
- Ask "Proceed with staging these files?" and wait for confirmation before continuing

### Step 3 - Stage files

- If the user passed explicit paths/globs: `git add <paths>`
- Otherwise: `git add .`

If `git add` fails, surface the exact error and abort.

### Step 4 - Capture the diff

Run `git diff --staged`.

If the diff is empty after staging (e.g. binary-only or whitespace changes with no diff output), inform the user and abort.

### Step 5 - Generate commit message from diff

Read the full diff and generate a commit message:

- Use conventional commit format strictly: `type(scope): description`
- Valid types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`, `perf`
- If the user provided a hint message, use it to guide tone and intent - but the diff drives the actual content
- CLAUDE or it's model and Co-Author mentions should no be present in the message.
- No co-author footers
- No emojis, tick icons, or cross icons

### Step 6 - Confirm with user

Show the generated message and ask for confirmation. Label the round: "(round 1 of 3)".

- If the user confirms: proceed to Step 7
- If the user provides feedback: regenerate the message based on their input, show again as "(round 2 of 3)" then "(round 3 of 3)"
- After 3 rounds without confirmation: abort and inform the user

### Step 7 - Commit

```bash
git commit -m "$(cat <<'EOF'
type(scope): your message here
EOF
)"
```

If `git commit` fails, surface the exact error and abort.

### Step 8 - Show result

Run `git log -1 --oneline`. Do NOT push - user handles that separately.

## Examples

**Example 1 - No hint (diff-only):**

```
/add-n-commit
```

Claude runs `git diff --staged`, reads the changes, and generates:
`feat(auth): add JWT expiry validation to login middleware`

**Example 2 - With hint:**

```
/add-n-commit 'contact form fixes'
```

Claude uses the hint as intent context and generates from the diff:
`fix(contact-form): validate email format and fix label alignment`

**Example 3 - Specific path:**

```
/add-n-commit src/api/ 'rate limiting'
```

Only stages `src/api/`, then generates from that diff:
`feat(api): implement per-user rate limiting with Redis TTL`

## Important Notes:

- No references to "Claude", "AI", "model", "automated", or similar terms
- Message is generated from the diff - the diff is the source of truth, not the user's hint
- Risky file patterns to detect before staging: `.env`, `*.env.*`, `*.pem`, `*.key`, `*.p12`, `*.pfx`, `*secret*`, `*credential*`, `*password*`
- Conventional commit types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `style`, `perf`
- Confirmation loop capped at 3 rounds - label each round "(round N of 3)"
- Never force push or rewrite history
- Never automatically push - user handles that separately
- Never use emojis, tick or cross icons in the commit message
- Surface git errors verbatim - do not paraphrase them
