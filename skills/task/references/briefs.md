# Briefs for the task pipeline

An agent knows only its brief. Build every brief from the **skeleton** + the **role part** + the
**subject**. Rules for briefs and reports: [contract](../../../docs/contract.md), "Briefs".
Start agents in the background; independent ones in one message. A checker is always a fresh
agent; between fix rounds continue the same author and the same checker (`SendMessage`).

## Skeleton — every brief

```text
Task <KEY>: <one line>. Workspace: <ws>.
Read first: <ws>/.claude/kit-profile.md; <ws>/tasks/<status>/<KEY>/<KEY>.md (request, scope, decisions);
the AGENTS.md / CLAUDE.md of repo <name> in full and the docs they name for this work;
<the stage skill or check guide of this role>.
The human's decisions in the task file are final: do not argue with them or widen the task.
Never: <the profile's Never, verbatim>. Delete only what you created. A refused tool or access —
do not work around it; say so in the report. You cannot ask the human: put a question in the
report as one line with a default.
Report: <ws>/tasks/<status>/<KEY>/<folder>/<role>-<part>-<round>.md, <folder> = the stage (research, design,
plan, e2e) or the part (P1…); a run that leaves files (screenshots, logs) is the folder
<role>-<part>-<round>/ with the report inside under the same name. And a short reply: the conclusion in two
lines first; for every statement — checked by running, by reading, or not checked; code as path:line.
```

## Models and agent types

Pass `model` and `effort` on every Agent call, by the contract's "Models": thinking roles
`effort: high`, the rest the default effort.

| Role | `subagent_type` | Model |
|---|---|---|
| Implementer: architecture, plan | `ai-kit:implementer` | `opus` (`fable` for a large architecture if available), `effort: high` |
| Implementer: develop, tests, fixes, rebase, mock-ups | `ai-kit:implementer` | `opus` |
| Implementer: docs | `ai-kit:implementer` | `sonnet` |
| Plan checker, reviewer | `ai-kit:checker` | `opus`, `effort: high` |
| Mock-up checker | `ai-kit:checker` | `sonnet` |
| Function, look, small combined checker | `ai-kit:checker` (runs commands, the app, a browser; changes nothing) | `sonnet` |

## Implementer — per stage (add to the skeleton)

All stages: "Your decisions so far: <the human's decisions and approved plan/mock-ups>."

- **architecture** — "Follow `ai-kit:architecture`, Mode: change. Subject: the request (or the
  planner's 'the architecture must change: …'), research `<task>/research/research*.md`, the repos. Report
  to `<task>/plan/architecture-all-<round>.md` (part `all`: it covers the whole task). First the gather
  list there under `## Gather` and in your reply, and stop; you will be continued with research and
  the human's answers. A gather list of "none" → go on to the amendment in the same run. Then,
  adding `## Result` to the same file, amend `<ws>/architecture.md` only where this task needs it.
  Repo docs to update → list them in your report; they are changed in the task's branches by the
  docs stage."
- **plan** — "Follow `ai-kit:plan`. Subject: research, the human's answers, mock-ups `<link>`,
  journeys `<task>/design/journeys.md` (every step needs a part of the plan), `<ws>/architecture.md` if
  this task amended it. Write `<ws>/tasks/<status>/<KEY>/plan.md`. Forks for the
  human at the top, each with a default. Decide small things yourself, one line of reason each.
  Research or an architecture change you need → a request in your reply; you will be continued
  with the result."
- **journey** — "Follow `ai-kit:journey`. Subject: the request, research, the human's answers, the
  chosen approach, the code of the screens it touches. Write `<task>/design/journeys.md`. Mode:
  `<outline | complete with the frames of <mock-ups link>>`. Questions for the human go at the top
  of your reply, each with options and a default."
- **mock-ups** — "Follow `ai-kit:design` or the profile's Design stage. Draw one self-contained
  HTML page from the real design system `<profile Design>` and the real texts: one frame per state
  named in `<task>/design/journeys.md`, each labelled with its step (e.g. J2.4), so every state of this
  task is there. A state you need that no journey names → say so in your reply. Screen sizes:
  `<profile Design>`. Write `<task>/design/mockups.html`."
- **end-to-end** — "Follow `ai-kit:e2e` with the approved scenario and the profile's
  End-to-end rules. Report the environment, revisions, actual results, evidence and changes
  under `<task>/e2e/`. Slots: `<held for you | not needed>`. Report deviations before running
  them. Leave product fixes and slot release to the orchestrator and part owners."
- **develop** — "Follow `ai-kit:develop`. Part: <part of the plan>. Worktree: `<ws>/worktrees/<KEY>/<repo>`,
  branch `<branch>`. Checks to keep green: <profile Checks for this repo>. Run: <profile Run>.
  slot: `<not yet — you will be continued for the look once your commit is pushed | not needed>`.
  Look at what a human will see before you report; with a slot, look only when continued with it.
  Tests come after the function check: build and push the part now; you will be continued to
  write the tests."
- **look** (continue the same instance; only with a shared slot, after its push) — "The slot is
  held for you on your pushed commit `<sha>`. Run: <profile Run>. Look at what a human will see,
  fix what you see, push, report; the slot is returned right after your report."
- **tests** (continue the same instance) — "The function check passed at `<sha>`. Write the part's
  tests by `ai-kit:develop`, Tests; run the checks; push."
- **docs** — "Follow `ai-kit:docs`. Same worktree and branch. Subject: the diff
  `git diff origin/<base>...<branch>`, the plan part, repo docs the architecture change listed.
  Docs for people and for AI, decisions where the repo keeps them; the PR description text in your
  report (the orchestrator sets it)."
- **fixes** (continue the same instance) — "Findings: `<task>/<folder>/<report>.md`. Fix BLOCKS and MUST;
  MINOR if cheap; never TASTE; reject a finding that widens the task or argues with a decision.
  Answer with the table finding → fixed (commit) / rejected (why) / could not fix (why)."
- **rebase** (the part's implementer) — "Rebase `<branch>` in `<worktree>` on `<target>`,
  resolve conflicts keeping both sides' intent, run the checks, push with `--force-with-lease`.
  This branch only; never a plain force push." You name `<target>`: `origin/<base>` for a single PR
  or the first part of a chain; in a chain of PRs, the previous part's branch until that part is
  merged.

## Checkers (add to the skeleton)

Never pass the author's report, reasoning or replies. A checker gets the subject, the request and
the decisions.

- **Plan checker** — "Follow `<skill>/references/check-plan.md`. Subject: `<ws>/tasks/<status>/<KEY>/plan.md`;
  the repos at `origin/<base>`; `<ws>/architecture.md` if this task amended it."
- **Journey checker** — "Follow `<skill>/references/check-journey.md`. Subject:
  `<task>/design/journeys.md` (and the mock-ups `<link>` if drawn); the request; the human's decisions."
- **Mock-up checker** — "Follow `<skill>/references/check-look.md`, part Mock-ups, including its
  logic and obviousness check. Subject: `<link or path>`; journeys `<task>/design/journeys.md`; design
  system: `<profile Design>`."
- **Function checker** — "Follow `<skill>/references/check-function.md`. Subject: branch
  `<branch>` at commit `<sha>`, worktree `<path>` (read and run only, never edit); the plan part;
  run: `<profile Run>`; slot: `<held for you | not needed>`."
- **Look checker** — "Follow `<skill>/references/check-look.md`, part Built UI. Subject: commit
  `<sha>`, run: `<profile Run>`; slot: `<held for you | not needed>`; approved mock-ups `<link>`;
  screen sizes `<profile Design>`."
- **Reviewer** — "Follow `<skill>/references/check-review.md`. Subject:
  `git diff origin/<base>...<branch>` at `<sha>`; the plan part; the repo's rules."
- **Re-check** (continue the same checker) — "Fixes: commit `<sha>`. Per each of your findings:
  closed / not closed / the fix made a new one. New findings only if the fix caused them."
- **Docs re-check** (continue the same reviewer) — "Docs: `git diff <sha-before-docs>..<sha>` and
  the PR description `<path>`. Check only these, against the current code, by `check-review.md`
  (docs and the PR description). Findings as before."

## Small task — one checker, continued

If mock-ups were drawn, this checker starts there: skeleton + the mock-up checker part above; then
continue it with the next brief. Otherwise it starts here. Skeleton + "Follow
`<skill>/references/check-function.md` now. Subject: branch `<branch>` at `<sha>`, worktree
`<path>` (read and run only), the plan in the task file; run: `<profile Run>`; slot:
`<held for you | not needed>`." Add the look
(`check-look.md`, part Built UI) only if something visible changed. After the tests, continue the
same checker: "Now follow `<skill>/references/check-review.md` on `git diff origin/<base>...<branch>`
at `<sha>`." After the docs: the docs re-check above.
