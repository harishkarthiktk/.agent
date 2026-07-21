# Python Project Audit Patterns

## Detecting new dependencies

From diff `+` lines, capture:
- `import <pkg>` → package root is first segment (e.g. `import httpx` → `httpx`)
- `from <pkg>` → same rule (e.g. `from PIL import Image` → `Pillow` - note alias)
- Common alias mappings: `PIL`→`Pillow`, `cv2`→`opencv-python`, `sklearn`→`scikit-learn`, `bs4`→`beautifulsoup4`, `yaml`→`PyYAML`, `dotenv`→`python-dotenv`

## Dependency files to check (in priority order)
1. `requirements.txt` - direct list
2. `pyproject.toml` - look in `[project].dependencies` or `[tool.poetry.dependencies]`
3. `setup.py` - `install_requires` list
4. `setup.cfg` - `install_requires` under `[options]`
5. `Pipfile` - `[packages]` section

Cross-check: if a dep is in `pyproject.toml` extras but not base deps, note it.

## Standard library (do NOT flag these as missing deps)
Common stdlib modules to ignore: `os`, `sys`, `re`, `json`, `math`, `time`, `datetime`, `pathlib`, `typing`, `collections`, `itertools`, `functools`, `io`, `abc`, `copy`, `enum`, `logging`, `unittest`, `dataclasses`, `contextlib`, `threading`, `subprocess`, `shutil`, `tempfile`, `hashlib`, `base64`, `urllib`, `http`, `socket`, `struct`, `csv`, `sqlite3`, `argparse`, `traceback`, `inspect`, `ast`

## README patterns
- New CLI commands: check for `argparse` additions, `click` commands, `typer` commands
- New env vars: `os.environ.get(`, `os.getenv(`, `dotenv`
- New config keys: dataclass fields, pydantic model fields if they're configuration

## CLAUDE.md / agent file patterns
- New utility functions that Claude is told to use
- New scripts in `scripts/` directory
- New virtual environment or dependency install instructions
- Changes to test commands or run commands

## Changelog
- Look for `CHANGELOG.md`, `CHANGES.rst`, `HISTORY.md`
- Unreleased section may be `## [Unreleased]` or `## Unreleased`
- If using `towncrier`, look for `changelog.d/` fragments instead
