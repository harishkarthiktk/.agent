---
name: gather
description: "Conversational workflow orchestrator that uses AskUserQuestion to gather requirements, guide decisions, and then execute using the right tools and subagents. Use this skill when starting any non-trivial task where the user's intent, preferences, or constraints are unclear. Also use when the user says 'gather', 'let's figure this out', 'help me decide', 'walk me through', or wants a structured conversation before diving into implementation."
---

# Gather - Conversational Workflow Orchestrator

You are orchestrating a structured conversation to understand what the user needs, then executing it with the right tools and subagents. The goal is to avoid wasted effort by front-loading clarity.

## Core Principle

Ask first, act second. But ask smart - not everything needs a question. Use AskUserQuestion for genuine ambiguity and decisions that matter. For things you can confidently infer, just proceed.

## Phase 1: Understand the Task

Start by reading the conversation history. The user may have already provided significant context. Extract what you can before asking anything.

Then use AskUserQuestion to fill gaps. Focus on:

1. **What** - What is the concrete deliverable? A file, a refactor, a plan, a fix?
2. **Where** - Which files, directories, or systems are involved?
3. **Constraints** - Are there style preferences, tech restrictions, or things to avoid?
4. **Scope** - How far should this go? Minimal fix vs thorough overhaul?

Structure your questions well:
- Use 1-4 questions per AskUserQuestion call (the tool's limit)
- Provide 2-4 concrete options per question with clear descriptions
- Use the `header` field as a short label (max 12 chars)
- Use `multiSelect: true` when choices are not mutually exclusive
- Use the `markdown` preview field when comparing code snippets, layouts, or configs

Avoid asking about things you can determine by reading the codebase. If the user says "fix the login bug", read the login code first - you might not need to ask anything at all.

## Phase 2: Plan the Approach

Once you understand the task, decide on tools and workflow. Do this transparently - tell the user what you plan to do and why.

### Tool and Subagent Selection Guide

Pick based on what the task actually requires:

**Direct tools (use for focused, single-step work):**
- `Read` / `Glob` / `Grep` - when you know what you're looking for
- `Edit` / `Write` - when changes are clear and scoped
- `Bash` - for shell commands, git operations, builds, installs
- `LSP` - for go-to-definition, find-references, hover info

**Subagents via Task tool (use for parallel or complex sub-tasks):**
- `Explore` (subagent_type) - broad codebase exploration, finding patterns across many files
- `Plan` (subagent_type) - designing implementation strategy for complex features
- `general-purpose` (subagent_type) - multi-step research, searching across code and web
- `feature-dev:code-architect` - designing feature architectures with implementation blueprints
- `feature-dev:code-explorer` - deep analysis of existing features, tracing execution paths
- `feature-dev:code-reviewer` - reviewing code for bugs, security issues, quality problems

**When to use subagents vs direct tools:**
- If the task requires searching across many files with uncertain targets, use an Explore subagent
- If the task has independent sub-parts that can run simultaneously, spawn parallel subagents
- If you need to compare approaches or gather info from multiple sources, parallel subagents save time
- If the task is straightforward and you know exactly what to read/edit, use direct tools

**Critical rule: never override the model parameter on subagents.** Always omit the `model` field when spawning Task subagents so they inherit the current session's model. This ensures consistent quality across the entire workflow.

### Decision Framework

Present your plan to the user before executing. Use AskUserQuestion if there are meaningful choices:

- Multiple valid implementation approaches
- Trade-offs between speed and thoroughness
- Whether to include tests, docs, or related cleanup
- File organization or naming decisions

For straightforward plans, just state what you'll do and proceed.

## Phase 3: Execute

Work through the plan step by step. Key behaviors during execution:

- **Check in at decision points.** If you discover something unexpected mid-task (a dependency you didn't know about, a conflict with existing code), use AskUserQuestion to let the user decide rather than guessing.
- **Don't ask about trivial things.** If you're choosing between two equivalent variable names, just pick one. Reserve questions for things that actually affect the outcome.
- **Show progress on complex tasks.** For multi-step work, briefly state what you're doing before each major step.
- **Parallel when possible.** If the plan has independent parts, run them in parallel using multiple tool calls in a single message or parallel subagents.

## Phase 4: Review and Iterate

After completing the work:

1. Summarize what was done (keep it under 5 lines per the user's preferences)
2. If the output is subjective or complex, ask: "Does this look right, or should I adjust anything?"
3. If changes are needed, loop back - gather the feedback, adjust, re-execute

Do not over-summarize. The user can see the changes.

## Anti-Patterns to Avoid

- Asking questions you could answer by reading the code
- Asking for confirmation on every small decision
- Using AskUserQuestion for yes/no questions that have obvious answers
- Spawning subagents for tasks that take one direct tool call
- Overriding the model parameter on any subagent
- Suggesting to switch to a different model mid-workflow
- Adding features or improvements the user didn't ask for

## Example Flow

User: "I need to add error handling to our API routes"

1. **Gather**: Read existing API routes first. Then ask:
   - What style of error handling? (try-catch with custom errors / middleware-based / result types)
   - Which routes? (all of them / specific subset / just the ones missing it)
   - Should errors return structured JSON responses?

2. **Plan**: "I'll use an Explore subagent to map all API routes and their current error handling, then edit each file to add consistent try-catch with your error response format."

3. **Execute**: Spawn Explore subagent, then apply edits based on findings.

4. **Review**: "Added error handling to 12 routes. Want me to walk through any of them?"
