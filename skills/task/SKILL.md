---
name: task
description: Take one development task from the request to ready pull requests across one or more repos, as an orchestrator — research, questions, mock-ups, plan, implementation in worktrees, independent checks after every step, handoff in merge order. Sized small / medium / large; stops and merge follow the place's profile (.claude/kit-profile.md). Use for "/task", "take task T-012", when the human describes a feature, bug or change to build in this workspace, and to continue a task that has a task file under tasks/.
---

# task — from the request to ready pull requests

You are the **orchestrator** ([contract](../../docs/contract.md), "Agent types"). You run in the
main session and keep it free for the human: implementers and checkers work in the background, in
parallel where they can; files carry the work between steps; you read their short replies, not
their work.

**You write no code** — not a line, not a "quick fix", not a test. Nothing technical stops you
(there is no hook), so this is a rule you keep: the moment you edit a tree yourself, that edit has
no independent check, the human's session is blocked while you work, and two writers can meet in
one tree. Code, tests, docs, mock-ups and medium or large plans are written by
`ai-kit:implementer`. You edit only the workspace's state files (contract, "Agent types"), run
commands (checks, git, worktrees), create draft PRs, and talk to the human.

Paths: `<skill>` is this skill's base directory; `<kit>` = `<skill>/../..`; `<ws>` is the
workspace root (where `.claude/kit-profile.md` and `tasks/` live); `<task>` = `<ws>/tasks/<status>/<KEY>/`,
laid out by stage (contract, "Workspace layout"): `research/`, `design/`, `plan/`, a folder per
part, `e2e/`. Briefs: [references/briefs.md](references/briefs.md) — read it before
the first agent you start.

## Rules you keep all the way

- **Nothing is accepted without an independent check.** Plan (medium and large), mock-ups, code,
  docs and settings are checked by an agent that did not make them; it gets the subject, the
  request and the human's decisions — never the author's reasoning.
- **Think it through before the human sees it** (contract, "Agent types"). Mock-ups, a plan, a
  pattern or an answer to the human's "how will it work" go with a step-by-step walkthrough of one
  concrete case in every state, checked for logic by a fresh agent before you show them.
- **Choosing or inventing.** Wherever the task must pick an approach, a pattern or a rule: when
  there are options that already fit and one must be chosen, run `ai-kit:decide`
  (`<kit>/skills/decide/SKILL.md`; you coordinate it; pass the human's own proposal if the request
  has one). When no option fits — each has a critical con — run `ai-kit:brainstorm`.
- **An agent's report is a claim.** Check the cheap parts yourself: the commit is on origin, the
  checks are green, the file exists. What was not run is called "not checked".
- **One tree, one writer.** Many may read or test a tree; only its implementer writes there.
- **Update `tasks/<status>/<KEY>/<KEY>.md` after every step** (stage, branches, PRs, round counters, next step): a
  new session continues from it, not from this conversation.
- **The human hears only what matters** (contract, "Human"): a stage passed, a blocker, a question
  with options and your recommendation. Small technical questions you decide yourself, without
  asking; any change to a repo or to tooling (a broken script, a dependency) goes to an implementer.
- **Inside a repo its own `AGENTS.md` / `CLAUDE.md` win** over the profile and this skill.
- **The kind of task (feature, bug, debt) is optional.** Use it if the task gives it; never ask.

## 0. Start or continue

1. Argument: a task key, a description in words, or nothing (then ask what the task is).
2. Read the profile's `Tasks` first. A key assigned to another procedure → say so and stop.
   Find the task across its current and legacy locations. If a legacy task file has no
   `status:` line, follow the profile's migration approval rule or ask the human by default.
   If any paths use the legacy layout, wait for active writers to finish, then use the profile's
   layout command or the [task-folder helper](references/tooling.md#task-folders). For a legacy task
   file, carry its decisions, reports, branch and PR links into the contract format. Then resume
   from `State` and `Next step`. For a task in the current format, read its file, reports and linked
   PRs and resume from the recorded state. If none exists, continue to step 3.
3. Otherwise create it by the contract's task-file template. Key: the profile's format (default:
   the next free `T-NNN` across every status folder of `tasks/`). Set `status: in work`; the folder is
   `tasks/in-work/<KEY>/`.
4. **Read the profile** `<ws>/.claude/kit-profile.md`; a missing heading means the contract's
   default. No profile at all → say so in one line, work on defaults, and offer to write one from
   [references/profile-template.md](references/profile-template.md) (or `ai-kit:setup`). The human
   may change the stops level for this task by a word ("on your own this time") — record it in
   `Decisions`. The profile's `Extra stages` may add steps and may also **replace or switch off** a
   default step of this skill (the place has its own way of doing it): follow the profile for that
   step and say so in one line when you reach it.
5. For repos with sync on, run [`ai-kit:sync`](../sync/SKILL.md) with the profile's adapter when it names one. After a successful refresh, a task branch behind its base →
   brief its implementer to rebase it (briefs, "rebase"). **Rebase rule:** only the task's own
   branch, only by its implementer on your brief, pushed with `--force-with-lease` — never a plain
   force push, never on a shared or base branch.

## Size — say the choice in one line

The human may correct it. Default rule: one repo, nothing visible or one screen, under half a day →
small; several parts or repos, or a contract between them → large; else medium.

| | small | medium | large |
|---|---|---|---|
| Other tasks (step 1) | yes | yes | yes |
| Research (step 2) | inside; outside + brainstorm only if something is new | same | same |
| Plan | you, in the task file | implementer + plan check | + a contract between parts; `ai-kit:architecture` first only as step 5 says |
| Mock-ups | if anything visible changes; checked by the one checker | if anything visible changes + check | if anything visible changes + check |
| Code | one implementer | implementer per part | several, in separate worktrees |
| Checks | by command | by command | by command |
| Function and look | one checker for all | function; look only if the UI changed | both + the place's end-to-end stage |
| Review | the same checker, continued | separate, after green | separate, per part |
| Docs | implementer, last, same PR | same | same |
| Result | one PR | one PR | a chain of PRs in merge order |

## Stops — by the profile's Autonomy

| Level | Where work waits for the human |
|---|---|
| `approve` (default) | after the mock-ups and after the plan; then only on a blocker or a change to what was approved |
| `blockers` | only on a blocker, a change to the request or scope, or a finding that survived the cap; independent checks stand in for approval; the human sees the ready PRs |
| `own` | as `blockers`; you may merge (step 9) |

At every level: a question whose answer changes a screen, a contract or the scope is a stop; other
questions get your recommended default, recorded as "default, not confirmed".

## 1. Request and scope

- Read the task where the profile's `Tasks` says (a tracker through this session's connector; if it
  is not available, say so and ask for the text). Read comments, linked items, attachments.
- Decide with the human which repos and parts are touched, and what is out of scope.
- Write to the task file: the human's words quoted with the date, acceptance criteria, scope.
- Cheap facts yourself: branches or PRs that already carry this key in any repo (`git branch -r`,
  the PR list) — someone may have started.
- **Other tasks — always, before any work on this one.** Read the place's other tasks where the
  profile's `Tasks` says they live (a tracker, issues, `tasks/` files — every source it names).
  Only **open** ones: everything not released counts, in progress and in review included. Related
  means related by context or by the area the change touches, not only by links: read titles and
  descriptions. One read-only agent writes `<task>/research/related-tasks.md`: per task — key, status, what
  it changes, and how it meets this one (duplicate / related / conflicts / depends / this task can
  prepare the ground); for work with branches or PRs, also its approach in a few lines, with the
  branch or PR. Then propose to the human: **duplicates** — delete (or close) them;
  **related** — merge them into this task, or keep them apart and carry their context into this
  one (scope, plan, what not to break, what to prepare for them). The answers go to `Decisions`.
  The kit never edits the tracker itself.
  **Related or duplicate task that already has work** (branches, draft PRs): check if it is still
  current — last activity, owner, how far behind base. Say your call in one line, in `Decisions`;
  in doubt, treat it as active. *Active* (someone works on it now): ask the
  human as above (merge, keep apart, depend). *Stale or abandoned*: never build on its branch;
  this task's branch starts from a fresh base. The approach from `related-tasks.md` goes in as
  **one candidate option** — compared, not copied by default — into where options are compared
  (`ai-kit:decide`, or the options in the design or plan); if nothing is compared, note it in
  the plan.

## 2. Research — what exists, and whether anything is new

1. **Inside — always.** Read-only agents (one per touched repo) report what exists now: code,
   patterns, docs, recent and open changes in the same area (`<task>/research/research-<repo>.md`).
2. **Is anything fundamentally new? — you decide, by the existing code and docs only**, not by
   other tasks. New means one of: no existing feature or pattern does it; it exists in code but
   the approach is **not documented**; or the same goal is reached **in different ways** in
   different places. The last two need a decision and documentation too: the plan names the doc
   that will record the chosen approach. Nothing new → say "by pattern X" in one line and go to
   step 3.
3. **Something new → outside research.** Run `ai-kit:research` (read its `SKILL.md` and follow it;
   you stay its coordinator) on the new part only: how other projects and products do it, what
   the options cost. Report: `<task>/research/research-external.md`.
4. **Then a brainstorm.** Run `ai-kit:brainstorm` (you coordinate it; mode `stops`, depth `quick`
   or `standard`) on the new part. Input: the inside, related-tasks (with a stale task's approach) and outside
   reports. Its people
   are the users of the change and the developers of the related tasks; its limit — do not get in
   the related tasks' way, prepare the ground for them where it is cheap.
5. **Stop — the human picks** one of the options (AskUserQuestion, with your recommendation); the
   pick goes to `Decisions`, dated. Questions, journeys, mock-ups and the plan build on it.

Tell the human in a few lines at each step: what is there now, what is new and why, what was
unexpected.

## 3. Questions — in batches

Everything the code cannot decide: who sees what, limits, states, texts, failure and offline
behaviour, what stays out. AskUserQuestion, up to 4 per call, each with options and your
recommendation. Answers go to `Decisions`, quoted, dated. Do not draw or plan while a question that
changes a screen or a contract is open.

## 3b. Journeys — the user's path, before mock-ups and plan

Whenever a person sees or does something new or different (at any size), a fresh implementer
follows `ai-kit:journey` (brief: "journey") and writes `<task>/design/journeys.md`: every role, every
case, step by step — what they see, do, hear, where they go next. No person-facing change → skip
3b and 4, say so in one line. Order, for work with screens (steps 3b and 4 are one flow):

1. The journey implementer writes the **outline**.
2. Step 4 draws the frames from it.
3. The same journey implementer is continued to **complete** the journeys from the frames.
4. One combined check (step 4).

Without screens, skip 2 and the frames in the check. Run the journey stage also when a brainstorm
or `decide` picks an approach, and whenever the human asks "how will it work": answer with
checked journeys.

## 4. Mock-ups — if anything visible changes

At any size, even one button. No visible change → skip, say so in one line.

- A fresh implementer uses [`ai-kit:design`](../design/SKILL.md) or the profile's design stage
  (brief: "mock-ups"). Include one frame per state named in `journeys.md`, labeled with its step,
  e.g. J2.4. Publish the board as an artifact if the session can.
- After step 3 of 3b, **one combined checker**: fresh; `check-look.md` part "Mock-ups" (design
  system, states, and logic and obviousness to a first-time user) and `check-journey.md` on the
  journeys with the frames. Fix loop per the contract, to "satisfied". In a small task this is the
  one combined checker, continued later for steps 7.3, 7.5 and 7.7.
- `approve`: **stop** — the mock-ups **and** the journeys (links) with the open questions;
  continue on the human's yes. Later changes go into the same page.

## 5. Plan

- **Small:** you write a short plan in the task file in the format of `ai-kit:plan`.
- **Medium / large:** an implementer with stage `ai-kit:plan` writes `tasks/<status>/<KEY>/plan.md` (large:
  first an implementer with `ai-kit:architecture` in change mode, which amends
  `<ws>/architecture.md`; briefs, "architecture"; run as in "Architecture change" below — only when
  the task changes the system's structure **and** the workspace keeps an `architecture.md` or the
  profile's `Extra stages` asks for it; otherwise the contract between parts lives in the plan).
  Then a fresh checker with `check-plan.md`. The planner (continued) answers the findings; loop to
  "satisfied".
- **The planner's requests.** Its reply may carry a neutral research question → run
  `ai-kit:research` (as in step 2), report to `<task>/research/research-<n>.md`; or "the architecture must
  change: …" → under the same condition as above, a fresh implementer with `ai-kit:architecture` in
  change mode (briefs, "architecture"; run as in "Architecture change" below), then continue the
  same planner with the result's path; otherwise continue the planner to write the structural change
  and the contract into the plan. The plan check covers an architecture change made for this task.
- **Architecture change** — the architect gathers first, writes after: (1) run `ai-kit:research`
  on each fact in its gather list, worded neutrally, report to `<task>/research/research-<n>.md`; (2) ask
  the human its missing requirements and limits, with its defaults; (3) continue the **same**
  instance with the report paths and answers. A new question in its reply is one more gather
  round, back through (1)–(3).
- The plan holds per repo what changes and what could break, the checks that cover it, the contract
  between parts, the parts in merge order (the first useful on its own), the place's extra stages
  and their scenario, forks for the human at the top with defaults, what will stay unchecked.
  If the profile's `End-to-end` applies, include its scenario, test environment, data changes and cleanup.
- Before approval, define the manual scenarios and expected outcomes, automated tests and CI jobs,
  and how each affected app will run for human review. Include prerequisites and ownership of
  shared resources. Use the architect's testing approach when the architecture stage runs.
  Otherwise the planner makes these choices from the profile's Run and Checks sections.
- `approve`: **stop** — parts, estimate, forks with defaults, what the checker raised and what was
  rejected. The yes also approves the extra stages' scenario.

## 6. Branches and worktrees

- One branch name for the task in every touched repo (the profile's `Tasks`; default
  `task/<KEY>-<slug>`), from a fresh base, each in its worktree:
  from the repo root run `bash <kit>/skills/task/scripts/git-worktree.sh add <ws>/worktrees/<KEY>/<repo> <branch> origin/<base>`, or the
  worktree command the profile's `Git and PRs` gives instead. Main checkouts stay on the base
  branch, and **nothing is ever written into them** — not by you, not by an agent, not as a quick
  fix outside the task (contract, "Agent types"): every change of a code repo lives in a worktree.
  Install dependencies in the worktree, or link them from the main checkout while the lock file is
  identical.
- **Shared slot.** If running the app needs the main checkout or a single shared resource (a port, a
  database), one task holds it at a time: you take it on a pushed commit, hand it to the implementer
  for its own look (step 7.1) or to a checker that runs the app, and return it as soon as that look
  or run is over (main checkout back to base; refuse if the run left edits). Never hold it while a
  part is being developed. Taken by another task → wait in line.
- Branches → task file.

## 7. Implementation — part by part

Independent parts in parallel (separate worktrees); what others depend on (a contract, a backend)
first. For each part:

1. **Develop.** An implementer with stage `ai-kit:develop` writes the code in its worktree (tests
   come in step 4), commits, pushes. It must look at what a human will see before it reports. If
   the place has a shared slot, the implementer works without it (briefs, "develop": `slot`): after
   it pushes, take the slot on that commit, continue the same implementer to look and fix what it
   sees, and return the slot right after. A wrong or silent plan → it stops; a small clarification
   you settle with the planner and the plan checker; a change to scope, contract or mock-ups goes to the human;
   record it in the task file with the date. After the part's first push: a PR per repo by the
   profile's `Git and PRs` (default: draft), title and description by the repo's rules,
   links to the paired PRs, and **the reviewers set at once** — the ones the profile's `Reviewers`
   names for this repo and this kind of task (several rules match → all their reviewers; none
   match or no `Reviewers` → nobody, and say so in the task file). Setting reviewers never takes a
   PR out of draft or asks for review earlier than the profile's review order says. PR links and
   reviewers → task file.
2. **Checks — by command, not a model.** Run the profile's `Checks` on the pushed commit yourself.
   Red = not ready: the failures go back to the same implementer (continue it).
3. **Function and look.** On the green commit: a function checker (`check-function.md`); a look
   checker (`check-look.md`) if anything visible changed. Both are `ai-kit:checker`: it may run
   commands, start the app and use a browser, and changes nothing in the tree.
4. **Tests.** The same implementer (continued) writes the part's tests; checks again.
5. **Review — only after green.** A fresh checker with `check-review.md` on the whole diff to base.
6. **Fixes — loop** per the contract after every check (3, 5, 7): findings to the author (continued);
   it answers with a table; the same checker re-checks per finding. A fix that changes behaviour →
   function and look re-check the affected part. Counters in `State` (e.g. `review 2/3`); at the
   cap → the human, both sides.
7. **Docs — last, before handoff.** A fresh implementer with stage `ai-kit:docs`, same branch: the
   repo's docs for people and for AI, decisions where the repo keeps them, and the PR description,
   which you put on the PR. Checks again. Then the same reviewer (continued) re-checks only the
   docs diff and the PR description; its findings go to the docs implementer (continued).

Small task: one checker checks the mock-ups (step 4) if any were drawn, does step 3 (the look only
if something visible changed) and, continued, the review (5) and the docs re-check (7).

## 8. End-to-end and extra stages

When the profile's `End-to-end` applies, brief a separate implementer with [`ai-kit:e2e`](../e2e/SKILL.md),
the end-to-end brief, the scenario from the plan, and the slots you hold. Use the profile's runner or stage if it overrides
this default. Release the slots after the run and send findings to part owners.

Run each extra stage where the profile's `Extra stages` says (default: after all parts, before handoff), with the
skill it names, the scenario from the approved plan, and the slot held by you. If a stage would
change something the plan did not cover → **stop** and show the difference. Findings go back to the
part's implementer; affected steps run again.

## 9. Handoff — and merge only within the level

1. Check yourself: every PR description tells the truth about the current code and links its pairs;
   no stray files, debug output or other people's changes in the diff; checks green on the last
   commit. Return slots used by agent checks before preparing the human's review environment.
2. Prepare the human's review environment from the plan and the profile's Run section. Start each
   affected app or verify that its existing endpoint already serves the work. Apply required setup
   and migrations through the profile's procedure. Verify the task revision and a usable entry point.
   Keep the apps running for the review window. Record any review slot, process, revision and
   cleanup in State. If access is blocked, report the affected app and reason in a progress update
   and keep working on apps you can start. Handoff stays pending until the required apps are ready
   or the human approves an exception.
3. One message to the human, in their language, with separate lists for **PRs in merge order**
   and **manual testing links or native entry points**. Include what was done,
   2–3 lines per part; per PR what was checked by running, by reading, not at all and why; findings
   left unfixed and why; what elsewhere became outdated (docs, tests, recordings).
   For each app, say where to open it, what to do and what to expect. Use a page for more than
   four steps (artifact or `<task>/e2e/manual-check.md`).
4. **Merge** only under stops `own`, within the profile's merge level (contract, "Autonomy
   levels"); under `approve` and `blockers` the human merges, whatever the merge level:
   - `pr` (default) — you never merge or take a PR out of draft; the human does.
   - `auto-low` — only PRs the profile marks low-risk, after all checks are green and every checker
     is satisfied on that commit; the rest stay with the human.
   - `full` — every PR of the task, by the same conditions, in merge order.
5. Record the PRs and next step. Move the task to review with the [task-folder helper](references/tooling.md#task-folders)
   or the profile’s layout command.

Append one line to `tasks/runs.md` by the contract's "Run log", every field but the last.

## After handoff

- When the human finishes manual testing or the agreed review window ends, stop the review
  processes and release slots using the profile's cleanup procedure. Restore the base checkout
  and its build if the review used a shared checkout. Record the result in State.
- Review comments → the same implementer, new commits on the same branch; behaviour changed →
  function and look re-check before the next review.
- The human's findings after handoff → the last field of this task's line in `tasks/runs.md`.
- A PR merged → note it; in a chain, brief the next parts' implementer to rebase them on the new
  base (the rebase rule, step 0.5).
- **Close** when all PRs are merged or the human says the work is over: return slots and remove
  clean, merged worktrees using the [worktree helper](references/tooling.md#sync-and-worktrees) or
  the profile's command. Move the task whole to done with the task-folder helper or the profile's command.
