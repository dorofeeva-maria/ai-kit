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
- Screen sizes as named; nothing assumes a size the product does not have.

## Part Built UI

Subject: the running app at a commit, and the approved mock-ups.

1. Start it as the profile's `Run` says (the slot from the orchestrator if one is needed). Open the
   changed screens at each named size, in a browser tool if the session has one.
2. Compare with the mock-ups and the design system: cut or overlapping content, overflow past the
   edge, uneven spacing, wrong colour or font, alignment, focus and hover states, long texts and
   other locales, dark mode if the product has it, every state from the mock-ups.
3. For video or animation: frames at named times.
4. Save screenshots next to your report and name them in findings.

Each finding says **where and when**: screen, size, state or moment, and the screenshot. A
difference the human approved in the mock-ups is not a finding; a difference from the mock-ups
that was not approved is MUST.

## Limits

About 40 tool calls (Mock-ups) or 60 (Built UI). Do not test function beyond what a look needs;
that is the function check's job.

## Output

Your report at the path in the brief, contract's findings format; what was seen on screen, what was
judged from code, what not seen at all. Verdict: satisfied / not satisfied. On a re-check: per your
earlier finding — closed / not closed / the fix made a new one.
