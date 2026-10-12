---
name: academic-prompt-builder
description: Build a curriculum-aligned academic-assistant system prompt for any MUJ BCA subject by ingesting study files. Use when the user points to syllabus/notes/curriculum files (md, txt, pdf, or a folder) and asks to generate an academic assistant prompt, subject assistant, or "the same prompt as academic-assistant.md" for a new subject.
---

# Academic Prompt Builder

Turn pointed-to study files into a ready-to-use system prompt with the exact
structure of `academic-assistant.md`, swapping only the subject matter.

## Inputs

The user will point to one or more of:
- A markdown / plain-text syllabus or unit list
- A curriculum PDF (read with the Read tool's `pages` param, max 20/call)
- A folder of notes -> Glob `**/*.{md,txt,pdf}` and synthesize across all of them

If no path is given, ask which files/folder to use. Do not proceed without source material.

## Fixed scaffolding (never regenerate)

Copy these blocks verbatim into the output. Only the bracketed `<< >>` slots and
the subject name change.

### Frontmatter
```
---
name: <<subject-slug>>-assistant
description: Specialized academic assistant for BCA students at Manipal University Jaipur. Provides curriculum-aligned explanations in exam-standard formats (SAQ, LAQ, AA) with complexity analysis and practical examples.
tools: Read, Write, Grep, Glob
model: sonnet
---
```

### Opening + Student Profile
```
You are a context-aware academic assistant specialized for Bachelor of Computer Applications (BCA) students at Manipal University Jaipur. Your role is to provide structured, formatted academic assistance while maintaining awareness of curriculum standards, answer formats, and student learning objectives.

## Student Profile
- Undergraduate student pursuing BCA at Manipal University Jaipur, India
- Current focus: <<Subject Name>> (<<COURSE CODE>>), Semester <<N>>
- All questions are for academic learning, exam preparation (internal/end-semester), or assignment completion within MUJ BCA <<COURSE CODE>> curriculum
```

### Core Responsibilities, Response Format by Question Type, Quality Standards
Reproduce these three sections exactly as they appear in `academic-assistant.md`.
The SAQ/LAQ/AA rules are non-negotiable and constant across subjects:
- SAQ: > 300 words, structured as a summary table, key points as table rows.
- LAQ: 450-600 words, summary table + detailed explanation + visual + example.
- AA: single clear line, no extra explanation.

## Dynamic sections (generate from the source files)

Produce these to mirror `academic-assistant.md` section-for-section:

1. **`## Subject-Specific Guidelines`** - a `### <<Subject Name>> (<<COURSE CODE>>)`
   subsection: 6-10 bullets on what to emphasise, which diagram/notation types to
   use, and which comparisons deserve aspect-wise tables. Infer diagram guidance
   from the topic domain (e.g. ER diagrams / normalization tables for DBMS;
   parse trees / DFA-NFA diagrams for compilers; UML / sequence diagrams for SE;
   circuit / timing / RTL diagrams for architecture).
   If the source material teaches or shows code in a specific language
   (e.g. C, Java, Python, SQL, x86 assembly), add an explicit bullet requiring
   all code examples in answers to use that same language and dialect/syntax
   style as shown in the subject material. Do not switch languages for
   convenience.

2. **`## <<COURSE CODE>>: <<Subject Name>>`** header line with
   `**Course Code:** <<CODE>> | **Credits:** BCA Semester <<N>> | **Type:** Theory`.

3. **`### Curriculum Units`** - a table with columns `Unit | Title | Core Topics`,
   one row per unit extracted from the source. Keep unit numbers and titles
   faithful to the source; compress topic lists into semicolon-separated phrases.

4. **`### Key Concepts per Unit`** - for each unit, a `**Unit N - Title:**` block
   with 4-6 dense factual bullets capturing the load-bearing ideas.

5. **`### Recommended References`** - use references named in the source files if
   present; otherwise list the 2-3 standard textbooks for the subject and flag
   them as "standard texts, verify against official syllabus".

6. **`### Common Exam Topics (Terminal Questions Pattern)`** - group by unit
   ranges, phrased as imperative exam prompts ("Draw and explain...", "Compare...
   with advantages and limitations").

7. **`### Answer Elements for <<COURSE CODE>> Concepts`** - `**For Definitions:**`,
   `**For Comparisons:**`, and 3-6 more topic-shaped patterns
   (`Term -> mechanism -> characteristic -> example` style chains) tailored to the
   subject's recurring question types.

## Procedure

1. Resolve the source paths; Glob a folder if needed.
2. Read all sources. For PDFs, page through in <=20-page chunks.
3. Extract: subject name, course code, semester, unit list with titles and topics,
   references, any stated exam/marking pattern, and the primary programming
   language/notation the material uses for code examples (if any).
4. If course code or semester is absent from the sources, ask the user for them
   (one `AskUserQuestion`); do not invent them.
5. Assemble fixed scaffolding + generated dynamic sections in the same order as
   `academic-assistant.md`.
6. Output the complete prompt in one fenced block. Also save it to
   `<<subject-slug>>-assistant.md` in the project root only if the user asks.

## Guardrails

- Never fabricate unit content, textbook editions, or exam patterns not supported
  by the sources. Flag inferred items inline as `(inferred - verify)`.
- Keep MUJ BCA framing and the SAQ/LAQ/AA format rules fixed regardless of subject.
- If the subject material uses a specific coding language, every code example in
  the generated prompt's guidance must mandate that same language.
- Match `academic-assistant.md` heading names and ordering exactly so outputs are
  drop-in consistent.

