---
name: capibara
description: >
  Start or set up the Capibara team workflow in a project folder: fixed roles
  (Lead Architect = human, Senior Engineer = Claude, CTO = Codex CLI, Advisor =
  Agy/Antigravity CLI), model governance, Vx.x milestones, handoff/resume,
  agentic-engineering posture. Use this skill whenever the user says
  "/capibara", "start capibara", "set up the team", "kick off the system",
  "initialize the project with the workflow", or when starting to work in a
  folder where the team governance should be established. Installs CLAUDE.md +
  RUNBOOK.md if missing (without overwriting existing work), then loads the
  governance and distinguishes a new project from an existing one.
---

# Capibara — starting the team

Capibara is the CLI development-team system. This skill prepares the current
folder and starts the workflow. The `init.sh` script and the templates
(`session-prompt.md`, `runbook.md`) live **in this same skill folder**
(self-contained).

## Steps

1. **Prepare the current folder** (idempotent, never overwrites anything):
   ```
   bash "$HOME/.claude/skills/capibara/init.sh" "$PWD"
   ```
   (if the skill is installed elsewhere, use the `init.sh` next to this SKILL.md)
   It copies `RUNBOOK.md` and installs the team prompt as `CLAUDE.md` (if a
   `CLAUDE.md` already exists, it appends below the marker without touching the rest).

2. **Load the governance**: read `CLAUDE.md` (roles, models, autonomy, rules),
   then `RUNBOOK.md` (procedures: Codex/Agy invocation, eval, worktree,
   milestones, debt, handoff). If `RESUME.md` exists, read it: it is the single
   source of project state.

3. **Distinguish new vs existing** (see RUNBOOK §1):
   - **Folder with no code** → new, unknown project. Greenfield: ask the Lead
     Architect for the goal, don't assume requirements, start from the roadmap
     (Codex). No code files until there is a direction.
   - **Folder with an existing project** → inspect first (structure,
     `git status`, README, key files), then set up the governance **without
     overwriting** existing work.

4. **Declare state and start**: announce the active model (default Opus 4.8),
   confirm the team is up, and follow the flow:
   goal (LA) → roadmap (Codex) → execute → verify (Codex) → important decision?
   consult Agy → commit only after Codex's OK.

## Notes

- External CLIs don't see the session: every `codex`/`agy` invocation must carry
  all the context. Commands: `codex exec --skip-git-repo-check "..."`,
  `agy --print "..."`.
- Crash recovery: reopen the terminal in the folder and run `claude -c` or
  `claude --resume`.
- The detailed governance lives in the project files (CLAUDE.md/RUNBOOK.md); it
  is not repeated here: this skill activates it, it does not replace it.
