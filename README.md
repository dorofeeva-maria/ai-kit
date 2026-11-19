# ai-kit

A Claude Code plugin: an orchestrator session, a few role agents and the skills they load.
Generic — no project, company or person is named here; a place adds its own context through
`.claude/kit-profile.md` (see [docs/contract.md](docs/contract.md)).

## Install

Clone into the user skills folder; it loads as the plugin `ai-kit@skills-dir` in every session:

```bash
git clone <repo-url> ~/.claude/skills/ai-kit
```

After pulling changes: `/reload-plugins` or a new session. Check it loaded: `claude plugin list`.

## What is inside

| Path | What |
|---|---|
| [`docs/contract.md`](docs/contract.md) | what every skill and agent agrees on: agent types, profile, workspace layout, findings, autonomy, briefs, models |
| `skills/task/` | `/ai-kit:task` — coordinator: one development task from the request to ready PRs (research, questions, mock-ups, plan, implementation in worktrees, checks, docs, handoff) |
| `skills/project/` | `/ai-kit:project` — coordinator: a chosen idea to a ready workspace (idea, product, architecture, check, setup) |
| `skills/research/` | `/ai-kit:research` — coordinator: research on any topic: three depths, blind researchers, link check, a checker that tries to refute claims, verified findings only |
| `skills/brainstorm/` | `/ai-kit:brainstorm` — coordinator: invent something new for any goal when nothing suitable exists: interview, blind research, independent generators, selection, hyperbole, a reality loop, an attack by critics; three checked ideas |
| `skills/decide/` | `/ai-kit:decide` — coordinator: choose among solutions that already exist: the place's own way, what others do (research), the human's proposal as a candidate; pros against cons with weights, hybrids, an attack by a critic, a checked walkthrough; a recommendation (calls brainstorm only if every option is weak) |
| `skills/prs/` | `/ai-kit:prs` — read-only: one person's open PRs (MRs) across the workspace for a period, grouped by task, each with what it waits for (review, rebase, pipeline, close) |
| `skills/product/` | stage: MVP cut, feature order, one task file per feature; triage of new requests |
| `skills/architecture/` | stage: parts, repos, stack, data, every decision reasoned; change mode |
| `skills/setup/` | stage: repos, tooling, checks, CI, the kit profile and the workspace files; repair mode |
| `skills/journey/` | stage: the user's path step by step (what they see, do, hear, where they go next) before mock-ups and plan; checked as a first-time user |
| `skills/plan/` | stage: the plan of a task — per repo changes, contract between parts, PRs, estimate, forks |
| `skills/develop/` | stage: implement one planned part and its tests; run the place's checks |
| `skills/docs/` | stage: docs for people and AI, decisions, the PR description — last, before the PR is ready |
| `agents/implementer.md` | `ai-kit:implementer` — the only agent that writes into a tree; loads its stage skill |
| `agents/checker.md` | `ai-kit:checker` — the read-only, always-fresh checker every pipeline uses |

## Task-stage tools

| Skill | When it runs |
|---|---|
| `/ai-kit:sync` | Task startup or on request. Refreshes clean bases and reports incoming changes. |
| `/ai-kit:design` | Before a visible change is implemented. Produces one board from the journeys and the profile. |
| `/ai-kit:e2e` | On request or when the profile and plan call for a live end-to-end scenario. |

The [tooling reference](skills/task/references/tooling.md) covers worktree creation and cleanup,
repository reports, task folder moves and optional sync reminders.

## Agent types

- **Orchestrator** — the main session: talks to the human, picks the pipeline, never writes code.
- **Implementer** — writes; loads the skills of its stage; a fresh instance per stage.
- **Checker** — reads only; gets the subject and the criteria, never the author's reasoning.

Skills carry the know-how; agents are just the execution contexts that load them.
