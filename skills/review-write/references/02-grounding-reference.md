# 02: Grounding & Reference Ingestion

## Purpose
Lazy-load reference materials (URLs or text files) as read-only context to extract a baseline style guide, ensuring the critique aligns with the writer's desired standard.

## Pre-Analysis Pass
If the user provides reference materials, analyze them to extract a temporary "Style Guide" based on:
1.  **Vocabulary & Formality:** Does the text rely on industry jargon, or simple, punchy language? 
2.  **Formatting Quirks:** Note the frequency of blockquotes, numbered lists, subhead frequency, and paragraph length.
3.  **Pacing:** How long is the introduction? Where in the piece is the core thesis usually revealed?

## Output
Pass this extracted Style Guide to the parallel subagents as a strict grading rubric. If no references are provided, rely entirely on the metadata from `01-gather-phase`.