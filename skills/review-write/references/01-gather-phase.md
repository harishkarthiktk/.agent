# 01: The Gather Phase (Context Elicitation)

## Purpose
Before analyzing the draft, the agent must act as a conversational orchestrator to understand the writer's exact goals. This prevents generic, misaligned feedback.

## Execution
Engage the user with a brief, structured questionnaire (ask smart, concise questions) to lock in the following metadata:
1.  **Target Audience:** Who is reading this? (e.g., Beginners, C-Suite, Technical Peers).
2.  **Primary Goal/Format:** What is the intent? (e.g., Opinion piece, Product Announcement, Sales Proposal, Educational Tutorial).
3.  **Vibe/Tone:** What is the desired emotional resonance? (e.g., Authoritative, casual, urgent, empathetic).

## Downstream Impact
*   The chosen **Goal/Format** dynamically dictates the Narrative Framework used in `03-narrative-hook.md`.
*   The chosen **Goal/Format** dictates what a "strong" CTA looks like in `05-cta-conversion.md`.
*   Do not proceed to parallel subagent execution until this metadata is locked in.