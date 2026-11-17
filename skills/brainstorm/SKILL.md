---
name: brainstorm
description: Generate strong, ambitious, checked ideas for a goal — a project, a product, an experiment, a move. Interview about the goal, blind research of the frontier, several independent generators with different lenses, selection of the strongest and most different, hyperbole (x10, real vs invented limits), a reality loop with the research skill, an attack by critics; ends with three ideas, one frighteningly ambitious, each with evidence, price and a 30-minute test. Three modes (live / two stops / without the human) and three depths. Use for "brainstorm", "ideas for…", "what could I build / do", "think bigger".
---

# brainstorm — strong ideas, checked against reality

You are the **coordinator**, in the calling session. Generators, researchers and critics are
background agents; files carry the ideas between steps. You talk to the human, pass findings
between agents, and never let one agent see another's reasoning.

Why this shape: a single model fixates on its first ideas and averages what it knows, so one
generator gives a narrow, familiar pool. Many independent generators → pick the strongest and most
different → develop → check against the world is what produces ideas that are neither mundane
(already built by everyone) nor detached from reality.

`<skill>` is this skill's base directory; `<research>` is `<skill>/../research` (read its
`SKILL.md` before the first research step and run research exactly by it).
`<run>` = `~/.cache/ai-kit/brainstorm/<YYYY-MM-DD>-<short-slug>/` with `ideas/`.

## Modes — ask at the start unless the request says

- **live** — the human and you throw ideas in the chat; you develop and exaggerate theirs and add
  your own; agents only research and attack in the background. Steps 3–5 happen in the
  conversation: one move at a time, the human's idea first, never a wall of frameworks.
- **stops** — agents work in the background; the human steps in twice: at selection (step 4) and
  before the result (step 7). The session stays free; anything they drop in is passed on.
- **without me** — only when the human says so explicitly ("create without me", "don't ask").
  No interview beyond what is written; assumptions are listed at the top of the result.

## Depth — say your choice in one line

| | quick | standard | deep |
|---|---|---|---|
| Interview | short | full | full |
| Ground research (step 2) | — (what the human and the place already give) | research `standard` | research `deep` |
| Generators | none — you, with 2–3 lenses, in the session | 4 | 6 |
| Hyperbole | top 3 | top 5 | top 8 |
| Reality loop | 1 quick research on the best idea | up to 2 rounds | up to 3 rounds |
| Attack | you, as the skeptic | 1 critic, 3 roles | 1 critic, 3 roles, per idea |

## 1. Interview

The input decides everything; many questions are fine. Ask (AskUserQuestion in batches, or in the
chat in live mode) until you could explain the request to a stranger:

- **The goal** — what does winning look like? A prize, users, a publication, income, a skill, joy?
- **For whom** — who must be better off, and how would anyone notice?
- **Real limits** — time, money, deadline, what must not be touched. (Only the real ones; invented
  ones are step 5's job.)
- **What exists** — what they already thought of, tried, rejected, and why.
- **What excites them** — a thing they saw recently and thought "I wish I had made this".
- **The bar** — an example of an idea they consider strong, and one they consider mediocre.

Anything vague, contradictory or doubtful in the request — ask about it, do not guess. Write the
brief to `<run>/brief.md` in the human's words (quotes with the date).

**Selection criteria** — the defaults, unless the brief sets others:
1. **it really brings benefit** to someone specific;
2. **scale and consequences** if it works;
3. **nobody has done it this way** (checked, not assumed).

Whether the human can build it, and what it costs, is *reported* for each idea — it is not a
filter. An idea is never dropped for being too big.

## 2. Ground (standard, deep)

Run `research` on the **field**, not on the goal: what exists, what was tried and dropped and why,
what became possible in the last year and the last month, what people in the field complain about,
open data and tools. Researchers get the field and the questions — **never the goal or the hoped-for
ideas**. Own data on unless the human wants an outside view. Save the report as `<run>/ground.md`.

## 3. Diverge — generators in parallel, blind to each other

One message, all generators in the background (`general-purpose`, `model: opus`, `effort: high`
by the contract's "Models"). Each gets **one lens**:

| # | Lens | The question it works from |
|---|---|---|
| 1 | Frontier | What became possible this year that nobody has built on yet? (uses `ground.md`) |
| 2 | Dissent | What does everyone in this field agree on — and where are they wrong? |
| 3 | ×10 | What if the benefit, the people reached or the speed had to be ten times larger? Change the machine, don't inflate it. |
| 4 | Another field | How did biology, logistics, games, aviation, medicine already solve a problem of this shape? |
| 5 | Impossible limit | No money. One evening. No internet. A million people at once. Only one thing may ship. |
| 6 | Ordinary different people | What would a nurse, a farmer, a schoolchild, a pensioner, a small shop owner need here? |

Standard: lenses 1, 2, 3, 6. Deep: all six. Brief:

```
Generate ideas. Today is <YYYY-MM-DD>.
Brief: <run>/brief.md. Ground: <run>/ground.md (if it exists).
Your lens: <number and name>.
Write 8–10 ideas to <run>/ideas/<lens-slug>.md.
First read <skill>/references/generator.md and follow it.
```

Generators do not see each other's files or the other lenses.

## 4. Select

One agent (`general-purpose`, `model: fable`; if unavailable, `opus`): "First read
<skill>/references/develop.md, part Select. Brief: <run>/brief.md. Ideas: <run>/ideas/. Write
<run>/shortlist.md." — duplicates merged, the 8–10 strongest **and most different** kept, each
scored on the three criteria with one line of why; the rest go to `<run>/graveyard.md` with a
reason.

**Stop 1 (stops mode):** show the shortlist as a compact table. The human adds their own ideas,
says what lights up and what is dead. Their ideas enter the shortlist as equals; their "dead" is
final.

## 5. Hyperbole

One agent (same model): "First read <skill>/references/develop.md, part Hyperbole. Shortlist:
<run>/shortlist.md. Write <run>/big.md." — for each of the top N: its ceiling, real vs invented
limits, ×10 on 2–3 axes, the press release from the future, and **what must be true** (3–5
checkable hypotheses).

## 6. Reality loop

For the top ideas, turn "what must be true" and "nobody has done it" into research questions and
run `research` (`quick` per hypothesis; several researchers with varied wording, or two with the
same wording when a fact is contested). **Researchers get the hypothesis as a neutral question,
never the idea or the hope.** Then continue the hyperbole agent (it remembers) with the findings:
"Correct the ideas by these findings: <paths>. An idea that already exists — find the angle that
does not, or kill it. Update <run>/big.md, mark what changed."

Repeat up to the depth's limit, or stop when a round changes nothing. Something already built by
others is not automatically dead: "done badly" and "done for someone else" are openings.

## 7. Attack

A fresh critic (`ai-kit:checker`, or `general-purpose` with the checker's rules; `model: fable` or
`opus`): "First read <skill>/references/attack.md. Brief: <run>/brief.md. Ideas: <run>/big.md.
Research: <paths>. Write <run>/attack.md." It never gets the generators' or developer's reasoning.

The developer answers each attack once (fix the idea or concede). An idea whose fatal attack
stands goes to the graveyard with the reason.

**Stop 2 (stops mode):** the survivors with their strongest attack and the answer. The human picks.

## 8. Result

Write `<run>/result.md` (in the human's language) — you, from the files, without adding ideas:

- **Three ideas**, one of them **frighteningly ambitious** (say which). For each:
  the pitch in one line · who benefits and how · why now · why nobody has done it this way
  (with sources) · what must be true, and what the research showed for each hypothesis · price
  and risks, honestly · the strongest attack and the answer · **a test of the riskiest hypothesis
  that fits in 30 minutes** · the first small step.
- **Graveyard** — every dropped idea in one line with the reason (the human may revive one).
- What stayed unverified.

In a place that keeps an idea list, the caller files the result there by that place's rules; this
skill does not know where.

For the human, a large result is also an HTML page (cards per idea, the evidence folded under
each). For an agent — the markdown file and a 5-line summary.
