---
name: wrap
description: End of the working day in one session — settle the session's background work (wait for what is about to finish, stop what is long, say what happened to each), then print right in the session a short recap to copy onto paper - what was done, what is being done now, which stage the task is at and which stage comes next, and the PRs (MRs on GitLab) of this task only that can be handed over for review, with links. Commits nothing, pushes nothing, writes no file, calls the code host read-only, starts no agents. A personal session with no code gets only the background and the recap. Use for "wrap", "wrap up", "end of day", "stop for today", "shutdown", when the human's alarm rings and they close the day in each open session.
---

# wrap — close the day in this session

The human closes the day in every open session, writes on paper where they stopped, and tomorrow
says "continue" in the same session. You make that paper note easy: settle what runs, then one
short recap. Nothing else.

**You write nothing.** No commit, no push, no stash, no file, no task file edit, no folder move, no
PR change, no reminder, hook, schedule or time setting, no agent started. Unfinished work stays
exactly as it is — `task` (or the human) commits it later. The only output is the message in the
session. No closing phrase at the end: the human says that themselves.

Answer in the place's language (`.claude/kit-profile.md`, heading `Language`); default: the
language the human speaks in this session.

## 1. Background work — wait or stop

After `wrap` nothing of this session keeps working overnight. List the session's background work
and settle each item, with the current tool's own means of listing and stopping it — whatever this
tool has: subagents, background shell commands, monitors. In Claude Code these are the background
agents and `run_in_background` commands (stopped with its task-stop tool); in Codex, its own
background tasks. If the tool does not let you see or stop them, say so in one line.

| The work | What you do |
|---|---|
| about to finish (its last step is running, or it reported it is wrapping up) | wait for it — a few minutes at most — and take its result |
| long (a whole stage, a test suite, a research round) | stop it. An agent's edits are not lost: they stay uncommitted in its tree — name the tree |
| an operation that breaks if cut mid-way (a rebase, migration, install or push half done) | wait for its end, then stop what started it if anything is left |
| a loop or scheduled wake-up of this session | leave it unchanged (wrap touches no schedule); name it — the rule below keeps it from starting work |
| a review environment `task` holds for the human's review window (an app, its slot) | not this session's background work: leave it running; name it in the recap |

The human's word wins: "wait for all" — wait for every one; "stop all" — stop every one, and
still name what was lost (only the agent's context; its edits stay in the tree).

**After the recap, start nothing** until the human themselves says to continue. A result or a
wake-up that arrives later is only noted in one line — no new agent, check, commit, push or step of
the task. A loop or schedule firing is not the human's message, even when it arrives as a prompt.

One line per item for the recap: what it was · finished / stopped — why.

## 2. Where the work is

Read, do not write:

- **The conversation** — what was done today, what was being done when the human called you.
- **The task file**, in a task session: `tasks/<status>/<KEY>/<KEY>.md` in the workspace — `State`
  (stage, branches and PRs per repo, round counters) and `Next step`. The conversation may be
  ahead of the file; trust the newer one and say so if they differ.
- **The trees** of this session: `worktrees/<KEY>/<repo>/` and any repo the session worked in —
  `git status -sb` for uncommitted files and commits ahead; `git log @{u}..` for unpushed
  commits, or `git log origin/<base>..` when the branch has no upstream yet.

Name the **stage**, not one next action. In a task session the stages are the `task` skill's
steps: request and scope · research · questions · journeys · mock-ups · plan · branches and
worktrees · implementation per part (develop, checks, function and look, tests, review with its
round, docs) · end-to-end and extra stages · handoff · after handoff. Give the part and the round
where it matters ("part 2 of 3, review 2/3"). Outside a task, name the stages the conversation
itself shows (outline → draft → edit; plan → week → day).

## 3. PRs of this task — read-only

Skip this step when the session touched no code repo and no PR: no host call at all.

**Find the host** from the profile: `Git and PRs` (the code host, its address and the tool to reach
it — a connector such as an MCP server, `gh`, `glab`), `Repos` (the repos and their base branches),
`Tasks` (the key format). No profile or no host named → the remotes of the repos (`git remote -v`).

**Only this task's PRs**, open ones, drafts included. A PR belongs here when:

- its source branch is in the task file's `State`;
- its source branch is one of this session's worktrees (`git -C <tree> branch --show-current`);
- its branch or title carries the task's key (default branch form `task/<KEY>-<slug>`).

Query per repo of the task, never the person's whole PR list:

- GitHub — `gh pr list -R <owner/repo> --state open --head <branch> --json
  number,title,url,isDraft,mergeable,reviewDecision,statusCheckRollup`, and once more with
  `--search "<KEY> in:title"` instead of `--head` (`<owner/repo>` from the repo's remote).
- GitLab — the project from the repo's remote; `GET /projects/:id/merge_requests?state=opened`
  with `source_branch=<branch>`, and once with `search=<KEY>&in=title`. For a candidate for
  "ready" only: `GET .../merge_requests/:iid` (head pipeline), plus its `/approvals` and
  `/discussions`.

Print only the fields you need; never read raw host JSON whole.

**Ready for review — strict.** All of: not a draft, or the task file says this part's work is done
and checked; pipeline green on the head commit; no conflicts; no reviewer has answered yet; and no
`task` stage is unfinished for this part (develop, checks, function and look, tests, review, docs)
or for the task before handoff (end-to-end, extra stages). A PR whose code looks done while a stage
still waits is **not** ready; the Stage line of the recap already says what it waits for. Only
ready PRs go into the recap.

(The `prs` skill of the same kit lists all of one person's PRs with the full verdict table; this
step is the same judgement, narrowed to one task.)

## 4. The recap — in the session

Short, in the style of a `/recap`: enough to copy onto paper in a minute. Labels in the place's
language. Leave out a line that has nothing.

```markdown
**<KEY> — <title>** · <date>
Done: <a few words>
Now: <what was in progress when you stopped>
Stage: <current stage, part and round> → next: <next stage>
Background: <item> — finished · <item> — stopped, edits left in <tree>
Not committed: <repo or tree> — <n> files, stays as is
Not pushed: <repo or tree> — <n> commits
Ready for review: [!123 Title](link) · [!124 Title](link)
```

A session without a task: the first line is the topic instead of the key. A personal session (no
code, no PRs): only the title, Done, Now, Stage → next and Background.

## Why this shape

- Writing a concrete plan for an unfinished goal frees the mind from intrusive thoughts about it
  (Masicampo & Baumeister, 2011, on the Zeigarnik effect) — so the recap names the next stage and
  the human writes it down by hand.
- A fixed end-of-day shutdown routine (Cal Newport's shutdown ritual) — one command in every open
  session, the same output each time.
- Ready-made handoff skills and wrap-up commands write to files and know nothing of the code host
  or the task's stages; here the task file already holds the state, and the PRs come from the host.
