---
name: develop
description: Implement one part of an approved plan and write its tests — read the repo's rules and neighbouring code first, write like it, only what the plan says; run the place's checks by command and read the failures; look at what a human will see; atomic commits; a truthful report; fix findings without breaking things; stop and report when the plan or contract is wrong or silent. Use when the brief says "follow ai-kit:develop", or when the human asks to build a planned part ("implement part 2 of T-012").
---

# develop — the part the plan asked for, working, and proven so

You build one part of an approved plan. Done means: the part does what the plan says, the place's
checks are green, and your report says truthfully what was run and seen. Shared terms (task file,
profile, findings, reports): [contract](../../docs/contract.md).

## Read first

- Your brief: the part you build, the worktree or branch, what must not be done.
- The plan (task file `## Plan` or `tasks/<KEY>-plan.md`) — your part, the contract with the other
  parts, the decisions. The task file's Decisions are final.
- The profile: Checks, Run, Git and PRs, Never, Language.
- The repo's own `AGENTS.md` / `CLAUDE.md` and contributing docs — they win over this skill.
- **The neighbouring code**: the files you will change, two or three similar features already in
  the repo, their tests. Learn how this repo names things, splits files, handles errors, logs,
  validates input and writes tests. Then write like it — a new style in an old repo is a cost
  for every later reader.

## Write the code

Only what the plan says. Something missing from the plan that you need → see "Stop and report".
Something nice to have → a line in the report, not code.

Concrete rules (the repo's own rules win where they differ):

- **No abstraction before the second use.** One caller → a plain function. A base class, a
  factory, a generic helper appear when the second real case does.
- **No dead options**: no parameter, flag, config key or branch that nothing uses yet.
- **Errors are handled where they can be acted on** — retried, turned into a user message,
  mapped to the contract's error. Elsewhere they propagate. No catch that only logs and goes on;
  no silent defaults that hide a failure.
- **Names from the domain**: the words of the repo, the plan and the contract — not new synonyms.
- Small units with one job; a file grows by the repo's usual size, not past it.
- Validate at the boundary (input from users, other services, files); trust inside.
- No commented-out code, no TODO without a task key, no debugging output left behind.
- Follow the contract to the letter — field names, shapes, error order. If it is wrong, stop.
- Never touch what the profile's Never lists; never commit secrets or local config.

## Tests

- Test **behaviour**, not the implementation: inputs and visible results, the contract's cases,
  the failure cases. A test that only restates the code (mocks everything, asserts the mock was
  called) proves nothing.
- Unit tests for the logic; end-to-end tests where the repo has the tooling and the plan asks
  for them. Use the repo's test framework, fixtures and layout.
- If the brief says tests come after the function check (the `task` pipeline does), build and push
  the part first, and write the tests when you are continued after that check passes.
- Each test fails without your change — check this once for the key ones (revert, run, restore).
- Add new test suites to CI where the place has CI and they are not picked up automatically.

## Run the checks

Run the place's check commands from the profile (lint, types, tests, build) for every repo you
touched, by command. **Read the failures yourself**; do not guess and re-run. A failing check
means not done — including one that "was already failing": say so, with the output, and show that
it fails the same way on the base branch.

Run the app (profile's Run) and **look at anything a human will see** — a screen, a message, an
API response, a CLI output — before handing over. Compare it with the mock-up or the contract.
Could not run it → say so in the report; never write "works" for something not seen working.

## Commits

Atomic: one logical change per commit, each one builds. The profile's commit format, the
language of the profile. Never rewrite history on a shared or base branch. Rebase the task's own
branch only when the brief says to, and push it with `--force-with-lease`; never a plain force push.

## The report

A file in `tasks/<KEY>-notes/` (name from the brief) and a short reply. Conclusion first, two
lines. Then:

- **Commits** — hash and message.
- **What changed** — per file, one line.
- **Decisions you made** — what the plan left open and what you chose, with the reason.
- **What was run and seen** — each command with its result (passed / the failure); what you
  looked at in the running app.
- **Not checked** — and why.

Every statement marked: checked by running, checked by reading, or not checked.

## Fixing findings

Findings come in the contract's format. Fix BLOCKS and MUST; MINOR if cheap and in scope; never
TASTE. A finding that widens the task or argues with a decision — reject it with a reason. After
**every** fix run the tests and checks again: a fix that breaks something else is a new finding.
Report per finding: fixed (commit) / rejected (why) / could not fix (why).

## Stop and report — instead of guessing

Stop, write the report so far, and say what blocks when:

- the plan or the contract is **wrong** (it cannot work, it contradicts the code or itself);
- the plan is **silent** on something that changes behaviour, a shape, or another part;
- the change needs work outside your part, or touches the system's structure;
- a check fails for a reason you cannot find within reasonable effort.

Give the options you see and the one you would take. The orchestrator (or the human in their own
session) decides; work that does not depend on the answer continues.
