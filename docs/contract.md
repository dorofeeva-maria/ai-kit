# ai-kit contract

What every skill and agent of the kit agrees on. A skill may add detail; it may not contradict
this file. The kit is generic: **no project, company, product, person, server or tracker key is
named anywhere in it.** A place brings its own context through its profile.

## Agent types

| Type | What it is | Rules |
|---|---|---|
| **Orchestrator** | the main session running a coordinator skill (`task`, `project`, `research`, `brainstorm`, `decide`) | Talks to the human, picks the pipeline, keeps the state file, starts agents in the background and in parallel, passes findings between them, checks cheap claims itself, decides small technical questions without asking. **Writes no code**: edits only the workspace's state files (`tasks/`, its notes, `idea.md` in a project start, the profile on the human's word); any change to a repo or to tooling goes to an implementer. "Tooling" includes the kit's own skills and docs and the workspace's rules and scripts (`AGENTS.md`, `CLAUDE.md`, `docs/`, `scripts/`, `.claude/` except `kit-profile.md`, which the orchestrator edits on the human's word): the orchestrator never edits them itself — an implementer does, and an independent checker checks the change. Reads agents' short replies, not their work. |
| **Implementer** | `ai-kit:implementer` | The only one that writes into a tree. Loads the skill of its stage. A fresh instance per stage; within a stage's fix loop the same instance is continued (it remembers). The `journey` stage spans the outline and its completion from the mock-ups, so its instance is continued between them. Parallel instances only for independent parts in separate worktrees. |
| **Checker** | `ai-kit:checker` | Changes nothing, always fresh. May run checks, start the app and use a browser. Gets the subject and the criteria, never the author's reasoning. Loads the check guide named in its brief. Read-only by rule: Write is allowed only for its own report. |

Subagents cannot start subagents: only the orchestrator starts agents.

**No one writes into a code repo's main checkout** — the place's product repos, where the human
keeps uncommitted work — no agent, no session, in a task or outside one. Every change of a code repo, even a one-line local fix to unblock the
human, is made in a worktree on
its own branch. The main checkout belongs to the human: it may hold their uncommitted work, and an
edit there mixes with it, skips every check and is lost or committed by mistake. The only thing
that may change in a main checkout is which branch it has checked out, through the place's shared
slot for a run, and it goes back to the base branch right after. If the human needs a fix to run
something now, push it on a worktree branch and offer to check that branch out through the slot.

The workspace's own files and the kit are not code repos. They are changed by an implementer, in
place, in atomic commits, and then an independent checker checks the change. The orchestrator
itself writes only state files (`tasks/`, its notes).

**Think it through before the human sees it.** A design, a pattern, a plan, a recommendation or an
explanation is walked through step by step on one concrete case before it is shown: what the
person sees, what they press, what happens, in every state, in every app it touches. Then a fresh
agent checks that walkthrough for logic — every control or message named exists in that state and
does what is said, no step contradicts another or a rule of the place, nothing promised is lost
(text, data, focus), each part has a reason to be there. The human gets the walkthrough together
with the result, after the check is clean. A gap the human has to find (a button that is said to
be both there and gone; a feature that solves nothing in this case) means this step was skipped.

## Skills

Coordinators: `task`, `project`, `research`, `brainstorm` (invent something new), `decide` (choose
among solutions that exist).
Tools for the human: `prs` (one person's open PRs across the workspace, with what each waits for;
read-only), `wrap` (end of the day in one session: settles background work and prints a short
recap with the stage and this task's PRs ready for review; writes nothing).
Tools for any session that talks to the human (loaded by that session itself, start no agents):
`debate` (honest argument when the human's words disagree with research or sources, or on request).
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
## Run              <!-- per app: startup for agent checks and human review, including the environment, access, shared resources, and cleanup -->
## Tasks            <!-- where tasks come from (tasks/ files, a tracker, issues); every place the team keeps tasks and what "open" means there (read for duplicates and related, task step 1); key format, branch naming, keys the kit must not take -->
## Git and PRs      <!-- code host and the tool to reach it; commit format, PR title and description rules, draft or not, who is assigned, a worktree command if not the default -->
## Reviewers        <!-- per repo, kind of task or area: code host usernames set as reviewers when a PR is created; review order; default none -->
## Autonomy         <!-- stops: approve | blockers | own · merge: pr | auto-low | full -->
## Sync             <!-- optional: adapter / after commands per repo, submodules, reminder hours (skills/sync) -->
## Design           <!-- design system location(s), screen sizes -->
## End-to-end       <!-- optional trigger, environment, tools, data and slot rules for a planned live run -->
## Extra stages     <!-- place-only skills and when they run, e.g. an end-to-end test on a stand; default steps replaced or switched off (e.g. architecture: always | never) -->
## Never            <!-- what must not be read, changed or taken outside -->
## Language         <!-- language with the human; language of code, commits and docs -->
```

Defaults: stops `approve`, merge `pr`, tasks in `tasks/` files, sync off, the human's language for
conversation and English for everything that goes into repos.

`Extra stages` may add steps, and may also **replace or switch off** a default step of a coordinator
skill when the place has its own way of doing it; the coordinator then follows the profile for that
step.

For changed UI, the profile may change the runner, placement or checker of visual acceptance.
Independent visual evidence remains a handoff requirement. An exception requires an explicit
human waiver of the named gap and scope, recorded in the task file.

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
  tasks/README.md        the place's notes on its tasks (optional)
  tasks/runs.md          the run log
  tasks/<status>/        a folder per status: backlog/, in-work/, review/, done/, dropped/
    <KEY>/               everything of one task, and nothing else
      <KEY>.md           the task file: state, decisions, links
      plan.md            the plan, when it is too long for the task file
      research/          research, related tasks, facts, their checks
      design/            journeys, mock-ups (with their sources), their checks
      plan/              the planner's and architect's reports, plan checks
      <part>/            one per part of the plan (= one PR): develop, review, function and look
                         checks, the PR description draft
        <run>/           a run that left files: <run>.md inside, screenshots and logs beside it
      e2e/               end-to-end runs and the manual check, a folder per run
      other/             what fits no stage
    START/               the project start, before any task key exists: START.md + notes/
                         (in `in-work/`, then `done/`)
  worktrees/<KEY>/<repo>/
  <repo>/ …
```

The workspace tracks under git only `AGENTS.md`, `idea.md`, `product.md`, `architecture.md`,
`.claude/` and `tasks/`; its `.gitignore` (written by setup) keeps every code repo folder and
`worktrees/` out, so a sync tool that auto-commits the workspace never picks up code.

The workspace is its own git repo, private by default. It may be a private repo registered in a
system the human already keeps; then that system's rules decide its place, name, remote and sync.
Its remote, if any, follows those rules or the human's yes. Code repos are separate repos with their
own names and visibility (possibly public), decided by the architecture and each approved on its
own. They live as ignored subfolders `<ws>/<repo>/`, so nothing private from the workspace reaches a
public repo and no code reaches the workspace. A public code repo's files, commits and PR text never
copy the workspace's private content (idea, plan, task notes) and link nothing in it.

Task keys: the place's format; default `T-001`, `T-002`…

**One folder per task, in the folder of its status.** Nothing about a task lies loose in `tasks/`:
the task file, the plan and every agent output go into `tasks/<status>/<KEY>/`, so the human sees
what is in work, what waits for review and what is done at a glance. The status folder always
matches the task file's `status:` line (`in work` → `in-work/`): whoever changes the status moves
the folder in the same step, never while an agent of the task is running, and fixes full-path
links to it. Inside it, every agent output goes into the folder of its stage or part; only the
task file and the plan lie at the top. Work without a task key (a review of the kit, a one-off check
of the tooling) gets a folder too, named by a short slug (`tasks/kit-review-2026-11-18/`), with a
file of the same name. Links inside a task's folder are relative (`plan.md`,
`plan/check-plan-1.md`); from elsewhere they name the full path. An older layout (flat
`tasks/<KEY>.md`, `<KEY>-plan.md`, `<KEY>-notes/`, one `notes/` folder, no status folder) is laid out by stage
when the task is next continued, its links fixed, and anything an agent still writes to an old
path is moved in after it.

## Task file — `tasks/<status>/<KEY>/<KEY>.md`

```markdown
# <KEY> — <title>
status: backlog | in work | review | done | dropped · priority: <n> · kind: feature | bug | debt (optional)

## Request            <!-- the human's words, quoted, with dates; acceptance criteria -->
## Scope              <!-- repos touched; what is out of scope -->
## Decisions          <!-- dated; the human's are final -->
## Plan               <!-- short, or a link to plan.md -->
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
subject · what the human approved, where the stage needs an approval (the workspace remote, a code
repo's remote with its visibility, an account, a paid service, anything public) · what must not be
done (from the profile's Never) · where to write the report and what the reply must contain. Authors
are told their decisions; checkers are never told the author's reasoning.

Reports: a file `tasks/<status>/<KEY>/<stage or part>/<role>-<part>-<round>.md` plus a short reply; a run
that leaves screenshots, logs or recordings is a folder `<role>-<part>-<round>/` with the report
inside under the same name and its files beside it; artefacts that are
not reports (`research.md`, `mockups.html`, `manual-check.md`) keep a plain name, and the project
start names its reports by stage (`START/notes/product.md`, `check-1.md`…). Conclusion first, in
two lines. For every statement — checked by running, checked by reading, or not checked. If a file write is
refused, the agent returns the text and the orchestrator saves it. Claude Code always refuses a
subagent's Write of a markdown file whose name starts with `report`, `summary`, `findings` or
`analysis`: a step whose output is such a document returns it as text and the orchestrator (the
main session) saves it — never work around that refusal. Reports are written in the
language the profile sets for talking with the human.

**A large result is built in parts.** An agent whose result is a large file (a board, a report, a
plan, a long document) writes the skeleton first, then fills it part by part and saves the file
after each part. At the top of its report it keeps a short progress note: done / next. A run that is
cut off (usage limit, crash) then leaves a usable partial file. When a run fails, the orchestrator
continues the same agent, or starts a new one pointed at the partial file and its progress note —
it never restarts from zero while a partial result exists.

## Models

The Agent tool call takes `model` and `effort`; the orchestrator passes both on every call, by the
kind of work. Thinking roles — architecture, plan, plan check, review, selection, the product cut —
get a strong model (`opus`) — the strongest (`fable`) for the hardest work: a large architecture,
the critique of a large plan — and `effort: high` (the human of this kit asked for high effort on
thinking roles). Ordinary implementation — a strong model; mechanical work (setup, running checks,
gathering) — a cheaper one; both at the default effort. Effort is never set in agent definitions.
Tests and linters are run by command, not by a model; the implementer reads the failures.

## Human

Before implementation, the plan names the manual scenarios, automated tests, and CI jobs that
will cover the task. The architect defines the testing approach when the architecture stage runs.
Otherwise the planner defines it from the profile and the existing project. The plan checker
checks that the proposed coverage and review environment are feasible.

At handoff, prepare and verify a runnable review environment for each affected app, following
the profile's Run section. The review instance must serve the changes being handed over. A
staging or production URL can meet this requirement when that instance already serves those
changes and the planned checks are allowed there. For a native app, give its device, emulator or
desktop entry point. Give two separate lists: PRs in merge order and manual testing links or entry
points. Record any resources held during the human's review and release them when the review
window ends.

Only what matters, briefly: a stage passed, a blocker, a question. A question comes with options and
a recommendation, and work that does not depend on it continues. Small technical decisions are made
without asking.

**Quiet while working.** The human runs several sessions at once and gets context back on demand
(Claude Code's `/recap`, or by asking), not from a stream of messages. So while work runs, a
coordinator writes almost nothing to the chat: no narration of its own steps, and progress of
agents or other sessions in at most a few words ("research: 3 of 6") or not at all. When it needs
the human, one line: "need your answer: <topic>" — no context dump. The full exchange starts when
the human comes back and asks; then explain the question with its problem, options and
recommendation, short, and plainly enough for someone who forgot the whole conversation. A question
that blocks nothing still never gets decided by default unless the place allows it. Done means: PRs ready to merge under the place's rules, listed in merge order, with
what was checked by running, by reading, and not at all.

## Disagreeing with the human

The goal is the best decision, not winning. Every coordinator and stage that talks to the human:

- **Argues when the evidence disagrees.** When a proposal or answer of the human contradicts verified
  sources or what research found, say so before acting on it: the claim, the source and how strong it
  is, and what follows. Be most critical where the human adds structure, rules, tracking or
  strictness. Agreeing to be pleasant is a failure.
- **Weighs the human's arguments honestly.** Their own experience, context and constraints are
  evidence too, often better than a general study. When their argument is stronger, say so plainly
  and take their side; when parts of both hold, propose the compromise and say why it is better
  than either side.
- **Keeps it open and short.** Both sides may change their mind. Name what would change yours. After
  the argument, the human decides; record the decision and the argument that settled it with the
  decision. (Checkers inside a loop still don't argue with a recorded decision — see Findings.)

The step-by-step procedure for all of this: [`skills/debate`](../skills/debate/SKILL.md).
