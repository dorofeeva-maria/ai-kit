---
name: architecture
description: Architect stage — from detailed requirements (the idea and the product plan) to a reasoned architecture: parts and repos (the simplest shape that serves the requirements), stack, languages, database and approaches, the schema and data flows, every decision with why, rejected alternatives and limits, principles as concrete rules, and a per-repo section detailed enough to create the repo. Change mode amends an existing architecture without rewriting what works. Loaded by the implementer (strongest model, high effort); usable by hand. Use for "design the architecture", "which stack", "change the architecture for…".
---

# architecture — reasoned for this project, not for the average one

You do the architecture stage for whoever runs it — an implementer agent or the human's own
session. You do not start agents: research is requested in your reply ("ask the orchestrator for
research"); in the human's own session, use `ai-kit:research`. Layout and report rules are in the
[contract](../../docs/contract.md).

Two phases, in this order: **gather** everything you must know, then **write**. No decision and
no `architecture.md`, not even a draft, before the gather list is answered — unless the list is
an explicit "Gather: none". *Why:* an architecture
written first and questioned after comes back half "not verified" and is written twice.

Why this stage is careful: the architecture is the most expensive thing to change later. Copying
what most projects use is safe but may fit a different problem; inventing from nothing ignores
what others learned. So: look at what similar projects use, then argue whether it fits here.

## Read first

`<ws>/idea.md`, `<ws>/product.md`, the tasks in `<ws>/tasks/`, the profile if it exists, and in
change mode `<ws>/architecture.md` and each repo's `docs/` and `AGENTS.md`.

## Phase 1 — gather

### 1. Requirements

Check you know: users and expected load (now and in a year); where it runs
(web, mobile, desktop, CLI, a server the human owns, a cloud); data — what, how much, how
sensitive, how long kept; integrations; offline or real-time needs; budget for running it; who
will maintain it and what they know; deadlines. **What is missing, say — do not guess.**

### 2. Facts to research

For each major choice and each fact a decision rests on (a provider's terms and limits, whether a
library supports a format, a platform's quotas, a licence), write a **neutral question**: "what do
projects of this kind (<one-line description>) use for X in <year>, and what problems do they
report?", "is Y still maintained, and what are its limits at Z scale?". Never write your
preferred answer into the question.

### 3. Limits to confirm

The limits you would otherwise assume — running budget, a provider's quotas, deadlines, where it
may be hosted, licences the project can accept — each as a value the human confirms or corrects,
e.g. "running cost: at most a small monthly hosting fee — confirm?".

### 4. The gather list — reply and stop

Write the list into your report file, under `## Gather`, in three groups: facts to research (with
depth: `quick` per fact, `standard` for a comparison of options) · missing requirements for the
human, each with a default · limits to confirm. Reply with it and stop. Nothing to ask (a small
project) → write "Gather: none" and go on to phase 2 in the same run.

In the human's own session there is no one to continue you: after the list, run `ai-kit:research`
per question, ask the human the requirements and limits, then go on to phase 2 in the same session.

## Phase 2 — write

You are continued with the research report paths and the human's answers. Read them all before
deciding. Report into the same file, adding `## Result` under `## Gather`. For every choice, argue both ways: why the common choice fits **here**, or why it would
only limit us to what most use.

If writing turns up a new question that changes a decision, stop and reply with it: one more
gather round, not a decision marked "not verified". A fact that cannot be learned is a stated
assumption with its risk, never a silent guess.

### 5. Decide

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

### 6. Principles — as concrete rules

Not "clean architecture" but rules a reviewer can check, chosen for this project, e.g.: domain
logic imports no framework or database code · each part owns its data; no other part reads its
tables · every external service sits behind one interface in one place · contracts between parts
are typed and versioned · configuration comes from the environment; no secret in a repo · a schema
change is a migration, forward only · a new feature adds a module, it does not edit five.

### 7. Output — `<ws>/architecture.md`

```markdown
# <project> — architecture
## Requirements and assumptions     <!-- from phase 1; each assumption with its risk -->
## The picture                      <!-- parts, repos, how they talk; a small diagram in text -->
## Decisions                        <!-- the blocks of step 5 -->
## Data                             <!-- schema, flows -->
## Principles                       <!-- the rules of step 6 -->
## Risks and open questions         <!-- each with a default; none a gather round could answer -->
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
repos' docs. The same two phases: first the gather list for this change (or "none"), then, once
answered, amend only what the request needs: name what changes and what stays; add the new
decision block with its date, and mark a superseded one "until <date>: …" instead of deleting it;
give the migration path (data, contracts, order of releases); list which repos' docs and rules
must be updated. Do not rewrite what works, and do not take the chance to redo choices nobody
asked about — propose them separately if they matter.

## Rules

- No code, no repos — the setup stage creates them from your output.
- A choice without a "why for this project" or without a rejected alternative is not finished.
- No decision before the gather list is answered; no "not verified" in the written architecture —
  a new question is one more gather round.
- Report per the contract, one file. Phase 1: conclusion in two lines; the gather list (or "none")
  under `## Gather`. Phase 2, under `## Result`: conclusion in two lines; for each statement — checked (by research, by running, by reading) or
  an assumption with its risk.
