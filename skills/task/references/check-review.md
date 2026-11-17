# Check guide — review

You review a branch's whole diff to its base after the checks are green. You did not write it and
you do not get the author's report: judge the code. Output and levels:
[contract](../../../docs/contract.md), "Findings". Change nothing; write only your report.

## Read first

1. The repo's `AGENTS.md` / `CLAUDE.md` and the docs they name for code, tests and docs — these are
   the standard you hold the diff to.
2. The task file (request, decisions) and the plan part, with the contract between parts if any.
3. The diff: `git diff origin/<base>...<branch>` at the sha in the brief; then the full files where
   context matters.

## What to look for

- **Bugs.** Wrong logic, edge cases (empty, null, many, concurrent, repeated), error handling that
  hides failures, resource leaks, off-by-one, time zones and locales, security (input trusted
  without checks, secrets, permissions skipped).
- **Against the plan and the contract.** Missing steps, extra work nobody asked for, a contract
  shape that differs from what the other side expects.
- **The repo's rules.** Layers, patterns, naming, file placement, formats of commits.
- **Too much.** Duplication of something that already exists in the repo, abstractions with one
  user, dead code, debug output, commented-out code, stray files.
- **Tests test behaviour**, not themselves: they would fail if the code were wrong; no test that
  only restates the implementation; changed behaviour has a test.
- **Instructions and settings** in the diff (README, `AGENTS.md`, skills, configs, CI): correct,
  runnable as written, consistent with the code.
- **Docs and the PR description** — in the first review they are not written yet (docs come after
  the review): do not flag them as missing. In the docs re-check they are the whole subject: they
  tell the truth about the current code.
- **Translations.** Every user-facing text the diff adds or changes is present in every locale the
  repo keeps — checked in the first review too, not left to the docs re-check.
- **No data that must not leave:** secrets, real customer data, anything in the profile's Never.

Not findings: style the repo's formatter or linter already decides; personal taste (mark TASTE if
you must say it); widening the task.

## How

Read the diff file by file, worst risk first. For a suspected bug, show it: the path:line and the
input that breaks it; run a single command or test if you can do so without editing anything
(otherwise say "by reading").

## Limits

About 50 tool calls. A diff over ~1500 changed lines: review the riskiest files fully and say which
were only skimmed.

## Output

Your report at the path in the brief, contract's findings format, each finding with path:line.
Verdict: satisfied / not satisfied. On a re-check: per your earlier finding — closed / not closed /
the fix made a new one; read only the fix commits and what they touch.
