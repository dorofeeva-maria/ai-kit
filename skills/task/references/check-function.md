# Check guide — function

You check that a pushed commit does what the plan part and the request say — by running it, not by
reading it. Output and levels: [contract](../../../docs/contract.md), "Findings".

## Rules of this check

- **Change nothing in the tree.** Read and run only. No edits, no commits, no pushes, no installs
  that change lock files. Temporary files only with an obvious name, outside the repo or ignored by
  it, and removed at the end: `git status` must be clean when you finish — say so in the report.
- Use the slot the orchestrator gives you. Not given and the run needs the main checkout or a shared
  resource → stop and say so; do not take it yourself.
- Never use real customer or production data; respect the profile's Never.

## Read first

The task file (request, acceptance criteria, decisions), the plan part, the profile's `Checks` and
`Run`, the repo's own rules and its README for how to run.

## How

1. Confirm the commit: `git -C <worktree> log -1` matches the sha in the brief.
2. Run the repo's checks (profile `Checks`) — record command and result. Red → report it as BLOCKS
   and continue with what can still run.
3. Start the app as the profile's `Run` says (or the repo's README). Cannot start → BLOCKS with the
   output; stop.
4. Each acceptance criterion: the ordinary path, then the edges — empty, one, many, very long,
   wrong input, no permission, a failing dependency or network, repeat and undo, what happens on
   reload. For an API: the requests and responses, codes and error texts in the plan's contract.
5. What other code calls the changed parts: try one or two of those paths for regressions.
6. Instructions the task changed (README, setup steps, a skill): follow them literally, as written.

Write each case as: what you did → what you expected (from where) → what happened. A finding without
the command and its output, or the screen and moment, is not a finding.

## Limits

About 60 tool calls. Prefer the repo's own test commands and a few targeted manual runs over
exploring. Out of time → list what you did not get to.

## Output

Your report at the path in the brief, contract's findings format, with a table of cases run
(case · result) before the findings, and a line: what was checked by running, by reading, not at
all. Verdict: satisfied / not satisfied.

On a re-check: per your earlier finding — closed / not closed / the fix made a new one; re-run the
affected cases only.
