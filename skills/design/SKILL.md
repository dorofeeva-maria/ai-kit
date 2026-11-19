---
name: design
description: Draw or revise interface mock-ups in one reviewable artifact. Use for visible changes during task design and when asked to sketch, compare, or show a proposed interface.
---

# Draw interface mock-ups

Read the profile's `Design`, each affected app's rules, design system and current screen. Use
the existing screen and nearby patterns as references. Use the journey outline when one exists.

- Make one board for the task. Group frames by app and put them in journey order. Reuse the same
  example data across the flow. Use the device sizes, themes and input modes the profile names.
- Label each journey frame with its step ID. Show the current and proposed screen where the
  comparison helps. Draw the relevant loading, empty, error, permission and other states, plus
  what happens after each action.
- Reuse components, tokens and product terminology. Mark extensions and new components so the
  reviewer can see what the design system needs. Preserve behavior outside the agreed scope.
- Show meaningful variants together with their trade-offs. Keep the board focused on the screens
  and put detailed rationale in a linked note. List open decisions and design-system gaps.

Follow the profile's artifact format. When no format is specified, produce one reviewable HTML
page. Save the source in the task's `design/` folder when a task exists.

Inside `ai-kit:task`, the implementer draws and returns the source and open questions. The
orchestrator publishes the artifact, arranges the combined journey and look check, and applies
the task's approval rules. For a standalone design, arrange independent review before presenting
the board and ask for a decision on unresolved choices. Update the same artifact for revisions
and record approved choices in the task file when one exists.
