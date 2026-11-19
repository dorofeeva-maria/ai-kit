---
name: e2e
description: Run a user journey end to end on a configured test environment, including flows that cross applications. Use for an approved task scenario or when asked to verify an integrated flow live.
---

# Run an end-to-end scenario

Read the profile's `Run`, `End-to-end` and any applicable `Extra stages`, then the affected
repositories' rules. Use the planned scenario and the configured test environment and tools.

1. Write a scenario with role, app, action and expected result per step. Mark steps that change
   data, and cover relevant failure paths. Record the intended changes and cleanup. Inside
   `ai-kit:task`, use the agreed plan and report deviations to the orchestrator before running.
   For a standalone run, get agreement on the environment and any new mutations before writing.
   Apply any standalone approval and slot rules from the profile.
2. Verify that required checks are green and that all apps and the backend serve the intended
   revisions. Follow the profile for provisioning, fixtures, accounts and access. In a task the
   orchestrator acquires any required shared slots and gives their details to the runner.
3. Follow the real navigation and input path. For cross-app steps, verify the resulting state in
   the other apps. Check relevant console and network errors. Capture screenshots or relevant
   request evidence under the workspace's data rules. Record actual results as you go.
4. Write the report with the environment and revisions, a table of expected and actual results,
   evidence links, findings, changed data and restoration, and cases or devices left unchecked.
   For a task use `<task>/e2e/e2e-<round>/e2e-<round>.md` with evidence beside the report when
   there is evidence to retain. An unavailable environment or incomplete scenario is a blocked
   or partial result.
5. Close the browsers and stop processes you started. Remove test data as agreed and update
   the report with actual restoration and any cleanup that failed.
   Inside a task return control to the orchestrator so it can release the slots and send findings
   to the part owner. Re-run affected steps after a fix. Where practical, have the part owner
   cover the verified behavior with an automated test.
