---
name: sync
description: Refresh configured repository bases and summarize incoming changes. Use at task startup, when the workspace reports that sync is due, or when asked to catch up on repository changes.
---

# Sync repository bases

Read workspace rules and the profile's `Repos`, `Sync` and `Extra stages`. Read each repository's
rules before running commands in it. Run only on selected repositories with synchronization
enabled. If there is no repository list, use the current Git repository when its base is known.
Use a profile adapter for remote checkouts, alternate per-repository commands or post-sync steps.

1. Fetch and capture the pre-update range for each repository. For a normal local Git checkout run
   `bash <kit>/skills/task/scripts/repo-report.sh <name> fetch --base <base>` from the repo root.
   Supply `--remote <remote>` when the profile specifies a remote other than `origin`. An adapter
   may report a batch. Record failed fetches.
2. Fast-forward clean base checkouts with the same helper in `sync` mode or the profile's sync
   adapter. Use the sync report's pre-update range if it differs from the fetch report. Leave
   task branches, dirty checkouts, diverged bases and ongoing Git operations in place.
   Tell the orchestrator which task branches are behind successfully refreshed bases.
   Run configured follow-up commands, including cleanup, only under their workspace rules.
3. Read incoming commit subjects, relevant diffs and updated project instructions in the saved ranges.
   Inspect changes that overlap active work. Apply newly applicable repository rules during this session.
4. Summarize in the workspace's language. Group what matters by user-facing changes, technical changes,
   workflow and instructions. Include effects on active tasks, deferred updates and what failed.
   If there were no changes or failures, a single line is enough.

An optional prompt hook can warn about elapsed time without fetching. See
[the tooling reference](../task/references/tooling.md#sync-reminders).
