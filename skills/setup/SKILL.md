---
name: setup
description: Tech specialist stage — from an architecture creates the project's repos with base configuration for the chosen stack, database, dependencies, linters and formatters, unit, end-to-end and look-check tooling, and CI that runs the checks; moves each repo's architecture section into that repo's docs and AGENTS.md; writes the kit profile and the workspace AGENTS.md; proves every check command works on the empty project. Implements no feature. Repair mode fixes or extends tooling later. Loaded by the implementer (a cheaper model); usable by hand. Use for "set up the repos", "add a linter / e2e / CI", "the tests don't run".
---

# setup — the workspace ready for the first task

You do the setup stage for whoever runs it — an implementer agent or the human's own session. You
do not start agents. Layout, the profile's headings and report rules are in the
[contract](../../docs/contract.md).

Why this stage is separate: every later task relies on checks that run and a profile that says
how. Tooling built alongside the first feature gets bent to that feature; built on an empty
project, its failures are tooling failures and nothing else.

## Read first

`<ws>/architecture.md` (above all the `## Repo:` sections), `<ws>/idea.md`, `<ws>/product.md`,
and the brief: which remote repositories, accounts or services the human approved. **Nothing
remote, paid, or public beyond that list** — if you need one more, stop and ask for it in your
reply.

## Mode: create

For each `## Repo:` section:

1. **The repo.** Create `<ws>/<repo>/`, `git init`, base branch as the architecture says (default
   `main`). Its name and visibility come from the section and the brief's approval. A remote only
   if approved in the brief: private, or public only when approved as public; add it, push the
   first commit.
2. **The stack.** Start from the stack's official generator or a minimal hand-written layout —
   whichever leaves less to remove. Take versions by asking the package manager for the current
   stable one, not from memory, and pin them (lockfile committed). Folder structure as the
   architecture says.
3. **Database** (if any): a local instance the human can start with one command, the migration
   tool, an initial migration with the MVP schema's tables, a seed only if tests need one. No
   secrets in the repo: an example env file with every variable and a safe value.
4. **Checks:** formatter, linter, type check, unit tests (one trivial passing test that imports
   real code), end-to-end tests (one smoke test that starts the app and opens it), the look check
   where there is an interface (screenshot comparison with a first baseline). One command each,
   exposed through the stack's usual task runner.
5. **CI** running the same commands as locally, on every push and PR to the base branch.
6. **Docs.** Move the repo's section from `<ws>/architecture.md` into `<repo>/docs/architecture.md`;
   leave in the workspace only the general picture and one line pointing to it. Write the repo's
   `AGENTS.md`: what the repo is, how to run and check it, its rules (from the section and the
   principles of the architecture), what must not be done. A short `README.md` for humans.
7. **Commit** locally in the repo: one commit, "chore: initial setup", in the place's commit format.

Then for the workspace:

- **Its own git repo and remote are not yours to decide.** If the workspace is already a repo (for
  example a module of a system the human keeps), leave it and its remote alone. Otherwise
  `git init` it; a remote only if approved in the brief, private.
- **`<ws>/.claude/kit-profile.md`** with every heading of the contract: Repos (folder · what it is ·
  base branch · sync off unless others work there), Checks and Run per repo (the exact commands),
  Tasks (`tasks/` files, the key format used by the product stage), Git and PRs, Autonomy (the
  stop level from the brief), Design (where the design system will live; screen sizes), Never,
  Language. Unknown → the contract's default, written out.
- **`<ws>/AGENTS.md`** — what is where, in a page: the idea, the product plan, the architecture,
  the profile, the tasks, each repo in one line with its visibility (private or public); "start a
  task with `ai-kit:task`".
- **`<ws>/.gitignore`** that ignores every code repo folder and `worktrees/`, so a sync tool that
  auto-commits the workspace never picks up code. The workspace tracks only `AGENTS.md`,
  `idea.md`, `product.md`, `architecture.md`, `.claude/` and `tasks/` (simplest: ignore `/*`, then
  re-include those with `!`).

## Verify — by running

Run **every** command under Checks and Run in the profile, in each repo, on the empty project, and
the CI file through its local validator if the platform has one. Each must exit green (Run: the
app starts and answers). A red one is fixed, not removed; a command that cannot run on this
device (a missing runtime, no container engine) is written in the report with what the human
must install — never marked green.

## Mode: repair

Input: a tooling request (a check that fails for tooling reasons, a new tool, a CI change). Read
the profile and the repo's `AGENTS.md`. Change only the tooling the request names, keep the
profile's commands and CI in step with it, run every affected command, and report. A repo's own
rules win over this skill.

## Never

- Implement a product feature, a screen, an endpoint with logic — not even "a start". Example
  code only where a check needs something to test.
- Create a remote repo, an account, a paid service, or publish anything without the human's yes
  for that one thing (passed in the brief).
- Commit secrets, or weaken a check to make it pass.

## Report

Per the contract: conclusion in two lines; per repo — what was created, each check command and its
result (ran green / red / could not run, with why); what the human must do (install, approve).
