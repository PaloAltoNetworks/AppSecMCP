# Cortex AppSec — Cursor Plugin

Cursor build of the Cortex AppSec plugin.

## Layout

| Path | Purpose |
|------|---------|
| `.cursor-plugin/plugin.json` | Plugin manifest read by Cursor |
| `hooks/hooks.json` | `preToolUse` / `postToolUse` hooks (Cursor schema) |
| `mcp.json` | Cortex AppSec MCP server definition |

`skills/` and `commands/` subdirectories can be added here when needed.

## Cursor-specific notes

- Hook event keys are **camelCase** (`preToolUse`, `postToolUse`), the file
  carries a top-level `"version": 1`, and each entry is a flat object with
  `command` / `matcher` / `failClosed`.
- Hooks run with `--agent cursor`. Cursor only enforces the **process exit code**
  for `preToolUse` — the JSON `permission` field is ignored — so the CLI uses
  exit code `2` plus a single-use ack file to emulate "ask the user".
- Exit codes: `0` = allow (messages dropped), `2` = block (deny envelope delivered).
- `failClosed: true` blocks the write if the hook itself crashes.
- MCP variables use the `${env:VAR}` prefix form.

Do not copy this `hooks.json` into the Claude plugin — the schemas are not
interchangeable. See [`../claude-plugin/README.md`](../claude-plugin/README.md).

## Required environment variables

| Variable | Description |
|----------|-------------|
| `CORTEX_API_BASE_URL` | e.g. `https://api-<tenant>.xdr.us.paloaltonetworks.com` |
| `CORTEX_API_KEY` | Cortex API key secret |
| `CORTEX_KEY_ID` | Cortex API key ID |

> On macOS/Linux, GUI-launched Cursor does not inherit shell exports. Launch with
> `cursor .` from a terminal, or hardcode values in `~/.cursor/mcp.json`.
