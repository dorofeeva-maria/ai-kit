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

Moving a task to `review`, `done` or `dropped` also removes its trees under `worktrees/<KEY>/`
(`git-worktree.sh release <path> <remote>`): only a tree with nothing uncommitted whose commits are
all on its remote branch or in the default branch; a linked `node_modules` or `vendor` loses only
the link; the local branch stays. A kept tree is printed with the reason. `--keep-trees` skips this.
Work that comes back from review gets a new tree.

Run layout migration before converting a legacy task file to the contract. Status moves carry
the whole folder, update the status line and fix references in task Markdown. Run with one
writer for the task and no concurrent edits to affected references. Optional `--config <json>`
supplies legacy status rules, filename mappings and task key patterns. See the
[helper's configuration notes](../scripts/task_folder.py).

## Workspace sync

`bash <kit>/skills/sync/scripts/workspace-sync.sh status|fetch|sync` runs the whole workspace
from its profile: bases, task trees, rebase, what came. Its header lists the profile bullets and
the adapter contract. The plugin's hooks call it as `hook-start` and `hook-prompt`; state (last
sync, base points, queued trees) is in `<ws>/.git/ai-kit/`.

`sync-due.sh <timestamp-file> <max-age-seconds> <command-label> [<message>]` is the older
stand-alone reminder for a workspace that keeps its own hook.
