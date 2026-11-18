---
name: brainstorm
description: Generate strong, ambitious, checked ideas for a goal — a product, a project, an experiment, a move. Starts from the real people who will use it and their day (jobs, habits, what they use now), generates whole solutions rather than features with independent generators whose lenses are those people's days and jobs, checks "does this already exist?" before selection, keeps only what we can build within the stated appetite and what people would use every day, then exaggerates, checks against reality with the research skill and lets critics attack; ends with three ideas, one ambitious-but-buildable, each with evidence, price, a day-in-the-life and a 30-minute test. Three modes (live / stops / without the human) and three depths. Use for "brainstorm", "ideas for…", "what could I build / do", "think bigger".
---

# brainstorm — whole solutions people would use every day, checked against reality

You are the **coordinator**, in the **main session** — never inside a subagent (subagents cannot
reliably start agents or save report files; see "Files" below). Generators, researchers and
critics are background agents; files carry the ideas between steps. You talk to the human, pass
findings between agents, and never let one agent see another's reasoning.

Why this shape: a single model fixates on its first ideas and averages what it knows, so one
generator gives a narrow, familiar pool — hence many independent generators, then selection. But
diversity alone produced the failure of the first run (17.11.2026): features instead of products,
ideas nobody would use on an ordinary day, and an "ambitious" idea that already existed and that
the team could not build. So every step here is anchored on three things:

1. **The users' day.** Ideas are generated from the real people who would use the thing — their
   shift, their habits, what they use now and why it is good enough — not from abstract lenses.
2. **Whole solutions.** The unit is a product or solution that takes a whole job off someone's
   day, end to end; a feature is material for a solution, never an idea on its own.
3. **Reality before selection.** "Does this already exist?" and "can we build it within our
   appetite?" are checked *before* the shortlist, not after the attack.

`<skill>` is this skill's base directory; `<research>` is `<skill>/../research` (read its
`SKILL.md` before the first research step and run research exactly by it).
`<run>` = `~/.cache/ai-kit/brainstorm/<YYYY-MM-DD>-<short-slug>/` with `ideas/` (absolute path).

## Files — who writes what

Claude Code refuses a subagent's Write of a markdown file whose name starts with `report`,
`summary`, `findings` or `analysis`, and that is the harness's rule, not a bug to get around. In
this skill: generators, the developer and the critic write their working files themselves
(`ideas/<lens>.md`, `taken.md`, `shortlist.md`, `big.md`, `attack.md` — names chosen to be
allowed). Research runs by the research skill, where the compressor and the writer return text
and you save it. If any agent's write is refused anyway, it returns the full text and you save it
verbatim — never by renaming, Bash or a script.

## Modes — ask at the start unless the request says

- **live** — the human and you throw ideas in the chat; you develop and exaggerate theirs and add
  your own; agents only research and attack in the background. Steps 4–7 happen in the
  conversation: one move at a time, the human's idea first, never a wall of frameworks.
- **stops** — agents work in the background; the human steps in three times: after the brief
  (step 1), at selection (step 6) and before the result (step 9). The session stays free;
  anything they drop in between is passed on.
- **without me** — only when the human says so explicitly ("create without me", "don't ask").
  No interview beyond what is written; assumptions are listed at the top of the result.

## Depth — say your choice in one line

| | quick | standard | deep |
|---|---|---|---|
| Interview | short | full | full |
| Ground: users' day + what exists (step 2) | from what the place already has | + research `standard` on what exists | + research `deep` |
| Generators (step 3) | none — you, with 2–3 lenses, in the session | 4 | 7 |
| "Already exists?" before selection (step 5) | you, one quick search per finalist | research `quick` per cluster | research `quick` per cluster, 2 phrasings |
| Hyperbole | top 3 | top 5 | top 6 |
| Reality loop | 1 quick research on the best idea | up to 2 rounds | up to 3 rounds |
| Attack | you, as the skeptic and the user | 1 critic, 4 roles | 1 critic, 4 roles, per idea |

## 1. Interview — the goal, the people, the appetite

The input decides everything; many questions are fine. Ask (AskUserQuestion in batches, or in the
chat in live mode) until you could explain the request to a stranger:

- **The goal** — what does winning look like? Users, income, a prize, a publication, a skill?
- **The people, by role** — who would *use* it, who would *pay*, who would *be affected* (they may
  be different people). For each role: an ordinary day near this topic hour by hour, what they use
  now (paper, a chat group, a spreadsheet, a system, someone's memory), their habits and
  constraints (hands busy, noise, night shift, phone only, Telegram all day), what they complain
  about and how often. Quote the human's sources (interviews, conversations) — real words beat
  guesses; say where you have none.
- **Appetite — what "we can build it" means.** Who builds, how many hours a week, until when;
  money; skills; what must not be touched (contracts, employers, law). Fix two horizons in the
  human's words: **near** (the first version real people use — e.g. "in 6 weeks") and **bold**
  (the most this team could build and run with focus — e.g. "in 9–12 months, maybe one hire").
  Appetite is a fixed budget: scope bends to fit it, not the other way round.
- **What exists and was rejected** — what they already thought of, tried, dropped, and why.
- **The bar** — an idea they consider strong, and one they consider mediocre; what excites them.

Anything vague, contradictory or doubtful — ask, do not guess. Write the brief to `<run>/brief.md`
in the human's words (quotes with the date), with the roles, their days and the appetite as
sections.

**Selection criteria** — the defaults, unless the brief sets others; all are applied before the
shortlist:

1. **Used every day (or every time the job comes up) without being forced** — by a named role, in
   their real conditions; convenient enough to beat what they use now. Frequency × pain.
2. **Real benefit** — to the user and to whoever pays; say who pays and why they would.
3. **A whole solution** — it takes a whole job (or a chain of jobs) off someone's day end to end;
   not a feature of something else.
4. **New where it matters** — checked in step 5, not assumed: not already done in this form, for
   these people, in this market.
5. **Buildable by us within the appetite** — the three main ideas fit the near horizon for their
   first used version; the ambitious one fits the bold horizon as a whole.

Scale is wanted: among ideas that pass 1–5, the bigger consequence wins. What does **not** pass
5 is not "ambitious", it is out of reach — it goes to the graveyard with "beyond appetite" and
what would have to change (money, a partner, a hire) to revive it.

**Stop 0 (stops mode):** show the brief in 10–15 lines — the roles and their day, the appetite,
the criteria. The human corrects it before anything runs.

## 2. Ground — the users' day and what already exists

Two inputs every generator reads, both written before any generation:

- **`<run>/day.md` — the day of each role**, from the place's own material (interviews, notes,
  conversations, the brief) and, at standard and deep, the research below. Per role: the day hour
  by hour; each recurring job as a job story ("When <moment>, I want <…>, so I can <…>") with its
  **frequency** (every shift / weekly / monthly) and **intensity** (how much it hurts, in their
  words), how they do it now, what it costs them, what would push them off the current way and
  what habit holds them; habits and conditions; direct quotes with dates. You write it from the material; at deep, one agent may draft it for you.
- **`<run>/ground.md` — what exists**: research on the **field** (standard: `standard`, deep:
  `deep`): products and services that serve these roles' jobs (globally and in the human's market,
  with prices and dates), what was tried and dropped and why, what became possible in the last
  year, what users complain about. Researchers get the field, the roles and the jobs — **never the
  goal or hoped-for ideas**. Own data on unless the human wants an outside view. Save the report
  as `ground.md`.

## 3. Diverge — generators in parallel, blind to each other

One message, all generators in the background (`general-purpose`, `model: opus`, high effort —
the human of this kit asked for high effort on thinking roles). Each gets **one lens**; every lens
starts from the people in `day.md`:

| # | Lens | The question it works from |
|---|---|---|
| 1 | The user's day | Walk one role's day hour by hour. Where is the worst recurring moment? What single product would sit in that day every day and take whole jobs off it? |
| 2 | The payer's day | Walk the payer's day and night (owner, manager, buyer). What do they decide blind, worry about, chase by hand? What would they pay for every month and check every morning? |
| 3 | Fire the current tool | What do they "hire" today for each job (paper, chat group, spreadsheet, a system, memory)? What would make them fire it — and what keeps them (habit, fear, effort)? Design the replacement that wins on all four forces. |
| 4 | The whole system | Instead of one job, the whole operational loop of the team (a shift, a week, a month): one solution that carries it end to end, so the pieces stop living in different places. |
| 5 | Frontier, applied to a job | What became possible this year (models, voice, vision, prices, laws, platforms) that changes *how one of the jobs in `day.md` is done* — not a technology looking for a use? |
| 6 | ×10 for one segment | Pick one segment of users. What would be ten times better for them on the one dimension they care most about — a different machine, not a bigger one? |
| 7 | The schlep | Which dull, hard work does everyone in this field avoid (data entry, local integrations, onboarding by hand, messy formats)? What becomes possible for whoever does it? |

Standard: lenses 1, 2, 3, 4. Deep: all seven. Brief:

```
Generate ideas. Today is <YYYY-MM-DD>.
Brief: <run>/brief.md. The users' day: <run>/day.md. What exists: <run>/ground.md (if it exists).
Your lens: <number and name>.
Write 6–8 ideas to <run>/ideas/<lens-slug>.md.
First read <skill>/references/generator.md and follow it.
```

Generators do not see each other's files or the other lenses.

## 4. Cluster

One agent (`general-purpose`, `model: fable`; if unavailable, `opus`): "First read
<skill>/references/develop.md, part Cluster. Brief: <run>/brief.md. Ideas: <run>/ideas/. Write
<run>/clusters.md." — duplicates merged, features folded into the whole solutions they belong
to, 10–16 candidate solutions left, each with the jobs it takes over and the existing products
it would meet. Its reply lists, per candidate, 1–2 neutral questions for step 5 ("Is there a
product that does X for Y in Z?").

## 5. "Already exists?" — before selection

Run research `quick` on the candidates' questions (standard: one researcher per 3–4 candidates;
deep: two phrasings each). **Researchers get the neutral question, never the idea or the hope.**
Save the findings to `<run>/taken.md`: per candidate — exists as is / exists for other people or
another market / exists but done badly (with what users say) / not found (with what was searched).

## 6. Select

Continue the cluster agent (it remembers): "Part Select. Taken: <run>/taken.md. Day:
<run>/day.md. Write <run>/shortlist.md." — scored on the five criteria with one line of why; an
idea that exists as is in the human's market is dropped or rebuilt around its real opening; an
idea beyond the bold appetite goes to the graveyard; the rest are **weighed, pros against cons**, never knocked out by one weak
criterion; 6–8 kept, the strongest **and most different**, at least two of them as ambitious as
the bold appetite allows.

**One more round when the first is weak.** If the agent wrote `<run>/lessons.md` (fewer than 6
ideas keep a balance in their favour, or the last three picks are weak), do two things at once:

- **Tell the human now**, in a few lines: what went wrong in this round and, for each lesson, the
  change to this skill's rules that would prevent it (which file, what to add). On their yes, edit
  the kit's skill files and commit; the kit is meant to learn from each run.
- **Run step 3 again** with new generators (same brief form), adding to each brief: "Lessons from
  the first round: <run>/lessons.md — avoid these mistakes. The first round's ideas are in
  <run>/clusters.md: do not repeat them." Then steps 4–6 on the old and new ideas together. One
  extra round at most; if it is still weak, say so in the result.

**Stop 1 (stops mode):** show the shortlist as a compact table (name · who uses it daily · which
jobs it takes · exists? · fits which horizon). The human adds their own ideas, says what lights up
and what is dead. Their ideas enter as equals; their "dead" is final.

## 7. Hyperbole — bigger inside the appetite

Continue the same agent: "Part Hyperbole, top <N>. Write <run>/big.md." — for each: its ceiling,
real vs invented limits, ×10 on the user's benefit and on adoption (not on a marketplace or
network nobody can build), the **day in the life with the product** (the user's shift, then the
payer's morning), the press release from the future, the **wedge** (the first version used daily
within the near horizon) and the path to the big version within the bold horizon, and **what must
be true** (3–5 checkable hypotheses).

## 8. Reality loop

For the top ideas, turn "what must be true" into research questions and run `research` (`quick`
per hypothesis; several researchers with varied wording, or two with the same wording when a fact
is contested). **Researchers get the hypothesis as a neutral question, never the idea or the
hope.** Then continue the developer with the findings: "Part Correct. Findings: <paths>. Update
<run>/big.md, mark what changed." Repeat up to the depth's limit, or stop when a round changes
nothing.

## 9. Attack

A fresh critic (`ai-kit:checker`, or `general-purpose` with the checker's rules; `model: fable` or
`opus`): "First read <skill>/references/attack.md. Brief: <run>/brief.md. Day: <run>/day.md.
Ideas: <run>/big.md. Research: <paths>. Write <run>/attack.md." It never gets the generators' or
developer's reasoning. The developer answers each attack once (fix or concede). An idea whose
fatal attack stands goes to the graveyard with the reason.

**Stop 2 (stops mode):** the survivors with their day-in-the-life, the strongest attack and the
answer. The human picks the three and which is the ambitious one.

## 10. Result

Write `<run>/result.md` (in the human's language) — you, from the files, without adding ideas:

- **Three ideas**, one of them **the ambitious one** (the biggest consequence that is new and
  fits the bold appetite — say which). For each: the pitch in one line · **who uses it every day
  and the day with it** (a short story of the user's shift and the payer's morning) · which jobs
  it takes over and what it replaces · who pays and why · why now · what exists and how this
  differs (sources) · what must be true, and what the research showed · price in the team's hours
  and money, fit to the near / bold horizon · risks, honestly · the strongest attack and the
  answer · **a test of the riskiest hypothesis that fits in 30 minutes** · the first small step.
- If no idea passes as ambitious within the bold appetite, say so plainly, and name what would
  make the strongest out-of-reach one possible.
- **Graveyard** — every dropped idea in one line with the reason (exists as…, beyond appetite,
  nobody would use it daily, feature of…). The human may revive one.
- What stayed unverified.

In a place that keeps an idea list, the caller files the result there by that place's rules; this
skill does not know where. For the human, a large result is also an HTML page (cards per idea, the
evidence folded under each). For an agent — the markdown file and a 5-line summary.
