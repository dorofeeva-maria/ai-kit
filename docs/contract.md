# ai-kit contract

What every skill and agent of the kit agrees on. A skill may add detail; it may not contradict
this file. The kit is generic: **no project, company, product, person, server or tracker key is
named anywhere in it.** A place brings its own context through its profile.

## Agent types

| Type | What it is | Rules |
|---|---|---|
| **Orchestrator** | the main session running a coordinator skill (`task`, `project`, `research`, `brainstorm`) | Talks to the human, picks the pipeline, keeps the state file, starts agents in the background and in parallel, passes findings between them, checks cheap claims itself, decides small technical questions without asking. **Writes no code**: edits only the workspace's state files (`tasks/`, its notes, `idea.md` in a project start, the profile on the human's word); any change to a repo or to tooling goes to an implementer. "Tooling" includes the kit's own skills and docs and the workspace's rules and scripts (`AGENTS.md`, `CLAUDE.md`, `docs/`, `scripts/`, `.claude/`): the orchestrator never edits them itself — an implementer does, and an independent checker checks the change. Reads agents' short replies, not their work. |
| **Implementer** | `ai-kit:implementer` | The only one that writes into a tree. Loads the skill of its stage. A fresh instance per stage; within a stage's fix loop the same instance is continued (it remembers). Parallel instances only for independent parts in separate worktrees. |
| **Checker** | `ai-kit:checker` | Changes nothing, always fresh. May run checks, start the app and use a browser. Gets the subject and the criteria, never the author's reasoning. Loads the check guide named in its brief. Read-only by rule: Write is allowed only for its own report. |

Subagents cannot start subagents: only the orchestrator starts agents.

**No one writes into a repo's main checkout** — no agent, no session, in a task or outside one.
Every change of a repo, even a one-line local fix to unblock the human, is made in a worktree on
its own branch. The main checkout belongs to the human: it may hold their uncommitted work, and an
edit there mixes with it, skips every check and is lost or committed by mistake. The only thing
that may change in a main checkout is which branch it has checked out, through the place's shared
slot for a run, and it goes back to the base branch right after. If the human needs a fix to run
something now, push it on a worktree branch and offer to check that branch out through the slot.

**Think it through before the human sees it.** A design, a pattern, a plan, a recommendation or an
explanation is walked through step by step on one concrete case before it is shown: what the
person sees, what they press, what happens, in every state, in every app it touches. Then a fresh
agent checks that walkthrough for logic — every control or message named exists in that state and
does what is said, no step contradicts another or a rule of the place, nothing promised is lost
(text, data, focus), each part has a reason to be there. The human gets the walkthrough together
with the result, after the check is clean. A gap the human has to find (a button that is said to
be both there and gone; a feature that solves nothing in this case) means this step was skipped.

## Skills

Coordinators: `task`, `project`, `research`, `brainstorm`.
Stage skills (loaded by the implementer, also usable by hand): `product`, `architecture`, `setup`,
`journey`, `plan`, `develop`, `docs`.
Check guides live with the coordinator that uses them (`skills/<coordinator>/references/check-*.md`);
a coordinator with a single short check may give the criteria in the checker's brief.

A stage skill's `SKILL.md` is written for whoever does the stage — an implementer agent or the
human's own session — and never assumes it can start agents.

## The place's profile — `.claude/kit-profile.md`

In the workspace root. Plain markdown with these headings (a missing heading = the default):

```markdown
# Kit profile
## Repos            <!-- table: folder · what it is · base branch · sync (on only where others work too) -->
## Checks           <!-- per repo: the commands that must be green (lint, types, tests, build) -->
## Run              <!-- per repo: how to start the app for a function or look check -->
## Tasks            <!-- where tasks come from (tasks/ files, a tracker), key format, branch naming, keys the kit must not take -->
## Git and PRs      <!-- commit format, PR title and description rules, draft or not, who is assigned, a worktree command if not the default -->
## Autonomy         <!-- stops: approve | blockers | own · merge: pr | auto-low | full -->
## Design           <!-- design system location(s), screen sizes -->
## Extra stages     <!-- place-only skills and when they run, e.g. an end-to-end test on a stand; default steps replaced or switched off (e.g. architecture: always | never) -->
## Never            <!-- what must not be read, changed or taken outside -->
## Language         <!-- language with the human; language of code, commits and docs -->
```

Defaults: stops `approve`, merge `pr`, tasks in `tasks/` files, sync off, the human's language for
conversation and English for everything that goes into repos.

`Extra stages` may add steps, and may also **replace or switch off** a default step of a coordinator
skill when the place has its own way of doing it; the coordinator then follows the profile for that
step.

Before the profile exists (a project being started), the coordinator asks the human for the stop
level and the languages once, and setup writes them into the profile.

Inside a repo that repo's own `AGENTS.md` / `CLAUDE.md` win over the profile and over the kit.

## Workspace layout

```
<workspace>/
  .gitignore             ignores every repo folder and worktrees/
  AGENTS.md              what is where, in a page
  idea.md                the idea, its decisions, its change log     (project pipeline)
  product.md             features, the MVP cut and the order                  (project pipeline)
  architecture.md        the general picture only; details live in each repo's docs
  .claude/kit-profile.md
  tasks/<KEY>.md         one task: state, decisions, links
  tasks/<KEY>-plan.md    the plan, when it is too long for the task file
  tasks/<KEY>-notes/     agents' reports for that task
  tasks/START.md         state of the project start, before any task key exists (+ START-notes/)
  tasks/runs.md          the run log
  tasks/done/
  worktrees/<KEY>/<repo>/
  <repo>/ …
```

The workspace tracks under git only `AGENTS.md`, `idea.md`, `product.md`, `architecture.md`,
`.claude/` and `tasks/`; its `.gitignore` (written by setup) keeps every code repo folder and
`worktrees/` out, so a sync tool that auto-commits the workspace never picks up code.

Task keys: the place's format; default `T-001`, `T-002`…

## Task file — `tasks/<KEY>.md`

```markdown
# <KEY> — <title>
status: backlog | in work | review | done | dropped · priority: <n> · kind: feature | bug | debt (optional)

## Request            <!-- the human's words, quoted, with dates; acceptance criteria -->
## Scope              <!-- repos touched; what is out of scope -->
## Decisions          <!-- dated; the human's are final -->
## Plan               <!-- short, or a link to <KEY>-plan.md -->
## State              <!-- stage · branches and PRs per repo · round counters per loop -->
## Tried and dropped
## Next step
```

A new session continues from this file, not from an old conversation.

## Findings — one format for every checker

```
Each finding: number · level · what is wrong · evidence (path:line, command and output,
URL, screen and moment) · the smallest fix.
Levels: BLOCKS (broken, or against the request) · MUST (fix before merge) · MINOR (may wait) ·
TASTE (not fixed).
At most 12, the worst first. No "what is good".
Verdict at the end: satisfied / not satisfied.
```

The author of the checked work answers the checker — the same instance, continued. After a fix
the implementer re-runs the place's checks itself; the orchestrator runs them once more on the last
commit before handoff. Round counts per loop are kept in the task file's State.

A loop ends when a check has no BLOCKS and no MUST on the same commit. TASTE is never fixed. A
finding that widens the task or argues with the human's decision is rejected. **Loop cap: 3
rounds** — a finding that survives goes to the human with both sides. Re-check: the same checker
answers per finding "closed / not closed / the fix made a new one"; after the human decides a
capped finding, the next check is a fresh checker.

## Autonomy levels

Stops: `approve` — the human approves the plan and the mock-ups (in a project start: the MVP cut and
the architecture) · `blockers` — an independent check replaces the approval, the human sees the
ready PR · `own` — as `blockers`, and the orchestrator may merge (below). A change of the stop
level for one task is recorded in that task's Decisions.

Merge: `pr` — the human merges · `auto-low` — the orchestrator merges only changes the profile
lists as low-risk, after green checks and review · `full` — the orchestrator merges after green
checks and an independent review. **The orchestrator merges only when the stop level is `own` and
the merge level allows that change; under `approve` and `blockers` the human merges, whatever the
merge level.**

## Run log

At handoff the orchestrator appends one line to `tasks/runs.md`: date · key (`START` for a project
start) · size · agents started · total tokens (summed from the usage each agent reports back) ·
wall time · rounds per loop · findings per level for each checker · what the human found after
handoff (filled in later by `task`'s "After handoff"). Numbers only — it shows which role earns its
cost. `task` and `project` each append their own line.

## Briefs

An agent knows only its brief. Every brief has: the task in one line and the workspace path · what
to read first (profile, task file, the repo's own rules, the stage skill or check guide) · the
subject · what the human approved, where the stage needs an approval (a remote repo, an account,
a paid service, anything public) · what must not be done (from the profile's Never) · where to write the report and what the
reply must contain. Authors are told their decisions; checkers are never told the author's
reasoning.

Reports: a file `tasks/<KEY>-notes/<role>-<part>-<round>.md` plus a short reply; artefacts that are
not reports (`research.md`, `mockups.html`, `manual-check.md`) keep a plain name, and the project
start names its reports by stage (`START-notes/product.md`, `check-1.md`…). Conclusion first, in
two lines. For every statement — checked by running, checked by reading, or not checked. If a file write is
refused, the agent returns the text and the orchestrator saves it. Claude Code always refuses a
subagent's Write of a markdown file whose name starts with `report`, `summary`, `findings` or
`analysis`: a step whose output is such a document returns it as text and the orchestrator (the
main session) saves it — never work around that refusal. Reports are written in the
language the profile sets for talking with the human.

## Models

The Agent tool call takes `model` and `effort`; the orchestrator passes both on every call, by the
kind of work. Thinking roles — architecture, plan, plan check, review, selection, the product cut —
get a strong model (`opus`) — the strongest (`fable`) for the hardest work: a large architecture,
the critique of a large plan — and `effort: high` (the human of this kit asked for high effort on
thinking roles). Ordinary implementation — a strong model; mechanical work (setup, running checks,
gathering) — a cheaper one; both at the default effort. Effort is never set in agent definitions.
Tests and linters are run by command, not by a model; the implementer reads the failures.

## Human

Only what matters, briefly: a stage passed, a blocker, a question. A question comes with options and
a recommendation, and work that does not depend on it continues. Small technical decisions are made
without asking. Done means: PRs ready to merge under the place's rules, listed in merge order, with
what was checked by running, by reading, and not at all.
