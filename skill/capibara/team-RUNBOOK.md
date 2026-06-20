# RUNBOOK di progetto — procedure operative del team

Template di team. Copialo nella radice di ogni progetto come `RUNBOOK.md` e
adattalo. Contiene le procedure ripetibili (l'*Harness*) che il prompt di avvio
(il *Model*) richiama. Tienilo snello: caricato on-demand, non a ogni turno.

> Vincoli fissi del progetto: **niente GitHub, niente remote, niente PR.** Git
> solo locale. Un eventuale remoto futuro dev'essere privato, non condiviso, e
> solo dopo OK esplicito del LA. Tutti i backup restano locali.

---

## 1. Protocollo di avvio task

**Prima cosa: nuovo progetto o esistente?**
- **Cartella senza codice (solo CLAUDE.md/RUNBOOK.md, o vuota)** → progetto nuovo
  e sconosciuto. Modalità greenfield: chiedi l'obiettivo al LA, non assumere
  requisiti, parti dalla roadmap (Codex). Niente file di codice finché non c'è una
  direzione.
- **Cartella con un progetto esistente** → ispeziona PRIMA di proporre modifiche
  (struttura, `git status`, README, file chiave) per capire cosa c'è. La
  governance (CLAUDE.md/RUNBOOK.md) si aggiunge **senza sovrascrivere** il lavoro
  già presente; `team-init` lo garantisce a livello di file.

Quando il LA dà un obiettivo, prima di modificare qualsiasi file:

1. `git status --short` + branch corrente (se il progetto è git); altrimenti nota
   lo stato della cartella.
2. Leggi i file guida: questo `RUNBOOK.md`, `AGENTS.md`/`CLAUDE.md`, README rilevanti.
3. Identifica workspace/repo autorizzato (non uscirne).
4. Prepara un brief per Codex (vedi template §2) con: obiettivo, stato repo,
   vincoli, modello attivo, file guida trovati, rischi iniziali.
5. Chiedi a Codex roadmap + primo passo + criteri di verifica.
6. Solo letture/ispezioni finché Codex non ha dato la roadmap.

---

## 2. Template invocazione Codex (CTO)

`codex exec --skip-git-repo-check "<...>"` — includi sempre:

- **Obiettivo** (dal LA)
- **Modello attivo** del SE
- **Repo/workdir** e stato git sintetico
- **Contesto statico** rilevante (estratti di `AGENTS.md`/`CLAUDE.md` se presenti)
- **Roadmap / stato del passo corrente**
- **Diff o file cambiati**, se si è in fase di verifica
- **Test/eval eseguiti** con risultato
- **Decisione richiesta** a Codex

## 2b. Template invocazione Agy (Consulente)

`agy --print "<...>"` (modalità non-interattiva; `agy` richiede TTY senza `--print`).
Usa per decisioni importanti (architettura, trade-off, scelte irreversibili).
Includi: setup/ruoli, oggetto della decisione, opzioni con trade-off, riserva del
SE, domanda netta. Agy non vede la sessione: contesto autosufficiente.

---

## 3. Eval operativa

Usa un eval quando il risultato ha qualità **non deterministica**: UX, refactoring
ampio, ranking, generazione testo, workflow agentici, decisioni architetturali.
(Per logica puramente deterministica bastano i test.)

Ogni eval deve avere:
- **rubrica** con criteri osservabili (cosa si misura)
- **soglia** di accettazione (pass/fail)
- **casi** positivi/negativi o scenari
- **procedura ripetibile** (comando, checklist o script)

Bar all'eval, non alla demo: una demo prova che funziona una volta, l'eval che
funziona affidabilmente.

---

## 4. Policy worktree / file sporco

Prima di modificare, controlla lo stato della cartella:
- Non sovrascrivere modifiche non tue o file non tracciati.
- Se un file già modificato è necessario, leggilo e integra conservativamente.
- Conflitto sostanziale o branch sbagliato → fermati e chiedi al LA.

---

## 5. Milestone e backup `Vx.x`

A ogni milestone importante (Codex autorizza il commit che chiude un modulo/fase,
o il LA approva uno stato stabile). Scopo: cronistoria + rollback locale.

**Se il progetto è git (preferito):**
```
git tag vX.Y            # es. git tag v1.1 -m "modulo X stabile, make test verde"
git tag                 # elenco milestone
git checkout vX.Y       # ispeziona/rollback a una milestone
```
Niente push: i tag restano locali.

**Se il progetto NON è git (o serve backup fisico navigabile/zippabile):**
```
mkdir -p milestones/Vx.x
rsync -a --exclude node_modules --exclude target --exclude __pycache__ \
      --exclude '.git' --exclude milestones ./ milestones/Vx.x/
```
Poi crea `milestones/Vx.x/NOTES.md`:
```
# Vx.x — <titolo milestone>
Data: <YYYY-MM-DD>
Stato: stabile (perché: <test/eval verdi, criteri soddisfatti>)
Riferimento: <commit/hash o descrizione>
Contenuto: <cosa include questo snapshot>
Rollback: ripristina questa cartella se la versione di lavoro si rompe.
```

**Naming:** `major.minor` — `minor` a ogni milestone funzionante, `major` a cambi
strutturali/release. Tutto resta locale al progetto.

---

## 5b. Dati sensibili / segreti

Se il LA fornisce user, password, API key, token o altri segreti:

- Mettili in un file dedicato fuori dal codice, es. `secrets.local.json` o `.env`,
  e referenzialo dal sorgente (mai hard-coding).
- Aggiungi il file a `.gitignore` **e** alle esclusioni degli snapshot `Vx.x`:
  ```
  # .gitignore
  .env
  secrets.local.*
  ```
  ```
  # snapshot: aggiungi alle --exclude di rsync
  --exclude '.env' --exclude 'secrets.local.*'
  ```
- Versiona solo un template senza valori reali (`.env.example` / `secrets.example.json`).
- Per la produzione il file è rimovibile/sostituibile senza modificare il codice.
- Mai stampare segreti negli output passati a Codex/Agy o nei log/report.

---

## 6. Escalation / fallback

- `codex` o `agy` non disponibili, falliti, in timeout o con output ambiguo →
  non procedere a indovinare: riporta al LA il comando, l'errore e cosa serviva.
- Tool/comando di progetto mancante (es. `make`, runner test) → segnala al LA,
  non aggirare silenziosamente.

---

## 7. Stato corrente (aggiornare dopo ogni passo)

Breve memo vivo dello stato, così la sessione resta sincronizzata:

```
Obiettivo: <...>
Modello attivo: <opus|fable|...>
Passo corrente: <n> — <descrizione>
Stato: <in corso | in verifica Codex | atteso OK | committato>
Ultima milestone: <Vx.x / tag>
```

---

## 8. Debito tecnico tracciato (`ponytail:`)

Ogni scorciatoia/semplificazione deliberata lascia un commento che ne nomina il
limite e il percorso di upgrade, così un rinvio non diventa silenziosamente
permanente:

```
# ponytail: <limite raggiunto>, <trigger per rivederlo>
# es: ponytail: lock globale, passare a lock per-account se il throughput conta
```

A ogni milestone (§5), prima di congelare lo snapshot, scansiona il debito:

```
grep -rnE '(#|//) ?ponytail:' . --exclude-dir=.git --exclude-dir=node_modules
```

- Ogni hit = una riga di registro: `<file>:<riga>, <cosa è semplificato>. limite: <...>. upgrade: <...>`.
- Flagga `no-trigger` i marker senza percorso di upgrade: sono quelli che marciscono.
- Opzionale: persisti il registro in `PONYTAIL-DEBT.md` del progetto.

Scopo: tenere il debito visibile e rivisto agli stati stabili, non disperso.

---

## 9. Handoff, resume e recupero da crash

**Handoff pianificato (contesto ~40%).** Quando il countdown del contesto scende
verso il ~60% rimanente (≈40% usato), prima di esaurirlo:
1. Scrivi `RESUME.md` nella radice del progetto (e, se vuoi un punto unico,
   `~/.claude/handoffs/latest-resume.md`) con:
   ```
   # Resume — <progetto> — <YYYY-MM-DD HH:MM>
   Obiettivo: <...>
   Modello attivo: <...>
   Passo corrente: <n> — <stato> (in verifica Codex / atteso OK / ...)
   Ultima milestone: <Vx.x / tag>
   Fatto finora: <bullet>
   Prossimi passi: <bullet>
   File chiave: <path:linea>
   Decisioni aperte: <...>
   ```
2. Stampa il contenuto del resume in chat.
3. Invita l'utente al `/clear`; alla nuova sessione ripartirai leggendo `RESUME.md`.

Warning automatici a contesto pieno: il context-monitor di GSD è **già attivo
globalmente** (avvisa l'agente a 35%/25% di contesto rimanente per qualsiasi
progetto; dipende dalla statusline, non da `.planning/`). Per disattivarlo in un
progetto: `.planning/config.json` → `"hooks": { "context_warnings": false }`.

In progetti GSD: usa `/gsd-pause-work` (handoff) e `/gsd-resume-work` (ripristino).
L'iniezione dello stato progetto all'avvio (`.planning/STATE.md`) richiede invece
GSD inizializzato + `.planning/config.json` con `"hooks": { "community": true }`.

**Recupero da crash (PC/terminale impallato).** Claude Code persiste la sessione
su disco a ogni turno; non serve fare nulla in anticipo.
- Riapri il terminale **nella stessa cartella** del progetto.
- `claude -c` → continua automaticamente l'ultima sessione di quella cartella.
- `claude --resume` → elenco delle sessioni, scegli quella giusta.
- Il contesto e il punto di lavoro vengono ripristinati. `claude-mem` inietta la
  memoria cross-sessione; se presente, leggi anche `RESUME.md` per orientarti.
- File: `/rewind` ripristina lo stato dei file (checkpoint attivi via
  `fileCheckpointingEnabled`).

**Autonomia.** La sessione è in `defaultMode: auto`: le operazioni ordinarie non
chiedono conferma; restano a conferma solo distruttive/irreversibili/sicurezza
(più `git push` che è negato del tutto). I gate logici del workflow (OK Codex per
il commit, consulto Agy) restano e vanno rispettati comunque.
