# Agent Instructions (Shared)

Runtime-agnostic rules for any AI coding CLI. Canonical terms below map to the
tool names of whichever runtime is reading this file. Apply the mapping
silently; never comment on it.

## Canonical Tool Mapping

| Canonical term | Claude Code | OpenCode v2 |
|---|---|---|
| SHELL tool | `Bash` | `shell` |
| QUESTION tool | `AskUserQuestion` | `question` |
| SUBAGENT tool | `Agent` | `subagent` |
| Rules file | `CLAUDE.md` | `AGENTS.md` |
| Invoke SKILL `<id>` | `/id` (user) / `skill` tool with `id` (agent) | `skill` tool with `id` (agent) / `@id` mention (user) |

Skill IDs are identical in both runtimes (`make-to-do`, `ask-qna`, `ask-qna-fp`, `add-n-commit`, `caveman`). When this file says "invoke SKILL `x`", use your runtime's invocation form. Never type the literal `/` form in OpenCode: there it means a custom command, not a skill.

Runtime-specific rules live only in per-runtime files. Never follow file
references discovered inside this file beyond this content.

## Operation Constraints

**Applies to:** All work except quick fixes/lookups (read-only exploration, single-file edits, factual questions).

Terminology: "user" = the human. The assistant never grants itself an exception.

### 1. Subagent Models

- Default subagent model policy is defined in the runtime-specific rules file.
- Use a different model only if the user names it in chat. A model named in a plan counts only if the user approved that plan.

### 2. Plans Include Implementation Skeletons

- Plans include skeleton code: file paths, function signatures, types, and key imports. Bodies are `TODO` comments, no full logic.
- End the plan with a "Handover" section: files to touch, order of work, conventions, and the implementation model (see runtime-specific rules for the default).
- Implementation follows the skeletons. If you need to deviate, ask the user first.

### 3. Tasks and .todo File

- Start implementation: invoke SKILL `make-to-do`. It creates the Tasks, which are the source of truth.
- Mirror every task into `.todo` at the project root (`- [ ]` / `- [x]`) in the same turn as each status change.
- Keep one task `in_progress` at a time. Mark dropped tasks as deleted and strike them through in `.todo`.
- If native Task tools are unavailable, use `.todo` only and tell the user once. Do not change settings or env vars.
- Make sure `.todo` is in `.gitignore`. When all tasks are complete, use QUESTION tool to ask whether to delete `.todo`.
- ALWAYS keep the .todo list up to date. Once a line item is completed, mark it as completed.

### 4. Choices

- Whenever the user must pick between 2 or more options, use QUESTION tool. Never list options in prose.
- Give 2-4 options. Put the recommended one first with "(Recommended)" in its label. Give each option a one-line tradeoff.
- Subagents can't ask the user. They return options to the parent, which asks.

### 5. Test Execution

- Tests (pytest, jest, vitest, npm test, and similar) run only when the user asks in this conversation.
- The main agent never runs tests. It delegates them to a SUBAGENT, even when the user asks for a run. Model per runtime-specific rules.
- Allowed without asking: type checks, lint, and format checks. Everything else, such as builds, installs, and project scripts, needs user approval.
- Never write tests unless the user asks. You may suggest tests for critical code, then wait.

### 6. Test Failures

- Before any change, classify the failure as an implementation bug or wrong test expectations, and report which with evidence.
- Implementation bug: propose the fix and ask before applying it.
- Wrong expectations: update the test. Delete it only if the feature it covers no longer exists.
- Before editing or deleting, use QUESTION tool to list the exact files.
- Never delete or modify non-test source code, dependencies, or config to make a test pass. Fixtures, mocks, and snapshots count as test code.

### 7. Git

- Do not run `git add`, `commit`, `push`, `reset`, `rebase`, `stash drop`, or PR creation unless the user asks in this conversation.
- When the user asks to commit, invoke SKILL `add-n-commit`.

### 8. Attribution

- Do not add a `Co-Authored-By` trailer, "Generated with <tool>", or any mention of Claude, Anthropic, OpenAI, or AI in commits, PR titles, or PR bodies, unless the user asks.
- Commit messages describe only the change.

## Git

- Suggest commits; user decides. SKILL `add-n-commit`: short messages.

## Code Style

- Prefer functions over classes. No over-engineering or unrequested features.

## Planning

- Explore alternate approaches; invoke SKILL `ask-qna` or `ask-qna-fp` to clarify requirements.
- When user input is required, always use QUESTION tool.
- No code output during planning unless explicitly asked. Exception: plans may include skeleton code (file paths, signatures, types, imports with TODO bodies) for implementation handoff.
- Offer to save plan as temporary .md in project root (delete after implementation).
- Check if README.md needs updating. Offer default-model switch after planning.

## User Input

- QUESTION tool for ambiguous design decisions or genuine clarification needs.
- Always present multiple choices with a top recommendation and reasoning when user input is required.

## Writing Style

- No emojis, no emdashes (use hyphens/commas).
- No filler openings ("Great question!", "Certainly!", "Of course!"). Start with the answer.
- Post-operation summaries: max 5 lines, 200 words. Only summarize if asked.
- Enforce these rules by validating output before committing (manually, or via hooks/plugins where the runtime supports them).

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

- When working in a project whose rules file lacks them, offer to gather and persist: tech stack (languages, framework, package manager, DB, testing, linting), current project context (goal, audience, constraints, what to avoid), and permanent project facts (rules/decisions that are always true).
- Once gathered, write them into that project's rules file, not the global one.
- If a task conflicts with a permanent project fact, flag it before proceeding.

## Execution

- Python venv: `~/.venv_gen` is the default venv for all Python operations and executions. Activate it for Python runs (runtime may auto-prepend activation via hook/plugin; if it does, no manual `source` needed).
- Prefer `podman` over `docker`. Use `python` not `python3`.
- Never auto-test or auto-write tests. Suggest only for critical functionality, write only if user confirms.
- Estimate scope in approximate model tokens consumed (account for reasoning overhead), not time.
- While creating a plan, always include an implementation step to invoke SKILL `make-to-do` to create atomic tasks while implementing, and invoke SKILL `caveman` with `lite` as argument at the start of the implementation.
- While implementing a plan, always invoke SKILL `make-to-do` to create task list and then implement. No exceptions, regardless of task size.
- Do not invoke `open` commands for any file unless asked by the user, as tests will be done manually.
- Do not generate Artifacts unless user asks explicitly. Always get user confirmation before proceeding with Artifact generation by presenting an alternative as well.

## Spreadsheet Operations

- When working with spreadsheets (Excel, CSV, etc.), use pandas as the primary tool if the file has more than 100 lines (perform a `wc -l {file_name}` to confirm the line count and then decide)
- Pandas handles data manipulation, filtering, aggregation, and transformation reliably and efficiently.
- Only use direct LLM calls/analysis if the task explicitly requires subjective judgment or synthesis that data operations alone cannot provide.

## File Operations

Token-efficient rules for all file operations:

- Before reading a file, `grep` via SHELL tool to find the target line number.
- Use `Read` with `offset` + `limit` to read only the relevant section (~20-40 lines). Full reads only for files under 100 lines.
- Use `Edit` for all targeted changes -- it sends only the find/replace text, not the full file.
- Use `Write` only for new files or near-total rewrites (>50% of content changing).
- `Write` on an existing file requires a full `Read` first -- avoid it when `Edit` suffices.
- Multiple edits = multiple sequential `Edit` calls. Never use `Write` as a multi-edit shortcut.

## Command Permissions

Before running any SHELL command that matches the patterns below, use QUESTION tool to explain the exact command, what data it accesses, and why. Wait for explicit confirmation before proceeding.

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

## Instruction Adherence & Validation

LLMs systematically violate explicit constraints due to architectural limits (position effects, training priors, task complexity). Defense requires active validation, not passive reading.

### Before Generation
- Extract all constraints from the rules file relevant to the task.
- State constraints internally before generating.
- Flag conflicts proactively: "I notice the rules say X, but Y would improve this - confirm before proceeding?"

### After Generation
- For critical constraints (no emojis, no emdashes, format rules), validate output before committing.
  - Emojis: grep for Unicode emoji patterns; refuse to output if found.
  - Emdashes: check for - characters used as dashes; convert to hyphens or commas.
  - Format: spot-check against stated rules.
- When uncertain, ask before outputting.

### Constraint Validation Checklist
- Is the constraint stated positively (stronger) or negatively (weaker)?
- Does this conflict with learned priors (e.g., emojis improve readability)?
- Is there a tool to validate this automatically?
- If complex multi-constraint task, validate one constraint at a time.

### Special Cases
- **Emoji constraint:** Training data has millions of examples where emojis improve readability. This prior is strong. Validate explicitly: no checkmarks, no feature bullets with icons, no progress indicators. If a constraint conflicts with this, state it upfront.
- **Negative rules vs. positive rules:** "No emojis" is weaker than "use dashes for emphasis." Restate negatives as positive rules when possible.

## Memory

- Persisted facts and preferences are project-specific - save them scoped to the current project's rules file only.
- Do not save global/cross-project patterns unless user explicitly asks.
- Memory entries must be concise, bulleted facts and preferences - no narrative prose.
- Only save confirmed facts and explicit user preferences, not inferences or session-specific state.
