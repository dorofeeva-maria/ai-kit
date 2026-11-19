---
name: project
description: Start a software project from zero — from a chosen idea to a ready workspace. Writes the idea file, then runs the product stage (MVP cut, feature order, prioritised tasks), the architecture stage (parts, repos, stack, data, every choice reasoned), an independent check of both against the idea, the human's approval, and the setup stage (repos, tooling, tests, CI, kit profile); ends with the first task to take. Coordinator for the main session. Use for "start a project", "new project from this idea", "set up a project for…", or after a brainstorm picked an idea.
---

# project — from a chosen idea to a ready workspace

You are the **orchestrator** of the [contract](../../docs/contract.md): you talk to the human, keep
the state file, start agents in the background and pass files between them. You write no plan, no
architecture and no code — only `idea.md`, the state file and the human's decisions. You read
agents' short replies and the files you must show the human, not their whole work.

Why this shape: an idea goes wrong in predictable places — a product that tries to ship everything,
an architecture copied from what most projects use, a setup that pre-builds features. Separate
stages with one job each, an independent check against the idea before anything is built, and the
human's approval at the two expensive turns (the MVP cut, the architecture) catch these early,
when changing course costs a file and not a codebase.

`<ws>` is the workspace folder; `<kit>` is the kit's root (two levels above this skill's base
directory). Layout, task file, findings and briefs are as in the contract.

## Input — a chosen idea

- **Normally** the result file of `ai-kit:brainstorm` (or the idea the human picked from it).
- **No result file:** offer two options — run `ai-kit:brainstorm` first (recommended when the idea
  is still vague), or a short interview now: what it is, for whom, what winning looks like, real
  limits (time, money, deadline), what already exists, what must not be done. Ask until you could
  explain it to a stranger; contradictions and doubts are asked, not guessed.

Take today's date with a tool. Ask the human, in one batch with defaults, only what the place does
not already say:

- **The workspace** — where it lives and its name. It is a private git repo of its own (idea,
  plan, tasks). The place's rules win: it may be a private repo registered in a system the human
  already keeps, with that system's naming and remote.
- **The project name** — the working name of the product, used in `idea.md` and the plan. Default:
  the workspace's name, unless the human names the product otherwise.
- **The code repos** — not named now. They are separate repos; their names and visibility (private
  or public) come from the architecture, and each remote is created only on its own yes at setup
  (§6).
- The language with the human (default: theirs) and of files (default: English), and the stop
  level (default `approve`).

The workspace's remote is a separate question, asked on its own (here or with the §6 asks), and
created only on an explicit yes for it. Default: none, or what the place already set.

Every Agent call below passes `model` and `effort` by the contract's "Models".

## Size — say your choice in one line

| | short pass | full pass |
|---|---|---|
| For | one repo, one deployable, one kind of user, little shared data (a CLI, a library, a bot, a small app) | several parts (front and back, services, apps), several user roles, shared data, payments, personal data, integrations |
| Product | one page: MVP, cuts, order, tasks | full plan, a request to development per feature |
| Architecture | one page, one repo section | full: parts, data flows, schema, per-repo sections |
| Pairs | never | a second independent pass when the size asks for it (below) |
| Check | one checker, both stages together | one checker per stage, or both together if small |

**When the size asks for a pair** (full pass only): three or more parts that talk to each other,
money or sensitive personal data, a choice the checker flagged as BLOCKS twice, or the human asks.
A pair is a second implementer on the same stage, from the same inputs, blind to the first; the
checker compares the two and the first author merges what the second did better. Say why you pair.

## State

The start is tracked like a task: `<ws>/tasks/START/START.md` in the contract's task-file format (stage,
round counters, the human's decisions with dates), agents' reports in `<ws>/tasks/START/notes/`.
A new session continues from it. At the end the `START/` folder moves to `tasks/done/START/`.

## 1. Workspace and `idea.md`

Create `<ws>` (or use the one the place made) and `tasks/`. Write `<ws>/idea.md` from the
brainstorm result or the interview, the human's words quoted with dates where they decided
something:

```markdown
# <project name> — idea
## The idea            <!-- the pitch in one line, then a paragraph -->
## For whom and why    <!-- who is better off and how anyone would notice -->
## Decisions           <!-- dated; the human's are final -->
## Evidence            <!-- what research showed, with sources -->
## Open hypotheses     <!-- what must still be true; the riskiest first; its quick test -->
## Limits              <!-- time, money, what must not be done -->
## Change log          <!-- dated: what changed in the idea and why -->
```

Nothing from the brainstorm's graveyard or the generators' reasoning goes in — only the chosen idea.

## 2. Product stage

Start `ai-kit:implementer`, `model: opus`, `effort: high` (the MVP cut is weighing options):

```
Product stage of a new project. Workspace: <ws>. Today is <YYYY-MM-DD>.
First read the product skill (ai-kit:product), then <ws>/idea.md. Mode: plan. Size: <short|full>.
Decisions already made: <the human's, dated, or "none">.
Never: <limits from idea.md; no code, no repos>.
Write <ws>/product.md and the tasks in <ws>/tasks/; report to <ws>/tasks/START/notes/product.md.
Reply: conclusion in two lines, the MVP list, open questions with your default.
```

Questions it returns go to the human with options and a recommendation; work that does not depend
on them continues. With stops `approve` and the human present, show the MVP cut as soon as it
exists — their remarks reach the architect while it works, not after.

## 3. Architecture stage

Two phases: the architect gathers first, writes only after. Start a fresh `ai-kit:implementer`,
`model: fable` (if unavailable, `opus`), `effort: high`:

```
Architecture stage of a new project, phase 1 (gather). Workspace: <ws>. Today is <YYYY-MM-DD>.
First read the architecture skill (ai-kit:architecture), then idea.md, product.md, tasks/.
Size: <short|full>. Decisions already made: <…>.
Never: <…>; no repos, no code; no architecture.md before the gather list is answered.
Report to <ws>/tasks/START/notes/architecture.md (the gather list under ## Gather).
Reply: conclusion in two lines; the gather list (facts to research, missing requirements with
defaults, limits to confirm) — or "none", then go on and write.
```

1. **Facts** — run `ai-kit:research` yourself, by its SKILL.md, giving each question neutrally
   (never the architect's preferred answer); depth `quick` per fact, `standard` for a comparison
   of options.
2. **Missing requirements and limits** — ask the human, with the architect's defaults. Do not let
   it guess.
3. **Write** — continue the **same** instance: "Phase 2: write <ws>/architecture.md; report into the
   same file under ## Result. Research: <report paths>. The human's answers: <…>." A new question in
   its reply is one more gather round (1–3 again); it does not write "not verified".

## 4. Independent check

A fresh `ai-kit:checker`, `model: opus`, `effort: high`. It gets the files, never the authors'
replies or reports:

```
Check the product plan and the architecture of a new project against its idea. Today is <date>.
Subject: <ws>/product.md, <ws>/tasks/, <ws>/architecture.md. The idea: <ws>/idea.md.
Criteria: every MVP point serves the idea and nothing the idea needs is silently missing; every cut
has a reason; every task has checkable acceptance criteria and what is out; the order respects
dependencies and tests the riskiest hypothesis early; the architecture covers every MVP feature
and builds nothing the MVP does not need; every decision has why, rejected alternatives and
limits; no decision is marked "not verified" and every assumption states its risk; the schema and
data flows support the features; product and architecture do not contradict each other; each repo
section is enough to create that repo without guessing.
Findings in the contract's format (<kit>/docs/contract.md). Write <ws>/tasks/START/notes/check-1.md.
```

Fix loop: findings go to the **same** author instance (product or architect — it remembers); the
same checker re-checks per finding. Cap: 3 rounds, then the surviving finding goes to the human
with both sides. A finding that argues with the human's decision is rejected.

## 5. Stop — by the stop level

- `approve` (default): show the human the MVP cut (in, out with reasons, order) and the
  architecture (parts, stack, data, the biggest trade-off) — short, with what the check found and
  what stayed open. Nothing is set up before their yes; their changes go back to stage 2 or 3.
- `blockers`: go on unless the check left a BLOCKS; tell the human the stage passed.
- `own`: go on; report at the end.

A change to the idea itself (not just the plan) is logged in `idea.md`'s Change log with the reason.

## 6. Setup stage

Before it, ask the human **separately for each** code repo's remote (with its name and visibility),
account, paid service or anything public the architecture calls for — a yes once is not a yes for
the next one. Ask about the workspace's own remote here too, as its own question, if it was not
settled at the start. Then start a fresh `ai-kit:implementer`, `model: sonnet`:

```
Setup stage of a new project. Workspace: <ws>. Today is <YYYY-MM-DD>.
First read the setup skill (ai-kit:setup), then architecture.md, idea.md, product.md.
Mode: create. Approved by the human: <each repo remote with its name and visibility / account /
service, or "none — local only">.
Workspace remote: <set by the place / approved, private / none>.
Stops: <level>. Never: <…>; no product feature; nothing remote, paid or public beyond the list.
Report to <ws>/tasks/START/notes/setup.md.
Reply: conclusion in two lines; each check command and whether it ran green; what could not run.
```

Run one check command from its list yourself (cheap claim). Anything red or not run goes back to
the same instance; cap 3 rounds.

## 7. Handoff

Tell the human, briefly: the workspace path and its remote, if any; the code repos (local / remote,
private / public); the MVP in one line each; what was checked by running, by reading, not at all;
open hypotheses. Name the **first task** — the highest-priority one in `tasks/` (often the design
system or the thinnest end-to-end slice) — to take with `ai-kit:task`. Append the run-log line
(contract, "Run log", key `START`) to `tasks/runs.md`. Move the `tasks/START/` folder to
`tasks/done/START/`.

## Never

- Create a remote repository, an account, a paid service or anything public without the human's
  explicit yes for that one thing.
- Write the plan, the architecture or code yourself, or skip the check because the plan looks fine.
- Give a checker the authors' reasoning, or a researcher the hoped-for answer.
