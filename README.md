# 🦫 Capibara

A **distributed CLI development team** for Claude Code: an *agentic engineering*
posture (not vibe coding), fixed roles, model governance, handoff/resume,
milestones and autonomy — all driven from a single chat.

The capybara gets along with every "animal" (the agents) and makes them work
together: calm but productive.

## Roles

| Role | Who | Does |
|---|---|---|
| **Lead Architect** | human | vision, goals, constraints, approves |
| **Senior Engineer** | Claude Code | executes: code, tests, refactoring, commits |
| **CTO** | Codex (CLI) | roadmap, validation, authorizes commits |
| **Advisor** | Agy / Antigravity (CLI) | opinions on important decisions |

Codex and Agy are external CLIs invoked by the Senior Engineer via shell; the
only human interface is the Claude Code chat.

## Structure (`skill/capibara/`)

- `SKILL.md` — the `/capibara` skill that starts the team in a folder.
- `team-session-prompt.md` — the *Model*: posture, roles, models, governance,
  continuity. Installed as the project's `CLAUDE.md` (auto-loaded at startup).
- `team-RUNBOOK.md` — the *Harness*: operational procedures (boot, Codex/Agy
  invocation, eval, worktree, milestones, debt, handoff/resume).
- `team-init.sh` — prepares a project folder (idempotent, never overwrites);
  finds its templates next to itself, so it is portable wherever it is cloned.

## Installation

```bash
# clone and install the skill into your home
git clone https://github.com/faustodas-afk/capibara.git
cp -R capibara/skill/capibara "$HOME/.claude/skills/capibara"
# (optional) handy alias
echo 'alias team-init='\''bash "$HOME/.claude/skills/capibara/team-init.sh"'\''' >> "$HOME/.zshrc"
```

## Usage

```bash
cd <project-folder>
# start the team in a chat:
#   /capibara          (slash command)
# or prepare the folder manually:
team-init            # installs CLAUDE.md + RUNBOOK.md

# then, every time
claude               # new chat, already governed (zero paste)
claude -c            # resume the last session (after a crash or /clear)
```

At startup: a folder with no code → new project (greenfield, asks for the goal);
a folder with an existing project → inspect first, then set up the governance
**without overwriting** existing work.

## Recommended Claude Code settings (`~/.claude/settings.json`)

- `permissions.defaultMode: "auto"` — fewer prompts; stops only on
  destructive/irreversible/security actions.
- `totalTokensReminder: "countdown"` — the model always sees remaining context
  (handoff rule at ~40%).
- `fileCheckpointingEnabled: true` — `/rewind` restores files.
- `cleanupPeriodDays: 90` — transcripts kept longer for recovery.

Crash recovery: reopen the terminal in the folder and run `claude -c` /
`claude --resume` (Claude Code persists the session every turn).

## Principles (from the Google whitepaper "The New SDLC With Vibe Coding")

- Verification = contract (tests + evals before declaring something *done*).
- The 80% problem: human judgment on the hard 20%.
- Agent = Model + Harness: failures are almost always configuration failures.
- Context engineering: dense context, static vs dynamic.
- `Vx.x` milestones for history and rollback; secrets in a separate file.

## Author

**Fausto Dasè** ([@faustodas-afk](https://github.com/faustodas-afk)).

Capibara versions the *working system*, not the code of the projects.
