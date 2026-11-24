---
name: plan
description: Write the plan of a task from the request, the human's answers, the research and the mock-ups — per repo what changes, in which files, what can break and which checks cover it; the contract between parts so they can be built in parallel; which implementers, in what order; PR cuts, an honest estimate, forks for the human with defaults, what stays unverified. Also answers the plan checker's findings. Use when a task needs a plan before code ("plan T-012", "how would we build this"), or when the brief says "follow ai-kit:plan".
---

# plan — a plan others can build from without asking

The plan is the only thing the implementers and the plan checker will share. Anything that is not
in it gets decided mid-build, by someone who does not see the whole picture. Write it so that a
fresh implementer, given one part of it, can build that part and know when it is done.

Shared terms (task file, profile, findings, briefs): [contract](../../docs/contract.md).

## Read first

- The task file `tasks/<status>/<KEY>/<KEY>.md`: Request, Scope, Decisions (the human's are final), Tried and
  dropped.
- The profile `.claude/kit-profile.md`: Repos, Checks, Run, Git and PRs, Autonomy, Never.
- `journeys.md` when the task has one: the plan builds those journeys; every step needs a part.
- Research reports and mock-ups named in your brief or linked from the task file.
- In every repo you will touch: its `AGENTS.md` / `CLAUDE.md`, its docs on architecture, and the
  code you will change and its neighbours. **Open the files you name in the plan** — a plan built
  on guessed file names fails on the first step.

Missing information is not guessed. If something must be found out (a library's behaviour, how
others solve it), stop and put a neutral research question in your reply — the orchestrator runs
the research and continues you with the report; in a human's own session, use the
`ai-kit:research` skill. Small facts in the repo you check yourself by reading.

## When to ask for the architecture stage

Stop and reply "the architecture must change: <what and why>" — the orchestrator runs the
architecture stage and continues you (in your own session: say so to the human) — when the plan
would change the system's structure: a new repo, service or module boundary;
a new storage or a schema change other code depends on; a new external dependency of weight; a
change to how parts talk to each other. A plan does not make those choices quietly.

## Size

The plan scales with the task. A small task (one repo, a few files, under half a day) gets about
ten lines straight in the task file's `## Plan`. A larger one goes into `tasks/<status>/<KEY>/plan.md`,
linked from `## Plan`. Never pad a small plan with empty sections.

## What the plan holds — in this order

1. **Forks for the human** — at the top. Every choice the human may want to make (behaviour,
   scope, trade-off), each with options and **a default** you would take. Find them now: a fork
   discovered mid-build stops several agents. Small technical choices are not forks — make them.
2. **Per repo** — what changes and why; the files (create / change / delete); what can break
   (callers, data already stored, other screens, other repos that read this one); which checks and
   tests cover it — existing ones by name, new ones to write (unit, end-to-end where the repo has
   the tooling), and the place's check commands from the profile.
   **Reuse first.** For every helper the plan adds — parsing and formatting, escaping, hashing and
   signing, cookies and tokens, HTTP responses and request checks, mail, captcha, export formats,
   environment checks — search the repos for one that already does it, by purpose, not only by
   name. Reuse it, or extract it into a shared module that both callers use; where the callers
   need different behaviour, share the mechanism and keep the policy in each caller. Copying an
   existing helper instead of extracting it is a fork for the human with the reason, never a
   silent step of the plan.
   **One job per module.** Name the module each new piece of code goes into. A file the plan would
   make mix unrelated concerns, or grow well past the repo's usual file size, is split in the plan.
   Include a test and review plan. Name manual scenarios and expected outcomes, the automated
   suites to run or extend, and the CI jobs that judge the change. For each affected app, name the
   review environment and startup procedure from the profile, any required setup or test data,
   the entry point for the human, and cleanup. Use the architecture's testing approach when it
   exists.
3. **Contract between parts** — only when there is more than one part or repo. Precise enough to
   build both sides in parallel without talking:
   - endpoints or interfaces with their names, inputs and outputs, and the exact shapes (fields,
     types, optional or not, an example);
   - the order of checks (auth, validation, existence, business rules) and which error each
     returns;
   - failure cases: what the caller gets and does on each (timeout, empty, not found, conflict);
   - what is versioned or must stay backward compatible.
4. **Implementers** — how many, which part each, in what order, what may run in parallel (only
   independent parts, each in its own worktree), what one waits for from another.
5. **PRs** — one PR unless the work exceeds a day or two; then parts with their own PR, in merge
   order, **the first part useful by itself** (it can be merged and does no harm if the rest never
   comes). Say what each PR leaves behind (a flag off, an unused endpoint) and why that is safe.
6. **Estimate** — honest and minimal: per part, in hours or days, with what would make it longer.
   No padding to look safe, no optimism to look fast.
7. **Unverified** — what the plan assumes but nobody checked (a library's behaviour, data in
   production, a mock-up's state), and how it will be found out during the build.
8. **Out of scope** — what a reader may expect but this task does not do.

Write for both a person and an agent: short lines, real paths, no prose a reader must interpret.
Names come from the repo's own vocabulary.

## Checks on your own plan before handing it over

- Every requirement of the request maps to a step; no step without a requirement behind it.
- Every file named exists (or is marked new), and its path is right.
- Every change that can break something has a check or a test against it.
- No new helper duplicates one the repos already have; each new module has one job.
- The contract leaves no shape or error case to the implementer's taste.
- Nothing contradicts a decision in the task file.

## Answering the plan checker

The checker's findings come in the contract's format. Answer with a table, and change the plan
only where you accepted:

| # | Finding (short) | Accepted / rejected | Where in the plan / why rejected |
|---|---|---|---|

- Accept what is right, even when it costs work. Fix it in the plan, and say in the table where.
- Reject a finding that widens the task, argues with the human's decision, or is TASTE — with a
  one-line reason. **Never add to the plan what you rejected**, not even "just in case".
- A finding you cannot judge (it depends on a fork) goes to the forks at the top.
- After the third round a finding that survives goes to the human with both sides — you do not
  argue a fourth time.

## Hand over

- The plan in the task file, or `tasks/<status>/<KEY>/plan.md` linked from it; `## Next step` updated.
- Reply (conclusion first, two lines): the size, the forks with their defaults, the number of
  implementers and PRs, the estimate, what is unverified. Say which file statements you checked by
  reading and which you did not.
