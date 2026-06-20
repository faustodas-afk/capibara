#!/usr/bin/env bash
# team-init.sh — Capibara: prepara una cartella progetto per il workflow di team.
# Uso: bash team-init.sh [cartella]   (default: cartella corrente)
# Idempotente: non sovrascrive file esistenti; accoda il prompt a un CLAUDE.md
# già presente solo se non c'è già (marcatore).
set -euo pipefail

# I template stanno nella stessa cartella di questo script (portabile).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_PROMPT="$SCRIPT_DIR/team-session-prompt.md"
SRC_RUNBOOK="$SCRIPT_DIR/team-RUNBOOK.md"
MARK="<!-- team-session-prompt -->"

dir="${1:-$PWD}"
[ -d "$dir" ] || { echo "✗ cartella inesistente: $dir" >&2; exit 1; }
[ -f "$SRC_PROMPT" ] || { echo "✗ manca $SRC_PROMPT" >&2; exit 1; }
[ -f "$SRC_RUNBOOK" ] || { echo "✗ manca $SRC_RUNBOOK" >&2; exit 1; }

# RUNBOOK: copia se assente
if [ -f "$dir/RUNBOOK.md" ]; then
  echo "• RUNBOOK.md già presente, lasciato com'è"
else
  cp "$SRC_RUNBOOK" "$dir/RUNBOOK.md"
  echo "✓ RUNBOOK.md copiato"
fi

# CLAUDE.md: crea, oppure accoda il prompt se non già marcato
if [ ! -f "$dir/CLAUDE.md" ]; then
  { echo "$MARK"; cat "$SRC_PROMPT"; } > "$dir/CLAUDE.md"
  echo "✓ CLAUDE.md creato (prompt di team auto-caricato all'avvio)"
elif grep -qF "$MARK" "$dir/CLAUDE.md"; then
  echo "• CLAUDE.md contiene già il prompt di team, niente da fare"
else
  { echo; echo "$MARK"; cat "$SRC_PROMPT"; } >> "$dir/CLAUDE.md"
  echo "✓ prompt di team accodato al CLAUDE.md esistente"
fi

echo "Pronto. Apri:  cd \"$dir\" && claude   (oppure: claude -c per riprendere)"
