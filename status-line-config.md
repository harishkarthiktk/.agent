  Components (in order):

  1. Directory name (cyan) — basename of current directory
  2. Git branch (blue) — shows git:branch-name if in a repo
  3. Model name (yellow) — e.g., "Claude Haiku"
  4. Zsh version (magenta) — shows zsh:5.9
  5. Context usage (green) — shows ctx:XX% when available
  6. Rate limits (red) — shows 5h:XX% (5-hour/session) and 7d:XX% (7-day/weekly)

  Example output:
  rustScrapper git:main Claude Haiku zsh:5.9 ctx:23% 5h:42% 7d:17%

  Color scheme:
  - Cyan: directory
  - Blue: git branch
  - Yellow: model
  - Magenta: zsh version
  - Green: context usage
  - Red: rate limits

  The script calculates context usage from token counts if used_percentage isn't available, and all rate/context fields only appear after the first API call.
