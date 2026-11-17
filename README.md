# ai-kit

A Claude Code plugin: an orchestrator session, a few role agents and the skills they load.
Generic — no project, company or person is named here; a place adds its own context through its
own `AGENTS.md`.

## Install

Clone into the user skills folder; it loads as the plugin `ai-kit@skills-dir` in every session:

```bash
git clone <repo-url> ~/.claude/skills/ai-kit
```

After pulling changes: `/reload-plugins` or a new session. Check it loaded: `claude plugin list`.

## What is inside

| Path | What |
|---|---|
| `skills/research/` | `/ai-kit:research` — research on any topic: three depths, blind researchers, link check, a checker that tries to refute claims, verified findings only |
| `skills/brainstorm/` | `/ai-kit:brainstorm` — ideas for a goal: interview, blind research of the field, independent generators with different lenses, selection, hyperbole, a reality loop with research, an attack by critics; three checked ideas at the end |
| `agents/checker.md` | `ai-kit:checker` — the read-only, always-fresh checker every pipeline uses |

## Agent types (design)

- **Orchestrator** — the main session: talks to the human, picks the pipeline, never writes code.
- **Implementer** — writes; loads the skills of its stage; a fresh instance per stage.
- **Checker** — reads only; gets the subject and the criteria, never the author's reasoning.

Skills carry the know-how; agents are just the execution contexts that load them.
