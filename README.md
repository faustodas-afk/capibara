# 🦫 Capibara

Sistema di **team di sviluppo distribuito da CLI** per Claude Code: postura
*agentic engineering* (non vibe coding), ruoli fissi, governance dei modelli,
handoff/resume, milestone e autonomia — tutto guidato da un'unica chat.

Capibara sta in pace con tutti gli "animali" (gli agenti) e li fa lavorare
insieme: tranquillo ma produttivo.

## I ruoli

| Ruolo | Chi | Cosa fa |
|---|---|---|
| **Lead Architect** | umano | visione, obiettivi, vincoli, approva |
| **Senior Engineer** | Claude Code | esegue: codice, test, refactoring, commit |
| **CTO** | Codex (CLI) | roadmap, validazione, autorizza i commit |
| **Consulente** | Agy / Antigravity (CLI) | pareri su decisioni importanti |

Codex e Agy sono CLI esterne invocate dal Senior Engineer via shell; l'unica
interfaccia umana è la chat di Claude Code.

## Struttura (`skill/capibara/`)

- `SKILL.md` — la skill `/capibara` che avvia il team in una cartella.
- `team-session-prompt.md` — il *Model*: postura, ruoli, modelli, governance,
  continuità. Installato come `CLAUDE.md` nel progetto (auto-caricato all'avvio).
- `team-RUNBOOK.md` — l'*Harness*: procedure operative (boot, invocazione
  Codex/Agy, eval, worktree, milestone, debito, handoff/resume).
- `team-init.sh` — prepara una cartella progetto (idempotente, non sovrascrive);
  trova i template accanto a sé, quindi è portabile ovunque venga clonato.

## Installazione

```bash
# clona e installa la skill nella tua home
git clone https://github.com/faustodas-afk/capibara.git
cp -R capibara/skill/capibara "$HOME/.claude/skills/capibara"
# (opzionale) alias comodo
echo 'alias team-init='\''bash "$HOME/.claude/skills/capibara/team-init.sh"'\''' >> "$HOME/.zshrc"
```

## Uso

```bash
cd <cartella-progetto>
# attiva il team in una chat:
#   /capibara          (slash command)
# oppure prepara la cartella a mano:
team-init            # installa CLAUDE.md + RUNBOOK.md

# poi, ogni volta
claude               # nuova chat già governata (zero paste)
claude -c            # riprendi l'ultima sessione (dopo crash o /clear)
```

All'avvio: cartella senza codice → progetto nuovo (greenfield, chiede l'obiettivo);
cartella con progetto esistente → ispeziona prima, poi imposta la governance
**senza sovrascrivere** il lavoro svolto.

## Impostazioni Claude Code consigliate (`~/.claude/settings.json`)

- `permissions.defaultMode: "auto"` — meno conferme; si ferma solo su
  distruttivo/irreversibile/sicurezza.
- `totalTokensReminder: "countdown"` — il modello vede sempre il contesto
  rimanente (regola handoff a ~40%).
- `fileCheckpointingEnabled: true` — `/rewind` ripristina i file.
- `cleanupPeriodDays: 90` — transcript conservati a lungo per il recupero.

Recupero da crash: riaprire il terminale nella cartella e `claude -c` /
`claude --resume` (Claude Code persiste la sessione a ogni turno).

## Principi (dal whitepaper Google "The New SDLC With Vibe Coding")

- Verifica = contratto (test + eval prima di dichiarare *fatto*).
- Problema dell'80%: il giudizio umano sul 20% difficile.
- Agent = Model + Harness: i fallimenti sono quasi sempre di configurazione.
- Context engineering: contesto denso, statico vs dinamico.
- Milestone `Vx.x` per cronistoria e rollback; segreti in file separato.

## Autore

**Fausto Dasè** ([@faustodas-afk](https://github.com/faustodas-afk)).

Capibara versiona il *sistema* di lavoro, non il codice dei progetti.
