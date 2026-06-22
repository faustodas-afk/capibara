#!/usr/bin/env bash
# init.sh — Capibara: prepare a project folder for the team workflow.
# Usage: bash init.sh [folder]   (default: current folder)
# Idempotent: never overwrites existing files; appends the prompt to an existing
# CLAUDE.md only if it isn't already there (marker).
set -euo pipefail

# Templates live in the same folder as this script (portable).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_PROMPT="$SCRIPT_DIR/session-prompt.md"
SRC_RUNBOOK="$SCRIPT_DIR/runbook.md"
MARK="<!-- team-session-prompt -->"

dir="${1:-$PWD}"
[ -d "$dir" ] || { echo "✗ folder does not exist: $dir" >&2; exit 1; }
[ -f "$SRC_PROMPT" ] || { echo "✗ missing $SRC_PROMPT" >&2; exit 1; }
[ -f "$SRC_RUNBOOK" ] || { echo "✗ missing $SRC_RUNBOOK" >&2; exit 1; }

# RUNBOOK: copy if absent
if [ -f "$dir/RUNBOOK.md" ]; then
  echo "• RUNBOOK.md already present, left as is"
else
  cp "$SRC_RUNBOOK" "$dir/RUNBOOK.md"
  echo "✓ RUNBOOK.md copied"
fi

# CLAUDE.md: create, or append the prompt if not already marked
if [ ! -f "$dir/CLAUDE.md" ]; then
  { echo "$MARK"; cat "$SRC_PROMPT"; } > "$dir/CLAUDE.md"
  echo "✓ CLAUDE.md created (team prompt auto-loaded at startup)"
elif grep -qF "$MARK" "$dir/CLAUDE.md"; then
  echo "• CLAUDE.md already contains the team prompt, nothing to do"
else
  { echo; echo "$MARK"; cat "$SRC_PROMPT"; } >> "$dir/CLAUDE.md"
  echo "✓ team prompt appended to the existing CLAUDE.md"
fi

echo "Ready. Open:  cd \"$dir\" && claude   (or: claude -c to resume)"
