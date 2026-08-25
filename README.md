# Cortex AppSec MCP Plugin for Cursor

The **Cortex AppSec Model Context Protocol (MCP)** plugin integrates Palo Alto Networks Cortex AppSec directly into Cursor, acting as an intelligent real-time security gateway for AI-assisted coding and agentic workflows.

---

## Overview

When AI coding assistants generate, refactor, or review code, they often lack visibility into organizational security policies and open-source supply chain risks. The Cortex AppSec MCP plugin shifts security left by providing real-time security guardrails directly inside Cursor before code is committed or dependencies are introduced.

### Core Capabilities & Tools

1. **SAST Security Context Plan (`get_security_context_plan`)**
   - **What it does:** Dynamically fetches organization-specific SAST rules, secure coding standards, and compliance policies from your Cortex AppSec platform.
   - **Why to use it:** Provides the AI agent with a precise security checklist (such as input validation, cryptographic standards, and secure secret handling) so that generated code complies with your enterprise policies from the start.

2. **Supply Chain Package Risk Enrichment (`enrich_packages`)**
   - **What it does:** Enriches batches of software dependencies with real-time risk assessments from Cortex AppSec, identifying malicious and typosquatted packages across supported ecosystems (NPM, PyPI, Maven, Go Modules, Cargo, NuGet, Composer, Bundler).
   - **Why to use it:** Protects your project before importing or adding new packages to manifests (such as `package.json`, `requirements.txt`, `pom.xml`, `go.mod`, etc.).

---

## Prerequisites & Credentials

To connect the MCP server, you will need three credentials from your Cortex account:

- `CORTEX_API_BASE_URL`: The base URL of your Cortex API gateway, including the protocol (e.g., `https://api-<tenant>.xdr.us.paloaltonetworks.com` or `https://api-<tenant>.<region>.paloaltonetworks.com`).
- `CORTEX_API_KEY`: The API key secret for authentication.
- `CORTEX_KEY_ID`: The API key ID associated with the key.

### How to Obtain Credentials

1. Log in to your **Cortex** management console.
2. Navigate to **Settings** &rarr; **Configurations** &rarr; **API Keys**.
3. Create a new API Key (or select an existing key with AppSec permissions).
4. Copy the **Key ID** and the generated **API Key** secret.
5. Determine your **API Base URL** based on your tenant URL (found in your browser address bar or tenant profile).

---

## Configuration

The plugin manifest in [`mcp.json`](mcp.json) is configured to connect to Cortex AppSec via remote HTTP transport:

```json
{
  "mcpServers": {
    "cortex-appsec": {
      "type": "http",
      "url": "${env:CORTEX_API_BASE_URL}/public_api/appsec/v1/stream/mcp",
      "headers": {
        "Authorization": "${env:CORTEX_API_KEY}",
        "x-xdr-auth-id": "${env:CORTEX_KEY_ID}"
      }
    }
  }
}
```

You can set up the configuration using either of the following approaches:

### Option 1: Direct Configuration in Cursor (Recommended & Simplest)

If you prefer not to manage environment variables, you can paste your **actual values** directly into your workspace [`.cursor/mcp.json`](.cursor/mcp.json) or global `~/.cursor/mcp.json` file:

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

---

### Option 2: Dynamic Environment Variables (`${env:...}`)

If using the default [`mcp.json`](mcp.json) with environment variable placeholders (`${env:CORTEX_...}`), provide the variables to Cursor's process:

#### Method A: Launch Cursor from Terminal (Recommended for CLI workflows)
Define the variables in your shell profile (`~/.zshrc` or `~/.bashrc`) or active terminal session, then launch Cursor from the command line:

```bash
export CORTEX_API_BASE_URL="your-cortex-base-url"
export CORTEX_API_KEY="your-cortex-api-key"
export CORTEX_KEY_ID="your-cortex-key-id"

cursor .
```

> **Why this is needed:** On macOS and Linux, GUI applications launched from the Desktop/Dock do not inherit environment variables from `~/.zshrc` or `~/.bashrc`. Launching via `cursor .` ensures all exported variables are passed to Cursor.

#### Method B: Project `.env` with Environment Auto-Loading
If your project uses environment management tools (such as `direnv`, `dotenv-cli`, or a containerized dev environment), you can define the variables in a `.env` file:

```bash
CORTEX_API_BASE_URL="your-cortex-base-url"
CORTEX_API_KEY="your-cortex-api-key"
CORTEX_KEY_ID="your-cortex-key-id"
```

---

## Troubleshooting & Support

- **Authentication Errors (401 / 403):** Verify that `CORTEX_API_KEY` and `CORTEX_KEY_ID` are valid, active, and have the appropriate AppSec API feature permissions in Cortex.
- **Connection / URL Errors:** Check that `CORTEX_API_BASE_URL` includes the proper protocol (`https://`) and hostname without trailing slashes, and that your network permits outbound HTTPS traffic to your Cortex domain.
- **Variables Not Resolving:** If using `${env:...}`, ensure Cursor was launched from a terminal where the variables were exported, or switch to [Option 1](#option-1-direct-configuration-in-cursor-recommended--simplest).
- **Issues & Feedback:**
  - Open an issue or feature request on the [GitHub Repository](https://github.com/PaloAltoNetworks/AppSecMCP/issues).
  - For Cortex platform inquiries, visit the [Palo Alto Networks Support Portal](https://support.paloaltonetworks.com/).
