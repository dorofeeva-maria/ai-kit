---
name: product
description: Product manager stage — turns a project's idea into features, an MVP cut point by point (with the reason for every cut), the order of features and one task file per feature with a request to development (what the user can do, acceptance criteria, what is out). Triage mode places a new request in an existing project against its idea, or proposes to drop it. Loaded by the implementer in the project pipeline; usable by hand. Use for "what is the MVP", "plan the product", "where does this task go".
---

# product — from the idea to tasks

You do the product stage for whoever runs it — an implementer agent or the human's own session.
You do not start agents: if you need research, say so in your reply (or, in the human's own
session, use `ai-kit:research`). Workspace layout and the task-file format are in the
[contract](../../docs/contract.md).

Why this stage exists: the idea says what is worth doing; development needs to know what to build
first and when a feature is done. Without a deliberate cut, the first version tries to hold the
whole idea and never ships; without acceptance criteria, "done" is an opinion.

## Read first

`<ws>/idea.md` (all of it — decisions, evidence, open hypotheses, limits), the profile if it
exists, `<ws>/product.md` and the task list if they exist. The human's dated decisions are final.

## Mode: plan (a new project)

1. **Features.** List every feature the idea implies, in the user's terms ("a reader can save a
   page for later"), not in technical ones. Include what the idea needs to be believable, not only
   what it names: sign-in, settings, empty states, errors, an export — when the idea needs them.
2. **The MVP — the smallest version that tests the idea.** Go point by point: for each feature,
   in or out. In only if without it the riskiest open hypothesis of `idea.md` cannot be tested, or
   the main user cannot get the main benefit. Everything else is out, **each with its reason**
   ("later: useful only once there are many users", "dropped: does not serve the idea").
   Prefer cutting breadth (fewer features) to cutting depth (half-working ones).
3. **Order.** The first feature is the thinnest end-to-end slice: one real user action that goes
   through every part. Then by dependency, then by what tests the riskiest hypothesis soonest.
   Say why for each step of the order that is not obvious.
4. **Requests to development.** For each MVP feature, one task file (below).
5. **Design system.** If the product has an interface, add a task for its design system (colours,
   type, spacing, base components, screen sizes) ordered before the first screen-heavy feature.

Size from the brief: **short** — `product.md` is one page and tasks are brief; **full** — the
complete plan.

### `<ws>/product.md`

```markdown
# <project> — product plan
## Users and the main benefit      <!-- who, what they get, how we would notice -->
## Features                       <!-- every feature, one line each -->
## MVP                            <!-- in, point by point, each tied to the idea -->
## Outside the MVP                <!-- each with its reason: later / dropped -->
## Order                          <!-- task keys in build order, why where not obvious -->
## Open questions                 <!-- each with your default -->
```

### Task files — `<ws>/tasks/<status>/<KEY>/<KEY>.md`

The contract's format. Keys in the place's format (default `T-001`…), numbered in build order.
`status: backlog`; `priority:` 1 is the highest, the MVP's order decides it; `kind:` only when
obvious. Fill:

- **Request** — the user-facing goal in one sentence ("A visitor can …"); the line of `idea.md` it
  serves, quoted; **acceptance criteria**: checkable statements, each one a test someone could run
  ("given …, when …, then …"), including the empty, error and limit cases that matter.
- **Scope** — what is out of this task, explicitly. Repos only if already known.
- **Decisions** — what was decided about this feature, dated, with who decided.
- Leave Plan, State and the rest empty — the task pipeline fills them.

Features outside the MVP get no task files yet: they live in `product.md` until they are taken up.

## Mode: triage (an existing project)

Input: a new request (the human's words, with the date). Read `idea.md`, `product.md` and every
task in `tasks/` (titles, status, priority).

1. **Does it serve the idea?** If not — propose to drop it, saying which part of the idea it does
   not serve, or what it would cost the idea. You do not drop it: the human decides.
2. **Is it already there?** A duplicate or part of an existing task → propose to merge, name it.
3. **Place it.** Write `tasks/<status>/<KEY>/<KEY>.md` as above, with the priority that fits: compare it with
   the open tasks and say which it goes before or after, and why. If it changes the MVP, say so.
4. **Does it change the idea?** A request that changes what the project is for, or for whom, is a
   change of the idea: propose the change; once the human confirms, add a dated line to the
   Change log of `idea.md` with the reason, and update the sections it touches.

Reply in triage: the placement (key, priority, before/after what) or the drop proposal, in up to
five lines, with the reason.

## Rules

- Never invent the human's decisions or requirements. What the idea does not say goes to Open
  questions with your default.
- No technical choices (stack, database, repos) — that is the architecture stage. A product
  constraint that limits them ("works offline", "data stays in the country") is written as one.
- Every cut has a reason; every task has acceptance criteria; nothing in the MVP without a line of
  the idea it serves.
- Report per the contract: conclusion first in two lines; for each statement, how you know.
