---
name: subagent
description: Delegate complex investigation, research, or analysis tasks to an isolated subagent to keep your conversation context clean. When you need to investigate something intricate (deep codebase analysis, research questions, debugging, code review), use this skill to spawn a focused subagent that explores fully and returns only the polished findings. The subagent handles exploration, tool calls, dead ends, and reasoning - you get clean, actionable results without context pollution. Triggers: "research whether X", "investigate why Y is slow", "review Z for security issues", "analyze this codebase for patterns", "debug X and find root cause", "find all instances of X in the code", "determine if we should use X or Y".
compatibility: Requires ability to spawn Task tool with subagents
---

## When to Use

Use `/subagent` when:
- **You need to investigate something without cluttering context** — research a tech decision, debug an issue, analyze a codebase
- **The task is complex and involves exploration** — many file reads, multiple tool calls, trial-and-error
- **You want only the conclusion, not the process** — findings matter, not the journey
- **Context isolation helps focus the main conversation** — keep your current chat clean and readable
- **The work is exploratory in nature** — you don't know exactly what you're looking for yet

Don't use `/subagent` when:
- The task is straightforward and you already know exactly what to do (just use direct tools)
- You need the subagent's full transcript or working notes (they're intentionally hidden)
- Real-time back-and-forth collaboration is needed

## How It Works

When you invoke `/subagent`, provide a clear task description and any relevant context (file paths, code blocks, URLs, etc.). The skill will:

1. **Spawn a Haiku subagent** with isolated context — it won't pollute your conversation
2. **The subagent explores freely** — reads files, runs tools, tries different approaches
3. **Collects findings** — the final conclusions, discoveries, or results
4. **Returns clean findings to you** — stripped of intermediate work, token counts, failed attempts
5. **Routes output appropriately** — small findings inline, large findings to file

## Usage Pattern

Invoke with an explicit task and context:

**Research/Architecture Decision:**
```
/subagent Research whether we should migrate to Postgres.
Context: Current system uses SQLite with 10M records, need to support 1000+ concurrent users
```

**Security/Code Review:**
```
/subagent Review the authentication module for security vulnerabilities.
Code location: src/auth/
Focus: Input validation, secret management, token handling
```

**Debugging/Performance:**
```
/subagent Investigate why the checkout endpoint is slow (currently 2-3 seconds).
Code: src/routes/checkout.js
Database: PostgreSQL, 50M transaction records
Expected: < 500ms response time
```

**Code Analysis/Refactoring:**
```
/subagent Analyze this codebase for code duplication and suggest refactoring opportunities.
Codebase: src/services/
Constraint: Maintain backward compatibility
```

## What You'll Get Back

The subagent returns **only findings**, formatted as cleaned-up raw results:

**Small findings (inline):**
```
Key findings:
- Migration to Postgres is justified given your volume (10M records) and query patterns
- Estimated migration time: 2-3 weeks (schema design, data migration, testing)
- Recommend starting with connection pooling (PgBouncer) to validate performance first
- Biggest risk: complex queries with SQLite-specific syntax
```

**Large findings (to file):**
```
The subagent discovered 23 potential issues and saved a detailed analysis to:
/tmp/findings-auth-review-20250422.md

Key summary:
- 3 critical security issues found
- 7 medium-priority improvements
- 4 minor code quality suggestions
See the full report in the file above.
```

## What's Hidden

The subagent's context is **completely isolated** from your conversation. You won't see:
- Token usage or performance metrics
- Intermediate thinking or reasoning steps
- Failed approaches or dead ends
- Detailed file reads or tool call transcripts
- Debugging exploration steps
- Search iterations

Only the findings are returned.

## Output Size Handling

- **Small findings (< 2000 words):** Displayed inline in conversation
- **Large findings (> 2000 words):** Saved to file, you get a summary + link
- **Partial results:** If the subagent runs into limits, it returns what it found with a note on what wasn't explored

## Error Handling

If the subagent can't complete the task:

**Too vague:** Suggestion for refinement
```
The task was too open-ended. Try narrowing it down:
- "Analyze performance bottlenecks in the auth module" (not just "analyze the code")
- "Find all SQL injection vulnerabilities in user input handlers" (not "review for security")
```

**Missing context:** Guidance on what to provide
```
Couldn't find enough context to investigate. Please provide:
- File paths or directories to examine
- Specific code blocks to review
- URLs or external resources to research
```

**No findings:** Honest report
```
The subagent found no issues, security vulnerabilities, or problems in the specified area.
This means either: (1) the code is solid, or (2) the investigation missed something.
Try being more specific about what you're looking for.
```

## Invoking the Subagent

You (the primary agent) decide when to use this skill. When you do:

1. Read the user's request to understand what they're asking for
2. Determine if `/subagent` is the right approach (complex exploration? need clean findings?)
3. Craft a clear task description and context for the subagent
4. Spawn the subagent via the Task tool with:
   - `subagent_type`: "general-purpose"
   - `model`: Inherit from current session (omit the model parameter)
   - `prompt`: Clear task + context (e.g., "Research X. Here's the relevant code: [code]")
5. The subagent returns findings
6. Present findings to the user

## Example Invocation (for your reference)

When you want to delegate to the subagent, use the Task tool like this:

```
{
  "description": "Research database migration strategy",
  "subagent_type": "general-purpose",
  "prompt": "Research whether we should migrate from SQLite to Postgres. Consider: current volume (10M records), query patterns, team capacity. Provide actionable recommendations."
}
```

**Important:** Do NOT include the `model` parameter — let it inherit from the current session.

The subagent will explore, research, read docs, and return findings. You get clean results, not the working transcript.
