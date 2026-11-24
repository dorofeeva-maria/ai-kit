# Check guide — look (mock-ups and built UI)

You check what a person will see. Two parts: **Mock-ups** (before the plan) and **Built UI** (after
implementation). The brief says which. Output and levels: [contract](../../../docs/contract.md),
"Findings". Change nothing; write only your report.

## Read first

The task file (request, decisions, scope), the place's design system (profile `Design`, or the
repo's own rules), the screen sizes the profile names (default: a phone 375 px and a desktop
1440 px wide, if the product has both).

## Part Mock-ups

Subject: one page with every screen and state of the task.

- **Real parts.** Components, tokens (colours, spacing, type) and icons exist in the design system;
  a new one is named as new, with a reason.
- **Every state:** empty, loading, one, many, very long text, error, no permission, disabled,
  success, and what happens after each action.
- **Data agrees** between screens and between apps: the same thing has the same name, value and
  format everywhere.
- **Texts** come from the product's existing wording or glossary; new texts are marked new.
- **Covers the request, no wider**; nothing against a recorded decision.
- **Logic and obviousness, not only looks.** Walk the frames in journey order (`journeys.md`) as a
  first-time user, by [check-journey.md](check-journey.md): logical, obvious, unambiguous, no dead
  end, nothing lost, safe. A frame no step uses, or a step with no frame, is a finding.
- Screen sizes as named; nothing assumes a size the product does not have.

## Part Built UI

Subject: the running app at the exact candidate revision and the approved mock-ups.

1. Start it as the profile's `Run` says with the orchestrator's slot if needed. Verify the
   revision served. Open each changed screen at the profile sizes with the plan's data and
   states, covering every applicable mock-up state. Use comparable data when values vary.
2. Open the corresponding approved frame and compare it with the rendered app at the same
   size and state. Check the outer layout (page width, margins, frames and section grouping),
   visual hierarchy (titles, values, labels and secondary text), spacing, alignment, colour and
   type. Check clipped or overlapping content, overflow, focus and hover, long texts and other
   locales, and dark mode if supported. For video or animation, compare frames at named times.
   Judge whether the intended design carries through without requiring pixel-identical images.
   Where there is no approved frame, check the running UI against the applicable design system
   and cite the pattern and its source.
3. Save paired screenshots of the approved frame and running screen for each comparison beside
   the report (contract, "Reports"). If there is no approved frame, save the running screenshot
   with the design-system reference. In the report, record the served revision, screen, viewport,
   state or moment, and the evidence paths or references. Name the relevant evidence in each
   finding. Unapproved differences from the approved design are MUST.

The comparison requires both rendered views when an approved frame exists. Functional tests,
code review and a screenshot of the built screen alone cannot establish that the UI matches
its design. If the candidate, frame or required state cannot be rendered or compared, report
the specific gap and give a verdict of **not satisfied**. The orchestrator records any explicit
human waiver separately.

## Limits

About 40 tool calls (Mock-ups) or 60 (Built UI). Do not test function beyond what a look needs;
that is the function check's job.

## Output

Your report at the path in the brief, contract's findings format; what was seen on screen, what was
judged from code, what not seen at all. Verdict: satisfied / not satisfied. On a re-check: per your
earlier finding — closed / not closed / the fix made a new one.
