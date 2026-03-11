---
name: add-n-commit
description: Stages all current changes with git add and commits with a custom message. Use when you want to commit all pending changes in one action. The commit message will be expanded to approximately 50 tokens with no references to Claude, AI models, or automated processes.
allowed-tools: Bash
model: haiku
user-invocable: true
---

# Add n Commit

## What This Does

1. Stages all changes in the current directory (`git add .`)
2. Expands your provided commit message to ~50 tokens with context and detail
3. Creates a commit with the expanded message
4. Shows the result

## How to Use

Invoke with a commit message:

```
/add-n-commit 'your brief message here'
```

## Instructions

When the user invokes `/add-n-commit 'message'`:

1. Run `git status` to check what will be staged
2. If there are changes:
   - Take the user's message as the foundation
   - Expand it to approximately 50 tokens by adding:
     - Specific details about what changed
     - Why the change was made
     - Any relevant context (file names, feature area, affected components)
   - Ensure the expanded message:
     - Remains clear and professional
     - Contains NO references to "Claude", "AI", "model", "automated", or similar terms
     - Contains NO references to co-authors anywhere (including Co-Authored-By footers)
     - Follows conventional commit style (imperative mood: "Add feature" not "Added feature")
   - Provide the commit message to the user, and get an user feedback. Once user confirms, proceed.
     - If user provides feedback, recreate the commit message based on the user feedback.
3. Run `git add .`
4. Run `git commit -m "[expanded message]"` (use HEREDOC syntax for safety with special characters)
5. Run `git log -1` to show the created commit
6. Do NOT push to remote - user will push manually
7. If there are no changes:
   - Run `git status` to show the clean state
   - Abort gracefully with a message that there are no staged changes to commit

## Examples

**User:** /add-n-commit 'update contact form'

**Claude:** Shows git status, then expands to something like:

"Update contact form with new email validation and improved error handling. Added client-side validation for email format before submission. Fixed styling inconsistencies in form labels and added accessibility improvements for form inputs."

Then commits with that expanded message.

## Important Notes

- Expansion should add meaningful detail, not filler
- Keep the core intent of the user's message
- Never force push or rewrite history
- Never automatically push - user handles that separately
- Never use emojis, tick or cross icons in the commit message.
- If git status shows nothing to commit, abort and inform the user
