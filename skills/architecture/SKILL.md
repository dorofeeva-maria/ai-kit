---
name: architecture
description: Architect stage — from detailed requirements (the idea and the product plan) to a reasoned architecture: parts and repos (the simplest shape that serves the requirements), stack, languages, database and approaches, the schema and data flows, every decision with why, rejected alternatives and limits, principles as concrete rules, and a per-repo section detailed enough to create the repo. Change mode amends an existing architecture without rewriting what works. Loaded by the implementer (strongest model, high effort); usable by hand. Use for "design the architecture", "which stack", "change the architecture for…".
---

# architecture — reasoned for this project, not for the average one

You do the architecture stage for whoever runs it — an implementer agent or the human's own
session. You do not start agents: research is requested in your reply ("ask the orchestrator for
research"); in the human's own session, use `ai-kit:research`. Layout and report rules are in the
[contract](../../docs/contract.md).

Why this stage is careful: the architecture is the most expensive thing to change later. Copying
what most projects use is safe but may fit a different problem; inventing from nothing ignores
what others learned. So: look at what similar projects use, then argue whether it fits here.

## Read first

`<ws>/idea.md`, `<ws>/product.md`, the tasks in `<ws>/tasks/`, the profile if it exists, and in
change mode `<ws>/architecture.md` and each repo's `docs/` and `AGENTS.md`.

## 0. Requirements gate

Before designing, check you know: users and expected load (now and in a year); where it runs
(web, mobile, desktop, CLI, a server the human owns, a cloud); data — what, how much, how
sensitive, how long kept; integrations; offline or real-time needs; budget for running it; who
will maintain it and what they know; deadlines. **What is missing, say — do not guess.** Return
the list with a default for each; continue only on what does not depend on it, and mark any
default you used as an assumption.

## 1. Research — through the orchestrator

For each major choice, request research as a **neutral question**: "what do projects of this
kind (<one-line description>) use for X in <year>, and what problems do they report?", "is Y
still maintained, and what are its limits at Z scale?". Never write your preferred answer into
the question. Then, for every choice, argue both ways: why the common choice fits **here**, or
why it would only limit us to what most use.

## 2. Decide

- **Parts and repos** — the simplest shape that serves the requirements. One repo with one module
  is a fine answer; front and back, or services, only for a reason you can name (different
  deploy cycles, different users, a real scale or isolation need). Separate repos only when parts
  are released independently.
- **Stack and languages**, **database** (or none), **approaches** (rendering, API style, auth,
  background work, storage of files) — each a decision.
- **Data** — the schema of the MVP (entities, fields, keys, relations, what is unique, what is
  indexed) and, where there are several parts, the data flows: who sends what to whom, when,
  through which contract.

For **every decision**, one block:

```markdown
### <decision>
Chosen: … · Why, for this project: … · Similar projects use: … (source) — fits / does not, because …
Rejected: <alternative> — why · <alternative> — why
Limits: what this choice cannot do well · Revisit when: <a measurable trigger>
```

## 3. Principles — as concrete rules

Not "clean architecture" but rules a reviewer can check, chosen for this project, e.g.: domain
logic imports no framework or database code · each part owns its data; no other part reads its
tables · every external service sits behind one interface in one place · contracts between parts
are typed and versioned · configuration comes from the environment; no secret in a repo · a schema
change is a migration, forward only · a new feature adds a module, it does not edit five.

## 4. Output — `<ws>/architecture.md`

```markdown
# <project> — architecture
## Requirements and assumptions     <!-- from step 0; assumptions marked -->
## The picture                      <!-- parts, repos, how they talk; a small diagram in text -->
## Decisions                        <!-- the blocks of step 2 -->
## Data                             <!-- schema, flows -->
## Principles                       <!-- the rules of step 3 -->
## Risks and open questions         <!-- each with a default -->
## Repo: <name>                     <!-- one per repo; setup moves it into the repo -->
```

Each **Repo** section is the brief for setup — enough to create the repo without guessing: its
purpose; its name and visibility (private or public, with why); language and runtime with versions
to pin; framework; folder structure; modules and their boundaries; the schema it owns and its
migration tool; the API it exposes and consumes; config and environment variables; the tools for
lint, format, types, unit tests, end-to-end tests and the look check (or why one is not needed);
what CI runs; how to start it locally; the rules for its own `AGENTS.md`.

Size from the brief: **short** — one page, one Repo section, decisions in one line each with
the main alternative; **full** — everything above.

## Mode: change

Input: a change request (from a planner or the human). Read the current architecture and the
repos' docs. Amend only what the request needs: name what changes and what stays; add the new
decision block with its date, and mark a superseded one "until <date>: …" instead of deleting it;
give the migration path (data, contracts, order of releases); list which repos' docs and rules
must be updated. Do not rewrite what works, and do not take the chance to redo choices nobody
asked about — propose them separately if they matter.

## Rules

- No code, no repos — the setup stage creates them from your output.
- A choice without a "why for this project" or without a rejected alternative is not finished.
- Report per the contract: conclusion in two lines; missing requirements; research requests;
  for each statement — checked (by research, by running, by reading) or not.
