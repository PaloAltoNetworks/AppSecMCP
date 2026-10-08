#!/usr/bin/env bash
# Cortex AppSec shift-left scanning hook.
#
# Invoked by Claude Code PreToolUse / PostToolUse hooks. Runs the externally
# installed `cortexcli` binary to scan file writes/edits before and after they
# reach disk.
#
# Usage: scan.sh <framework>
#   <framework>  cortexcli scan framework, e.g. "combined" or "iac".

set -euo pipefail

FRAMEWORK="${1:-combined}"


CORTEX_HIDE_UPDATE_NOTICE=1 cortexcli \
  --api-base-url "${CORTEX_API_BASE_URL}" \
  --api-key "${CORTEX_API_KEY}" \
  --api-key-id "${CORTEX_KEY_ID}" \
  code ai-hook \
  --agent claude-code \
  --framework "${FRAMEWORK}"
