# Task tooling

Resolve `<kit>` from the installed plugin directory. The shell helpers use Bash and Git.
The task folder helper uses Python 3.10 or newer.

## Sync and worktrees

Run from the repository root.

```bash
bash <kit>/skills/task/scripts/repo-report.sh <name> fetch --base <branch>
bash <kit>/skills/task/scripts/repo-report.sh <name> sync --base <branch>
bash <kit>/skills/task/scripts/git-worktree.sh add <path> <branch> origin/<base>
bash <kit>/skills/task/scripts/git-worktree.sh remove <path> origin/<base>
```

The report has eight pipe-delimited fields: name, branch, base, behind, ahead, dirty, incoming
range and note. Counts and range describe the checkout before fast-forward. A failure returns
a nonzero exit and a diagnostic row. `status` is read-only, `fetch` updates remote refs, and
`sync` can fast-forward a clean base. Without `--base`, the report uses the remote's HEAD.
Reports and worktree creation accept `--remote <name>` (default `origin`).
`--ignore-submodules` expresses a workspace policy.

Worktree creation reuses the local task branch, tracks an existing remote task branch, or
creates the branch from the start ref. The `merged <path> <base-ref>` predicate handles
regular and squash merges. Removal is non-forced and leaves branch deletion to the workspace.
Use the repository and tree recorded for the task. Keep dependency setup, remote transport
and shared slot handling in the profile.

## Task folders

```bash
python3 <kit>/skills/task/scripts/task_folder.py --workspace <ws> <KEY>
python3 <kit>/skills/task/scripts/task_folder.py --workspace <ws> --status review <KEY>
```

Run layout migration before converting a legacy task file to the contract. Status moves carry
the whole folder, update the status line and fix references in task Markdown. Run with one
writer for the task and no concurrent edits to affected references. Optional `--config <json>`
supplies legacy status rules, filename mappings and task key patterns. See the
[helper's configuration notes](../scripts/task_folder.py).

## Sync reminders

A prompt hook can run `bash <kit>/skills/task/scripts/sync-due.sh <timestamp-file>
<max-age-seconds> <command-label> [<message>]`. The sync adapter records epoch seconds after
a refresh. A missing or stale timestamp prints a reminder. The optional message supplies
the workspace's wording.
