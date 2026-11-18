# Profile template — `.claude/kit-profile.md`

Copy the block below into `<workspace>/.claude/kit-profile.md` and fill it. The headings are the
[contract](../../../docs/contract.md)'s; a heading left out or empty means its default (in each
comment). Write facts only — no code rules (they live in each repo's own `AGENTS.md`, which wins
over this file).

```markdown
# Kit profile

## Repos
<!-- One row per repo in the workspace. Sync on only where other people (or devices) push too. -->
| Folder | What it is | Base branch | Sync |
|---|---|---|---|
| app | the web app | main | off |

## Checks
<!-- Per repo: the commands that must be green, in order. Default: what the repo's own rules name. -->
- app: `npm run lint` · `npm run typecheck` · `npm test` · `npm run build`

## Run
<!-- Per repo: how to start it for a function or look check; URL, test login if any (test only);
     whether it needs the main checkout or a shared resource (then the task uses a slot). -->
- app: `npm run dev` → http://localhost:5173 · runs from any worktree

## Tasks
<!-- Where tasks come from, key format, branch name; keys or kinds of task the kit must not take
     (another procedure owns them). Default: tasks/ files, T-001, task/<KEY>-<slug>, none excluded.
     Name EVERY place where the team keeps tasks (a tracker and its projects, GitHub/GitLab issues,
     tasks/ files) and how to read it: the task skill reads all of them for duplicates and related
     tasks before each task (step 1); say what "open" (= not released) means there. -->
- Source: `tasks/` files
- Other tasks (duplicates, related): `tasks/` files; open = `status:` is not `done`
- Key: `T-001`
- Branch: `task/<KEY>-<slug>`
- Not taken by the kit: none

## Git and PRs
<!-- The code host (GitHub / GitLab, its address) and the tool to reach it (a connector, `gh`,
     `glab`) — the prs skill and the task skill use it. Commit format, PR title and description
     rules, draft or not, who is assigned, AI attribution lines yes/no; a worktree command if the
     place creates worktrees its own way (it replaces the default `git worktree add`; say its
     arguments). Default: the host of the repos' remotes; the repo's rules; PRs open as drafts;
     nobody assigned; plain `git worktree add`. -->
- Host: GitHub, `gh`
- Commits: the repo's format
- PRs: draft; title `<KEY>: <what>`; description: what, why, how checked
- Worktree: default

## Reviewers
<!-- Who is set as reviewer when the task skill creates a PR: per repo, per kind of task
     (feature / bug / docs …) or per area (backend / frontend / translations), with the code host
     username. A PR gets the reviewers of every row that matches; a row may say "nobody". The order
     of review, if the team has one (backend first, then frontend), and whether reviewers are set
     on drafts. Default: none — the kit sets no reviewer. -->
| Repo or area | Kind of task | Reviewers |
|---|---|---|
| app | any | `@username` |

## Autonomy
<!-- stops: approve (the human approves mock-ups and plan) | blockers (stop only on blockers) |
     own (as blockers, and merges within the merge level).
     merge: pr (the human merges) | auto-low (the orchestrator merges low-risk PRs after all checks)
     | full (merges every PR after all checks). The orchestrator merges only under stops own;
     otherwise the human merges. Default: approve · pr. With auto-low, say what is low-risk here. -->
- stops: approve
- merge: pr
- low-risk (for auto-low): docs only · tests only · dependency patch bumps with green checks

## Design
<!-- Design system location(s) per repo or for all; screen sizes; a design skill or stage to use for
     mock-ups if the place has one. Default: none — the implementer draws mock-ups as one page. -->
- System: none
- Sizes: 375 px · 1440 px

## Extra stages
<!-- Place-only skills and where they run; a default step of the task skill replaced by the
     place's own way, or switched off. Default: none. Examples:
     - e2e: skill `e2e`, after all parts, before handoff; needs the slot.
     - architecture: never (the contract between parts lives in the plan) | always for large tasks. -->

## Never
<!-- What must not be read, changed or taken outside — passed verbatim into every brief.
     Default: secrets and .env files are never read; no real user data in commits, PRs or reports. -->
- Never read `.env*` or files with passwords or keys.

## Language
<!-- With the human; in code, commits, PRs and docs. Default: the human's language / English. -->
- With the human: the human's language
- Repos: English
```
