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

---

## Core Capabilities & Tools

1. **SAST Security Context Plan (`get_security_context_plan`)**
   - **What it does:** Dynamically fetches organization-specific SAST rules, secure coding standards, and compliance policies from your Cortex AppSec platform.
   - **Why to use it:** Provides the AI agent with a precise security checklist (such as input validation, cryptographic standards, and secure secret handling) so that generated code complies with your enterprise policies from the start.

2. **Supply Chain Package Risk Enrichment (`enrich_packages`)**
   - **What it does:** Enriches batches of software dependencies with real-time risk assessments from Cortex AppSec, identifying malicious and typosquatted packages across supported ecosystems (NPM, PyPI, Maven, Go Modules, Cargo, NuGet, Composer, Bundler).
   - **Why to use it:** Protects your project before importing or adding new packages to manifests (such as `package.json`, `requirements.txt`, `pom.xml`, `go.mod`, etc.).

3. **Shift-left scanning hooks**
   - Hooks invoke the `cortexcli` binary on every file write/edit, scanning for secrets and SCA issues **before** the content reaches disk, and IAC after file was written.

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

## Troubleshooting & Support

- **Authentication Errors (401 / 403):** Verify that `CORTEX_API_KEY` and `CORTEX_KEY_ID` are valid, active, and have the appropriate AppSec API permissions.
- **Connection / URL Errors:** Check that `CORTEX_API_BASE_URL` includes `https://` and has no trailing slash.
- **Variables Not Resolving:** Ensure the host was launched from a terminal where the variables were exported, or hardcode the values.
- **Plugin not found by the marketplace:** Confirm the `source` path in the root `marketplace.json` matches the actual plugin directory.
- **Hook not blocking writes:** Verify the correct `--agent` flag for your host, and that `cortexcli` is on `PATH`.
- **Issues & Feedback:**
  - Open an issue on the [GitHub Repository](https://github.com/PaloAltoNetworks/AppSecMCP/issues).
  - For Cortex platform inquiries, visit the [Palo Alto Networks Support Portal](https://support.paloaltonetworks.com/).
