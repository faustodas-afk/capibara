---
name: capibara
description: >
  Avvia o imposta il workflow di team Capibara in una cartella di progetto:
  ruoli fissi (Lead Architect umano, Senior Engineer = Claude, CTO = Codex CLI,
  Consulente = Agy/Antigravity CLI), governance dei modelli, milestone Vx.x,
  handoff/resume, postura agentic-engineering. Usa questa skill ogni volta che
  l'utente dice "/capibara", "avvia capibara", "imposta il team", "parti col
  sistema", "inizializza il progetto col workflow", oppure quando si comincia a
  lavorare in una cartella e va stabilita la governance del team. Installa
  CLAUDE.md + RUNBOOK.md se mancano (senza sovrascrivere il lavoro esistente),
  poi carica la governance e distingue progetto nuovo da progetto esistente.
---

# Capibara — avvio del team

Capibara è il sistema di team di sviluppo da CLI. Questa skill prepara la cartella
corrente e fa partire il workflow. Lo script `team-init.sh` e i template
(`team-session-prompt.md`, `team-RUNBOOK.md`) stanno **in questa stessa cartella
skill** (auto-contenuta).

## Passi

1. **Prepara la cartella corrente** (idempotente, non sovrascrive nulla):
   ```
   bash "$HOME/.claude/skills/capibara/team-init.sh" "$PWD"
   ```
   (se la skill è installata altrove, usa lo `team-init.sh` accanto a questo SKILL.md)
   Copia `RUNBOOK.md` e installa il prompt di team come `CLAUDE.md` (se un
   `CLAUDE.md` esiste già, accoda sotto il marcatore senza toccare il resto).

2. **Carica la governance**: leggi `CLAUDE.md` (ruoli, modelli, autonomia,
   regole), poi `RUNBOOK.md` (procedure: invocazione Codex/Agy, eval, worktree,
   milestone, debito, handoff). Se esiste `RESUME.md`, leggilo: è l'unica fonte
   di stato del progetto.

3. **Distingui nuovo vs esistente** (vedi RUNBOOK §1):
   - **Cartella senza codice** → progetto nuovo e sconosciuto. Greenfield: chiedi
     l'obiettivo al Lead Architect, non assumere requisiti, parti dalla roadmap
     (Codex). Niente file di codice finché non c'è una direzione.
   - **Cartella con progetto esistente** → ispeziona prima (struttura,
     `git status`, README, file chiave), poi imposta la governance **senza
     sovrascrivere** il lavoro svolto.

4. **Dichiara lo stato e parti**: comunica il modello attivo (default Opus 4.8),
   conferma che il team è in piedi, e procedi col flusso:
   obiettivo (LA) → roadmap (Codex) → esegui → verifica (Codex) → decisione
   importante? consulta Agy → commit solo dopo OK Codex.

## Note

- Le CLI esterne non vedono la sessione: ogni invocazione di `codex`/`agy` deve
  contenere tutto il contesto. Comandi: `codex exec --skip-git-repo-check "..."`,
  `agy --print "..."`.
- Recupero da crash: riaprire il terminale nella cartella e `claude -c` o
  `claude --resume`.
- La governance dettagliata vive nei file di progetto (CLAUDE.md/RUNBOOK.md), non
  va ripetuta qui: questa skill serve ad attivarla, non a sostituirla.
