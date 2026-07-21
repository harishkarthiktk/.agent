---
name: format-mom
description: Convert unstructured meeting notes into Minutes of Meeting (MoM) template format. Use when the user provides raw meeting notes, transcripts, or bullet points that need to be structured into a professional MoM. The skill extracts metadata (title, date, participants), respects existing section boundaries, identifies natural groupings within discussion points, and suggests improved organization. Triggers on any request to "format notes", "create MoM", "structure meeting", or when the user provides raw meeting content that needs templating.
compatibility: Requires Read/Write tools for file handling
---

## Overview

This skill converts unstructured meeting notes into your standardized Minutes of Meeting format. It:
- Parses raw notes and extracts metadata (title, date, participants, links)
- Respects existing section boundaries in the input
- Identifies natural groupings within discussion points and suggests reorganization
- Generates a formatted MoM file ready to save
- Asks for approval before finalizing

## Process

### Step 1: Receive Input

The user provides either:
- A file path to unstructured meeting notes, or a file can be tagged as `@filename`
- Inline text containing raw meeting content

### Step 2: Parse and Analyze

1. **Extract metadata**: Identify or infer title, meeting date, and created date
2. **Recognize sections**: Look for Discussion Points, Participants, Links, and Outcomes/Decisions (even if unstructured)
3. **Identify groupings**: Within Discussion Points, look for natural clusters:
   - Separate paragraphs or bullet lists
   - Topic transitions
   - Logical thematic groupings
4. **Suggest improvements**: If content seems better organized differently, note it

### Step 3: Format Using Template

Reference file: `references/mom_template.md`

The template uses these variable markers:
- `{{title}}` - Meeting title
- `{{meeting_date}}` - Date of the meeting (YYYY-MM-DD)
- `{{created_date}}` - When notes were created (YYYY-MM-DD HH:MM)
- `{{participants}}` - List of attendees
- `{{links}}` - Reference URLs or documents
- `{{discussion_points}}` - Main discussion content (may have sub-groupings)
- `{{outcomes_decisions}}` - Decisions and action items (optional - only include if present)

**Formatting rules**:
- Always write in first person for my notes, as it might be structured that way for a point of view.
  - If a different perspective fits the narrative, advise and get user confirmation before changing.
- Discussion Points: Each natural grouping becomes a bullet point or numbered item
- Participants: Bullet list format
- Links: Bullet list with URLs
- Outcomes/Decisions: Checkbox format `- [ ] Item` for tracking

**Section inclusion rule**: Only include a section heading if it has content. Do NOT include empty sections:
- If no Participants found → omit "### Participants" entirely
- If no Links found → omit "### Links" entirely
- If no Outcomes/Decisions → omit "### Outcomes/Decisions" entirely
- Discussion Points are required (always include)

### Step 4: Present and Get Approval

Generate two outputs:

**A) Formatted MoM Preview**
Show the formatted markdown following the template structure.

**B) Suggested Groupings** (if any)
If you identified multiple natural groupings in Discussion Points that differ from the input, present them like:

```
Suggested Groupings for Discussion Points:
1. Topic A (lines X-Y from input)
2. Topic B (lines Y-Z from input)
3. Topic C (lines Z-end from input)

Would you like me to group them this way, or keep the original structure?
```

### Step 5: Finalize

Once user approves:
1. Apply grouping preferences
2. Write the final MoM to a .md file using Write tool
3. Provide the file path

## Example Input and Output

**Raw Input Example:**
```
Q4 Planning Session with Alice and Bob

We talked about the new API design. Need to finalize endpoints by Friday.
Also discussed performance - database queries are slow on the reports page.
Action: Alice will optimize the queries.

Here's the dashboard: https://metrics.example.com
GitHub issue: https://github.com/example/repo/issues/123

Decided to ship without the search feature in this release.
Bob will handle the blog post announcement.
```

**Parsed Sections**:
- Title: Q4 Planning Session
- Participants: Alice, Bob
- Links: dashboard URL, GitHub issue
- Discussion Points (grouped):
  1. API design
  2. Performance optimization
- Outcomes/Decisions:
  - [ ] Finalize API endpoints by Friday
  - [ ] Optimize database queries (Alice)
  - [ ] Ship without search feature
  - [ ] Write announcement blog post (Bob)

## Tips for Better Results

- If input is very unstructured, ask clarifying questions about title, date, or participants
- When suggesting groupings, explain the logic (topic-based, by owner, by timeline, etc.)
- If Outcomes/Decisions is empty but the user mentioned action items elsewhere, suggest moving them there
- Preserve direct quotes or specific details from the meeting
- Mark the status as `draft` by default (can be changed later)
- **Clean output:** Only show sections with content. Never leave empty sections or placeholder text in the final output

## Template Reference

The bundled template at `references/mom_template.md` is the single source of truth. To update the template for future uses:
1. Edit `references/mom_template.md` in the skill directory
2. The next use of this skill will reflect the changes
3. No re-packaging needed—updates apply immediately

---

## Implementation Notes

- Always read the bundled template reference before formatting
- For Discussion Points, preserve bullet structure but reorganize by logical groupings
- Outcomes/Decisions should use checkbox format for tracking
- If date is not found in input, use today's date
- Make assumptions smart but transparent—always show them to the user
