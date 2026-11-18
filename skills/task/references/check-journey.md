# Check guide — journeys (the user's path) and the logic of mock-ups

You walk the path as **a person who opened this product for the first time**: you know the job
they came to do, not the product, not the code, not the designers' intent. Then you walk it again
as the experienced daily user in their real conditions (device, hurry, gloves, noise,
interruptions). You try to break it. Output and levels: [contract](../../../docs/contract.md),
"Findings". Change nothing; write only your report.

## Read first

The task file (request, the human's decisions — final, do not argue them), the subject
(`journeys.md`, and the mock-ups if given), the place's design systems and rules, and the code each
step cites.

## For every step of every case

- **Logical.** Every element and message named exists in that state and does what is said. No step
  contradicts another step, another case, a rule of the place or a decision. The order makes sense:
  what the person needs to decide is in front of them before they must decide.
- **Obvious.** A first-time user knows what this screen is for, what to press, and what happened
  after pressing — from what is on the screen, without being told. A label says what will happen
  ("Delete the comment", not "OK"). An icon without a label is a finding when the action matters.
- **Unambiguous.** One way to do one thing. A message names who, what and when. Two elements never
  claim the same job; one element never means two things in two states without saying so.
- **No dead end.** From every state there is a visible way on: retry, fix, undo, cancel, leave.
  Waiting always shows that something runs and whether other input still works. A refusal says what
  to do next.
- **Nothing lost.** Typed text, a selection, a scan, the focus, the place in a list — never lost
  silently. If something is lost, the step says so and the person was warned before.
- **Safe.** A destructive or irreversible action cannot happen by a slip: a double press, Enter, a
  scan, a stray tap. It names its object, and either asks to confirm or can be undone — or the human
  decided otherwise, recorded.
- **Minimal.** No step, message or control that the person in this case does not need. Fewer
  steps beat more; nothing to read that the person will not act on.
- **Accessible.** What a screen reader hears at each step (status or alert, focus), what sound or
  vibration a device gives, touch target sizes on touch devices.
- **Feasible.** Each step the code must do is cited and true in the code, or marked **needs
  change**. A step that silently assumes code that does not exist is a BLOCKS.
- **Consistent across apps.** The same situation behaves the same way in every app the task
  touches, or the difference has a reason.
- **Covered.** Every case in the list of `ai-kit:journey` (step 2) is there or dropped with a reason;
  every mock-up state belongs to a step, and every step that shows something has a frame.

## Output

Findings in the contract's format, worst first, at most 12: step id (`J2.4`), what is wrong, the
evidence (the step's words, `path:line`), the smallest fix. Then the verdict: **clear** (logical,
obvious, unambiguous, no dead end, nothing lost, safe) or **not clear**.
