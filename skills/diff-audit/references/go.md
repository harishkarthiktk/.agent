# Go Project Audit Patterns

## Detecting new dependencies from diff

From `+` lines inside import blocks or inline imports:
- Multi-line import block: `+\s*"<pkg-path>"` where pkg-path contains a `.` (not stdlib)
- Single import: `^+\s*import "<pkg-path>"`
- The module path root (e.g., `github.com/gin-gonic/gin`) is the dep

## Dependency files to check
1. `go.mod` - `require` block; new deps must appear here
2. `go.sum` - presence expected if `go.mod` updated (don't read, just note)

## Standard library (do NOT flag)
Anything without a dot in the path: `fmt`, `os`, `io`, `net/http`, `encoding/json`, `strings`, `strconv`, `sync`, `context`, `errors`, `log`, `math`, `sort`, `time`, `path/filepath`, `bufio`, `bytes`, `testing`, `flag`, `runtime`

## README / CLAUDE.md
- New CLI flags (`flag.String`, `flag.Bool`) → check README documents them
- New env vars (`os.Getenv`) → same
- New make targets if Makefile changed

## Changelog
Same as other projects - `CHANGELOG.md` with `[Unreleased]` section.
