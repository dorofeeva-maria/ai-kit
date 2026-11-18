---
name: journey
description: Walk the user's path through a feature or a pattern step by step before anything is drawn or planned — for each role and each case (the normal path, errors, a conflict with another person, no permission, empty, offline, interruption, a dangerous action), what the person sees, what they do, what the system answers, where they go next, what they hear with a screen reader, and how they recover or leave. Written with the designer when there are screens, so every step names where on the screen it happens. Ends in journeys.md that an independent checker reads as a first-time user and tries to break — illogical, ambiguous, a dead end, a lost input, a dangerous action without a guard. Use when the brief says "follow ai-kit:journey", after a brainstorm or `decide` picks an approach and before mock-ups and the plan, or when the human asks "how will it work step by step".
---

# journey — the path a person walks, before it is drawn or built

A screen can match the design system and still fail the person: a button that the text promises
is not there in that state, a message far from the control it explains, a typed text that
silently disappears, two ways to do one thing, a delete with nothing to stop a slip. These are
found cheaply on paper — by walking the path one step at a time — and expensively after code.
This skill writes that walk; an independent checker then walks it as someone who opened the
product for the first time. Shared terms: [contract](../../docs/contract.md).

## When it runs

- In a task, after research and the human's answers, **before mock-ups and before the plan**, for
  anything a person sees or does (task skill, step 3b). Mock-ups are then drawn from the journeys,
  and the plan builds them.
- After a brainstorm or a `decide` run that picks an approach (a pattern, a flow): one journey per
  surviving option, so the options are compared by what the person lives through.
- When the human asks "how will it work?": answer with a checked journey, never with a sketch.

## Inputs

The brief: the request, the human's decisions (final), research, the chosen approach, the
place's design systems and rules, the code of the screens it touches. With screens, the designer's
current mock-ups if there are any, or you draw alongside (see "With the designer").

## Write `journeys.md`

1. **Roles.** Each person who touches the feature (who edits, who views, who is refused), with
   their conditions: device, screen size, input (mouse, touch, keyboard, a special device, gloves), how often they do
   this, how much attention they have, what they know.
2. **Cases.** For each role, every case the feature can meet. Start from this list and drop only
   what cannot happen, saying why:
   normal path · empty / first time · undo or change of mind (cancel, back, close) · invalid input ·
   the server refuses (each refusal the code can return) · no network / timeout · busy / locked ·
   another person changed or deleted the same thing meanwhile · no permission / permission lost
   midway · time or quota ran out midway · the person leaves midway (navigates, scans, locks the
   device) · a double press / double submit · a dangerous or irreversible action · the old client
   or old data. Add the cases the feature has of its own.
3. **Steps.** Each case as numbered steps, one line each, in this shape:
   `<n>. State: <what is on screen, where> → Does: <press / type / scan / wait> → Sees: <what
   changes, where exactly> → Hears: <screen reader / sound / vibration> → Next: <the options now>`.
   Name the real element and its place ("Save button in the panel foot", "the comment row"), the
   exact words, and the focus. A step that waits says what shows while waiting and whether other
   input still works.
4. **Feasibility.** For every step that depends on the code (a dialog that closes, an interceptor,
   a scan handler, navigation that aborts a request, a field that keeps its value), read the code
   and cite `path:line`. A step the code cannot do today is marked **needs change** with what
   changes. Never promise what the code does not do without saying it.
5. **Rules it rests on.** The place's rules, decisions and ADRs each step relies on, cited.
6. **Questions for the human.** Where a step needs a choice that is theirs (a rule to bend, a
   trade-off with a cost), give 2 options with consequences and a recommendation. Never decide it.

Keep it short: steps, not prose. One file; one section per role, one subsection per case.

## With the designer

When the feature has screens, the journey and the mock-ups are made together, so every step points
at a place on a screen and every screen state is a step of some journey:

- Write the journeys first in outline. Then the mock-ups are drawn (in a task the orchestrator
  starts that stage next; by hand, you or the designer do it): one frame per state the journeys
  name, labelled with the journey step it shows ("J2.4"). Then complete the journeys with what the
  frames show.
- A state that appears in the mock-ups but in no journey, or a step with no frame, is a gap: fix it
  before the check.

## The check

Run by the orchestrator, or by hand by the human's session — this skill never starts agents. A
fresh checker (`ai-kit:checker`), never the author: "Follow
`<kit>/skills/task/references/check-journey.md` (`<kit>` = this skill's base directory plus
`../..`). Subject: `<notes>/journeys.md` (and the mock-ups `<link>` if drawn). Decisions: <the
human's decisions>." The author (the same instance, continued) fixes every BLOCKS and MUST, and
the same checker checks again, until it is satisfied. Only then do the journeys (and the
mock-ups) go to the human, with the open questions.

## Report

The path of `journeys.md`; the roles and cases covered and the ones dropped with why; the steps
marked **needs change**; the questions for the human. What was read in code and what was assumed.
