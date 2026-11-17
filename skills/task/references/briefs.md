# Briefs for the task pipeline

An agent knows only its brief. Build every brief from the **skeleton** + the **role part** + the
**subject**. Rules for briefs and reports: [contract](../../../docs/contract.md), "Briefs".
Start agents in the background; independent ones in one message. A checker is always a fresh
agent; between fix rounds continue the same author and the same checker (`SendMessage`).

## Skeleton — every brief

```text
Task <KEY>: <one line>. Workspace: <ws>.
Read first: <ws>/.claude/kit-profile.md; <ws>/tasks/<KEY>.md (request, scope, decisions);
the AGENTS.md / CLAUDE.md of repo <name> in full and the docs they name for this work;
<the stage skill or check guide of this role>.
The human's decisions in the task file are final: do not argue with them or widen the task.
Never: <the profile's Never, verbatim>. Delete only what you created. A refused tool or access —
do not work around it; say so in the report. You cannot ask the human: put a question in the
report as one line with a default.
Report: <ws>/tasks/<KEY>-notes/<role>-<part>-<round>.md and a short reply: the conclusion in two
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
  planner's 'the architecture must change: …'), research `<notes>/research*.md`, the repos. Amend
  `<ws>/architecture.md` only where this task needs it. Repo docs to update → list them in your
  report; they are changed in the task's branches by the docs stage."
- **plan** — "Follow `ai-kit:plan`. Subject: research, the human's answers, mock-ups `<link>`,
  `<ws>/architecture.md` if this task amended it. Write `<ws>/tasks/<KEY>-plan.md`. Forks for the
  human at the top, each with a default. Decide small things yourself, one line of reason each.
  Research or an architecture change you need → a request in your reply; you will be continued
  with the result."
- **mock-ups** — "No stage skill (unless the profile's Design names one). Draw one self-contained
  HTML page with every screen and state of this task, from the real design system
  `<profile Design>` and the real texts. Screen sizes: `<profile Design>`. Write `<notes>/mockups.html`."
- **develop** — "Follow `ai-kit:develop`. Part: <part of the plan>. Worktree: `<ws>/worktrees/<KEY>/<repo>`,
  branch `<branch>`. Checks to keep green: <profile Checks for this repo>. Run: <profile Run>.
  slot: `<held for you | not needed>` — look at what a human will see before you report.
  Tests come after the function check: build and push the part now; you will be continued to
  write the tests."
- **tests** (continue the same instance) — "The function check passed at `<sha>`. Write the part's
  tests by `ai-kit:develop`, Tests; run the checks; push."
- **docs** — "Follow `ai-kit:docs`. Same worktree and branch. Subject: the diff
  `git diff origin/<base>...<branch>`, the plan part, repo docs the architecture change listed.
  Docs for people and for AI, decisions where the repo keeps them; the PR description text in your
  report (the orchestrator sets it)."
- **fixes** (continue the same instance) — "Findings: `<notes>/<report>.md`. Fix BLOCKS and MUST;
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

- **Plan checker** — "Follow `<skill>/references/check-plan.md`. Subject: `<ws>/tasks/<KEY>-plan.md`;
  the repos at `origin/<base>`; `<ws>/architecture.md` if this task amended it."
- **Mock-up checker** — "Follow `<skill>/references/check-look.md`, part Mock-ups. Subject:
  `<link or path>`; design system: `<profile Design>`."
- **Function checker** — "Follow `<skill>/references/check-function.md`. Subject: branch
  `<branch>` at commit `<sha>`, worktree `<path>` (read and run only, never edit); the plan part;
  run: `<profile Run>`; slot: `<held for you | not needed>`."
- **Look checker** — "Follow `<skill>/references/check-look.md`, part Built UI. Subject: commit
  `<sha>`, run: `<profile Run>`; approved mock-ups `<link>`; screen sizes `<profile Design>`."
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
`<path>` (read and run only), the plan in the task file." Add the look
(`check-look.md`, part Built UI) only if something visible changed. After the tests, continue the
same checker: "Now follow `<skill>/references/check-review.md` on `git diff origin/<base>...<branch>`
at `<sha>`." After the docs: the docs re-check above.
