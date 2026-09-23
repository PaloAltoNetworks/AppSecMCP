# Cortex AppSec — Claude Code Plugin

Claude Code build of the Cortex AppSec plugin.

## Layout

| Path | Purpose |
|------|---------|
| `.claude-plugin/plugin.json` | Plugin manifest read by Claude Code |
| `hooks/hooks.json` | `PreToolUse` / `PostToolUse` hooks (Claude schema) |
| `.mcp.json` | Cortex AppSec MCP server definition |

`skills/` and `commands/` subdirectories can be added here when needed.

## Claude-specific notes

- Hook event keys are **PascalCase** (`PreToolUse`, `PostToolUse`) and each entry
  nests an inner `hooks` array of `{ "type": "command", "command": ... }`.
- Hooks run with `--agent claude-code`. Claude Code natively supports the `warn`
  decision, so **no ack-file workaround is needed**.
- Exit codes: `0` = allow (warn JSON still delivered), `1` = block.
- MCP variables use bare `${VAR}` interpolation.

Do not copy this `hooks.json` into the Cursor plugin — the schemas are not
interchangeable. See [`../cursor-plugin/README.md`](../cursor-plugin/README.md).

## Required environment variables

| Variable | Description |
|----------|-------------|
| `CORTEX_API_BASE_URL` | e.g. `https://api-<tenant>.xdr.us.paloaltonetworks.com` |
| `CORTEX_API_KEY` | Cortex API key secret |
| `CORTEX_KEY_ID` | Cortex API key ID |
