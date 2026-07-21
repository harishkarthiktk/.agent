# Node.js / JavaScript / TypeScript Project Audit Patterns

## Detecting new dependencies from diff

From `+` lines, capture:
- `require('<pkg>')` or `require("<pkg>")` → package name (stop at `/` for scoped: `@org/pkg`)
- `from '<pkg>'` or `from "<pkg>"` → same rule
- Dynamic: `import('<pkg>')` → same
- Ignore relative paths (`./`, `../`, `/`)

## Dependency files to check (in priority order)
1. `package.json` - `dependencies` and `devDependencies` sections
2. `package-lock.json` / `yarn.lock` / `pnpm-lock.yaml` - presence means dep should be resolved (don't read these, just note if package.json is updated)

Dev vs prod: if a new dep is only used in test files (`*.test.*`, `*.spec.*`, `__tests__/`), it belongs in `devDependencies`.

## Built-ins (do NOT flag these)
Node built-ins to ignore: `fs`, `path`, `os`, `http`, `https`, `url`, `crypto`, `stream`, `events`, `child_process`, `util`, `assert`, `buffer`, `net`, `dns`, `readline`, `zlib`, `cluster`, `worker_threads`, `perf_hooks`, `timers`, `module`, `process`, `console`, `global`

## README patterns
- New npm scripts added to `package.json` `scripts` section → check if README documents them
- New environment variables (look for `process.env.`, `dotenv`)
- New CLI commands if this is a CLI tool

## TypeScript specifics
- New `@types/<pkg>` needs - if a JS lib is added and no `@types` exists in diff, note it
- New type exports in `index.ts` / `types.ts` → public API change worth noting

## CLAUDE.md / agent file patterns
- Changes to `scripts` in package.json that agents are told to run
- New build or dev commands
- New test commands

## Changelog
- Look for `CHANGELOG.md`, `RELEASES.md`
- Unreleased section: `## [Unreleased]` pattern (Keep a Changelog format)
- If using `standard-version` or `semantic-release`, note that changelog may be auto-generated
