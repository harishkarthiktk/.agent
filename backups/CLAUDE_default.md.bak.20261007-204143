# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ccswitch** is a multi-account switcher for Claude Code that securely manages and switches between multiple Claude Code accounts on macOS, Linux, and WSL. It handles credential storage via platform-native secure storage (Keychain on macOS, libsecret on Linux, Windows DPAPI on WSL) and maintains account backups.

## Development Workflow

### Running & Testing

```bash
# Make the script executable
chmod +x .ccswitch.sh

# Show available commands
./.ccswitch.sh --help

# Test with a specific command
./.ccswitch.sh --list                    # List all managed accounts
./.ccswitch.sh --add-account             # Add current Claude Code account
./.ccswitch.sh --switch                  # Switch to next account in sequence
./.ccswitch.sh --switch-to <num|email>   # Switch to specific account by number or email
./.ccswitch.sh --remove-account <num>    # Remove an account
```

### Dependencies

**Required globally:**
- `jq`: JSON query tool (installed via `brew install jq` or `apt install jq`)
- `bash` 4.4+

**Platform-specific:**
- macOS: `security` command (built-in)
- Linux: `secret-tool` from libsecret (`sudo apt install libsecret-tools`)
- WSL: PowerShell (built-in)

Check dependencies before development:
```bash
command -v jq
command -v secret-tool  # Linux only
command -v powershell.exe  # WSL only
```

## Architecture & Key Concepts

### Storage Layout

```
~/.claude-switch-backup/
├── sequence.json                           # Global state: accounts, active account, sequence
├── configs/
│   ├── .claude-config-1-user1@ex.com.json  # Backed up .claude.json for each account
│   └── .claude-config-2-user2@ex.com.json
```

Credentials are stored in platform-native secure storage:
- macOS: Keychain via `security` command
- Linux: libsecret via `secret-tool`
- WSL: Windows DPAPI encrypted files in `%USERPROFILE%\.claude-switch\`

### Core Data Flow

1. **Add Account**: Extracts current credentials + config from Claude Code, stores with next account number
2. **Switch Account**: Backs up current account, retrieves target account from storage, restores credentials + config, updates active account state
3. **Remove Account**: Deletes all backups for an account and updates sequence

### Account Numbering

Accounts are identified by:
- **Number** (e.g., `1`, `2`, `3`) - assigned sequentially when added, persisted in `sequence.json`
- **Email** - extracting from credentials, used for lookup via `resolve_account_identifier()`
- **Sequence** - maintains order for `--switch` rotation

### JSON Structure (sequence.json)

```json
{
  "activeAccountNumber": 1,
  "lastUpdated": "2024-01-15T10:30:00Z",
  "sequence": [1, 2, 3],
  "accounts": {
    "1": { "email": "user1@example.com", "uuid": "...", "added": "2024-01-10T..." },
    "2": { "email": "user2@example.com", "uuid": "...", "added": "2024-01-12T..." }
  }
}
```

## Key Functions & Responsibilities

### Credential Management (Platform-Specific)
- `read_credentials()` / `write_credentials()` - active account credentials (single, for current switch)
- `read_account_credentials()` / `write_account_credentials()` - account-specific backups
- Platform dispatch functions: `linux_read_credentials()`, `wsl_read_credentials()`, etc.

### Account Operations
- `cmd_add_account()` - capture current account and add to managed list
- `cmd_switch()` - rotate to next account in sequence
- `cmd_switch_to()` - switch to specific account by number/email
- `cmd_remove_account()` - delete account and all backups
- `cmd_list()` - display all managed accounts with active indicator
- `perform_switch()` - core switch logic: backup current, restore target, update state

### Utilities
- `get_claude_config_path()` - resolve .claude.json location (primary: `~/.claude/.claude.json`, fallback: `~/.claude.json`)
- `resolve_account_identifier()` - convert email to account number via sequence.json
- `validate_json()`, `write_json()` - safe JSON serialization with validation
- `is_claude_running()`, `wait_for_claude_close()` - prevent switches while Claude Code is active
- `detect_platform()` - identify macOS/Linux/WSL for platform-specific behavior

### Initialization & First Run
- `init_sequence_file()` - create sequence.json if missing
- `first_run_setup()` - prompt user to add current account on first use

## Important Design Decisions

1. **Process Safety**: The script waits for all Claude Code processes to close before switching to avoid credential conflicts
2. **Config Merging**: When restoring, only the `oauthAccount` object is replaced; other settings are preserved
3. **JSON Validation**: All writes go through `write_json()` which validates JSON before commit to prevent corruption
4. **Email as Fallback ID**: Users can identify accounts by email as an alternative to account numbers
5. **Platform Abstraction**: Credential storage is abstracted into platform-specific functions, enabling cross-platform support
6. **Atomic State Updates**: `sequence.json` is the source of truth; timestamps track every mutation for debugging

## Error Handling Patterns

- Early exit on missing dependencies or invalid state
- Explicit validation before mutations (JSON, email format, file existence)
- Temp files for safe writes (mktemp → write → atomic mv)
- User confirmations for destructive operations (--remove-account)

## Testing Considerations

- Mock platform detection by temporarily setting environment variables (e.g., `CONTAINER=1`)
- Test JSON corruption recovery via `validate_json()` error paths
- Verify credential storage on each platform:
  - macOS: `security find-generic-password -s "Claude Code-credentials" -w`
  - Linux: `secret-tool search service claude-code`
  - WSL: PowerShell credential files in Windows profile
- Test edge cases: missing .claude.json, corrupted sequence.json, account with no backups

## Common Development Tasks

```bash
# Lint/format (bash has no built-in; use ShellCheck if available)
shellcheck .ccswitch.sh

# Debug: trace execution
bash -x .ccswitch.sh --list

# Test JSON handling: manually corrupt sequence.json and verify recovery
# Test platform detection: set CONTAINER=1 and verify Linux paths are used
```
