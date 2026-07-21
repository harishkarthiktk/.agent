#!/usr/bin/env python3
"""
Minutes of Meeting (MoM) formatter - converts unstructured notes to template format
"""

import re
from datetime import datetime
from pathlib import Path

class MoMFormatter:
    def __init__(self):
        self.template_path = Path(__file__).parent.parent / "references" / "mom_template.md"
        self.template = self._load_template()

    def _load_template(self):
        """Load the MoM template from bundled file"""
        with open(self.template_path, 'r') as f:
            return f.read()

    def parse_unstructured(self, content):
        """
        Parse unstructured meeting notes and extract sections.
        Smart inference to identify different sections.
        """
        lines = content.strip().split('\n')

        # Initialize sections
        metadata = {
            'title': '',
            'meeting_date': '',
            'created_date': '',
            'participants': [],
            'links': [],
            'discussion_points': [],
            'outcomes_decisions': []
        }

        current_section = None
        current_content = []

        # Keywords to identify sections
        participant_keywords = ['participants', 'attendees', 'people', 'who']
        links_keywords = ['links', 'references', 'urls', 'documents', 'files']
        discussion_keywords = ['discussion', 'topics', 'talked about', 'covered', 'agenda']
        outcome_keywords = ['outcome', 'decision', 'action', 'todo', 'decided', 'conclusions']

        for line in lines:
            line_lower = line.lower().strip()

            # Detect section headers
            if any(kw in line_lower for kw in participant_keywords):
                self._save_section(current_section, current_content, metadata)
                current_section = 'participants'
                current_content = []
            elif any(kw in line_lower for kw in links_keywords):
                self._save_section(current_section, current_content, metadata)
                current_section = 'links'
                current_content = []
            elif any(kw in line_lower for kw in discussion_keywords):
                self._save_section(current_section, current_content, metadata)
                current_section = 'discussion_points'
                current_content = []
            elif any(kw in line_lower for kw in outcome_keywords):
                self._save_section(current_section, current_content, metadata)
                current_section = 'outcomes_decisions'
                current_content = []
            elif line and not line.startswith('#'):
                # Accumulate content for current section
                if current_section is None:
                    # Before any section identified - likely title/metadata
                    if not metadata['title'] and line.strip():
                        metadata['title'] = line.strip()
                else:
                    current_content.append(line)

        # Save last section
        self._save_section(current_section, current_content, metadata)

        # Extract or infer date if not found
        if not metadata['meeting_date']:
            metadata['meeting_date'] = datetime.now().strftime('%Y-%m-%d')

        if not metadata['created_date']:
            metadata['created_date'] = datetime.now().strftime('%Y-%m-%d %H:%M')

        return metadata

    def _save_section(self, section, content, metadata):
        """Save accumulated content to appropriate metadata section"""
        if section is None or not content:
            return

        cleaned = [line.strip() for line in content if line.strip()]

        if section == 'participants':
            metadata['participants'] = self._format_list(cleaned)
        elif section == 'links':
            metadata['links'] = self._format_list(cleaned)
        elif section == 'discussion_points':
            metadata['discussion_points'] = self._format_list(cleaned)
        elif section == 'outcomes_decisions':
            metadata['outcomes_decisions'] = self._format_list(cleaned, as_checkbox=True)

    def _format_list(self, items, as_checkbox=False):
        """Format items as markdown list"""
        if not items:
            return "-"

        formatted = []
        for item in items:
            if item.startswith('-') or item.startswith('*'):
                item = item.lstrip('-*').strip()

            if as_checkbox and not item.startswith('- [ ]'):
                formatted.append(f"- [ ] {item}")
            else:
                formatted.append(f"- {item}")

        return '\n'.join(formatted) if formatted else "-"

    def format_output(self, metadata):
        """Format the final MoM using template"""
        output = self.template

        # Replace template variables
        output = output.replace('{{title}}', metadata['title'] or 'Untitled Meeting')
        output = output.replace('{{meeting_date}}', metadata['meeting_date'])
        output = output.replace('{{created_date}}', metadata['created_date'])
        output = output.replace('{{participants}}', metadata['participants'])
        output = output.replace('{{links}}', metadata['links'])
        output = output.replace('{{discussion_points}}', metadata['discussion_points'])

        # Only include outcomes section if there's content
        if metadata['outcomes_decisions'] and metadata['outcomes_decisions'] != "-":
            output = output.replace('{{outcomes_decisions}}', metadata['outcomes_decisions'])
        else:
            # Remove empty outcomes section
            output = re.sub(r'\n### Outcomes/Decisions\n{{\s*outcomes_decisions\s*}}\n', '', output)

        return output

    def process(self, content):
        """Full pipeline: parse unstructured input and return formatted MoM"""
        metadata = self.parse_unstructured(content)
        return self.format_output(metadata)


if __name__ == '__main__':
    import sys

    if len(sys.argv) > 1:
        # Read from file if provided
        input_file = sys.argv[1]
        with open(input_file, 'r') as f:
            content = f.read()
    else:
        # Read from stdin
        content = sys.stdin.read()

    formatter = MoMFormatter()
    result = formatter.process(content)
    print(result)
