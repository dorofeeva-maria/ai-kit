---
name: brainstorm
description: Invent something new for any goal — a product, a feature, an approach nobody has, names, a way to do X, an experiment, a move — when no suitable solution exists yet. Starts from the real people who will use or meet the result and their situation, generates whole solutions rather than fragments with independent generators, checks "does this already exist?" before selection, keeps only what we can do within the stated appetite and what people would really use, then exaggerates, checks against reality with the research skill and lets critics attack; ends with three ideas, one ambitious-but-doable, each with evidence, price, a walkthrough and a 30-minute test. Three modes (live / stops / without the human) and three depths. Not for choosing among solutions that already exist — that is ai-kit:decide. Use for "brainstorm", "ideas for…", "what could I build / do / call it", "think bigger", "invent a way to…".
---

# brainstorm — whole new solutions people would really use, checked against reality

You are the **coordinator**, in the **main session** — never inside a subagent (subagents cannot
reliably start agents or save report files; see "Files" below). Generators, researchers and
critics are background agents; files carry the ideas between steps. You talk to the human, pass
findings between agents, and never let one agent see another's reasoning.

**The main session stays free for the human — at every depth.** You never generate, cluster,
select, exaggerate, attack or write the result's ideas yourself, not even at `quick`: each of
those is a background agent, and you only start agents, save their returned text, check cheap
facts and talk to the human. A long piece of thinking in the main session blocks the human and has
no independent eye on it.

**What it is for.** Generating something new, whatever it is: a product, a feature, an approach
nobody has, names, a way to do X. It is not tied to any task or place. Use it when **no suitable
solution exists yet**, or none of the options fits because each has a critical con, and something
fundamentally new must be invented. When options that fit already exist and only the best must
be picked, use `<kit>/skills/decide` instead (it calls this skill back only if every option has
a critical con; a weak option that still fits stays with `decide`).

Some parts below fit only some goals: a payer, a market, a build horizon. Use them when the goal
has them (a product to sell, a thing to build and run) and leave them out when it has not (names,
a way to do one thing, an experiment). The interview says which apply.

**The human's own proposal** given in the request is a candidate from the start, labelled as
theirs, and weighed like the others — the result says honestly where it wins and where it loses.

Why this shape: a single model fixates on its first ideas and averages what it knows, so one
generator gives a narrow, familiar pool — hence many independent generators, then selection. But
diversity alone gives fragments instead of solutions, ideas nobody would use on an ordinary day,
and "ambitious" ideas that already exist or that the team cannot do. So every step here is
anchored on three things:

1. **The people's situation.** Ideas are generated from the real people who would use or meet the
   result — their day, their habits, what they use now and why it is good enough — not from
   abstract lenses.
2. **Whole solutions.** The unit is a solution that takes a whole job off someone, end to end; a
   fragment is material for a solution, never an idea on its own.
3. **Reality before selection.** "Does this already exist?" and "can we do it within our
   appetite?" are checked *before* the shortlist, not after the attack.

`<skill>` is this skill's base directory; `<kit>` = `<skill>/../..` (the kit's root, where
`docs/` and `skills/` live); `<research>` is
`<skill>/../research` (read its
`SKILL.md` before the first research step and run research exactly by it).
`<run>` = `~/.cache/ai-kit/brainstorm/<YYYY-MM-DD>-<short-slug>/` with `ideas/` (absolute path).

**When a caller (e.g. `decide`) gives a brief,** use it: do not re-ask what it already answers
(ask only what is missing), and take the mode and depth it names. Use the caller's subfolder (e.g. `<run>/brainstorm/`) as
your `<run>`. Read the caller's brief, copy what it answers into your own `brief.md`, and never
overwrite the caller's files.

## Files — who writes what

Claude Code refuses a subagent's Write of a markdown file whose name starts with `report`,
`summary`, `findings` or `analysis`, and that is the harness's rule, not a bug to get around. In
this skill: generators, the developer and the critic write their working files themselves
(`ideas/<lens>.md`, `taken.md`, `shortlist.md`, `big.md`, `attack.md` — names chosen to be
allowed). Research runs by the research skill, where the compressor and the writer return text
and you save it. If any agent's write is refused anyway, it returns the full text and you save it
verbatim — never by renaming, Bash or a script.

**Write early, check after.** Every agent that writes its own file (the `day.md` agent,
generators, the developer, the critic, the `result.md` agent) creates it at its first step and
adds to it as it goes — every brief says so. When an agent finishes — and after each part of the
continued developer (`clusters.md`, `shortlist.md`, `big.md`) — check that the expected file
exists and is not empty; if it is missing, save its reply text verbatim as that file. *Why:* a restart and a silent failed save lost work.

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
| Ground: the people's day + what exists (step 2) | from what the place already has | + research `standard` on what exists | + research `deep` |
| Generators (step 3) | 1 agent with 2–3 lenses | 4 | 7 (6 with no payer) |
| "Already exists?" before selection (step 5) | 1 research `quick` agent on the finalists | research `quick` per cluster | research `quick` per cluster, 2 phrasings |
| Hyperbole | top 3 | top 5 | top 6 |
| Reality loop | 1 quick research on the best idea | up to 2 rounds | up to 3 rounds |
| Attack | 1 critic, 2 roles (skeptic, the user) | 1 critic, 4 roles | 1 critic, 4 roles, per idea |

## 1. Interview — the goal, the people, the appetite

The input decides everything; many questions are fine. Ask (AskUserQuestion in batches, or in the
chat in live mode) until you could explain the request to a stranger:

- **The goal** — what does winning look like? Users, income, a prize, a publication, a skill, a
  name people remember?
- **The people, by role** — who would *use* it, who would *be affected*, and, if the goal has one,
  who would *pay* (they may be different people). For each role: an ordinary day near this topic hour by hour, what they use
  now (paper, a chat group, a spreadsheet, a system, someone's memory), their habits and
  constraints (hands busy, noise, night shift, phone only, one messenger all day), what they complain
  about and how often. Quote the human's sources (interviews, conversations) — real words beat
  guesses; say where you have none.
- **Appetite — what "we can do it" means.** Who does it, how many hours a week, until when;
  money; skills; what must not be touched (contracts, employers, law). When the goal is something
  to build and run over time, fix two horizons in the human's words: **near** (the first version
  real people use — e.g. "in 6 weeks") and **bold** (the most this team could do with focus — e.g.
  "in 9–12 months, maybe one hire"). For a one-off goal (names, a way to do one thing) the
  appetite is just the limits and the deadline. Appetite is a fixed budget: scope bends to fit
  it, not the other way round.
- **Hardware budget** — whenever own hardware (devices, sensors, servers) is plausible for the
  goal, ask it explicitly: is hardware allowed at all, how much per month, how much in total, can
  it be spread over months, or only in exceptional months? Record the answers in `brief.md` under
  the appetite; in **without me** mode, if unknown, assume none is allowed and say so there. *Why:* without a stated number, ideas either avoid hardware or assume any amount.
- **Real words per role** — for each main role: does the human have that role's own words
  (an interview, a message, a forum post by such a person)? If not, step 2 gets a live signal.
- **Deciding constraints** — the few constraints that decide whether an idea can work at all (how
  the result reaches its users or whoever pays, what the platform, the team or the law permits, a
  date that cannot move). Name them in `brief.md` under their own heading as constraints every
  idea is designed within, not a filter applied at Select. *Why:* a deciding constraint applied
  only at Select left the last picks with cons equal to pros.
- **The brief's facts, checked; the off-limits, listed** — check what the brief says about the
  human or team (experience, skills, access, earlier work) against the place's own records when it
  has any (notes, a CV, the repo, earlier decisions); correct what they contradict and mark the
  rest unchecked. List explicitly what is off-limits (an area, a system, a contract, an employer's
  work, people not to contact) under its own heading in `brief.md`. *Why:* an inflated experience
  claim and an area nobody fenced off went into every generator's brief.
- **What exists and was rejected** — what they already thought of, tried, dropped, and why.
- **The bar** — an idea they consider strong, and one they consider mediocre; what excites them.

Anything vague, contradictory or doubtful — ask, do not guess. Write the brief to `<run>/brief.md`
in the human's words (quotes with the date), with the roles, their days and the appetite as
sections.

**Selection criteria** — the defaults, unless the brief sets others; all are applied before the
shortlist:

1. **Used every time the job comes up, without being forced** — by a named role (a person, a
   team, or another system or app), in their real conditions; convenient enough to beat what they
   use now. Frequency × pain. Fit it to the goal: a product or tool is something they come back to
   regularly (at least about monthly), not a one-off report nobody reopens; a solution to a
   one-off problem is actually applied whenever that problem occurs. *Why:* the skill serves
   tasks inside a project as well as whole projects.
2. **Real benefit** — to the user and, if there is a payer, to whoever pays; say who and why.
3. **A whole solution** — it takes a whole job (or a chain of jobs) off someone end to end; not a
   fragment of something else.
4. **New where it matters** — checked in step 5, not assumed: not already done in this form, for
   these people, in this market (when there is one).
5. **Doable by us within the appetite** — the three main ideas fit the near horizon for their
   first used version, the ambitious one the bold horizon as a whole; with no horizons, they fit
   the limits and the deadline. Every idea carries a rough size in hours (an estimate, not a
   gate); when the brief has hours, the near-horizon check compares that size with the near horizon's
   hours (hours per week × weeks). Own
   hardware must fit the brief's hardware budget.

Scale is wanted: among ideas that pass 1–5, the bigger consequence wins. What does **not** pass
5 is not "ambitious", it is out of reach — it goes to the graveyard with "beyond appetite" and
what would have to change (money, a partner, a hire) to revive it. Hardware above the stated
budget goes there too.

**Stop 0 (stops mode):** show the brief in 10–15 lines — the roles and their day, the appetite
(with the hardware budget), the deciding constraints, the off-limits, the criteria. The human corrects it before anything runs.

## 2. Ground — the people's day and what already exists

Two inputs every generator reads, both written before any generation:

- **`<run>/day.md` — the day (or situation) of each role**, from the place's own material (interviews, notes,
  conversations, the brief) and, at standard and deep, the research below. Per role: the day hour
  by hour (or, for a one-off situation, what they meet and when); each recurring job as a job story ("When <moment>, I want <…>, so I can <…>") with its
  **frequency** (every shift / weekly / monthly) and **intensity** (how much it hurts, in their
  words), how they do it now, what it costs them, what would push them off the current way and
  what habit holds them; **the moments the need is forced on them** (a deadline, a rule, a
  recurring cost, a request from someone else); habits and conditions; direct quotes with dates. An agent writes it, at every depth, from the interview and the
  place's material (its brief: "create it now and add to it as you go"). Each role is marked **heard** (real words from such a person) or **guessed**.
- **`<run>/ground.md` — what exists**: research on the **field** (standard: `standard`, deep:
  `deep`): products, services and known approaches that serve these roles' jobs (globally and in the
  human's market if it has one, with prices and dates), what was tried and dropped and why, what became possible in the last
  year, what users complain about. It also covers **the tools the roles themselves already use
  for each job** (their own scripts, community tools, observatory or lab software — not only
  products sold to them) and **adjacent academic work** on the same jobs (papers, theses,
  student projects), and **what the surrounding system already gives for free or built in** for
  these jobs (the platform's or the existing product's own features, defaults of the tools the
  roles have, free public services) — an idea that duplicates it is not new. Researchers get the field, the roles and the jobs — **never the
  goal or hoped-for ideas**. Own data on unless the human wants an outside view. Save the report
  as `ground.md`. *Why:* ideas repeated a thesis and a tool found only after generation, and
  several ideas duplicated what was already free.

**A live signal for every guessed role — before generation, at every depth** (it is light).
When a main role has no real words,
get one cheap signal from it: a question on that community's mailing list or forum, one message
to a practitioner. Draft the 2–3 exact questions (neutral, about their job, not about our idea),
and say where to send them; write them into `day.md` under the role; the human sends them (you never post or message on their behalf).
Answers that arrive go into `day.md` and turn the role to **heard**; wait only as long as the
human agrees, then generate with the role still **guessed**. In **without me** mode, do not wait:
list them (as in `day.md`) and where to send them at the top of the result, and keep every such role
**guessed**. *Why:* a recommendation nobody was shown to need was rejected.

## 3. Diverge — generators in parallel, blind to each other

One message, all generators in the background (`general-purpose`, `model: opus`, high effort —
the human of this kit asked for high effort on thinking roles). Each gets **one lens**; every lens
starts from the people in `day.md`. Lens 2 applies only when the goal has a payer; with none, use
the next lens in its place:

| # | Lens | The question it works from |
|---|---|---|
| 1 | The user's day | Walk one role's day hour by hour. Where is the worst recurring moment? What single solution would sit in that day and take whole jobs off it? |
| 2 | The payer's day (only if there is a payer) | Walk the payer's day and night (owner, manager, buyer). What do they decide blind, worry about, chase by hand? What would they pay for every month and check every morning? |
| 3 | Fire the current tool | What do they "hire" today for each job (paper, chat group, spreadsheet, a system, memory)? What would make them fire it — and what keeps them (habit, fear, effort)? Design the replacement that wins on all four forces. |
| 4 | The whole system | Instead of one job, the whole loop of the people (a shift, a week, a month, a project): one solution that carries it end to end, so the pieces stop living in different places. |
| 5 | Frontier, applied to a job | What became possible this year (models, voice, vision, prices, laws, platforms) that changes *how one of the jobs in `day.md` is done* — not a technology looking for a use? |
| 6 | ×10 for one segment | Pick one segment of users. What would be ten times better for them on the one dimension they care most about — a different machine, not a bigger one? |
| 7 | The schlep | Which dull, hard work does everyone in this field avoid (data entry, local integrations, onboarding by hand, messy formats)? What becomes possible for whoever does it? |

Standard: lenses 1, 2, 3, 4 (no payer: 1, 3, 4, 5). Deep: all seven (no payer: six).

**A forcing moment, not only the human's own situation.** When the goal has users or a payer other
than the human, at least one generator (at quick, one of its lenses) starts from a moment in
`day.md` where the need is forced on them — add the brief's last line below to it. The human's own
situation is one input, never the only one. *Why:* every lens started from the human's own life, and
none from the people who must act.

Brief:

```
Generate ideas. Today is <YYYY-MM-DD>.
Brief: <run>/brief.md. The people's day: <run>/day.md. What exists: <run>/ground.md (if it exists).
Your lens: <number and name>.
Design within the deciding constraints and the off-limits in brief.md — not something checked later.
Write 6–8 ideas to <run>/ideas/<lens-slug>.md — create it now and add to it as you go.
First read <skill>/references/generator.md and follow it.
[Start from a forcing moment in day.md (a deadline, a rule, a recurring cost, a request from someone else).]
```

Generators do not see each other's files or the other lenses.

## 4. Cluster

One agent (`general-purpose`, `model: fable`; if unavailable, `opus`): "First read
<skill>/references/develop.md, part Cluster. Brief: <run>/brief.md. Ideas: <run>/ideas/. Write
<run>/clusters.md — create it now and add to it as you go." — duplicates merged, **the human's own proposal from `brief.md` entered as a candidate, labelled theirs**, features folded into the whole solutions they belong
to, 10–16 candidate solutions left, each with the jobs it takes over and the existing products
it would meet. Its reply lists, per candidate, 1–2 neutral questions for step 5 ("Is there a
product that does X for Y in Z?").

## 5. "Already exists?" — before selection

Run research `quick` on the candidates' questions (standard: one researcher per 3–4 candidates;
deep: two phrasings each). **Researchers get the neutral question, never the idea or the hope.**
Save the findings to `<run>/taken.md` as each research run returns, not at the end: per candidate — exists as is / exists for other people or
another market / exists but done badly (with what users say) / not found (with what was searched).

**An inference a candidate stands on is checked before selection.** When the research marks a
claim as an inference (not seen in a source) and a candidate would stand or fall on it, have it
checked in the place's own code or docs, when the place has any (a cheap read you may do
yourself, or a quick agent), and add the result to `taken.md`.

## 6. Select

Continue the cluster agent (it remembers): "Part Select. Taken: <run>/taken.md. Day:
<run>/day.md. Write <run>/shortlist.md — create it now and add to it as you go." — scored on the five criteria with one line of why; an
idea that exists as is in the human's market (or field) is dropped or rebuilt around its real opening; an
idea beyond the bold appetite goes to the graveyard; the rest are **weighed, pros against cons**, never knocked out by one weak
criterion; 6–8 kept, the strongest **and most different**, at least two of them as ambitious as
the bold appetite allows.

**One more round when the first is weak.** If the agent wrote `<run>/lessons.md` (fewer than 6
ideas keep a balance in their favour, or the last three picks are weak), do two things at once:

- **Tell the human now**, in a few lines: what went wrong in this round and, for each lesson, the
  change to this skill's rules that would prevent it (which file, what to add). On their yes, hand the
  change to an implementer (you never edit the kit yourself; an independent checker checks it); the
  kit is meant to learn from each run.
- **Run step 3 again** with new generators (same brief form), adding to each brief: "Lessons from
  the first round: <run>/lessons.md — avoid these mistakes. The first round's ideas are in
  <run>/clusters.md: do not repeat them." Then steps 4–6 on the old and new ideas together. One
  extra round at most; if it is still weak, say so in the result.

**Stop 1 (stops mode):** show the shortlist as a compact table (name · who uses it · which
jobs it takes · exists? · fits which horizon). The human adds their own ideas, says what lights up
and what is dead. Their ideas enter as equals; their "dead" is final.

## 7. Hyperbole — bigger inside the appetite

Continue the same agent: "Part Hyperbole, top <N>. Write <run>/big.md — create it now and add to it as you go." — for each: its ceiling,
real vs invented limits, ×10 on the user's benefit and on adoption (not on a marketplace or
network nobody can build), the **day in the life with it** (the user's moment of use, then the
payer's morning if there is a payer), the press release from the future, the **wedge** (the first version really used,
within the near horizon) and the path to the big version within the bold horizon, and **what must
be true** (3–5 checkable hypotheses).

## 8. Reality loop

For the top ideas, turn "what must be true" into research questions and run `research` (`quick`
per hypothesis; several researchers with varied wording, or two with the same wording when a fact
is contested). **Researchers get the hypothesis as a neutral question, never the idea or the
hope.** Where the place has code or docs that bear on a hypothesis, check it there as well. Then continue the developer with the findings: "Part Correct. Findings: <paths>. Update
<run>/big.md, mark what changed." Repeat up to the depth's limit, or stop when a round changes
nothing.

## 9. Attack

A fresh critic (`ai-kit:checker`, or `general-purpose` with the checker's rules; `model: fable` or
`opus`): "First read <skill>/references/attack.md. Brief: <run>/brief.md. Day: <run>/day.md.
Ideas: <run>/big.md. Research: <paths>. Write <run>/attack.md — create it now and add to it as you go." It never gets the generators' or
developer's reasoning. The developer answers each attack once (fix or concede). An idea whose
fatal attack stands goes to the graveyard with the reason.

**Stop 2 (stops mode):** the survivors with their day-in-the-life, the strongest attack and the
answer. The human picks the three and which is the ambitious one.

## 10. Result

Before the result: for each surviving idea, an agent writes **a step-by-step walkthrough** of one
concrete case (what the person sees and does, in every state), following `ai-kit:journey`, and a fresh agent checks it for
logic with `<kit>/skills/task/references/check-journey.md` (contract, "Think it through before the
human sees it"). Fix or drop what the check breaks;
the walkthroughs go into the result.

An agent writes `<run>/result.md` (in the human's language), from the files, without adding ideas
(its brief: "create it now and add to it as you go"):

- **Three ideas**, one of them **the ambitious one** (the biggest consequence that is new and
  fits the bold appetite — say which). For each: the pitch in one line · **who uses it and the
  situation with it** (a short story of the user's moment, and the payer's if there is one) ·
  which jobs it takes over and what it replaces · who pays and why (if the goal has a payer) ·
  why now · what exists and how this
  differs (sources) · what must be true, and what the research showed · price in the team's hours,
  money and hardware cost, fit to the appetite (the near / bold horizon where there are horizons) · risks, honestly · the strongest attack and the
  answer · **a test of the riskiest hypothesis that fits in 30 minutes** · the first small step.
- **An idea whose regular user is only guessed is recommended first only if no idea with a
  heard user survives** — then say so plainly at the top ("nobody is shown to need it yet; first
  step: ask"), and make the first step of each such idea asking that role (the questions from
  `day.md` and the top of the result, and where to send them).
- If no idea passes as ambitious within the bold appetite, say so plainly, and name what would
  make the strongest out-of-reach one possible.
- **The human's own proposal**, if there was one: where it wins and where it loses against the
  others, honestly.
- **Graveyard** — every dropped idea in one line with the reason (exists as…, beyond appetite,
  nobody would really use it, fragment of…). The human may revive one.
- What stayed unverified.

In a place that keeps an idea list, the caller files the result there by that place's rules; this
skill does not know where. For the human, a large result is also an HTML page (cards per idea, the
evidence folded under each). For an agent — the markdown file and a 5-line summary.
