# Project RUNBOOK — team operational procedures

Team template. Copy it to the root of every project as `RUNBOOK.md` and adapt it.
It holds the repeatable procedures (the *Harness*) that the startup prompt (the
*Model*) refers to. Keep it lean: loaded on demand, not every turn.

> Project default constraints: **no GitHub, no remote, no PR** for work-project
> code. Git local only. Any future remote must be private, not shared, and only
> after the LA's explicit OK. All backups stay local.

---

## 1. Task startup protocol

**First thing: new project or existing one?**
- **Folder with no code (only CLAUDE.md/RUNBOOK.md, or empty)** → new, unknown
  project. Greenfield mode: ask the LA for the goal, don't assume requirements,
  start from the roadmap (Codex). No code files until there's a direction.
- **Folder with an existing project** → inspect BEFORE proposing changes
  (structure, `git status`, README, key files) to understand what's there. The
  governance (CLAUDE.md/RUNBOOK.md) is added **without overwriting** existing
  work; `team-init` guarantees this at the file level.

When the LA gives a goal, before modifying any file:

1. `git status --short` + current branch (if the project is git); otherwise note
   the folder state.
2. Read the guide files: this `RUNBOOK.md`, `AGENTS.md`/`CLAUDE.md`, relevant READMEs.
3. Identify the authorized workspace/repo (don't leave it).
4. Prepare a brief for Codex (see template §2) with: goal, repo state,
   constraints, active model, guide files found, initial risks.
5. Ask Codex for roadmap + first step + verification criteria.
6. Reads/inspections only until Codex has given the roadmap.

---

## 2. Codex (CTO) invocation template

`codex exec --skip-git-repo-check "<...>"` — always include:

- **Goal** (from the LA)
- **Active model** of the SE
- **Repo/workdir** and a brief git status
- **Relevant static context** (excerpts of `AGENTS.md`/`CLAUDE.md` if present)
- **Roadmap / current step state**
- **Diff or changed files**, if in a verification phase
- **Tests/evals run** with their result
- **The decision requested** of Codex

## 2b. Agy (Advisor) invocation template

`agy --print "<...>"` (non-interactive mode; `agy` requires a TTY without
`--print`). Use for important decisions (architecture, trade-offs, irreversible
choices). Include: setup/roles, the decision at hand, options with trade-offs, the
SE's reservation, a sharp question. Agy doesn't see the session: self-contained
context.

---

## 3. Operational eval

Use an eval when the result has **non-deterministic** quality: UX, large
refactors, ranking, text generation, agentic workflows, architectural decisions.
(For purely deterministic logic, tests are enough.)

Every eval must have:
- a **rubric** with observable criteria (what is measured)
- an acceptance **threshold** (pass/fail)
- **cases** positive/negative or scenarios
- a **repeatable procedure** (command, checklist, or script)

Bar at the eval, not the demo: a demo proves it works once, an eval that it works
reliably.

---

## 4. Worktree / dirty-file policy

Before modifying, check the folder state:
- Don't overwrite changes that aren't yours or untracked files.
- If a file already modified is needed, read it and integrate conservatively.
- Substantial conflict or wrong branch → stop and ask the LA.

---

## 5. Milestones and backup `Vx.x`

At every important milestone (Codex authorizes the commit that closes a
module/phase, or the LA approves a stable state). Purpose: history + local
rollback.

**If the project is git (preferred):**
```
git tag vX.Y            # e.g. git tag v1.1 -m "module X stable, make test green"
git tag                 # list milestones
git checkout vX.Y       # inspect/rollback to a milestone
```
No push: tags stay local.

**If the project is NOT git (or a browsable/zippable physical backup is needed):**
```
mkdir -p milestones/Vx.x
rsync -a --exclude node_modules --exclude target --exclude __pycache__ \
      --exclude '.git' --exclude milestones ./ milestones/Vx.x/
```
Then create `milestones/Vx.x/NOTES.md`:
```
# Vx.x — <milestone title>
Date: <YYYY-MM-DD>
Status: stable (why: <green tests/evals, criteria met>)
Reference: <commit/hash or description>
Contents: <what this snapshot includes>
Rollback: restore this folder if the working version breaks.
```

**Naming:** `major.minor` — `minor` at every working milestone, `major` at
structural changes/releases. Everything stays local to the project.

---

## 5b. Sensitive data / secrets

If the LA provides usernames, passwords, API keys, tokens, or other secrets:

- Put them in a dedicated file outside the code, e.g. `secrets.local.json` or
  `.env`, and reference it from the source (never hard-code).
- Add the file to `.gitignore` **and** to the `Vx.x` snapshot exclusions:
  ```
  # .gitignore
  .env
  secrets.local.*
  ```
  ```
  # snapshot: add to the rsync --exclude list
  --exclude '.env' --exclude 'secrets.local.*'
  ```
- Version only a template without real values (`.env.example` / `secrets.example.json`).
- For production the file is removable/replaceable without modifying the code.
- Never print secrets in output passed to Codex/Agy or in logs/reports.

---

## 6. Escalation / fallback

- `codex` or `agy` unavailable, failed, timed out, or with ambiguous output →
  don't proceed by guessing: report to the LA the command, the error, and what
  was needed.
- Missing project tool/command (e.g. `make`, test runner) → flag it to the LA,
  don't silently work around it.

---

## 7. Current state (update after each step)

A short live memo of the state, so the session stays in sync:

```
Goal: <...>
Active model: <opus|fable|...>
Current step: <n> — <description>
Status: <in progress | in Codex review | awaiting OK | committed>
Last milestone: <Vx.x / tag>
```

---

## 8. Tracked technical debt (`ponytail:`)

Every deliberate shortcut/simplification leaves a comment naming its ceiling and
upgrade path, so a deferral doesn't silently become permanent:

```
# ponytail: <ceiling reached>, <trigger to revisit>
# e.g.: ponytail: global lock, switch to per-account locks if throughput matters
```

At each milestone (§5), before freezing the snapshot, scan the debt:

```
grep -rnE '(#|//) ?ponytail:' . --exclude-dir=.git --exclude-dir=node_modules
```

- Each hit = one ledger row: `<file>:<line>, <what is simplified>. ceiling: <...>. upgrade: <...>`.
- Flag `no-trigger` the markers with no upgrade path: those are the ones that rot.
- Optional: persist the ledger in the project's `PONYTAIL-DEBT.md`.

Purpose: keep the debt visible and reviewed at stable states, not scattered.

---

## 9. Handoff, resume, and crash recovery

**Planned handoff (~40% context).** When the context countdown drops toward ~60%
remaining (≈40% used), before exhausting it:
1. Write `RESUME.md` at the project root (and, if you want a single point,
   `~/.claude/handoffs/latest-resume.md`) with:
   ```
   # Resume — <project> — <YYYY-MM-DD HH:MM>
   Goal: <...>
   Active model: <...>
   Current step: <n> — <status> (in Codex review / awaiting OK / ...)
   Last milestone: <Vx.x / tag>
   Done so far: <bullets>
   Next steps: <bullets>
   Key files: <path:line>
   Open decisions: <...>
   ```
2. Print the resume content in chat.
3. Prompt the user for `/clear`; in the new session you resume by reading `RESUME.md`.

Automatic full-context warnings: GSD's context-monitor is **already active
globally** (warns the agent at 35%/25% remaining context for any project; depends
on the statusline, not on `.planning/`). To disable it in a project:
`.planning/config.json` → `"hooks": { "context_warnings": false }`.

In GSD projects: use `/gsd-pause-work` (handoff) and `/gsd-resume-work` (restore).
Startup project-state injection (`.planning/STATE.md`) instead requires GSD
initialized + `.planning/config.json` with `"hooks": { "community": true }`.

**Crash recovery (frozen PC/terminal).** Claude Code persists the session to disk
every turn; nothing needs to be done in advance.
- Reopen the terminal **in the same project folder**.
- `claude -c` → automatically continues that folder's last session.
- `claude --resume` → list of sessions, pick the right one.
- Context and work point are restored. `claude-mem` injects cross-session memory;
  if present, also read `RESUME.md` to get oriented.
- Files: `/rewind` restores file state (checkpoints active via
  `fileCheckpointingEnabled`).

**Autonomy.** The session runs in `defaultMode: auto`: ordinary operations don't
ask for confirmation; only destructive/irreversible/security actions still
prompt. The workflow's logical gates (Codex's OK to commit, consulting Agy) remain
and must be respected regardless.
