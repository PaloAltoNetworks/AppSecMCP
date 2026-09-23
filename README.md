# Cortex AppSec Plugins for AI Coding Assistants

The **Cortex AppSec** plugins integrate Palo Alto Networks Cortex AppSec directly into
AI coding assistants, acting as a real-time security gateway for AI-assisted coding
and agentic workflows.

This repository is a **plugin monorepo**: it ships one plugin per host agent
(Claude Code and Cursor) from a single source of truth.

---

## Repository Structure

```
AppSecMCP/
│
├── .claude-plugin/
│   └── marketplace.json        # Claude marketplace → ./plugins/claude-plugin
│
├── .cursor-plugin/
│   └── marketplace.json        # Cursor marketplace → ./plugins/cursor-plugin
│
├── plugins/
│   ├── claude-plugin/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── hooks/hooks.json    # Claude hook schema (PascalCase events)
│   │   ├── .mcp.json           # ${VAR} interpolation
│   │   └── README.md
│   │
│   └── cursor-plugin/
│       ├── .cursor-plugin/plugin.json
│       ├── hooks/hooks.json    # Cursor hook schema (camelCase + failClosed)
│       ├── mcp.json            # ${env:VAR} interpolation
│       └── README.md
│
├── LICENSE
└── README.md
```

Each plugin may later grow `skills/` and `commands/` subdirectories. They are
omitted until there is something to put in them.

### Why two plugin directories instead of one

The two agents are **not** config-compatible. Keeping a single merged plugin would
silently break one host or the other:

| Concern | Claude Code | Cursor |
|---|---|---|
| Manifest directory | `.claude-plugin/` | `.cursor-plugin/` |
| Hook event keys | `PreToolUse` / `PostToolUse` | `preToolUse` / `postToolUse` |
| Hook entry shape | nested inner `hooks[]` array | flat object |
| Top-level `version` in hooks | not used | `"version": 1` required |
| `failClosed` | not supported | supported |
| MCP file | `.mcp.json` | `mcp.json` |
| MCP variables | `${VAR}` | `${env:VAR}` |
| CLI flag | `--agent claude-code` | `--agent cursor` |
| Blocking mechanism | exit `1`, native `warn` | exit `2` + single-use ack file |

Splitting per agent means each marketplace installs only valid config, and a change
to one agent's hooks cannot regress the other.

### How marketplace routing works

Each root marketplace file declares the plugin and points at its subdirectory with a
relative `source` path:

```json
{
  "name": "cortex-appsec-marketplace",
  "owner": { "name": "Palo Alto Networks" },
  "plugins": [
    {
      "name": "cortex-appsec",
      "source": "./plugins/claude-plugin",
      "description": "..."
    }
  ]
}
```

The marketplace resolves `source` relative to the repository root and loads the
manifest from that subdirectory.

> **Only the plugin subdirectory is installed.** Anything outside it — a sibling
> plugin, a shared helper directory, or the repository root — will not exist on an
> end-user machine. A hook or MCP config must therefore never reference a path
> outside its own plugin directory. Anything a hook executes at runtime must live
> inside that directory or be provided by the externally installed `cortexcli`
> binary.

---

## Core Capabilities & Tools

1. **SAST Security Context Plan (`get_security_context_plan`)**
   - **What it does:** Dynamically fetches organization-specific SAST rules, secure coding standards, and compliance policies from your Cortex AppSec platform.
   - **Why to use it:** Provides the AI agent with a precise security checklist (such as input validation, cryptographic standards, and secure secret handling) so that generated code complies with your enterprise policies from the start.

2. **Supply Chain Package Risk Enrichment (`enrich_packages`)**
   - **What it does:** Enriches batches of software dependencies with real-time risk assessments from Cortex AppSec, identifying malicious and typosquatted packages across supported ecosystems (NPM, PyPI, Maven, Go Modules, Cargo, NuGet, Composer, Bundler).
   - **Why to use it:** Protects your project before importing or adding new packages to manifests (such as `package.json`, `requirements.txt`, `pom.xml`, `go.mod`, etc.).

3. **Shift-left scanning hooks**
   - Hooks invoke the `cortexcli` binary on every file write/edit, scanning for secrets, SCA and IaC issues **before** the content reaches disk.

---

## Prerequisites & Credentials

To connect the MCP server and the hooks, you will need three credentials from your Cortex account:

- `CORTEX_API_BASE_URL`: The base URL of your Cortex API gateway, including the protocol (e.g., `https://api-<tenant>.xdr.us.paloaltonetworks.com`).
- `CORTEX_API_KEY`: The API key secret for authentication.
- `CORTEX_KEY_ID`: The API key ID associated with the key.

The hooks additionally require the [`cortexcli`](https://github.com/PaloAltoNetworks) binary to be installed and on `PATH`.

### How to Obtain Credentials

1. Log in to your **Cortex** management console.
2. Navigate to **Settings** → **Configurations** → **API Keys**.
3. Create a new API Key (or select an existing key with AppSec permissions).
4. Copy the **Key ID** and the generated **API Key** secret.
5. Determine your **API Base URL** based on your tenant URL.

---

## Installation

### Claude Code

```
/plugin marketplace add PaloAltoNetworks/AppSecMCP
/plugin
```

Install `cortex-appsec` from the marketplace, then reload:

```
/reload-plugins
```

Set credentials in `.claude/settings.local.json` at your project root:

```json
{
  "env": {
    "CORTEX_API_BASE_URL": "<your-cortex-api-base-url>",
    "CORTEX_API_KEY": "<your-cortex-api-key>",
    "CORTEX_KEY_ID": "<your-cortex-key-id>"
  }
}
```

### Cursor

Add the marketplace and install `cortex-appsec`, then provide the credentials.

**Option 1 — Direct configuration (simplest).** Paste actual values into your
workspace `.cursor/mcp.json` or global `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "cortex-appsec": {
      "type": "http",
      "url": "<your-cortex-base-url>/public_api/appsec/v1/stream/mcp",
      "headers": {
        "Authorization": "<your-cortex-api-key>",
        "x-xdr-auth-id": "<your-cortex-key-id>"
      }
    }
  }
}
```

**Option 2 — Environment variables.** Export them and launch Cursor from a terminal:

```bash
export CORTEX_API_BASE_URL="your-cortex-base-url"
export CORTEX_API_KEY="your-cortex-api-key"
export CORTEX_KEY_ID="your-cortex-key-id"

cursor .
```

> On macOS and Linux, GUI applications launched from the Dock do not inherit
> variables from `~/.zshrc` or `~/.bashrc`. Launching via `cursor .` ensures all
> exported variables are passed to Cursor.

---

## Contributing

When changing plugin behavior:

1. Apply the change to **both** `plugins/claude-plugin` and `plugins/cursor-plugin`
   unless it is genuinely agent-specific.
2. Respect each agent's hook schema — see the table above. The two `hooks.json`
   files are **not** interchangeable.
3. Keep the `name` field identical (`cortex-appsec`) across both manifests, and bump
   `version` in both.
4. Never point a hook command or MCP config at a path outside its own plugin
   directory.

---

## Troubleshooting & Support

- **Authentication Errors (401 / 403):** Verify that `CORTEX_API_KEY` and `CORTEX_KEY_ID` are valid, active, and have the appropriate AppSec API permissions.
- **Connection / URL Errors:** Check that `CORTEX_API_BASE_URL` includes `https://` and has no trailing slash.
- **Variables Not Resolving:** Ensure the host was launched from a terminal where the variables were exported, or hardcode the values.
- **Plugin not found by the marketplace:** Confirm the `source` path in the root `marketplace.json` matches the actual plugin directory.
- **Hook not blocking writes:** Verify the correct `--agent` flag for your host, and that `cortexcli` is on `PATH`.
- **Issues & Feedback:**
  - Open an issue on the [GitHub Repository](https://github.com/PaloAltoNetworks/AppSecMCP/issues).
  - For Cortex platform inquiries, visit the [Palo Alto Networks Support Portal](https://support.paloaltonetworks.com/).
