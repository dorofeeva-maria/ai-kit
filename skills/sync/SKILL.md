---
name: sync
description: Bring the workspace up to date — fetch every repo with sync on, fast-forward clean bases, rebase the trees of active tasks on their fresh base (conflicts resolved by the session itself), queue trees with uncommitted changes and rebase them once committed, and summarize what came into each base. Use at session start, before creating a branch, worktree, push or PR, after a task's PR is merged, when the hook says sync is due or a queued tree is committed, or when asked to catch up on repository changes.
---

# Sync the workspace

Read the workspace rules and the profile's `Repos`, `Sync` and `Extra stages`. Read each
repository's rules before running commands in it. Answer in the workspace's language.

## 1. Run the script

From anywhere inside the workspace:

```bash
bash <kit>/skills/sync/scripts/workspace-sync.sh sync
```

It does, for every repo whose `Sync` cell starts with `on`:

- **base checkout** — fetch; fast-forward when it is on its base branch, clean and not ahead;
  otherwise leave it and say why;
- **task trees** (`worktrees/<KEY>/<repo>/`) of tasks in `tasks/in-work/` or `tasks/review/` —
  rebase on `origin/<base>` and push with `--force-with-lease` when the branch was pushed;
- **what came** — the commits that reached each base since the last sync, and the instruction
  files they changed.

A repo that needs its own way (a remote container, signed commits, another transport) has an
adapter in the profile (`- adapter <folder>: <command>`); a follow-up after a base refresh is
`- after <folder>: <command>`. The script's header documents the profile bullets and the adapter
output. `status` reads without network; `fetch` reports without moving anything.

## 2. Act on the notes in the table

| Note | What you do |
|---|---|
| `fast-forwarded`, `rebased …`, empty | Nothing |
| `conflict, rebase aborted: <files>` | In a task pipeline, brief the part's implementer (task briefs, "rebase"); otherwise rebase that tree yourself (`git rebase origin/<base>`) and resolve every conflict: keep the intent of both sides, run the repo's checks, push with `--force-with-lease` if the branch was pushed. Decide yourself: do not ask the human and do not list your choices |
| `waits: uncommitted changes` | Leave the tree. It is queued: the moment its work is committed (by you or by the human), rebase it as above; the prompt hook says so for a queued tree that became clean |
| `a chain with <tree>` | Rebase the chain bottom-up: the first part on `origin/<base>`; each next part with `git rebase --onto <previous part's branch> <old tip of the previous part>` (save the old tip before moving it). A part whose previous part is merged goes on `origin/<base>` the same way. Push each with `--force-with-lease` |
| `<origin/branch> has N commit(s) this tree lacks` | Someone else pushes to that branch. Do not rebase it; ask the human |
| `task not in work or review` | Leave it; mention it only if the task should be closed |
| `detached` | Leave it |
| `Git operation in progress` | Leave it and tell the human |
| `skipped: …` on a base checkout | Someone works there (another session, a test, the human): leave it and name it |
| `fetch failed`, `not on this device`, adapter failure | Say where the update is incomplete |

**Never** on any branch: `git stash`, a plain `git push --force`, a rebase of a base or shared
branch, a WIP commit made only to be able to rebase.

## 3. Read what came

Read the commit subjects, the relevant diffs and the instruction files the script lists. Inspect
changes that overlap active work. Apply newly applicable repository rules in this session.

## 4. Summarize

A separate part of the message, before returning to the task: what came, grouped by user-facing
changes, technical changes, workflow and instructions; the effect on active tasks; what was
rebased, what waits for a commit, what needs the human, what failed. No changes and no failures
— a single line.

Then follow the profile's `Sync` section for anything after a sync (cleanup of merged trees,
closing tasks).

## Hooks

The plugin's hooks run the script for you in any workspace with a profile and sync on, and stay
silent elsewhere: at session start the `fetch` report; on every prompt a reminder when the last
sync is older than `- reminder: <hours>` (default 3), and a line for each queued tree that is now
committed and still behind. State lives in the workspace's `.git/ai-kit/`.
