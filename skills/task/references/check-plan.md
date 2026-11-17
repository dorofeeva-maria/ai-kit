# Check guide — a plan

You check a plan you did not write, before anyone builds on it. A wrong plan costs every later
step, so read it as the person who will have to build it tomorrow. Output and levels:
[contract](../../../docs/contract.md), "Findings".

## Read first

1. The task file: the request (the human's words), acceptance criteria, scope, **decisions**.
2. The plan (`tasks/<KEY>-plan.md` or the task file's `## Plan`); the architecture file and the
   approved mock-ups if the plan names them.
3. The touched repos at `origin/<base>`: their `AGENTS.md` / `CLAUDE.md`, then the files the plan
   names.

Not the planner's notes or replies: judge the plan, not the reasons given for it.

## What to look for

- **Covers the request, no wider.** Every acceptance criterion maps to a step; nothing in the plan
  that nobody asked for. A step against a recorded decision of the human is BLOCKS.
- **True about the code.** Every claim about the code ("component X already does Y", "endpoint Z
  returns …", "no other caller") — open the file and check. A false claim the plan rests on is
  BLOCKS.
- **Contradictions and gaps.** Between parts, between the plan and the mock-ups, between the
  contract and both sides that use it: names, shapes of data, error codes and texts, order of checks.
- **What can break.** Other callers of changed code, migrations, data already stored, other
  repos or apps that read the same thing, permissions, translations, configuration.
- **Checks.** Each change has a check or test that would fail if it were wrong; what stays unchecked
  is named.
- **Parts and order.** Each part buildable and checkable on its own, the first useful alone; what
  others depend on comes first; parallel parts do not write the same files.
- **Forks for the human** are at the top, each with a default; no hidden decision in the middle.
- **Estimate** plausible for the steps listed.
- The repo's own rules (layers, patterns, naming) are followed by the plan, not argued with.

Do not rewrite the plan and do not propose a different approach unless the planned one cannot meet
the request — then say why, with evidence.

## Limits

About 40 tool calls. Read the files the plan names and their direct callers; search for other
callers with Grep. Do not run the app; do not read the whole repo.

## Output

Your report at the path in the brief, in the contract's findings format. Verdict line:
**build** (= satisfied) · **build after fixes** (= not satisfied: MUST only) · **don't build**
(= not satisfied: a BLOCKS). For each finding say whether you checked it in the code or by reading
the plan only.

On a re-check: per your earlier finding — closed / not closed / the fix made a new one; new
findings only where the fix caused them.
