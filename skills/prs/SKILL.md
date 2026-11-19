---
name: prs
description: List one person's open pull requests (merge requests on GitLab) across every repo of the workspace, for a period — the code host and how to reach it come from the place's profile. Each row says what the PR waits for (the author, a review, a rebase, a pipeline, a decision to close), which task it belongs to and whether that task is still alive; PRs of one task are grouped. Read-only: it never comments, rebases, closes or merges. Use for "my open PRs / MRs", "which MRs are ready for review", "what is open from <person> since <date>", "list the old PRs", "PR cleanup".
---

# prs — one person's open PRs, with what each one waits for

Read-only. You list and judge; you never comment, rebase, close, merge, un-draft or assign. A
proposal to close or rebase is a line in the result for the human to act on.

"PR" below means a pull request on GitHub or a merge request on GitLab, whichever the place uses.
Say it the place's way in the result (MR on GitLab).

## Inputs

- **person** — default: the user the code host is signed in as (`gh api user`, GitLab `whoami`).
  Another person by username or name; a name you cannot map to one username is a question.
- **period** — default: none (every open PR). A period filters by **creation date** unless the
  request says "active", "touched" or "updated" — then by the last update. Turn relative periods
  ("last month", "since Monday") into dates and say them in the result.
- **role** — default `author`. Also `reviewer` (PRs where the person is asked to review) or
  `assignee`, when the request says so.
- **state** — open only (drafts included and marked). Merged or closed only when asked.

## 1. Read the place

From `.claude/kit-profile.md` (if there is none, ask which code host and repos):

- **Git and PRs** — the code host, its address and the tool to reach it (a connector such as an
  MCP server, `gh`, `glab`); what a draft means here; who may un-draft and merge.
- **Repos** — the workspace's repos. The person's PRs in **other** repos of the same host are
  listed too, in their own group "outside the workspace".
- **Tasks** — the key format and the tracker, to tie a PR to its task (step 3).
- The place's rule for a **stale** task or branch, if it has one (often in the workspace
  `AGENTS.md`). Default: no work and no discussion for more than 30 days.
- **Language** — of the result.

If the profile names no code host, look at the remotes of the repos (`git remote -v`); several
hosts are each listed.

## 2. Collect

One list call per host, filtered on the host side by person, role, state and period
(GitHub: `gh search prs --author <u> --state open --created <from>..<to> --json …` or the API;
GitLab: list merge requests with `author_username` / `reviewer_username`, `state=opened`,
`created_after` / `created_before` or `updated_after`). Page through until the end.

**Keep raw results out of your context.** A host returns large objects (full descriptions). When a
result is long or the tool saves it to a file, read it with a short script (`jq`, `python -c`) that
prints one line per PR with only the fields below — never read the raw JSON whole.

Per PR: repo, number, title, link, draft, created, updated, source and target branch, reviewers,
assignees, mergeability (conflicts, needs rebase), approvals if the list gives them.

Then, **only for the PRs whose state you cannot judge from the list** (and at most ~20 calls),
fetch the head pipeline status and unresolved discussions per PR. Old PRs with conflicts need no
extra call: their state is already clear.

## 3. Tie each PR to its task

- The key from the title, then the branch name (profile's key format).
- PRs with the same key in several repos (an app and its translations, a chain of parts) are one
  group, in chain order when the target branch shows it (part 2 targets part 1's branch).
- If the profile names a tracker and a connector is available, read each key's status in **one**
  search (e.g. JQL `key in (…)`), not one call per key. A task that is done or released while its
  PR is still open is a finding.
- If the workspace keeps task files (`tasks/<KEY>/<KEY>.md`), read each key's stage line: it says what
  the work waits for better than the host does.

## 4. Judge what each PR waits for

One verdict per PR (per group when they move together), with its reason in a few words:

| Verdict | When |
|---|---|
| **ready for review** | not a draft, or the task file says the work is done and checked; pipeline green; no conflicts; no reviewer has answered yet |
| **in review** | reviewers set, open discussions or changes requested — waits for the reviewer or the author's answer |
| **in work** | draft, and the task file or recent commits show work going on |
| **needs rebase** | conflicts or "needs rebase"; say since when the PR is untouched |
| **pipeline failed** | the head pipeline failed |
| **stale — close?** | stale by the place's rule (no commits, no discussion past the limit) or its task is done / cancelled; propose: close, rebase and finish, or ask the owner |
| **someone else's call** | the PR is the person's but waits on another person (a reviewer named, the human said so) |

"Ready for review" is strict: a draft whose task still has unfinished stages is **in work**, even
if its code looks done. Say what is missing ("waits for the end-to-end test").

## 5. Result

In the place's language, short, newest first inside each section:

```markdown
## Open MRs of <person> · <period or "all"> · <date>

**Ready for review** — <n>
- [!123 Title](link) · repo · <task KEY, task status> · why ready

**In work / in review** — <n>
- …: what it waits for

**Needs attention** — <n>
- …: conflicts since <date> / pipeline failed / task released, PR still open — proposal

**Stale — close?** — <n>
- …: last activity <date> · proposal (close / rebase and finish / ask <owner>)

Outside the workspace: …
Not checked: what you did not fetch (pipelines of old PRs, discussions) and why.
```

- One line per PR or per group of one task; link every PR.
- No section without rows.
- More than ~25 rows: give the counts and the first two sections in the reply, and offer the full
  list as a page or a file in the scratchpad.
- Never put the PR descriptions' content, secrets or customer data into the result.

## What this skill does not do

It does not act on its proposals. Closing, rebasing, un-drafting, assigning reviewers or
commenting is the human's word, done by them or by a task on their instruction.
